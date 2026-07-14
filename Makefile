up:
	docker compose -f  "./containers/monitoring/docker-compose.yml" up --wait
	docker compose -f  "./containers/proxy_server/docker-compose.yml" up --wait
	docker compose -f  "./containers/airflow/docker-compose.yaml" up --wait

down:
	docker compose -f  "./containers/monitoring/docker-compose.yml" down
	docker compose -f  "./containers/proxy_server/docker-compose.yml" down
	docker compose -f  "./containers/airflow/docker-compose.yaml" down

ps:
	docker compose -f  "./containers/proxy_server/docker-compose.yml" ps
	docker compose -f  "./containers/monitoring/docker-compose.yml" ps
	docker compose -f  "./containers/airflow/docker-compose.yaml" ps

recreate:
	docker compose -f "./containers/monitoring/docker-compose.yml" up -d --force-recreate prometheus

logs-prometheus:
	docker compose -f "./containers/monitoring/docker-compose.yml" logs -f

logs-nginx:
	docker compose -f "./containers/proxy_server/docker-compose.yml" logs -f

logs-airflow:
	docker compose -f "./containers/airflow/docker-compose.yaml" logs -f

restart:
	down up



help:
	@echo "Available commands:"
	@echo "  make up              Start all services"
	@echo "  make down            Stop all services"
	@echo "  make restart         Restart all services"
	@echo "  make ps              Show running containers"