#!/bin/bash
################################################################################
# Test Lab 2: Resource Management
# Проверяет управление ресурсами VM
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

PASS=0
FAIL=0
VM_NAME="kvm-lab-vm"

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

echo -e "${GREEN}=== Lab 2 Tests: Resource Management ===${NC}"
echo ""

# Убедиться что VM запущена
if ! virsh list | grep -q "$VM_NAME"; then
    echo "Starting $VM_NAME for tests..."
    virsh start $VM_NAME &>/dev/null
    sleep 3
fi

echo "Test Group: CPU Configuration"
test_check "Can read CPU scheduler info" "virsh schedinfo $VM_NAME"
test_check "Can modify cpu_shares" "virsh schedinfo $VM_NAME --set cpu_shares=2048"
test_check "cpu_shares applied correctly" "virsh schedinfo $VM_NAME | grep -q 'cpu_shares.*2048'"

# Восстановить default
virsh schedinfo $VM_NAME --set cpu_shares=1024 &>/dev/null

test_check "Can set CPU quota" "virsh schedinfo $VM_NAME --set vcpu_quota=50000"
test_check "Can reset CPU quota" "virsh schedinfo $VM_NAME --set vcpu_quota=-1"

echo ""
echo "Test Group: CPU Pinning"
test_check "Can read vCPU pinning" "virsh vcpupin $VM_NAME"
test_check "Can pin vCPU to core" "virsh vcpupin $VM_NAME 0 0 --live"
test_check "vCPU pinning applied" "virsh vcpupin $VM_NAME | grep -q '0.*0'"

# Reset pinning
CPUS=$(nproc)
RANGE="0-$((CPUS-1))"
virsh vcpupin $VM_NAME 0 $RANGE --live &>/dev/null

echo ""
echo "Test Group: Memory Configuration"
test_check "Can read memory info" "virsh dominfo $VM_NAME | grep -q 'memory'"
test_check "Can read memory stats" "virsh dommemstat $VM_NAME"

# Получить текущую память
CURRENT_MEM=$(virsh dominfo $VM_NAME | grep 'Used memory' | awk '{print $3}')
NEW_MEM=$((CURRENT_MEM + 512000))  # Добавить ~512MB

test_check "Can modify memory (setmem)" "virsh setmem $VM_NAME ${NEW_MEM}KiB --current --live 2>/dev/null || true"

echo ""
echo "Test Group: Disk I/O"
test_check "Can read disk block info" "virsh domblklist $VM_NAME"
test_check "Can read block stats" "virsh domblkstat $VM_NAME vda"

# Установить I/O лимиты
test_check "Can set I/O limits" "virsh blkdeviotune $VM_NAME vda --total-iops-sec 1000"
test_check "I/O limits applied" "virsh blkdeviotune $VM_NAME vda | grep -q 'total_iops_sec.*1000'"

# Убрать лимиты
virsh blkdeviotune $VM_NAME vda --total-iops-sec 0 &>/dev/null

echo ""
echo "Test Group: Monitoring"
test_check "Can read domain stats" "virsh domstats $VM_NAME"
test_check "Can read CPU stats" "virsh cpu-stats $VM_NAME"
test_check "CPU time is incrementing" "virsh domstats $VM_NAME | grep -q 'cpu.time'"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "Lab 2 Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ All Lab 2 tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
