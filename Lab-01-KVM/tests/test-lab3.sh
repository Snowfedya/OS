#!/bin/bash
###############################################################################
# Test Lab 3: Networking
# Проверяет сетевую конфигурацию VM
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

echo -e "${GREEN}=== Lab 3 Tests: Networking ===${NC}"
echo ""

echo "Test Group: Virtual Networks"
test_check "Default network exists" "virsh net-list --all | grep -q 'default'"
test_check "Default network is active" "virsh net-list | grep -q 'default'"
test_check "Can read network config" "virsh net-dumpxml default"
test_check "Network has DHCP enabled" "virsh net-dumpxml default | grep -q '<dhcp>'"
test_check "Bridge virbr0 exists" "ip addr show virbr0"

echo ""
echo "Test Group: VM Network Configuration"
if ! virsh list | grep -q "$VM_NAME"; then
    virsh start $VM_NAME &>/dev/null
    sleep 3
fi

test_check "VM has network interface" "virsh domiflist $VM_NAME | grep -q 'network'"
test_check "Can read interface stats" "virsh domiflist $VM_NAME | grep -q 'vnet'"

# Попытаться получить IP
sleep 5  # Дать время DHCP
test_check "VM получил IP от DHCP" "virsh domifaddr $VM_NAME | grep -qE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' || virsh net-dhcp-leases default | grep -q '$VM_NAME'"

echo ""
echo "Test Group: Network Creation"
# Создать тестовую сеть
cat > /tmp/test-net.xml << 'EOF'
<network>
  <name>test-network</name>
  <bridge name='virbr-test'/>
  <ip address='10.20.30.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.20.30.10' end='10.20.30.100'/>
    </dhcp>
  </ip>
</network>
EOF

test_check "Can define new network" "virsh net-define /tmp/test-net.xml"
test_check "Can start network" "virsh net-start test-network"
test_check "Network is active" "virsh net-list | grep -q 'test-network'"
test_check "Network bridge created" "ip addr show virbr-test"

# Очистка
virsh net-destroy test-network &>/dev/null
virsh net-undefine test-network &>/dev/null
rm -f /tmp/test-net.xml

echo ""
echo "Test Group: Network Interface Management"
test_check "Can list network interfaces" "virsh domiflist $VM_NAME"
test_check "Can read interface stats" "virsh domifstat $VM_NAME"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "Lab 3 Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ All Lab 3 tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
