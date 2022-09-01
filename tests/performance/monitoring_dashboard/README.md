# NuvlaEdge Performance Monitoring

This will deploy a monitoring stack based on cAdvisor, Prometheus and Grafana.

Once up, import the Grafana dashboard as raw JSON, from the Grafana UI.

To launch the monitoring stack, run:

```shell
docker-compose -f <compose-file> up -d
# where the compose-file is one of the
# docker-compose.<arch>.yml files available in this folder
```

Then go to `localhost:3000`.

## Probes

By default, some of the Grafana dashboard plots will be empty. To get them populated,
you'll need to manually enable the probes available under the `probes` folder.

For example:

```bash
# from anywhere within the host device where the NuvlaEdge is running
./probes/get-mem-for-all-processes.sh &
```
