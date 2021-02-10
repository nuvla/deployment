## Deployment of Nuvla DB layer

`docker-compose.yml` deploys Elasticsearch and Zookeeper.

Prerequisites:

* Elasticsearch must be backed up. The backup configuration relies on S3. You
  need to provide S3 access key and secret in `./secrets/s3_access_key` and
  `./secrets/s3_secret_key` respectively.

