#!/bin/bash -xe

mvn -B clean
mvn -Brelease:clean
mvn -B release:prepare
mvn -B release:perform
mvn -B release:clean
