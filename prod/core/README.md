## Monitoring deployment state jobs

One can monitor the state of the deployment state jobs by deploying StatsD service
and pointing `jobd-deployment-state_10` and `jobd-deployment-state_60` to the StatsD
with `--statsd` parameter. E.g.:

```

  jobd-deployment-state_10:
    image: nuvla/job:2.5.0
    entrypoint: /app/job_distributor_deployment_state.py
    command: --api-url http://api:8200 --api-authn-header group/nuvla-admin --zk-hosts zk:2181 --interval 10 --statsd ${STATSD_HOST:-graphite}    
```
