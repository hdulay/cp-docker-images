![image](../confluent-logo-300-2.png)

# Overview

This `docker-compose.yml` includes all of the Confluent Platform components and shows how you can configure them to interoperate.
For an example of how to use this Docker setup, refer to the Confluent Platform quickstart: https://docs.confluent.io/current/quickstart/index.html

# Build the dependent jars
In the jupyter directory, execute `$ mvn dependency:copy-dependencies`. This will download all the dependent jars into **target/dependency**. This directory will get loaded by the IJava jupyter kernel. To add more dependencies, add them to the pom.xml file and execute the command again.

# Makefile
In the cp-all-in-one directory, build the images.

`$ make build` 

Deploy the cp-all-in-one cluster including a jupyter notebook.

`$ make run` 

# Jupyter
After you've started the cluster, get access to the jupyter notebook by executing:

 `$ docker logs -f jupyter`

You will see in the logs a url to copy and paste onto the browser.

# Wordcount
In the notebook you will see word-count-ipynb. Open this file. Create the topics **streams-plaintext-input** and **streams-wordcount-output** in c3 ( http://localhost:9021 ) using the default settings.

## Execute Notebook
Go to the cell containing the stop command and run all the cells above it. Go to the cell which checks to see if the stream is running and run it and make sure it is running.

## Produce Messages
Enter the docker broker instance.
```
$ docker exec -it broker bash
```

Run the console producer and create some messages.
```
$ kafka-console-producer --broker-list localhost:9092 --topic streams-plaintext-input
```

## Print out in notebook
Go to the cell containing the display call. Execute it. The notebook should show the contents of the row list with the messages you set to the topic.

## Modifying transformation
If you want to modify the transformation, execute the cell which closes the stream. Verify that the stream is closed. Then make your modifications. Start the stream again by running all the cells above the cell containing the close stream statement.

## Consume messages if you're writing to the out topic
```
kafka-console-consumer --topic streams-wordcount-output --from-beginning \
  --bootstrap-server localhost:9092 \
  --property print.key=true \
  --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer
```
