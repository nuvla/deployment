#!/bin/sh

# NuvlaBox Engine advanced installation script
# This script is an alternative for the conventional one-command `docker-compose ... ` installation/halt/remove methods
# It provides extra checks and guidance for making sure that:
#  1. there are no existing NuvlaBox Engines already running
#  2. handle existing installations before installing a new one
#  3. checks installation requirements
#  4. installs/updates/removes NuvlaBox Engine

compose_files="docker-compose.yml"
strategies="UPDATE OVERWRITE"
strategy="UPDATE"
actions="INSTALL REMOVE HALT"
action="INSTALL"
extra_env=""

usage()
{
    echo "NuvlaBox Engine advanced installation wrapper"
    echo ""
    echo "./install.sh"
    echo ""
    echo " -h --help"
    echo " --environment=KEY1=value1,KEY2=value2\t\t(optional) Comma-separated environment keypair values"
    echo " --compose-files=file1.yml,file2.yml\t\t(optional) Comma-separated list of compose files to deploy. Default: ${compose_files}"
    echo " --installation-strategy=STRING\t\t\t(optional) Strategy when action=INSTALL. Must be on of: ${strategies}. Default: ${strategy}"
    echo "\t\t UPDATE - if NuvlaBox Engine is already running, replace outdated components and start stopped ones. Otherwise, install"
    echo "\t\t OVERWRITE - if NuvlaBox Engine is already running, shut it down and re-install. Otherwise, install"
    echo " --action=STRING\t\t\t\t(optional) What action to take. Must be on of: ${actions}. Default: ${action}"
    echo "\t\t INSTALL - runs 'docker-compose up'"
    echo "\t\t REMOVE - removes the NuvlaBox Engine and all associated data. Same as 'docker-compose down -v"
    echo "\t\t HALT - shuts down the NuvlaBox Engine but keeps data, so it can be revived later. Same as 'docker-compose down"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | cut -d "=" -f 2-`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --environment)
            extra_env=$VALUE
            ;;
        --compose-files)
            compose_files=$VALUE
            ;;
        --installation-strategy)
            strategy=$VALUE
            ;;
        --action)
            action=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

which docker-compose &>/dev/null
if [ $? -ne 0 ]
then
  echo "ERR: docker-compose is not installed. Cannot continue"
  exit 1
fi

if [ ! -z "${extra_env}" ]
then
  echo "Setting up environment ${extra_env}"
  export $(echo ${extra_env} | tr ',' ' ') &>/dev/null
fi

command_compose_files=""
for file in $(echo ${compose_files} | tr ',' '\n')
do
  command_compose_files="${command_compose_files} -f ${file}"
done

if [ "${action}" = "REMOVE" ]
then
  echo "INFO: removing NuvlaBox installation completely"
  docker-compose -p nuvlabox ${command_compose_files} down -v
elif [ "${action}" = "HALT" ]
then
  echo "INFO: halting NuvlaBox. You can bring it back later by simply re-installing with the same parameters as before"
  docker-compose -p nuvlabox ${command_compose_files} down
elif [ "${action}" = "INSTALL" ]
then
  if [ "${strategy}" = "UPDATE" ]
  then
    existing_projects=$(docker-compose -p nuvlabox ${command_compose_files} ps -a -q)
    if [ ! -z "${existing_projects}" ]
    then
      echo "INFO: found an active NuvlaBox installation. Updating it"
    else
      echo "INFO: no active NuvlaBox installations found. Installing from scratch"
    fi
    docker-compose -p nuvlabox ${command_compose_files} up -d
  elif [ "${strategy}" = "OVERWRITE" ]
  then
    echo "WARNING: about to delete any existing NuvlaBox installations...press Ctrl+c in the next 5 seconds to stop"
    sleep 5
    docker-compose -p nuvlabox ${command_compose_files} down -v --remove-orphans
    echo "INFO: installing NuvlaBox Engine from scratch"
    docker-compose -p nuvlabox ${command_compose_files} up -d
  else
    echo "WARNING: strategy ${strategy} not recognized. Use -h for help. Nothing to do"
  fi
else
  echo "WARNING: action ${action} not recognized. Use -h for help. Nothing to do"
  exit 0
fi