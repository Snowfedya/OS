#!/bin/bash
################################################################################
# LXD Initialization Script
# Подготавливает LXD для работы с контейнерами
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== LXD Initialization ===${NC}"
echo ""

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗ Требуются права root${NC}"
   echo "  Используйте: sudo $0"
   exit 1
fi

echo -e "${YELLOW}[1/5] Установка LXD...${NC}"
if command -v lxc &>/dev/null; then
    echo -e "${GREEN}✓ LXD уже установлен${NC}"
else
    if command -v snap &>/dev/null; then
        snap install lxd
    elif command -v apt-get &>/dev/null; then
        apt-get update -qq
        apt-get install -y -qq lxd lxd-client
    else
        echo -e "${RED}✗ Не удалось определить метод установки${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ LXD установлен${NC}"
fi

echo -e "${YELLOW}[2/5] Добавление пользователя в группу lxd...${NC}"
CURRENT_USER=${SUDO_USER:-$USER}
if [[ -n "$CURRENT_USER" ]] && [[ "$CURRENT_USER" != "root" ]]; then
    usermod -aG lxd "$CURRENT_USER" || true
    echo -e "${GREEN}✓ Пользователь $CURRENT_USER добавлен в группу lxd${NC}"
    echo -e "${YELLOW}  ⚠ Необходимо перелогиниться для применения прав${NC}"
fi

echo -e "${YELLOW}[3/5] Инициализация LXD...${NC}"
if lxd init --dump 2>/dev/null | grep -q "cluster:"; then
    echo -e "${GREEN}✓ LXD уже инициализирован${NC}"
else
    # Автоматическая инициализация с настройками по умолчанию
    cat <<EOF | lxd init --preseed
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: none
  description: ""
  name: lxdbr0
  type: ""
  project: default
storage_pools:
- config:
    size: 30GB
  description: ""
  name: default
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
EOF
    echo -e "${GREEN}✓ LXD инициализирован${NC}"
fi

echo -e "${YELLOW}[4/5] Проверка storage pool...${NC}"
if lxc storage list | grep -q "default"; then
    echo -e "${GREEN}✓ Storage pool 'default' существует${NC}"
else
    lxc storage create default dir
    echo -e "${GREEN}✓ Storage pool 'default' создан${NC}"
fi

echo -e "${YELLOW}[5/5] Проверка сети...${NC}"
if lxc network list | grep -q "lxdbr0"; then
    echo -e "${GREEN}✓ Сеть lxdbr0 существует${NC}"
else
    lxc network create lxdbr0
    echo -e "${GREEN}✓ Сеть lxdbr0 создана${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ LXD успешно инициализирован                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Проверка:"
echo "  lxc version"
echo "  lxc storage list"
echo "  lxc network list"
echo "  lxc profile show default"
echo ""
echo "Следующий шаг: запустите deploy.sh"
