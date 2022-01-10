.PHONY: all

SHELL=/bin/sh -e

.DEFAULT_GOAL := help

-include .env

help: ## Справка
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

inf: ## Шпоргалка по установки из README.md
	@sed '/git/,/```/!d;/```/q' README.md | grep -v '```'

env: ## Создаёт .env .settings.php dbconn.php
	@if [ ! -f ./www/.env ]; then \
		cp .env.example .env; \
	fi

up: ## Запуск проекта
	docker-compose up -d

down: ## Остановка всех контейнеров проекта
	docker-compose down

rb: ## Перезапуск всех контейнеров проекта
	down up

bash: ## Зайти в bash контейнера с php
	docker-compose exec php /bin/bash

prepare-db: ## Выполнить скрипт с настройками базы
	@docker-compose exec database \
	cat /docker-entrypoint-initdb.d/create.sql | \
	mysql -h localhost -P 3306 -uroot --password=$(MYSQL_ROOT_PASSWORD) --protocol=tcp

backup:
	docker exec -it database sh -c "mysqldump -uroot --password=$(MYSQL_ROOT_PASSWORD) --databases $(MYSQL_DATABASE) | gzip > /docker-entrypoint-initdb.d/dump_$(MYSQL_DATABASE).sql.gz"