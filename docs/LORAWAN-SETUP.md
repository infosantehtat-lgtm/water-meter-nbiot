# 📡 Настройка LoRaWAN интеграции

## Введение

LoRaWAN (Long Range Wide Area Network) - это технология для IoT устройств с низким энергопотреблением и большим радиусом действия.

Эта интеграция по��воляет:
- 📡 Использовать LoRaWAN сетевые серверы
- 🔄 Получать данные через ChirpStack/TTN
- ⚡ Низкое энергопотребление
- 🌐 Большой радиус действия (до 15 км)
- 💰 Низкая стоимость оборудования

## Архитектура LoRaWAN системы

```
┌─────────────────────────────────────────────────────────────────┐
│    LoRaWAN Счетчики воды (STM32 + SX1276 LoRa модуль)          │
│  - Датчик объема                                               │
│  - Датчик давления (опционально)                               │
│  - LoRa модуль (SX1276/SX1278)                                  │
│  - Li-ion батарея (7-10 лет)                                   │
└──────────────────────────────┬──────────────────────────────────┘
                               │ LoRaWAN
                               │
         ┌────��────────────────┼─────────────────────┐
         │                     │                     │
    ┌────▼──┐            ┌────▼──┐            ┌────▼──┐
    │Gateway│            │Gateway│            │Gateway│
    │  1    │            │  2    │            │  3    │
    └────┬──┘            └────┬──┘            └────┬──┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────────┐
         │  LoRaWAN Network Server                │
         │  (ChirpStack / The Things Network)     │
         │  - Device management                   │
         │  - Routing & Forwarding                │
         └────────────────┬───────────────────────┘
                          │ MQTT/HTTP
                          ▼
         ┌────────────────────────────────────────┐
         │   Integration Layer                    │
         │   (MQTT Adapter / HTTP Bridge)         │
         └────────────┬───────────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────────┐
         │    ThingsBoard IoT Platform            │
         │    - Device Management                 │
         │    - Data Collection & Processing      │
         │    - Visualization                     │
         └────────────────────────────────────────┘
```

## Поддерживаемые сетевые серверы

### 1. ChirpStack (рекомендуется)
```
Описание: Open-source LoRaWAN Network Server
Поддержка: Полная
Делоровка: Легко развертывается на Docker
Списывается на: Европа, Азия, Америка
До��ументация: https://www.chirpstack.io/
```

**Преимущества:**
- Open-source
- Полный контроль
- Легко интегрируется
- Хороший REST API
- MQTT поддержка

### 2. The Things Network (TTN)
```
Описание: Public LoRaWAN Network
Поддержка: Частичная (через интеграцию)
Делоровка: Cloud-based
Покрытие: Глобальное
Документация: https://www.thethingsnetwork.org/
```

**Преимущества:**
- Бесплатно
- Глобальная сеть
- Управление через веб-портал
- MQTT и HTTP интеграция

### 3. Chirpstack Cloud
```
Описание: Managed ChirpStack
Поддержка: Полная
Делоровка: SaaS
Списывается на: Все регионы
Документация: https://chirpstack.io/cloud/
```

**Преимущества:**
- Управляемое решение
- Не требует развертывания
- Высокая надежность
- Professional поддержка

## Оборудование

### LoRa модули

#### SX1276 (RFM95)
```
Частота: 868 MHz (EU), 915 MHz (US)
Дальность: ~15 км (line-of-sight)
Потребление: 120 mA (TX), 10 mA (RX), 2 µA (Sleep)
Cena: $5-10
Поставщики: Aliexpress, Ebay, DFRobot
```

#### SX1278 (RFM98)
```
Частота: 433 MHz, 470 MHz
Дальность: ~10 км
Потребление: 100 mA (TX), 15 mA (RX)
Cena: $3-8
Поставщики: Aliexpress, локальные
```

#### RAK3172
```
Частота: Multi-band
Дальность: ~20 км
Потребление: 2.9 µA (Deep Sleep)
Cena: $20-30
Поставщики: RAK, распространители
Особенность: Встроенный LoRa, очень низкое потребление
```

### Микроконтроллеры

#### STM32L476
```
Процессор: ARM Cortex-M4
Flash: 1 MB
RAM: 128 KB
Потребление: <1 µA (Stop mode)
Cena: $5-10
Документация: https://www.st.com/en/microcontrollers/stm32l476.html
```

#### STM32WL (рекомендуется для LoRaWAN)
```
Процессор: ARM Cortex-M4 + Cortex-M0+
Flash: 256 KB
RAM: 64 KB
Встроенный: LoRa трансивер
Потребление: 2.1 µA (Deep Sleep)
Cena: $10-15
Особенность: Встроенный LoRa - не нужен отдельный модуль
Документация: https://www.st.com/en/microcontrollers/stm32wl.html
```

#### Arduino MKR WAN 1300
```
Процессор: SAMD21
Microcontroller LoRa module: Murata
Потребление: Low
От Arduino: Официальная поддержка
Cena: $50-70
Особенность: Arduino-совместимый, встроенный LoRa
Документация: https://store.arduino.cc/
```

## LoRaWAN Частоты и регионы

### Европа (868 MHz - EU868)
```
Оперирующие каналы: 8-3 (по умолчанию)
- CH0: 868.1 MHz
- CH1: 868.3 MHz
- CH2: 868.5 MHz
+ динамическое добавление каналов
Полоса пропускания: 125 kHz, 250 kHz
Мощность передачи: 14 dBm (25 mW)
Дежурное время: 10 ms
Деты: https://lora-alliance.org/
```

### США/Канада (915 MHz - US915)
```
Оперирующие каналы: 64 + 8
- Главный band: 902-928 MHz
- Uplink: 64 каналов 125 kHz + 8 каналов 500 kHz
- Downlink: 8 каналов 500 kHz
Полоса пропускания: 125 kHz, 250 kHz, 500 kHz
Мощность передачи: 30 dBm (1000 mW)
```

### Россия и СНГ
```
Частота: Зависит от оператора
МегаФон: 868 MHz (EU868 стандарт)
МТС: 868 MHz (EU868 стандарт)
Beeline: 868 MHz (EU868 стандарт)
Документация: Уточните у оператора
```

## Развертывание ChirpStack (локально)

### Шаг 1: Добавить ChirpStack в docker-compose.yml

```yaml
chirpstack-postgres:
  image: postgres:15-alpine
  environment:
    POSTGRES_DB: chirpstack
    POSTGRES_USER: chirpstack
    POSTGRES_PASSWORD: chirpstack_password
  volumes:
    - chirpstack_postgres_data:/var/lib/postgresql/data
  networks:
    - water-meter-network

chirpstack-redis:
  image: redis:7-alpine
  volumes:
    - chirpstack_redis_data:/data
  networks:
    - water-meter-network

chirpstack:
  image: chirpstack/chirpstack:4-latest
  ports:
    - "8081:8080"
    - "1700:1700/udp"
  environment:
    CHIRPSTACK_DATABASE__URL: postgresql://chirpstack:chirpstack_password@chirpstack-postgres/chirpstack
    CHIRPSTACK_REDIS__URL: redis://chirpstack-redis:6379
    CHIRPSTACK_REGION: EU868
  depends_on:
    - chirpstack-postgres
    - chirpstack-redis
  volumes:
    - ./config/chirpstack/chirpstack.toml:/etc/chirpstack/chirpstack.toml
  networks:
    - water-meter-network

chirpstack-gateway-bridge:
  image: chirpstack/chirpstack-gateway-bridge:4-latest
  ports:
    - "1700:1700/udp"
  environment:
    CHIRPSTACK_GATEWAY_BRIDGE_BACKEND__TYPE: mqtt
    CHIRPSTACK_GATEWAY_BRIDGE_INTEGRATION__MQTT__AUTH__GENERIC__USERNAME: guest
    CHIRPSTACK_GATEWAY_BRIDGE_INTEGRATION__MQTT__AUTH__GENERIC__PASSWORD: guest
  depends_on:
    - chirpstack
  networks:
    - water-meter-network
```

### Шаг 2: Конфигурация ChirpStack

```toml
# config/chirpstack/chirpstack.toml
[general]
log_level="info"
log_format="json"

[database]
# PostgreSQL connection string
dsn="postgresql://chirpstack:chirpstack_password@chirpstack-postgres/chirpstack"
# Automatically apply database migrations.
auto_migrate=true

[redis]
# Redis connection string.
url="redis://chirpstack-redis:6379"

[network]
# Network identifier (NetID). This must be set to the same value as used by the
# LoRa Server instance. (default: 000000)
net_id="000000"

# Time to wait for uplink de-duplication.
dedup_timeout="200ms"

# Regional configuration.
region="EU868"

[api]
# ip:port to bind the API interface to.
bind="0.0.0.0:8080"

# JWT secret used for API authentication / authorization.
jwt_secret="you-must-change-this"

[integration]
# Enabled integrations.
enabled=["mqtt"]

[[integration.mqtt]]
# Event topic template.
event_topic_template="eu868/events/{{ .ApplicationName }}/{{ .DeviceName }}/{{ .EventType }}"

# Command topic template.
command_topic_template="eu868/commands/{{ .ApplicationName }}/{{ .DeviceName }}/{{ .CommandType }}"

# MQTT broker address.
broker="mqtt://mosquitto:1883"
```

## Прошивка устройства (Arduino)

### Пример для SX1276 + STM32L476

```cpp
#include <lmic.h>
#include <hal/hal.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_BMP280.h>

// LoRaWAN Credentials (сохраняйте в безопасном месте)
// IMPORTANT: This key should be in big-endian format, so least-significant-byte
// comes first. When copying an MSB key from ttnctl output, this means to reverse
// the bytes. For TTN issued keys, the APPKEY is stored in big endian, so you need
// to reverse it as well, but it is done automatically on decoding.
static const u1_t PROGMEM APPKEY[16] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };

// LoRaWAN NwkSKey, application session key and device address.
// (Это значения TTN/ChirpStack - замените на свои)
static const u1_t PROGMEM NWKSKEY[16] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
static const u1_t PROGMEM APPSKEY[16] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
static const u4_t DEVADDR = 0x00000000; // <-- Change this address for every node!

// Пины для LoRa модуля
const lmic_pinmap lmic_pins = {
    .nss = 8,
    .rxtx = LMIC_UNUSED_PIN,
    .rst = 4,
    .dio = {2, 3, LMIC_UNUSED_PIN},
};

// Датчики
Adafruit_BMP280 bmp280;
const int FLOW_PIN = A0;
const int VOLUME_PIN = A1;

// Переменные
float water_volume = 0;
float flow_rate = 0;
float temperature = 0;
float pressure = 0;

void onEvent (ev_t ev) {
    Serial.print(os_getTime());
    Serial.print(": ");
    switch(ev) {
        case EV_SCAN_TIMEOUT:
            Serial.println(F("EV_SCAN_TIMEOUT"));
            break;
        case EV_BEACON_FOUND:
            Serial.println(F("EV_BEACON_FOUND"));
            break;
        case EV_BEACON_MISSED:
            Serial.println(F("EV_BEACON_MISSED"));
            break;
        case EV_BEACON_TRACKED:
            Serial.println(F("EV_BEACON_TRACKED"));
            break;
        case EV_JOINING:
            Serial.println(F("EV_JOINING"));
            break;
        case EV_JOINED:
            Serial.println(F("EV_JOINED"));
            break;
        case EV_RFU1:
            Serial.println(F("EV_RFU1"));
            break;
        case EV_JOIN_FAILED:
            Serial.println(F("EV_JOIN_FAILED"));
            break;
        case EV_REJOIN_FAILED:
            Serial.println(F("EV_REJOIN_FAILED"));
            break;
        case EV_TXCOMPLETE:
            Serial.println(F("EV_TXCOMPLETE (includes waiting for RX windows)"));
            if (LMIC.txrxFlags & TXRX_ACK)
              Serial.println(F("Received ack"));
            if (LMIC.dataLen) {
              Serial.println(F("Received "));
              Serial.println(LMIC.dataLen);
              Serial.println(F(" bytes of payload"));
            }
            // Schedule next transmission
            os_setTimedCallback(&sendjob, os_getTime()+sec2osticks(600), do_send);
            break;
        case EV_LOST_TSYNC:
            Serial.println(F("EV_LOST_TSYNC"));
            break;
        case EV_RESET:
            Serial.println(F("EV_RESET"));
            break;
        case EV_RXCOMPLETE:
            Serial.println(F("EV_RXCOMPLETE"));
            break;
        case EV_LINK_DEAD:
            Serial.println(F("EV_LINK_DEAD"));
            break;
        case EV_LINK_ALIVE:
            Serial.println(F("EV_LINK_ALIVE"));
            break;
        default:
            Serial.print(F("Unknown event: "));
            Serial.println((unsigned) ev);
            break;
    }
}

void do_send(osjob_t* j) {
    // Check if there is not a current TX/RX job running
    if (LMIC.opmode & OP_TXRXPEND) {
        Serial.println(F("OP_TXRXPEND, not sending"));
        return;
    }
    
    // Read sensors
    readSensors();
    
    // Prepare uplink data
    uint8_t lpp_data[20];  // LPP format
    int lpp_index = 0;
    
    // Channel 1 - Water Volume (0x02 = analog input)
    lpp_data[lpp_index++] = 1;      // Channel
    lpp_data[lpp_index++] = 0x02;   // Type = Analog Input
    int vol_int = (int)(water_volume * 100);  // Convert to int
    lpp_data[lpp_index++] = (vol_int >> 8) & 0xFF;
    lpp_data[lpp_index++] = vol_int & 0xFF;
    
    // Channel 2 - Flow Rate
    lpp_data[lpp_index++] = 2;
    lpp_data[lpp_index++] = 0x02;
    int flow_int = (int)(flow_rate * 100);
    lpp_data[lpp_index++] = (flow_int >> 8) & 0xFF;
    lpp_data[lpp_index++] = flow_int & 0xFF;
    
    // Channel 3 - Temperature
    lpp_data[lpp_index++] = 3;
    lpp_data[lpp_index++] = 0x67;   // Type = Temperature
    int temp_int = (int)(temperature * 10);
    lpp_data[lpp_index++] = (temp_int >> 8) & 0xFF;
    lpp_data[lpp_index++] = temp_int & 0xFF;
    
    // Send it off
    LMIC_setTxData2(1, lpp_data, lpp_index, 0);
    Serial.println(F("Packet queued"));
}

void readSensors() {
    // Читаем датчик объема
    int raw_vol = analogRead(VOLUME_PIN);
    water_volume = (raw_vol / 1023.0) * 1000;  // 0-1000 литров
    
    // Читаем датчик расхода
    int raw_flow = analogRead(FLOW_PIN);
    flow_rate = (raw_flow / 1023.0) * 100;  // 0-100 л/мин
    
    // Читаем температуру и давление
    if (bmp280.begin()) {
        temperature = bmp280.readTemperature();
        pressure = bmp280.readPressure() / 100.0;  // в hPa
    }
    
    Serial.print("Volume: ");
    Serial.print(water_volume);
    Serial.print(" L, Flow: ");
    Serial.print(flow_rate);
    Serial.print(" L/min, Temp: ");
    Serial.print(temperature);
    Serial.println(" C");
}

static osjob_t sendjob;

void setup() {
    Serial.begin(115200);
    delay(100);
    Serial.println(F("Starting LoRaWAN Water Meter"));
    
    // Initialize sensors
    if (!bmp280.begin()) {
        Serial.println(F("BMP280 initialization failed"));
    }
    
    // LMIC init.
    os_init();
    
    // Reset the MAC state. Session and pending data transfers will be discarded.
    LMIC_reset();
    
    // Set static session parameters.
    LMIC_setSession (0x1, DEVADDR, (uint8_t*)NWKSKEY, (uint8_t*)APPSKEY);
    
    // Disable link-check mode and ADR, because ADR tends to complicate testing.
    LMIC_setLinkCheckMode(0);
    
    // TTN uses SF9 for its RX2 window.
    LMIC.dn2Dr = DR_SF9;
    
    // Set data rate and transmit power for uplink
    LMIC_setDrTxpow(DR_SF7, 14);
    
    // Start job
    do_send(&sendjob);
}

void loop() {
    os_runloop_once();
}
```

## Интеграция с ThingsBoard

### Вариант 1: MQTT Bridge (рекомендуется)

```python
#!/usr/bin/env python3
# lorawan_mqtt_bridge.py

import json
import paho.mqtt.client as mqtt
import requests
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ChirpStack MQTT
CHIRPSTACK_MQTT_HOST = "localhost"
CHIRPSTACK_MQTT_PORT = 1883
CHIRPSTACK_MQTT_USER = "guest"
CHIRPSTACK_MQTT_PASS = "guest"

# ThingsBoard
TB_HOST = "localhost"
TB_PORT = 8080
TB_API_VERSION = "v1"

# Device mapping: LoRaWAN DevEUI -> ThingsBoard Device Token
DEVICE_MAPPING = {
    "0102030405060708": "tb_device_token_1",
    "0908070605040302": "tb_device_token_2",
}

class LoRaWANBridge:
    def __init__(self):
        self.client = mqtt.Client()
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        
    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            logger.info("Connected to ChirpStack MQTT")
            # Subscribe to all uplink messages
            client.subscribe("eu868/events/+/+/up")
        else:
            logger.error(f"Failed to connect, return code {rc}")
    
    def on_message(self, client, userdata, msg):
        try:
            data = json.loads(msg.payload.decode())
            logger.info(f"Received message: {data}")
            
            # Extract device info
            app_name = data.get("applicationName", "")
            dev_name = data.get("deviceName", "")
            dev_eui = data.get("devEui", "")
            
            # Check if device is mapped
            if dev_eui not in DEVICE_MAPPING:
                logger.warning(f"Device {dev_eui} not mapped to ThingsBoard")
                return
            
            tb_token = DEVICE_MAPPING[dev_eui]
            
            # Parse LPP payload
            rx_info = data.get("rxInfo", [])
            tx_info = data.get("txInfo", {})
            object_json = data.get("objectJSON", {})
            
            # Prepare ThingsBoard telemetry
            telemetry = {
                "ts": int(datetime.now().timestamp() * 1000),
                "values": object_json
            }
            
            # Add RSSI and SNR
            if rx_info:
                telemetry["values"]["rssi"] = rx_info[0].get("rssi", 0)
                telemetry["values"]["snr"] = rx_info[0].get("snr", 0)
            
            # Send to ThingsBoard
            self.send_to_thingsboard(tb_token, telemetry)
            
        except Exception as e:
            logger.error(f"Error processing message: {e}")
    
    def send_to_thingsboard(self, device_token, telemetry):
        url = f"http://{TB_HOST}:{TB_PORT}/api/{TB_API_VERSION}/{device_token}/telemetry"
        
        try:
            response = requests.post(
                url,
                json=telemetry,
                headers={"Content-Type": "application/json"},
                timeout=5
            )
            
            if response.status_code == 200:
                logger.info(f"Data sent to ThingsBoard successfully")
            else:
                logger.error(f"Failed to send to ThingsBoard: {response.status_code}")
        
        except Exception as e:
            logger.error(f"Error sending to ThingsBoard: {e}")
    
    def connect(self):
        self.client.username_pw_set(CHIRPSTACK_MQTT_USER, CHIRPSTACK_MQTT_PASS)
        self.client.connect(CHIRPSTACK_MQTT_HOST, CHIRPSTACK_MQTT_PORT, 60)
        self.client.loop_forever()

if __name__ == "__main__":
    bridge = LoRaWANBridge()
    bridge.connect()
```

### Вариант 2: HTTP Integration

```javascript
// Node.js HTTP Bridge
const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

const TB_HOST = process.env.TB_HOST || 'localhost';
const TB_PORT = process.env.TB_PORT || 8080;

// Device mapping
const deviceMapping = {
  '0102030405060708': 'tb_device_token_1',
  '0908070605040302': 'tb_device_token_2',
};

app.post('/api/lorawan/uplink', async (req, res) => {
  try {
    const { devEui, objectJSON, rxInfo } = req.body;
    
    // Check if device is mapped
    if (!deviceMapping[devEui]) {
      return res.status(404).json({ error: 'Device not found' });
    }
    
    const tbToken = deviceMapping[devEui];
    const telemetry = {
      ts: Date.now(),
      values: {
        ...objectJSON,
        rssi: rxInfo?.[0]?.rssi || 0,
        snr: rxInfo?.[0]?.snr || 0,
      }
    };
    
    // Send to ThingsBoard
    const response = await axios.post(
      `http://${TB_HOST}:${TB_PORT}/api/v1/${tbToken}/telemetry`,
      telemetry,
      { headers: { 'Content-Type': 'application/json' } }
    );
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(3001, () => {
  console.log('LoRaWAN Bridge listening on port 3001');
});
```

## Создание LoRaWAN устройства в ChirpStack

### 1. Через веб-интерфейс
```
1. Перейти: http://localhost:8081
2. Войти: admin / admin
3. Организации -> Выбрать организацию
4. Приложения -> Создать приложение
   - Имя: "Water Meters LoRa"
   - Description: "LoRaWAN Water Meters"
5. Приложение -> Устройства -> Добавить устройство
   - Имя: "Water Meter 01"
   - Device EUI: 0102030405060708 (уникальный)
   - Join EUI: все нули
   - App Key: случайный ключ
```

### 2. Через API

```bash
#!/bin/bash
# create-lorawan-device.sh

API_URL="http://localhost:8081/api"
API_TOKEN="your_api_token"

# Создать приложение
APP_RESPONSE=$(curl -s -X POST $API_URL/applications \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Water Meters LoRa",
    "description": "LoRaWAN Water Meters",
    "organizationID": 1
  }')

APP_ID=$(echo $APP_RESPONSE | jq -r '.id')

echo "Application created: $APP_ID"

# Создать устройство
DEVICE_RESPONSE=$(curl -s -X POST $API_URL/devices \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Water Meter 01\",
    \"description\": \"First water meter\",
    \"applicationID\": $APP_ID,
    \"deviceEUI\": \"0102030405060708\",
    \"deviceProfileID\": \"default_profile\",
    \"skipFCntCheck\": true
  }")

echo $DEVICE_RESPONSE | jq .
```

## LPP (Cayenne Low Power Payload) формат

```cpp
// Полезный для компактной передачи данных
/*
Пример: Отправка объема, расхода и температуры

Channel 1 - Volume (Analog Input)
Type: 0x02 (2 байта, big-endian)
Масштаб: 1/100
Ранг: -32,768 to 32,767

Channel 2 - Flow Rate (Analog Input)
Type: 0x02 (2 байта)
Масштаб: 1/100

Channel 3 - Temperature
Type: 0x67 (Temperature sensor, 2 байта, signed)
Масштаб: 1/10
Ранг: -327.68 to 327.67°C
*/

struct lpp_data_t {
    uint8_t channel;  // 1 байт (1-200)
    uint8_t type;     // 1 байт (тип данных)
    // ... данные (1-8 байт)
};

// Типы данных LPP
#define LPP_DIGITAL_INPUT 0x00
#define LPP_DIGITAL_OUTPUT 0x01
#define LPP_ANALOG_INPUT 0x02
#define LPP_ANALOG_OUTPUT 0x03
#define LPP_LUMINOSITY 0x65
#define LPP_PRESENCE 0x66
#define LPP_TEMPERATURE 0x67
#define LPP_HUMIDITY 0x68
#define LPP_ACCELEROMETER 0x71
#define LPP_BAROMETRIC_PRESSURE 0x73

// Декодер для ThingsBoard (JavaScript)
var decoded = Cayenne.parse(payload);
var data = {};

for (var i = 0; i < decoded.length; i++) {
  var channel = decoded[i];
  data[channel.key] = channel.value;
}

return { data: data };
```

## Сравнение NB-IoT и LoRaWAN

| Параметр | NB-IoT | LoRaWAN |
|----------|--------|----------|
| Дальность | 1-10 км | 2-15 км |
| Пропускная способность | 250 kbps | 50 kbps |
| Задержка | 10-1000 мс | 1-10 сек |
| Потребление | 2-10 mA (idle) | <1 µA (sleep) |
| Батарея | 2-5 лет | 7-10 лет |
| Сложность | Средняя | Простая |
| Стоимость | $10-50 | $5-30 |
| Сеть | Оператор | Публичная/Private |
| Лицензия | Лицензированный спектр | Unlicensed |

## Мониторинг LoRaWAN устройств

### В ThingsBoard

```javascript
// Создать dashboard для LoRaWAN
1. Dashboards -> Create new
2. Добавить виджеты:
   - Таблица устройств
   - График потребления
   - Показатель RSSI/SNR
   - Карта с координатами
```

### Алерты

```javascript
// Настроить правила
1. Device Management -> Rule Chains
2. Создать rule: LoRaWAN Water Meter Alerts
3. Условия:
   - RSSI < -100 (потеря сигнала)
   - Нет данных > 1 часа
   - Расход > нормы
```

## Безопасность LoRaWAN

### Ключи и сертификаты

```
EUI: Extended Unique Identifier (64 бита)
  - Join EUI: Сетевой идентификатор
  - Device EUI: Уникальный ID устройства

Ключи:
  - NwkKey: Network Key (генерируется сервером)
  - AppKey: Application Key (задается при регистрации)
  - NwkSKey: Network Session Key
  - AppSKey: Application Session Key
```

### Лучшие практики

1. Храните ключи в защищенном хранилище
2. Используйте уникальные DevEUI
3. Активируйте OTAA (Over-The-Air Activation)
4. Регулярно обновляйте прошивку
5. Используйте HTTPS для интеграции

## Растояние и покрытие

```
Условия распространения сигнала:
- Open space (поле): 15 км
- Urban (город): 2-5 км
- Indoor (в помещении): 50-200 м
- Through walls: 20-50 м

Расширение покрытия:
- Установка дополнительных gateways
- Размещение антенн выше
- Использование внешних антенн
```

## Решение проблем

### Устройство не подключается
```
1. Проверить DevEUI и AppKey
2. Убедиться, что ChirpStack запущен
3. Проверить наличие LoRaWAN gateway
4. Убедиться в совпадении frequency band
```

### Высокий packet loss
```
1. Проверить уровень сигнала (RSSI)
2. Переместить gateway ближе
3. Установить внешнюю антенну
4. Уменьшить SF (Spreading Factor)
```

### Высокое потребление
```
1. Увеличить интервал отправки
2. Включить ADR (Adaptive Data Rate)
3. Использовать режим класса B/C
4. Оптимизировать размер полезной нагрузки
```

---

📡 **LoRaWAN готов к использованию!**

**Рекомендуемый путь:**
1. Развернуть ChirpStack (локально)
2. Запрограммировать первое устройство
3. Проверить передачу данных
4. Настроить интеграцию с ThingsBoard
5. Создать dashboard для мониторинга

📚 [Больше информации](https://lora-alliance.org/)
