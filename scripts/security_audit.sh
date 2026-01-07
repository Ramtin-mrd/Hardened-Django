#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- Security Audit for Secure_Django_Deployment ---${NC}"

# 1. Test Non-root user
echo -n "1. Checking Non-root User: "
USER_ID=$(docker exec secure-django-app id -u)
if [ "$USER_ID" == "1000" ]; then
    echo -e "${GREEN}[PASS] Running as UID 1000${NC}"
else
    echo -e "${RED}[FAIL] Running as Root!${NC}"
fi

# 2. Test Read-only Filesystem
echo -n "2. Checking Read-only Root FS: "
docker exec secure-django-app touch /app/test_file 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${GREEN}[PASS] Filesystem is Read-only${NC}"
else
    echo -e "${RED}[FAIL] Filesystem is Writable!${NC}"
fi

# 3. Test Kernel Capabilities
echo -n "3. Checking No-New-Privileges: "
NO_NEW_PRIVS=$(docker inspect secure-django-app --format '{{.HostConfig.SecurityOpt}}')
if [[ "$NO_NEW_PRIVS" == *"no-new-privileges"* ]]; then
    echo -e "${GREEN}[PASS] Active${NC}"
else
    echo -e "${RED}[FAIL] Inactive!${NC}"
fi

# 4. Test Resource Limits
echo -n "4. Checking Memory Limits: "
MEM_LIMIT=$(docker inspect secure-django-app --format '{{.HostConfig.Memory}}')
if [ "$MEM_LIMIT" != "0" ]; then
    echo -e "${GREEN}[PASS] $(($MEM_LIMIT/1024/1024))MB Limit Set${NC}"
else
    echo -e "${RED}[FAIL] No Limit Set!${NC}"
fi
