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

echo -e "${YELLOW}[1/5] Установка LXD/Incus...${NC}"
if command -v lxc &>/dev/null; then
    echo -e "${GREEN}✓ LXD/Incus уже установлен${NC}"
else
    if apt-get install -y -qq lxd lxd-client &>/dev/null; then
        echo -e "${GREEN}✓ LXD установлен через apt${NC}"
    else
        echo -e "${YELLOW}⚠ Установка LXD не удалась, пробую Incus...${NC}"
        apt-get update -qq
        if apt-get install -y -qq incus; then
            echo -e "${GREEN}✓ Incus установлен${NC}"
            # Создаем символическую ссылку для совместимости
            ln -s /usr/bin/incus /usr/bin/lxc || true
            ln -s /usr/bin/incus /usr/bin/lxd || true
        else
            echo -e "${RED}✗ Не удалось установить ни LXD, ни Incus${NC}"
            exit 1
        fi
    fi
fi

echo -e "${YELLOW}[2/5] Добавление пользователя в группу lxd/incus...${NC}"
CURRENT_USER=${SUDO_USER:-$USER}
if [[ -n "$CURRENT_USER" ]] && [[ "$CURRENT_USER" != "root" ]]; then
    usermod -aG lxd "$CURRENT_USER" || usermod -aG incus "$CURRENT_USER" || true
    echo -e "${GREEN}✓ Пользователь $CURRENT_USER добавлен в группу lxd/incus${NC}"
    echo -e "${YELLOW}  ⚠ Необходимо перелогиниться для применения прав${NC}"
fi

echo -e "${YELLOW}[3/5] Инициализация LXD/Incus...${NC}"
systemctl start incus || true
if lxc profile show default &>/dev/null; then
    echo -e "${GREEN}✓ LXD/Incus уже инициализирован${NC}"
else
    # Автоматическая инициализация с настройками по умолчанию
    cat <<EOF | incus admin init --preseed
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
    echo -e "${GREEN}✓ LXD/Incus инициализирован${NC}"
fi
lxc profile device add default root disk path=/ pool=default || true

echo -e "${YELLOW}[4/5] Проверка storage pool...${NC}"
if lxc storage list | grep -q "default"; then
    echo -e "${GREEN}✓ Storage pool 'default' существует${NC}"
else
    lxc storage create default dir
    echo -e "${GREEN}✓ Storage pool 'default' создан${NC}"
fi

echo -e "${YELLOW}[5/5] Проверка сети... (пропущено в контейнере)${NC}"
# if lxc network list | grep -q "lxdbr0"; then
#     echo -e "${GREEN}✓ Сеть lxdbr0 существует${NC}"
# else
#     lxc network create lxdbr0
#     echo -e "${GREEN}✓ Сеть lxdbr0 создана${NC}"
# fi

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
