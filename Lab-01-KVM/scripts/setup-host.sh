#!/bin/bash
################################################################################
# KVM Host Setup Script
# Подготавливает хост-систему для работы с KVM/QEMU + libvirt
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== KVM Host Setup Script ===${NC}"
echo "Эта программа подготовит вашу систему для работы с KVM"
echo ""

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗ Этот скрипт должен быть запущен с правами root${NC}" 
   echo "  Используйте: sudo $0"
   exit 1
fi

echo -e "${YELLOW}[1/6] Проверка поддержки аппаратной виртуализации...${NC}"
if grep -E -q '(vmx|svm)' /proc/cpuinfo; then
    echo -e "${GREEN}✓ Аппаратная виртуализация поддерживается (VT-x/AMD-V)${NC}"
else
    echo -e "${RED}✗ Аппаратная виртуализация НЕ обнаружена!${NC}"
    echo "  Включите VT-x/AMD-V в BIOS/UEFI настройках"
    exit 1
fi

echo -e "${YELLOW}[2/6] Проверка загрузки KVM модулей...${NC}"
if lsmod | grep -q kvm; then
    echo -e "${GREEN}✓ KVM модули уже загружены${NC}"
else
    echo "  Загрузка KVM модулей..."
    modprobe kvm
    if grep -q Intel /proc/cpuinfo; then
        modprobe kvm_intel
    else
        modprobe kvm_amd
    fi
    echo -e "${GREEN}✓ KVM модули загружены${NC}"
fi

echo -e "${YELLOW}[3/6] Установка необходимых пакетов...${NC}"
export DEBIAN_FRONTEND=noninteractive

# Определение дистрибутива
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}✗ Не удалось определить дистрибутив${NC}"
    exit 1
fi

if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
    apt-get update -qq
    apt-get install -y -qq \
        qemu-kvm \
        libvirt-daemon-system \
        libvirt-clients \
        bridge-utils \
        virtinst \
        virt-manager \
        virt-viewer \
        libguestfs-tools \
        cpu-checker \
        guestfs-tools 2>&1 | grep -v "^Reading"
elif [[ "$OS" == "fedora" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "centos" ]]; then
    dnf install -y -q \
        qemu-kvm \
        libvirt \
        virt-install \
        virt-manager \
        virt-viewer \
        libguestfs-tools-c
else
    echo -e "${YELLOW}⚠ Неизвестный дистрибутив: $OS${NC}"
    echo "  Установите пакеты вручную: qemu-kvm, libvirt-daemon, virtinst"
fi

echo -e "${GREEN}✓ Пакеты установлены${NC}"

echo -e "${YELLOW}[4/6] Настройка сервиса libvirt...${NC}"
systemctl enable libvirtd --now 2>/dev/null || true
systemctl start libvirtd 2>/dev/null || true
sleep 2

if systemctl is-active --quiet libvirtd; then
    echo -e "${GREEN}✓ libvirtd запущен и активен${NC}"
else
    echo -e "${RED}✗ libvirtd не запущен!${NC}"
    exit 1
fi

echo -e "${YELLOW}[5/6] Настройка прав пользователя...${NC}"
CURRENT_USER=${SUDO_USER:-$USER}

if [[ -n "$CURRENT_USER" ]] && [[ "$CURRENT_USER" != "root" ]]; then
    usermod -aG libvirt "$CURRENT_USER" 2>/dev/null || true
    usermod -aG kvm "$CURRENT_USER" 2>/dev/null || true
    echo -e "${GREEN}✓ Пользователь $CURRENT_USER добавлен в группы libvirt и kvm${NC}"
    echo -e "${YELLOW}  ⚠ Необходимо перелогиниться для применения прав группы${NC}"
else
    echo -e "${YELLOW}⚠ Запущено напрямую под root - пропуск настройки пользователя${NC}"
fi

echo -e "${YELLOW}[6/6] Создание storage pool по умолчанию...${NC}"
if virsh pool-list --all | grep -q "default"; then
    echo -e "${GREEN}✓ Storage pool 'default' уже существует${NC}"
else
    virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
    virsh pool-build default
    virsh pool-start default
    virsh pool-autostart default
    echo -e "${GREEN}✓ Storage pool 'default' создан${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Хост успешно настроен для работы с KVM           ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Проверка установки:"
echo "  kvm-ok                  - проверка KVM"
echo "  virsh --version         - версия libvirt"
echo "  virsh list --all        - список VM"
echo "  virsh pool-list         - список storage pools"
echo ""
echo "Следующий шаг: запустите deploy.sh для импорта образа"
