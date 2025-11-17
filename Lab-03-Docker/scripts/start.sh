#!/bin/bash
################################################################################
# Docker Compose Start Script
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cd "$(dirname "$0")/.."

echo -e "${GREEN}=== Starting Docker Stack ===${NC}"
echo ""

echo -e "${YELLOW}Starting services with docker-compose...${NC}"
docker compose up -d

echo ""
echo "Waiting for services to be healthy..."
sleep 10

echo ""
echo -e "${GREEN}✓ Stack started${NC}"
echo ""

docker compose ps

echo ""
echo "Service URLs:"
echo "  Web:      http://localhost:5000"
echo "  API:      http://localhost:3000"
echo "  Database: localhost:5432 (user: labuser, password: labpass123)"
echo "  Cache:    localhost:6379"
echo ""
echo "Logs: docker-compose logs -f"
