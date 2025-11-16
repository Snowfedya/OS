#!/bin/bash
################################################################################
# Docker Build Script
# Собирает все образы для лабораторных работ
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Building Docker Images ===${NC}"
echo ""

cd "$(dirname "$0")/.."

echo -e "${YELLOW}[1/2] Building web image...${NC}"
docker build -f dockerfiles/Dockerfile.web -t lab-web:latest .
echo -e "${GREEN}✓ Web image built${NC}"

echo ""
echo -e "${YELLOW}[2/2] Building API image...${NC}"
docker build -f dockerfiles/Dockerfile.api -t lab-api:latest .
echo -e "${GREEN}✓ API image built${NC}"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ All images built successfully     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""

docker images | grep "lab-"
