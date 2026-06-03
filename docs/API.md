# 📡 REST API Документация

## Базовая информация

- **Base URL**: `http://localhost:8080/api`
- **Content-Type**: `application/json`
- **Authentication**: Bearer Token (JWT)

## Аутентификация

### Вход в систему

**POST** `/auth/login`

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "tenant@thingsboard.org",
    "password": "tenant"
  }'
```

**Ответ:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

### Обновление токена

**POST** `/auth/refresh`

```bash
curl -X POST http://localhost:8080/api/auth/refresh \
  -H "Authorization: Bearer <refresh_token>"
```

## Управление устройствами

### Получить все устройства

**GET** `/tenant/devices`

```bash
curl -X GET http://localhost:8080/api/tenant/devices \
  -H "Authorization: Bearer <token>"
```

**Параметры:**
- `page=0` - номер страницы (0-based)
- `pageSize=10` - размер страницы
- `sortProperty=createdTime` - поле для сортировки
- `sortOrder=DESC` - ASC или DESC

### Создать устройство

**POST** `/tenant/devices`

```bash
curl -X POST http://localhost:8080/api/tenant/devices \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Meter 01",
    "type": "waterMeter",
    "label": "Квартира 101"
  }'
```

**Ответ:**
```json
{
  "id": {
    "entityType": "DEVICE",
    "id": "d8c4c4e0-1234-5678-9abc-def012345678"
  },
  "name": "Water Meter 01",
  "type": "waterMeter",
  "createdTime": 1633024800000,
  "additionalInfo": {
    "description": "Квартира 101"
  }
}
```

### Получить информацию об устройстве

**GET** `/tenant/devices/{deviceId}`

```bash
curl -X GET http://localhost:8080/api/tenant/devices/d8c4c4e0-1234-5678-9abc-def012345678 \
  -H "Authorization: Bearer <token>"
```

### Обновить устройство

**PUT** `/tenant/devices/{deviceId}`

```bash
curl -X PUT http://localhost:8080/api/tenant/devices/d8c4c4e0-1234-5678-9abc-def012345678 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Meter 01 Updated",
    "type": "waterMeter"
  }'
```

### Удалить устройство

**DELETE** `/tenant/devices/{deviceId}`

```bash
curl -X DELETE http://localhost:8080/api/tenant/devices/d8c4c4e0-1234-5678-9abc-def012345678 \
  -H "Authorization: Bearer <token>"
```

## Телеметрия (Данные)

### Отправка данных (Device Token)

**POST** `/v1/{deviceToken}/telemetry`

```bash
curl -X POST http://localhost:8080/api/v1/YOUR_DEVICE_TOKEN/telemetry \
  -H "Content-Type: application/json" \
  -d '{
    "ts": 1633024800000,
    "values": {
      "water_volume": 1234.5,
      "flow_rate": 2.5,
      "temperature": 20.5
    }
  }'
```

### Получить последние значения

**GET** `/plugins/telemetry/DEVICE/{deviceId}/values/timeseries`

```bash
curl -X GET "http://localhost:8080/api/plugins/telemetry/DEVICE/d8c4c4e0-1234-5678-9abc-def012345678/values/timeseries?keys=water_volume,flow_rate" \
  -H "Authorization: Bearer <token>"
```

**Ответ:**
```json
{
  "water_volume": [
    {
      "ts": 1633024800000,
      "value": "1234.5"
    }
  ],
  "flow_rate": [
    {
      "ts": 1633024800000,
      "value": "2.5"
    }
  ]
}
```

### Получить историю данных

**GET** `/plugins/telemetry/DEVICE/{deviceId}/values/timeseries?startTs={start}&endTs={end}&limit=1000`

```bash
# Получить данные за последний день
START_TS=$(($(date +%s) - 86400))*1000
END_TS=$(date +%s)*1000

curl -X GET "http://localhost:8080/api/plugins/telemetry/DEVICE/d8c4c4e0-1234-5678-9abc-def012345678/values/timeseries?startTs=${START_TS}&endTs=${END_TS}&limit=1000&keys=water_volume" \
  -H "Authorization: Bearer <token>"
```

### Получить атрибуты

**GET** `/plugins/telemetry/DEVICE/{deviceId}/values/attributes?keys=model,location`

```bash
curl -X GET "http://localhost:8080/api/plugins/telemetry/DEVICE/d8c4c4e0-1234-5678-9abc-def012345678/values/attributes?keys=model,location" \
  -H "Authorization: Bearer <token>"
```

### Установить атрибуты

**POST** `/v1/{deviceToken}/attributes`

```bash
curl -X POST http://localhost:8080/api/v1/YOUR_DEVICE_TOKEN/attributes \
  -H "Content-Type: application/json" \
  -d '{
    "model": "WaterMeter-V2",
    "location": "Building A, Floor 3",
    "firmware": "1.0.1"
  }'
```

## Правила и обработка данных

### Создать правило обработки

**POST** `/ruleChains`

```bash
curl -X POST http://localhost:8080/api/ruleChains \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Meter Alert Rule",
    "firstRuleNodeId": null,
    "root": true,
    "debug": false
  }'
```

## Дашборды

### Получить все дашборды

**GET** `/tenant/dashboards`

```bash
curl -X GET http://localhost:8080/api/tenant/dashboards \
  -H "Authorization: Bearer <token>"
```

### Создать дашборд

**POST** `/tenant/dashboards`

```bash
curl -X POST http://localhost:8080/api/tenant/dashboards \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Water Meter Dashboard",
    "configuration": {"version": 0}
  }'
```

## Коды ошибок

| Код | Описание |
|-----|----------|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 500 | Internal Server Error |

## Примеры скриптов

### Python

```python
import requests
import json

BASE_URL = "http://localhost:8080/api"
username = "tenant@thingsboard.org"
password = "tenant"

# Вход
response = requests.post(f"{BASE_URL}/auth/login", json={
    "username": username,
    "password": password
})

token = response.json()["token"]
headers = {"Authorization": f"Bearer {token}"}

# Получить устройства
devices = requests.get(f"{BASE_URL}/tenant/devices", headers=headers)
print(json.dumps(devices.json(), indent=2))
```

### JavaScript (Node.js)

```javascript
const axios = require('axios');

const BASE_URL = 'http://localhost:8080/api';
const username = 'tenant@thingsboard.org';
const password = 'tenant';

const client = axios.create();

// Вход
const login = async () => {
    const response = await client.post(`${BASE_URL}/auth/login`, {
        username,
        password
    });
    return response.data.token;
};

// Получить устройства
const getDevices = async (token) => {
    const response = await client.get(`${BASE_URL}/tenant/devices`, {
        headers: { Authorization: `Bearer ${token}` }
    });
    return response.data;
};

(async () => {
    const token = await login();
    const devices = await getDevices(token);
    console.log(JSON.stringify(devices, null, 2));
})();
```

---

📚 [Полная документация ThingsBoard API](https://thingsboard.io/docs/api/)
