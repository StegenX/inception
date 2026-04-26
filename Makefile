NAME		= inception
COMPOSE		= docker compose -f srcs/docker-compose.yml
DATA_DIR	= /home/stegen/data

all: up

up:
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

logs:
	$(COMPOSE) logs -f

clean: down
	$(COMPOSE) down -v
	@sudo rm -rf $(DATA_DIR)

fclean: clean
	docker system prune -af

re: fclean all

status:
	@echo "=== Containers ==="
	@docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "=== Volumes ==="
	@docker volume ls
	@echo ""
	@echo "=== Networks ==="
	@docker network ls

.PHONY: all up down stop start logs clean fclean re status
