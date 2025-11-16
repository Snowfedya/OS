#!/bin/bash
################################################################################
# Test Lab 1: VM Creation
# Проверяет успешное создание и управление VM
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
VM_NAME="lab1-vm1"

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

echo -e "${GREEN}=== Lab 1 Tests: VM Creation ===${NC}"
echo ""

echo "Test Group: VM Existence"
test_check "VM $VM_NAME exists" "virsh list --all | grep -q '$VM_NAME'"
test_check "VM XML configuration valid" "virsh dumpxml $VM_NAME &>/dev/null"

echo ""
echo "Test Group: VM State Management"
if virsh list --all | grep -q "$VM_NAME"; then
    test_check "VM can be started" "virsh start $VM_NAME 2>/dev/null || virsh list | grep -q '$VM_NAME'"
    sleep 2
    test_check "VM is running" "virsh domstate $VM_NAME | grep -q 'running'"
    
    test_check "VM can be rebooted" "virsh reboot $VM_NAME --mode acpi"
    sleep 3
    
    test_check "VM responds after reboot" "virsh domstate $VM_NAME | grep -q 'running'"
    
    test_check "VM can be shut down" "virsh shutdown $VM_NAME"
    sleep 3
fi

echo ""
echo "Test Group: VM Configuration"
test_check "VM has assigned RAM" "virsh dominfo $VM_NAME | grep -q 'Used memory'"
test_check "VM has assigned vCPUs" "virsh dominfo $VM_NAME | grep -q 'CPU(s):'"
test_check "VM has disk attached" "virsh domblklist $VM_NAME | grep -q 'vda'"
test_check "VM has network interface" "virsh domiflist $VM_NAME | grep -qE '(default|network)'"

echo ""
echo "Test Group: VM Autostart"
virsh autostart $VM_NAME &>/dev/null
test_check "Autostart can be enabled" "virsh dominfo $VM_NAME | grep -q 'Autostart:.*enable'"
virsh autostart --disable $VM_NAME &>/dev/null
test_check "Autostart can be disabled" "virsh dominfo $VM_NAME | grep -q 'Autostart:.*disable'"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "Lab 1 Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ All Lab 1 tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
