.PHONY: \
	up down ps recreate logs-prometheus logs-nginx logs-airflow \
	logs-statsd logs-alloy logs-postgres restart help \
	register

up:
	docker compose -f  "./containers/prometheus/docker-compose.yml" up --wait
	docker compose -f  "./containers/postgres/docker-compose.yml" up --wait
	docker compose -f  "./containers/proxy_server/docker-compose.yml" up --wait
	docker compose -f  "./containers/statsd/docker-compose.yml" up --wait
	docker compose -f  "./containers/grafana_alloy/docker-compose.yml" up --wait
	docker compose -f  "./containers/kafka/docker-compose.yml" up --wait
	docker compose -f  "./containers/kafka-connect/docker-compose.yml" up --wait
	docker compose -f  "./containers/airflow/docker-compose.yaml" up --build --wait

down:
	docker compose -f  "./containers/prometheus/docker-compose.yml" down
	docker compose -f  "./containers/proxy_server/docker-compose.yml" down
	docker compose -f  "./containers/airflow/docker-compose.yaml" down
	docker compose -f  "./containers/statsd/docker-compose.yml" down
	docker compose -f  "./containers/grafana_alloy/docker-compose.yml" down
	docker compose -f  "./containers/postgres/docker-compose.yml" down
	docker compose -f  "./containers/kafka/docker-compose.yml" down
	docker compose -f  "./containers/kafka-connect/docker-compose.yml" down

ps:
	docker compose -f  "./containers/proxy_server/docker-compose.yml" ps
	docker compose -f  "./containers/prometheus/docker-compose.yml" ps
	docker compose -f  "./containers/airflow/docker-compose.yaml" ps
	docker compose -f  "./containers/statsd/docker-compose.yml" ps
	docker compose -f  "./containers/grafana_alloy/docker-compose.yml" ps
	docker compose -f  "./containers/postgres/docker-compose.yml" ps
	docker compose -f  "./containers/kafka/docker-compose.yml" ps
	docker compose -f  "./containers/kafka-connect/docker-compose.yml" ps
recreate:
	docker compose -f  "./containers/prometheus/docker-compose.yml" up -d --force-recreate prometheus

logs-prometheus:
	docker compose -f "./containers/prometheus/docker-compose.yml" logs -f

logs-nginx:
	docker compose -f "./containers/proxy_server/docker-compose.yml" logs -f

logs-airflow:
	docker compose -f "./containers/airflow/docker-compose.yaml" logs -f

logs-statsd:
	docker compose -f "./containers/statsd/docker-compose.yml" logs -f

logs-alloy:
	docker compose -f "./containers/grafana_alloy/docker-compose.yml" logs -f

logs-postgres:
	docker compose -f "./containers/postgres/docker-compose.yml" logs -f

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