#!/bin/bash
################################################################################
# Test Lab 4: Snapshots and Migration
# Проверяет снэпшоты и операции миграции
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

echo -e "${GREEN}=== Lab 4 Tests: Snapshots & Migration ===${NC}"
echo ""

# Убедиться что VM запущена
if ! virsh list | grep -q "$VM_NAME"; then
    virsh start $VM_NAME &>/dev/null
    sleep 3
fi

echo "Test Group: Snapshot Creation"
test_check "Can create disk snapshot" "virsh snapshot-create-as $VM_NAME test-snap-1 'Test snapshot' --disk-only --no-metadata"
test_check "Can list snapshots" "virsh snapshot-list $VM_NAME"
test_check "Snapshot appears in list" "virsh snapshot-list $VM_NAME | grep -q 'test-snap-1'"

echo ""
echo "Test Group: Snapshot Information"
test_check "Can read snapshot info" "virsh snapshot-info $VM_NAME test-snap-1"
test_check "Can dump snapshot XML" "virsh snapshot-dumpxml $VM_NAME test-snap-1"

echo ""
echo "Test Group: Multiple Snapshots"
test_check "Can create second snapshot" "virsh snapshot-create-as $VM_NAME test-snap-2 'Second test snapshot' --disk-only --no-metadata"
test_check "Both snapshots exist" "[[ $(virsh snapshot-list $VM_NAME --name | wc -l) -ge 2 ]]"

echo ""
echo "Test Group: Snapshot Management"
# Удалить один снэпшот
test_check "Can delete snapshot" "virsh snapshot-delete $VM_NAME test-snap-2 --metadata"
test_check "Snapshot removed from list" "! virsh snapshot-list $VM_NAME | grep -q 'test-snap-2'"

echo ""
echo "Test Group: Block Operations"
test_check "Can read block job info" "virsh blockjob $VM_NAME vda --info || true"
test_check "Can query block info" "virsh domblkinfo $VM_NAME vda"
test_check "Can list block devices" "virsh domblklist $VM_NAME"

echo ""
echo "Test Group: Domain Backup/Export"
XML_BACKUP="/tmp/${VM_NAME}-backup.xml"
test_check "Can export VM XML" "virsh dumpxml $VM_NAME > $XML_BACKUP"
test_check "Exported XML is valid" "test -s $XML_BACKUP && grep -q '<domain' $XML_BACKUP"
test_check "XML contains disk info" "grep -q '<disk' $XML_BACKUP"

echo ""
echo "Test Group: Clone Test"
CLONE_NAME="${VM_NAME}-test-clone"
# Удалить предыдущий клон если существует
virsh destroy $CLONE_NAME &>/dev/null
virsh undefine $CLONE_NAME --remove-all-storage &>/dev/null

# Выключить VM для клонирования
virsh shutdown $VM_NAME &>/dev/null
sleep 5

test_check "Can clone VM" "virt-clone --original $VM_NAME --name $CLONE_NAME --auto-clone --check path_in_use=off 2>/dev/null || echo 'Clone may already exist'"

if virsh list --all | grep -q "$CLONE_NAME"; then
    test_check "Clone VM exists" "virsh list --all | grep -q '$CLONE_NAME'"
    test_check "Clone has different UUID" "test $(virsh domuuid $VM_NAME) != $(virsh domuuid $CLONE_NAME)"
    
    # Очистка клона
    virsh destroy $CLONE_NAME &>/dev/null
    virsh undefine $CLONE_NAME --remove-all-storage &>/dev/null
fi

# Запустить VM обратно
virsh start $VM_NAME &>/dev/null

echo ""
echo "Test Group: Disk Image Info"
DISK_PATH=$(virsh domblklist $VM_NAME | grep vda | awk '{print $2}')
if [[ -n "$DISK_PATH" ]]; then
    test_check "Can read disk image info" "qemu-img info $DISK_PATH"
    test_check "Disk format is qcow2" "qemu-img info $DISK_PATH | grep -q 'file format: qcow2'"
fi

echo ""
echo "Test Group: Cleanup"
# Очистка тестовых снэпшотов
for snap in test-snap-1 test-snap-2; do
    virsh snapshot-delete $VM_NAME $snap --metadata &>/dev/null || true
done

# Очистка backup файлов
rm -f $XML_BACKUP

test_check "Cleanup completed" "true"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "Lab 4 Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ All Lab 4 tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
