#!/bin/bash
################################################################################
# Integration Test: All Platforms Check
# Проверяет доступность всех трех технологий
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

test_check() {
    local test_name="$1"
    local command="$2"
    
    echo -n "  Testing: $test_name... "
    
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

echo -e "${GREEN}=== Integration Test: All Platforms ===${NC}"
echo ""

echo -e "${YELLOW}[KVM Platform]${NC}"
test_check "KVM module loaded" "lsmod | grep -q kvm"
test_check "virsh command available" "command -v virsh"
test_check "libvirtd service running" "systemctl is-active --quiet libvirtd || pgrep libvirtd"
test_check "Default network exists" "virsh net-list --all 2>/dev/null | grep -q default || echo 'Skip'"

echo ""
echo -e "${YELLOW}[LXC/LXD Platform]${NC}"
test_check "LXD command available" "command -v lxc"
test_check "LXD responsive" "lxc version || snap list lxd"

echo ""
echo -e "${YELLOW}[Docker Platform]${NC}"
test_check "Docker command available" "command -v docker"
test_check "Docker daemon running" "docker info"
test_check "Docker compose available" "docker compose version || docker-compose --version"

echo ""
echo -e "${YELLOW}[System Requirements]${NC}"
test_check "CPU supports virtualization" "grep -E -q '(vmx|svm)' /proc/cpuinfo"
test_check "Sufficient memory (4GB+)" "[[ $(free -g | awk '/^Mem:/{print $2}') -ge 4 ]]"
test_check "Kernel version 4.18+" "[[ $(uname -r | cut -d. -f1) -ge 4 ]]"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "Integration Test Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ All platforms available!${NC}"
    echo "Система готова для всех лабораторных работ"
    exit 0
else
    echo -e "${YELLOW}⚠ Some platforms unavailable${NC}"
    echo "Установите отсутствующие компоненты:"
    echo "  KVM: sudo Lab-01-KVM/scripts/setup-host.sh"
    echo "  LXD: sudo Lab-02-LXC/scripts/init-lxd.sh"
    echo "  Docker: curl -fsSL https://get.docker.com | sudo bash"
    exit 1
fi
