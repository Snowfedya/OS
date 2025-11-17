#!/bin/bash
################################################################################
# Test Lab 2: LXC Container Verification
# Проверяет базовую функциональность контейнера LXC
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

PASS=0
FAIL=0
CONTAINER_NAME="lxc-lab-container"

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

echo -e "${GREEN}=== Lab 2 Tests: Container Verification ===${NC}"
echo ""

echo "Test Group: Container State"
test_check "Container $CONTAINER_NAME exists" "lxc list | grep -q '$CONTAINER_NAME'"
test_check "Container is running" "lxc list | grep '$CONTAINER_NAME' | grep -q 'RUNNING'"

echo ""
echo "Test Group: Container Configuration"
test_check "User 'ubuntu' exists" "lxc exec $CONTAINER_NAME -- id ubuntu"

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
