#!/usr/bin/env python3

import docker
import argparse
import json
import time


parser = argparse.ArgumentParser()
parser.add_argument("--output-file", action="store", dest="output", default="monitor-output.txt")
parser.add_argument("--duration", action="store", type=int, dest="duration", default=3600)

args = parser.parse_args()

docker_client = docker.from_env()

all_containers = []
docker_stats = []

old_cpu = {}
end = time.time() + args.duration
while time.time() < end:
        current_containers = docker_client.containers.list()
        deleted = set(all_containers) - set(current_containers)
        new_containers = set(current_containers) - set(all_containers)

        for container in deleted:
            docker_stats.pop(all_containers.index(container))
            all_containers.remove(container)

        for new_container in new_containers:
            all_containers.append(new_container)
            c_stat = docker_client.api.stats(new_container.name)
            docker_stats.append(c_stat)
            with open(new_container.name + '-' + args.output, 'w') as out:
                out.write('TIMESTAMP,CPU,MEMORY\n')

            # get first samples (needed for cpu monitoring)
            try:
                container_stats = json.loads(next(c_stat))
            except StopIteration:
                old_cpu[new_container.name] = (0, 0)
            else:
                old_cpu[new_container.name] = (
                    float(container_stats.get("cpu_stats", {}).get("cpu_usage", {}).get("total_usage", 0)),
                    float(container_stats.get("cpu_stats", {}).get("system_cpu_usage", 0))
                )

        for i, c_stat in enumerate(docker_stats):
            try:
                container_stats = json.loads(next(c_stat))
            except StopIteration:
                continue
            # CPU

            cpu_total = float(container_stats.get("cpu_stats", {}).get("cpu_usage", {}).get("total_usage", 0))
            cpu_system = float(container_stats.get("cpu_stats", {}).get("system_cpu_usage", 0))

            online_cpus = container_stats["cpu_stats"] \
                .get("online_cpus", len(container_stats["cpu_stats"]["cpu_usage"].get("percpu_usage", [])))

            cpu_delta = cpu_total - old_cpu[all_containers[i].name][0]
            system_delta = cpu_system - old_cpu[all_containers[i].name][1]

            cpu_percent = 0.0
            if system_delta > 0.0 and online_cpus > -1:
                cpu_percent = (cpu_delta / system_delta) * online_cpus * 100.0

            old_cpu[all_containers[i].name] = (cpu_total, cpu_system)

            # MEM
            mem_usage = float(container_stats["memory_stats"].get("usage", 0) / 1024 / 1024)

            with open(container_stats['name'].lstrip('/') + '-' + args.output, 'a+') as out:
                out.write(f'{int(time.time())},{cpu_percent},{mem_usage}\n')


