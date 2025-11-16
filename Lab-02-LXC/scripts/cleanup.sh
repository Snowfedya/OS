#!/bin/bash
################################################################################
# LXD Cleanup Script
# Удаляет все тестовые контейнеры и образы
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== LXD Cleanup ===${NC}"
echo ""

echo -e "${YELLOW}Текущие контейнеры:${NC}"
lxc list

echo ""
read -p "Удалить ВСЕ контейнеры? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Отменено"
    exit 0
fi

echo -e "${YELLOW}Остановка и удаление контейнеров...${NC}"
for container in $(lxc list -c n --format csv); do
    echo "  Удаление: $container"
    lxc stop $container --force 2>/dev/null || true
    lxc delete $container --force
done

echo -e "${GREEN}✓ Все контейнеры удалены${NC}"

echo ""
read -p "Удалить кэшированные образы? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Удаление образов...${NC}"
    for image in $(lxc image list --format csv -c f); do
        echo "  Удаление образа: $image"
        lxc image delete $image 2>/dev/null || true
    done
    echo -e "${GREEN}✓ Образы удалены${NC}"
fi

echo ""
echo -e "${GREEN}✓ Очистка завершена${NC}"
lxc list
