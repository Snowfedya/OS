#!/bin/bash
###############################################################################
# LXD Container Deployment
# Создает базовый контейнер для лабораторных работ
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONTAINER_NAME="lxc-lab-container"
IMAGE="ubuntu/jammy"

echo -e "${GREEN}=== LXD Container Deployment ===${NC}"
echo ""

echo -e "${YELLOW}[1/4] Проверка LXD...${NC}"
if ! command -v lxc &>/dev/null; then
    echo -e "${RED}✗ LXD не установлен${NC}"
    echo "  Запустите: sudo ./init-lxd.sh"
    exit 1
fi
echo -e "${GREEN}✓ LXD установлен${NC}"

echo -e "${YELLOW}[2/4] Проверка существующего контейнера...${NC}"
if lxc list | grep -q "$CONTAINER_NAME"; then
    echo -e "${YELLOW}⚠ Контейнер '$CONTAINER_NAME' уже существует${NC}"
    read -p "Удалить существующий контейнер? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        lxc stop $CONTAINER_NAME --force || true
        lxc delete $CONTAINER_NAME --force
        echo -e "${GREEN}✓ Существующий контейнер удален${NC}"
    else
        echo "Отменено"
        exit 0
    fi
fi

lxc remote add images images.linuxcontainers.org || true

echo -e "${YELLOW}[3/4] Создание контейнера из образа $IMAGE...${NC}"
lxc launch images:$IMAGE $CONTAINER_NAME -n ""

echo "Ожидание запуска контейнера..."
sleep 5

# Проверка состояния
if lxc list | grep "$CONTAINER_NAME" | grep -q "RUNNING"; then
    echo -e "${GREEN}✓ Контейнер создан и запущен${NC}"
else
    echo -e "${RED}✗ Контейнер не запустился${NC}"
    exit 1
fi

echo -e "${YELLOW}[4/4] Базовая настройка контейнера... (сетевые команды пропущены)${NC}"

# Создание пользователя
lxc exec $CONTAINER_NAME -- useradd -m -s /bin/bash ubuntu
lxc exec $CONTAINER_NAME -- bash -c "echo 'ubuntu:lab_password_123' | chpasswd"
lxc exec $CONTAINER_NAME -- usermod -aG sudo ubuntu

echo -e "${GREEN}✓ Базовая настройка завершена${NC}"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Контейнер развернут успешно!                     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Информация о контейнере:"
echo "  Имя:           $CONTAINER_NAME"
echo "  Образ:         $IMAGE"
echo "  Пользователь:  ubuntu"
echo "  Пароль:        lab_password_123"
echo ""
echo "Управление контейнером:"
echo "  lxc list                          - список контейнеров"
echo "  lxc exec $CONTAINER_NAME -- bash  - войти в контейнер"
echo "  lxc stop $CONTAINER_NAME          - остановить"
echo "  lxc start $CONTAINER_NAME         - запустить"
echo "  lxc info $CONTAINER_NAME          - информация"
echo ""
echo "Примеры команд:"
lxc list
