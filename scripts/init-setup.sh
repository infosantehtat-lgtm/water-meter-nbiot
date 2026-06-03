#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Water Meter NB-IoT Platform Initialization ===${NC}"

# Check if ThingsBoard is ready
echo -e "${YELLOW}Проверка готовности ThingsBoard...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d '{"username":"admin@thingsboard.org","password":"admin"}' > /dev/null 2>&1; then
        echo -e "${GREEN}✓ ThingsBoard готов${NC}"
        break
    fi
    
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗ ThingsBoard не готов после 30 попыток${NC}"
        exit 1
    fi
    
    echo "Попытка $i/30..."
    sleep 2
done

# Get admin token
echo -e "${YELLOW}Получение токена администратора...${NC}"
ADMIN_TOKEN=$(curl -s http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin@thingsboard.org","password":"admin"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ]; then
    echo -e "${RED}✗ Не удалось получить токен${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Токен получен${NC}"

# Get tenant token
echo -e "${YELLOW}Получение токена тенанта...${NC}"
TENANT_TOKEN=$(curl -s http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"tenant@thingsboard.org","password":"tenant"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)

echo -e "${GREEN}✓ Готово${NC}"

# Create device type
echo -e "${YELLOW}Создание типа устройства 'waterMeter'...${NC}"
curl -s -X POST http://localhost:8080/api/tenant/deviceProfile \
  -H "Authorization: Bearer $TENANT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Meter",
    "type": "DEFAULT",
    "transportType": "DEFAULT",
    "profileData": {
      "configuration": {},
      "alarmRules": {},
      "provisionType": "ALLOW_CREATE_NEW_DEVICES",
      "provisionDeviceSecret": null
    }
  }' > /dev/null 2>&1

echo -e "${GREEN}✓ Тип устройства создан${NC}"

# Create sample device
echo -e "${YELLOW}Создание примера устройства...${NC}"
DEVICE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/tenant/devices \
  -H "Authorization: Bearer $TENANT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Meter Demo",
    "type": "waterMeter",
    "label": "Демонстрационный счетчик",
    "additionalInfo": {
      "description": "Демонстрационное устройство для тестирования",
      "location": "Building A, Floor 1"
    }
  }')

echo -e "${GREEN}✓ Устройство создано${NC}"

# Get device credentials
echo -e "${YELLOW}Получение учетных данных устройства...${NC}"
DEVICE_ID=$(echo $DEVICE_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}✗ Не удалось получить ID устройства${NC}"
    echo "Ответ: $DEVICE_RESPONSE"
    exit 1
fi

# Get device token
DEVICE_CREDS=$(curl -s -X GET "http://localhost:8080/api/tenant/devices/$DEVICE_ID/credentials" \
  -H "Authorization: Bearer $TENANT_TOKEN")

DEVICE_TOKEN=$(echo $DEVICE_CREDS | grep -o '"credentialsValue":"[^"]*' | cut -d'"' -f4)

echo -e "${GREEN}✓ Учетные данные получены${NC}"

# Display information
echo -e "\n${GREEN}=== Инициализация завершена ===${NC}\n"
echo -e "${YELLOW}Информация о системе:${NC}"
echo "ThingsBoard URL: http://localhost:8080"
echo "Admin Email: admin@thingsboard.org"
echo "Admin Password: admin"
echo ""
echo "Tenant Email: tenant@thingsboard.org"
echo "Tenant Password: tenant"
echo ""
echo -e "${YELLOW}Демонстрационное устройство:${NC}"
echo "Device ID: $DEVICE_ID"
echo "Device Name: Water Meter Demo"
echo "Device Token: $DEVICE_TOKEN"
echo ""
echo -e "${YELLOW}PostgreSQL:${NC}"
echo "Host: localhost"
echo "Port: 5432"
echo "Database: thingsboard"
echo "Username: thingsboard"
echo ""
echo "PgAdmin URL: http://localhost:5050"
echo "PgAdmin Email: admin@example.com"
echo ""

# Save configuration to file
echo -e "${YELLOW}Сохранение конфигурации в config/device-config.json...${NC}"
cat > config/device-config.json << EOF
{
  "device_id": "$DEVICE_ID",
  "device_token": "$DEVICE_TOKEN",
  "device_name": "Water Meter Demo",
  "thingsboard_url": "http://localhost:8080",
  "thingsboard_api_version": "v1",
  "admin_email": "admin@thingsboard.org",
  "tenant_email": "tenant@thingsboard.org",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo -e "${GREEN}✓ Конфигурация сохранена${NC}"

echo -e "\n${GREEN}✓ Все готово к использованию!${NC}\n"
echo -e "${YELLOW}Следующие шаги:${NC}"
echo "1. Откройте http://localhost:8080 в браузере"
echo "2. Войдите с помощью tenant@thingsboard.org / tenant"
echo "3. Посетите: Devices -> Water Meter Demo"
echo "4. Используйте Device Token для отправки данных"
echo ""
echo -e "${YELLOW}Отправка тестовых данных:${NC}"
echo "curl -X POST http://localhost:8080/api/v1/$DEVICE_TOKEN/telemetry \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"ts\": '$(date +%s)'000, \"values\": {\"water_volume\": 123.45, \"flow_rate\": 2.5}}'"
echo ""
