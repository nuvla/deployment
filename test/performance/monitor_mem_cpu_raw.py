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

all_containers = docker_client.containers.list()
docker_stats = []

for container in all_containers:
    docker_stats.append(docker_client.api.stats(container.name))

# get first samples (needed for cpu monitoring)
old_cpu = []
for c_stat in docker_stats:
    container_stats = json.loads(next(c_stat))

    old_cpu.append((float(container_stats["cpu_stats"]["cpu_usage"]["total_usage"]),
                    float(container_stats["cpu_stats"]["system_cpu_usage"])))

# initialize output file
with open(args.output, 'w') as out:
    out.write('TIMESTAMP,CPU,MEMORY\n')

tick = 0
end = time.time() + args.duration
while time.time() < end:
        start = time.time()
        cpu = []
        ram = []
        for i, c_stat in enumerate(docker_stats):
            # CPU
            container_stats = json.loads(next(c_stat))

            cpu_total = float(container_stats["cpu_stats"]["cpu_usage"]["total_usage"])
            cpu_system = float(container_stats["cpu_stats"]["system_cpu_usage"])

            online_cpus = container_stats["cpu_stats"] \
                .get("online_cpus", len(container_stats["cpu_stats"]["cpu_usage"].get("percpu_usage", -1)))

            cpu_delta = cpu_total - old_cpu[i][0]
            system_delta = cpu_system - old_cpu[i][1]

            cpu_percent = 0.0
            if system_delta > 0.0 and online_cpus > -1:
                cpu_percent = (cpu_delta / system_delta) * online_cpus * 100.0

            old_cpu[i] = (cpu_total, cpu_system)

            # MEM
            mem_usage = float(container_stats["memory_stats"]["usage"] / 1024 / 1024)

            cpu.append(cpu_percent)
            ram.append(mem_usage)

        tick += int(time.time() - start)
        with open(args.output, 'a+') as out:
            out.write(f'{tick},{sum(cpu)},{sum(ram)}\n')


