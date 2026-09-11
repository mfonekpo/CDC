.PHONY: \
	up down ps recreate logs-prometheus logs-nginx logs-airflow \
	logs-statsd logs-alloy logs-postgres restart help \
	register datahub port-forward ingest-postgres \
	postgres-preview ingest-api kafka-ingest kafka-preview \
	kafka-lineage kafka-connect-preview kafka-connect-ingest

up:
	docker compose -f  "./containers/loki/docker-compose.yaml" up --build --wait
	docker compose -f "./containers/fluentd/docker-compose.yml" up --build --wait
	docker compose -f  "./containers/prometheus/docker-compose.yml" up --wait
	docker compose -f  "./containers/postgres/docker-compose.yml" up --wait
	docker compose -f  "./containers/proxy_server/docker-compose.yml" up --wait
	docker compose -f  "./containers/statsd/docker-compose.yml" up --wait
	docker compose -f  "./containers/grafana_alloy/docker-compose.yml" up --wait
	docker compose -f  "./containers/kafka/docker-compose.yml" up --build --wait
	docker compose -f  "./containers/kafka-connect/docker-compose.yml" up --build --wait
	docker compose -f  "./containers/airflow/docker-compose.yaml" up --build --wait
	docker compose -f "./containers/postgres_consumer/docker-compose.yml" up --build --wait

down:
	docker compose -f  "./containers/prometheus/docker-compose.yml" down
	docker compose -f  "./containers/proxy_server/docker-compose.yml" down
	docker compose -f  "./containers/airflow/docker-compose.yaml" down
	docker compose -f  "./containers/statsd/docker-compose.yml" down
	docker compose -f  "./containers/grafana_alloy/docker-compose.yml" down
	docker compose -f  "./containers/postgres/docker-compose.yml" down
	docker compose -f  "./containers/kafka/docker-compose.yml" down
	docker compose -f  "./containers/kafka-connect/docker-compose.yml" down
	docker compose -f  "./containers/postgres_consumer/docker-compose.yml" down
	docker compose -f  "./containers/fluentd/docker-compose.yml" down
	docker compose -f  "./containers/loki/docker-compose.yaml" down

ps:
	docker compose -f  "./containers/proxy_server/docker-compose.yml" ps
	docker compose -f  "./containers/prometheus/docker-compose.yml" ps
	docker compose -f  "./containers/airflow/docker-compose.yaml" ps
	docker compose -f  "./containers/statsd/docker-compose.yml" ps
	docker compose -f  "./containers/grafana_alloy/docker-compose.yml" ps
	docker compose -f  "./containers/postgres/docker-compose.yml" ps
	docker compose -f  "./containers/kafka/docker-compose.yml" ps
	docker compose -f  "./containers/kafka-connect/docker-compose.yml" ps
	docker compose -f "./containers/postgres_consumer/docker-compose.yml" ps
	docker compose -f "./containers/fluentd/docker-compose.yml" ps

# this command is meant to be run in a codespace environment.
datahub:
	datahub docker quickstart --quickstart-compose-file "containers/datahub/docker-compose.yml"

port-forward:
	gh codespace ports forward 8080:18080 -c super-duper-waddle-grp4w7j44gghv5gp

ingest-postgres:
	datahub ingest -c "containers/datahub/source-postgres.dhub.yaml"

postgres-preview:
	datahub ingest -c "containers/datahub/source-postgres.dhub.yaml" --preview --dry-run

ingest-api:
	python3 "containers/datahub/customPlatforms/weathermap_api.py"

kafka-ingest:
	datahub ingest -c "containers/datahub/cdc-kafka.dhub.yaml"

kafka-preview:
	datahub ingest -c "containers/datahub/cdc-kafka.dhub.yaml" --preview --dry-run

kafka-connect-preview:
	datahub ingest -c "containers/datahub/kafka-connect.dhub.yaml" --preview --dry-run

kafka-connect-ingest:
	datahub ingest -c "containers/datahub/kafka-connect.dhub.yaml"

kafka-lineage:
	python3 "containers/datahub/customPlatforms/kafka_lineage.py"

replication-preview:
	datahub ingest -c "containers/datahub/replication-postgres.dhub.yaml" --preview --dry-run

replication-ingest:
	datahub ingest -c "containers/datahub/replication-postgres.dhub.yaml"

kafka-rep:
	python3 "containers/datahub/customPlatforms/kafka_rep_db_lineage.py"

snowflake-preview:
	datahub ingest -c "containers/datahub/snowflake.dhub.yaml" --preview --dry-run

snowflake-ingest:
	datahub ingest -c "containers/datahub/snowflake.dhub.yaml"

recreate:
	docker compose -f  "./containers/prometheus/docker-compose.yml" up -d --force-recreate prometheus

log-prometheus:
	docker compose -f "./containers/prometheus/docker-compose.yml" logs -f

log-nginx:
	docker compose -f "./containers/proxy_server/docker-compose.yml" logs -f

log-airflow:
	docker compose -f "./containers/airflow/docker-compose.yaml" logs -f

log-statsd:
	docker compose -f "./containers/statsd/docker-compose.yml" logs -f

log-alloy:
	docker compose -f "./containers/grafana_alloy/docker-compose.yml" logs -f

log-postgres:
	docker compose -f "./containers/postgres/docker-compose.yml" logs -f

log-consumer:
	docker compose -f "./containers/postgres_consumer/docker-compose.yml" logs -f

restart:
	down up

help:
	@echo "Available commands:"
	@echo "  make up              Start all services"
	@echo "  make down            Stop all services"
	@echo "  make restart         Restart all services"
	@echo "  make ps              Show running containers"
	@echo "  make logs-prometheus Show Prometheus logs"
	@echo "  make logs-nginx      Show Nginx logs"
	@echo "  make logs-airflow    Show Airflow logs"
	@echo "  make logs-statsd     Show Statsd logs"
	@echo "  make logs-alloy      Show Alloy logs"
	@echo "  make logs-postgres   Show Postgres logs"

##############################################
# Debezium / Kafka Connect
##############################################

register-connector:
	bash ./containers/debezium/register.sh

update-connector:
	bash ./containers/debezium/update.sh

status-connector:
	bash ./containers/debezium/status.sh

delete-connector:
	bash ./containers/debezium/delete.sh

list-connector:
	bash ./containers/debezium/list-connectors.sh