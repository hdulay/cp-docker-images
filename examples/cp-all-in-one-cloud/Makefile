build:
	docker-compose build

cluster:
	docker-compose up -d connect
	docker-compose up -d control-center
	docker-compose up -d ksql-server
	docker-compose up -d ksql-cli

topics:
	ccloud topic create pageviews
	ccloud topic create users

connect:
	docker exec -it connect curl -d "@/project/datagen/pageviews.json" \
		-X PUT \
		-H "Content-Type: application/json" \
		http://connect:8083/connectors/pageviews/config | jq 

	docker exec -it connect curl -d "@/project/datagen/users.json" \
		-X PUT \
		-H "Content-Type: application/json" \
		http://connect:8083/connectors/datagen-users/config | jq 

	docker exec -it connect curl -d "@/project/datagen/sink.json" \
		-X PUT \
		-H "Content-Type: application/json" \
		http://connect:8083/connectors/users-sink/config | jq 

ksql:
	docker-compose exec ksql-cli bash -c "ksql http://ksql-server:8089 <<EOF
		run script '/project/datagen/ksqlcommands.sql';
		exit ;
		EOF
		"
ksql-cli:
	docker-compose exec ksql-cli ksql http://ksql-server:8089 

down:
	docker-compose down


aws:
	ssh -i ${PEM} ubuntu@34.229.233.192