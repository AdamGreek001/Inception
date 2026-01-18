# **************************************************************************** #
#                                   INCEPTION                                  #
# **************************************************************************** #

# Variables
NAME			= inception
COMPOSE_FILE	= srcs/docker-compose.yml
DATA_PATH		= /home/eel-alao/data
ENV_FILE		= srcs/.env

# Colors
GREEN	= \033[0;32m
YELLOW	= \033[0;33m
RED		= \033[0;31m
NC		= \033[0m

# Default target
all: up

# Create data directories and build images
build:
	@echo "$(GREEN)Creating data directories...$(NC)"
	@sudo mkdir -p $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	@sudo chown -R $(USER):$(USER) $(DATA_PATH)
	@echo "$(GREEN)Building Docker images...$(NC)"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build

# Start containers in detached mode
up: build
	@echo "$(GREEN)Starting containers...$(NC)"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d
	@echo "$(GREEN)Inception is now running!$(NC)"
	@echo "$(YELLOW)Access your site at: https://eel-alao.42.fr$(NC)"

# Stop containers
down:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down
	@echo "$(GREEN)Containers stopped.$(NC)"

# Stop containers and remove images/networks
clean: down
	@echo "$(RED)Cleaning up Docker resources...$(NC)"
	@docker system prune -af
	@docker volume rm $$(docker volume ls -q 2>/dev/null) 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete.$(NC)"

# Full clean including data directories
fclean: clean
	@echo "$(RED)Removing data directories...$(NC)"
	@sudo rm -rf $(DATA_PATH)
	@echo "$(GREEN)Full cleanup complete.$(NC)"

# Rebuild everything from scratch
re: fclean all

# Show container status
status:
	@echo "$(GREEN)Container Status:$(NC)"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) ps

# View logs
logs:
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs

# Follow logs in real-time
logs-f:
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

# Enter a container shell
shell-nginx:
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) exec nginx sh

shell-wordpress:
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) exec wordpress sh

shell-mariadb:
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) exec mariadb sh

# Restart containers
restart: down up

# Show help
help:
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  all        - Build and start containers (default)"
	@echo "  build      - Build Docker images"
	@echo "  up         - Start containers"
	@echo "  down       - Stop containers"
	@echo "  clean      - Remove containers, images, and volumes"
	@echo "  fclean     - Full clean including data directories"
	@echo "  re         - Rebuild everything from scratch"
	@echo "  status     - Show container status"
	@echo "  logs       - View container logs"
	@echo "  logs-f     - Follow logs in real-time"
	@echo "  shell-*    - Enter container shell (nginx/wordpress/mariadb)"
	@echo "  restart    - Restart all containers"

.PHONY: all build up down clean fclean re status logs logs-f shell-nginx shell-wordpress shell-mariadb restart help
