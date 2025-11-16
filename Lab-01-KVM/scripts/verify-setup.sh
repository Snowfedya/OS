#!/bin/bash
################################################################################
# KVM Setup Verification Script
# Проверяет корректность установки и конфигурации KVM
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

check() {
    local description="$1"
    local command="$2"
    
    echo -n "Проверка: $description... "
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((FAIL++))
        return 1
    fi
}

echo -e "${GREEN}=== KVM Setup Verification ===${NC}"
echo ""

echo -e "${YELLOW}[Аппаратная поддержка]${NC}"
check "VT-x/AMD-V в CPU" "grep -E -q '(vmx|svm)' /proc/cpuinfo"
check "KVM модуль загружен" "lsmod | grep -q kvm"

echo ""
echo -e "${YELLOW}[Установленные пакеты]${NC}"
check "qemu-kvm установлен" "which qemu-system-x86_64"
check "virsh установлен" "which virsh"
check "virt-install установлен" "which virt-install"
check "libguestfs-tools установлены" "which virt-df"

echo ""
echo -e "${YELLOW}[Сервисы]${NC}"
check "libvirtd активен" "systemctl is-active --quiet libvirtd"
check "libvirtd включен при загрузке" "systemctl is-enabled --quiet libvirtd"

echo ""
echo -e "${YELLOW}[Права доступа]${NC}"
check "Пользователь в группе libvirt" "groups | grep -q libvirt"
check "Доступ к /dev/kvm" "test -r /dev/kvm && test -w /dev/kvm"

echo ""
echo -e "${YELLOW}[Storage Pools]${NC}"
check "Default pool существует" "virsh pool-list --all | grep -q default"
check "Default pool активен" "virsh pool-list | grep -q default"

echo ""
echo -e "${YELLOW}[Сеть]${NC}"
check "Default network существует" "virsh net-list --all | grep -q default"
check "Default network активна" "virsh net-list | grep -q default"

echo ""
echo -e "${YELLOW}[Виртуальные машины]${NC}"
if virsh list --all | grep -q "kvm-lab-vm"; then
    check "Lab VM существует" "virsh list --all | grep -q kvm-lab-vm"
    check "Lab VM запущена" "virsh list | grep -q kvm-lab-vm"
else
    echo -e "${YELLOW}⚠ Lab VM не найдена (запустите deploy.sh)${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "Результаты: ${GREEN}$PASS пройдено${NC}, ${RED}$FAIL провалено${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ Все проверки пройдены успешно!${NC}"
    echo "Система готова к выполнению лабораторных работ"
    exit 0
else
    echo -e "${RED}✗ Некоторые проверки провалены${NC}"
    echo "Исправьте ошибки перед началом работы"
    exit 1
fi
