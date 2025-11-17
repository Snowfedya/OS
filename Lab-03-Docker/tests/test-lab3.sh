#!/bin/bash
################################################################################
# Test Lab 3: Docker Compose Verification
# Проверяет базовую функциональность Docker Compose стека
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
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

echo -e "${GREEN}=== Lab 3 Tests: Docker Compose Verification ===${NC}"
echo ""

echo "Test Group: Container State"
test_check "Container lab-web exists" "docker ps | grep -q 'lab-web'"
test_check "Container lab-api exists" "docker ps | grep -q 'lab-api'"
test_check "Container lab-web is running" "docker ps | grep 'lab-web' | grep -q 'Up'"
test_check "Container lab-api is running" "docker ps | grep 'lab-api' | grep -q 'Up'"

echo ""
echo "Test Group: Service Accessibility"
test_check "Web service is accessible" "curl -s http://localhost:5000 | grep -q 'Docker'"
test_check "API service is accessible" "curl -s http://localhost:3000/health | grep -q 'healthy'"

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
