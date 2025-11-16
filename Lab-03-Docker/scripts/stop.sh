#!/bin/bash
################################################################################
# Docker Compose Stop Script
################################################################################

cd "$(dirname "$0")/.."

echo "Stopping Docker stack..."
docker-compose down

echo ""
echo "✓ Stack stopped"
echo ""
echo "To remove volumes: docker-compose down -v"
