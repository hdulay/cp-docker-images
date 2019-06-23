![image](../confluent-logo-300-2.png)

# Failover with Schema registry (Leader / Follower) with Nginx loadbalancer and Rest Proxy
This docker compose sets up 2 schema registries as leader and follower with nginx as the load balancer. Follow the setup instructions to demonstrate failover. This usecase executes CURL commands through rest proxy.

## Overview

This `docker-compose.yml` includes all of the Confluent Platform components and shows how you can configure them to interoperate.
For an example of how to use this Docker setup, refer to the Confluent Platform quickstart: https://docs.confluent.io/current/quickstart/index.html

# Setup
```
$ docker-compose build
$ docker-compse up -d
```

Make sure everything is running.
```
$ docker-compose ps
```

If if one of the schema registries is down, with the error `This server does not host this topic-partition`, restart it.
```
$ docker-compose restart schema-registry
```

# Test Rest Proxy - Nginx - Schema Registry L/F
## Create topics
```bash
kafka-topics --create --zookeeper localhost:2181 --topic rest-avro --replication-factor 1 --partitions 1
kafka-topics --create --zookeeper localhost:2181 --topic rest-avro2 --replication-factor 1 --partitions 1
```

## Send a message to the REST Proxy
This also registers the schema.
```bash
$ curl --request POST \
  --url http://127.0.0.1:8082/topics/rest-avro \
  --header 'accept: application/vnd.kafka.v2+json, application/vnd.kafka+json, application/json' \
  --header 'content-type: application/vnd.kafka.avro.v2+json' \
  --data '{
  "value_schema": "{\"type\": \"record\", \"name\": \"User\", \"fields\": [{\"name\": \"name\", \"type\": \"string\"}, {\"name\" :\"age\",  \"type\": [\"null\",\"int\"]}]}",
  "records": [
    {
      "value": {"name": "testUser", "age": null }
    },
    {
      "value": {"name": "some name here", "age": {"int": 25} },
      "partition": 0
    }
  ]
}
'
```

## Response
```json
{
  "offsets": [
    {
      "partition": 0,
      "offset": 0,
      "error_code": null,
      "error": null
    },
    {
      "partition": 0,
      "offset": 1,
      "error_code": null,
      "error": null
    }
  ],
  "key_schema_id": null,
  "value_schema_id": 1
}
```

## Check Schema registries
Check for schema in leader, follower and load balancer
```bash
curl --request GET --url http://localhost:8081/schemas/ids/1
curl --request GET --url http://localhost:8281/schemas/ids/1
curl --request GET --url http://localhost:8381/schemas/ids/1
```

# Testing Failover
## Stop one of the schmea regsitries
```
$ docker-compose stop schema-registry2
```
And test the endpoints. Endpoint 8381 should fail.
```bash
curl --request GET --url http://localhost:8081/schemas/ids/1
curl --request GET --url http://localhost:8281/schemas/ids/1
curl --request GET --url http://localhost:8381/schemas/ids/1
```

## Register a new schema by posting a message to a topic rest-avro2
```bash
curl --request POST \
  --url http://127.0.0.1:8082/topics/rest-avro2 \
  --header 'accept: application/vnd.kafka.v2+json, application/vnd.kafka+json, application/json' \
  --header 'content-type: application/vnd.kafka.avro.v2+json' \
  --data '{
  "value_schema": "{\"type\": \"record\", \"name\": \"User\", \"fields\": [{\"name\": \"name\", \"type\": \"string\"}, {\"name\" :\"days\",  \"type\": [\"null\",\"long\"]}]}",
  "records": [
    {
      "value": {"name": "testUser", "days": null }
    },
    {
      "value": {"name": "master is back up", "days": {"long": 250000} },
      "partition": 0
    }
  ]
}
'
```

## Response
```json
{
  "offsets": [
    {
      "partition": 0,
      "offset": 0,
      "error_code": null,
      "error": null
    },
    {
      "partition": 0,
      "offset": 1,
      "error_code": null,
      "error": null
    }
  ],
  "key_schema_id": null,
  "value_schema_id": 21
}
```

# C3
http://localhost:9021/management/clusters/wCypdIBfTgKiy0ccoTdcOA/topics

Check topics `rest-avro` and `rest-avro2` and their schemas.

