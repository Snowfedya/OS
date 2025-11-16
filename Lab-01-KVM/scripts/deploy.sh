#!/bin/bash
################################################################################
# KVM Lab Deployment Script
# Импортирует готовый образ и создает VM для лабораторных работ
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_DIR="$LAB_DIR/images"
VM_NAME="kvm-lab-vm"
IMAGE_FILE="ubuntu-kvm-lab.qcow2"

echo -e "${GREEN}=== KVM Lab Deployment ===${NC}"
echo ""

# Проверка libvirt
if ! systemctl is-active --quiet libvirtd; then
    echo -e "${RED}✗ libvirtd не запущен!${NC}"
    echo "  Запустите сначала: sudo ./setup-host.sh"
    exit 1
fi

echo -e "${YELLOW}[1/5] Проверка наличия образа...${NC}"
if [[ ! -f "$IMAGE_DIR/$IMAGE_FILE" ]]; then
    echo -e "${RED}✗ Образ не найден: $IMAGE_DIR/$IMAGE_FILE${NC}"
    echo ""
    echo -e "${BLUE}Образ должен быть создан отдельно. Инструкция:${NC}"
    echo ""
    echo "1. Создайте VM через virt-install:"
    echo "   sudo virt-install \\"
    echo "     --name=kvm-lab-base \\"
    echo "     --ram=2048 \\"
    echo "     --vcpus=2 \\"
    echo "     --disk path=/var/lib/libvirt/images/kvm-lab.qcow2,size=20 \\"
    echo "     --os-variant=ubuntu22.04 \\"
    echo "     --network=default \\"
    echo "     --graphics=none \\"
    echo "     --console=pty,target_type=serial \\"
    echo "     --location=http://archive.ubuntu.com/ubuntu/dists/jammy/main/installer-amd64/ \\"
    echo "     --extra-args='console=ttyS0,115200n8'"
    echo ""
    echo "2. Установите необходимые пакеты в VM:"
    echo "   apt-get update && apt-get install -y qemu-guest-agent libvirt-clients"
    echo ""
    echo "3. Скопируйте образ:"
    echo "   cp /var/lib/libvirt/images/kvm-lab.qcow2 $IMAGE_DIR/$IMAGE_FILE"
    echo ""
    echo "ИЛИ скачайте готовый образ (если доступен):"
    echo "   wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \\"
    echo "     -O $IMAGE_DIR/$IMAGE_FILE"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Образ найден: $IMAGE_FILE${NC}"

echo -e "${YELLOW}[2/5] Проверка существующей VM...${NC}"
if virsh list --all | grep -q "$VM_NAME"; then
    echo -e "${YELLOW}⚠ VM '$VM_NAME' уже существует${NC}"
    read -p "Удалить существующую VM? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        virsh destroy "$VM_NAME" 2>/dev/null || true
        virsh undefine "$VM_NAME" --remove-all-storage 2>/dev/null || true
        echo -e "${GREEN}✓ Существующая VM удалена${NC}"
    else
        echo "Отменено"
        exit 0
    fi
else
    echo -e "${GREEN}✓ VM не существует, продолжаем${NC}"
fi

echo -e "${YELLOW}[3/5] Копирование образа в libvirt storage...${NC}"
TARGET_IMAGE="/var/lib/libvirt/images/${VM_NAME}.qcow2"
sudo cp "$IMAGE_DIR/$IMAGE_FILE" "$TARGET_IMAGE"
sudo chown libvirt-qemu:kvm "$TARGET_IMAGE" 2>/dev/null || sudo chown qemu:qemu "$TARGET_IMAGE"
echo -e "${GREEN}✓ Образ скопирован в $TARGET_IMAGE${NC}"

echo -e "${YELLOW}[4/5] Создание VM через virt-install...${NC}"
sudo virt-install \
    --name="$VM_NAME" \
    --ram=2048 \
    --vcpus=2 \
    --disk path="$TARGET_IMAGE",device=disk,bus=virtio \
    --os-variant=ubuntu22.04 \
    --network=default,model=virtio \
    --graphics=none \
    --console=pty,target_type=serial \
    --import \
    --noautoconsole

echo -e "${GREEN}✓ VM создана и запущена${NC}"

echo -e "${YELLOW}[5/5] Ожидание запуска VM...${NC}"
sleep 5

VM_STATE=$(virsh domstate "$VM_NAME")
if [[ "$VM_STATE" == "running" ]]; then
    echo -e "${GREEN}✓ VM успешно запущена${NC}"
else
    echo -e "${YELLOW}⚠ VM в состоянии: $VM_STATE${NC}"
fi

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Lab VM развернута успешно!                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Информация о VM:"
echo "  Имя:        $VM_NAME"
echo "  RAM:        2048 MB"
echo "  vCPUs:      2"
echo "  Диск:       $TARGET_IMAGE"
echo "  Сеть:       default (NAT)"
echo ""
echo "Подключение к VM:"
echo "  virsh console $VM_NAME"
echo "  (выход: Ctrl+])"
echo ""
echo "Управление VM:"
echo "  virsh start $VM_NAME       - запустить"
echo "  virsh shutdown $VM_NAME    - корректное выключение"
echo "  virsh destroy $VM_NAME     - принудительное выключение"
echo "  virsh reboot $VM_NAME      - перезагрузка"
echo "  virsh dominfo $VM_NAME     - информация о VM"
echo ""
echo "Для проверки установки запустите: ./verify-setup.sh"
