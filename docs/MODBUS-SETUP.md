# 🌡️ Настройка RS485 Modbus RTU интеграции

## Введение

RS485 Modbus RTU - это проводной промышленный протокол для связи с приборами измерения, контроля и управления. Идеально подходит для счетчиков тепла, энергии, давления и других приборов.

Эта интеграция позволяет:
- 📡 Собирать данные со счетчиков тепла через RS485
- ⚡ Поддерживать несколько Modbus устройств на одной линии
- 🔄 Преобразовывать Modbus RTU → JSON → ThingsBoard
- 📊 Интегрировать с NB-IoT и LoRaWAN счетчиками
- 💾 Хранить исторические данные

## Архитектура RS485 Modbus RTU системы

```
┌────────────────────���────────────────────────────────────────────┐
│  RS485 Modbus RTU Счетчики тепла (адреса 1-32)                 │
│  - Счетчик 1 (адрес 1): Энергия, расход, температура          │
│  - Счетчик 2 (адрес 2): Энергия, расход, температура          │
│  - Счетчик N (адрес N): Энергия, расход, температура          │
└───────────────────┬──────────────────────────────────────────────┘
                    │ RS485 (120 Ом кабель, витая пара)
                    │
┌───────────────────┴──────────────────────────────────────────────┐
│  Modbus RTU Master                                              │
│  (Raspberry Pi/PC + USB-RS485 адаптер)                         │
│  - Python Modbus Client                                        │
│  - Чтение регистров каждые 30 сек                             │
└───────────────────┬──────────────────────────────────────────────┘
                    │ HTTP/MQTT
                    ▼
┌─────────────────────────────────────────────────────────────────┐
│  Modbus Bridge Service                                         │
│  (Преобразование Modbus RTU → ThingsBoard API)                │
└───────────────────┬──────────────────────────────────────────────┘
                    │ HTTP API
                    ▼
┌─────────────────────────────────────────────────────────────────┐
│  ThingsBoard IoT Platform                                      │
│  - Device Management                                           │
│  - Data Collection & Processing                               │
│  - Visualization & Rules                                      │
└───────────────────┬──────────────────────────────────────────────┘
                    │
         ┌──────────┼──────────┐
         ▼          ▼          ▼
    Dashboard   API     Rules Engine
```

## Поддерживаемые счетчики тепла

### 1. ВЗЛЁТ ТЕПЛОСЧЁТЧИК (Россия) ✅
```
Модель: ТМВ-2, ТМВ-3, ТМВ-4M
Протокол: Modbus RTU
Адреса регистров:
  - 0x0000: Энергия (kWh) - 4 байта
  - 0x0002: Расход (m³/h) - 4 байта
  - 0x0004: Температура подачи (°C) - 2 байта
  - 0x0005: Температура обратно (°C) - 2 байта
Скорость: 9600 baud
Проверка: CRC-16
Документация: https://vzt.su/
```

### 2. СЧЁТЧИК ТЕПЛА ГРУППА ИВЦ
```
Модель: ИВЦ-3, ИВЦ-4, ИВЦ-5
Протокол: Modbus RTU
Адреса регистров:
  - 0x0000: Объём (m³) - 4 байта
  - 0x0002: Энергия (Gcal) - 4 байта
  - 0x0004: Масса (t) - 4 байта
  - 0x0006: Мощность (kW) - 4 байта
Скорость: 9600 baud (по умолчанию)
Документация: https://www.ivc-info.ru/
```

### 3. МЕГАЛОГ ТЕПЛОСЧЁТЧИК
```
Модель: МЕГАЛОГ-100, МЕГАЛОГ-110
Протокол: Modbus RTU
Адреса регистров:
  - 0x0000: Энергия (MJ) - 4 байта
  - 0x0002: Расход (kg/h) - 4 байта
  - 0x0004: Температура 1 (°C) - 2 байта
  - 0x0005: Температура 2 (°C) - 2 байта
Скорость: 9600/19200 baud
Документация: https://megalog.com/
```

### 4. УЛЬТРАСОНИК (Европа)
```
Модель: UH50, UH30, UH25
Протокол: Modbus RTU
Адреса регистров:
  - 0x0000: Объём (m³) - 4 байта
  - 0x0002: Энергия (MWh) - 4 байта
  - 0x0004: Расход (m³/h) - 4 байта
  - 0x0006: Температура подачи (°C) - 2 байта
Скорость: 19200 baud
Документация: https://www.ultrasonik.de/
```

### 5. SONTEX (Швейцария)
```
Модель: Sontex 531, Sontex 545
Протокол: Modbus RTU
Адреса регистров:
  - 0x0000: Объём (m³) - 4 байта
  - 0x0002: Энергия (MWh) - 4 байта
  - 0x0004: Масса (t) - 4 байта
Скорость: 9600/19200 baud
Документация: https://www.sontex.ch/
```

## Оборудование

### RS485 Адаптеры

#### USB-RS485 адаптер (рекомендуется)
```
Модель: CH340G или FT232RL
Интерфейс: USB
Протокол: RS485
Поддержка: Windows, Linux, macOS
Цена: $3-10
Поставщики: Aliexpress, DFRobot, промышленные поставщики
Преимущества:
  - Легко подключить к компьютеру/Raspberry Pi
  - Не требует отдельного питания
  - Встроенные защиты
```

#### Industrial RS485 модуль
```
Модель: Waveshare RS485 CAN HAT
Интерфейс: GPIO (для Raspberry Pi)
Протокол: RS485 + CAN
Преимущества:
  - Встроенная изоляция
  - Профессиональный уровень
  - Защита от помех
Цена: $30-50
```

#### Cabling
```
Тип: CAT5/CAT6 (витая пара)
Сопротивление: 120 Ом для RS485
Длина: до 1200 м (в стандартных условиях)
Охрана: Экранированный кабель рекомендуется
Т��рминирование: 120 Ом резисторы на концах длинных линий
```

### Raspberry Pi конфигурация

```bash
# Установка необходимых библиотек
sudo apt-get update
sudo apt-get install -y python3-pip git

# Установка Python Modbus библиотеки
pip3 install pymodbus3 pyserial

# Проверка подключения USB
lsusb
ls -la /dev/ttyUSB*

# Проверка прав доступа
sudo usermod -a -G dialout $USER
```

## Modbus RTU Протокол

### Основные концепции

```
┌─────────────────────────────────────────────────────────────┐
│ Modbus RTU Frame                                            │
├─────────┬──────────┬──────────┬─────────────┬──────────────┤
│ Address │ Function │  Data    │ Error Check │              │
│ (1 byte)│ Code     │  (n byte)│   CRC       │              │
│ 1-247   │ 0x03/0x04 │ Registers│ (2 bytes)  │              │
└─────────┴─���────────┴──────────┴─────────────┴──────────────┘

Примеры функций:
  0x03: Read Holding Registers
  0x04: Read Input Registers
  0x06: Write Single Register
  0x10: Write Multiple Registers
```

### Пример запроса Modbus RTU

```python
# Чтение регистров энергии со счетчика (адрес 1)
request_frame = [
    0x01,           # Адрес устройства
    0x03,           # Функция: Read Holding Registers
    0x00, 0x00,     # Начальный регистр
    0x00, 0x02,     # Количество регистров
    0x??, 0x??      # CRC-16 (вычисляется)
]

# Ответ:
response_frame = [
    0x01,           # Адрес устройства (эхо)
    0x03,           # Функция (эхо)
    0x04,           # Количество байт данных
    0x00, 0x01, 0x00, 0x02,  # Значения регистров
    0x??, 0x??      # CRC-16
]
```

## Python Modbus Master

### Установка и инициализация

```python
#!/usr/bin/env python3
# modbus_master.py

from pymodbus3.client.serial import ModbusSerialClient
from pymodbus3.exceptions import ModbusException
import time
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Инициализация Modbus RTU клиента
client = ModbusSerialClient(
    method='rtu',
    port='/dev/ttyUSB0',      # COM3 на Windows
    baudrate=9600,
    bytesize=8,
    parity='N',
    stopbits=1,
    timeout=1
)

if not client.connect():
    logger.error('Не удалось подключиться к RS485')
    exit(1)

logger.info('Подключено к RS485')

# Конфигурация счетчиков
HEAT_METERS = {
    1: {
        'name': 'Heat Meter 1',
        'location': 'Building A',
        'registers': {
            'energy': {'address': 0x0000, 'count': 2},      # 4 байта
            'flow': {'address': 0x0002, 'count': 2},        # 4 байта
            'temp_supply': {'address': 0x0004, 'count': 1}, # 2 байта
            'temp_return': {'address': 0x0005, 'count': 1}  # 2 байта
        }
    },
    2: {
        'name': 'Heat Meter 2',
        'location': 'Building B',
        'registers': {
            'energy': {'address': 0x0000, 'count': 2},
            'flow': {'address': 0x0002, 'count': 2},
            'temp_supply': {'address': 0x0004, 'count': 1},
            'temp_return': {'address': 0x0005, 'count': 1}
        }
    }
}

def read_modbus_register(device_id, register_name):
    """
    Чтение значения регистра из устройства
    """
    try:
        meter = HEAT_METERS[device_id]
        reg_info = meter['registers'][register_name]
        
        # Чтение регистров
        result = client.read_holding_registers(
            address=reg_info['address'],
            count=reg_info['count'],
            unit=device_id
        )
        
        if result.isError():
            logger.error(f"Ошибка чтения {meter['name']}: {result}")
            return None
        
        # Преобразование в значение
        if reg_info['count'] == 1:
            # 16-bit значение
            value = result.registers[0]
        else:
            # 32-bit значение (два регистра)
            high = result.registers[0]
            low = result.registers[1]
            value = (high << 16) | low
        
        logger.info(f"{meter['name']} {register_name}: {value}")
        return value
    
    except Exception as e:
        logger.error(f"Ошибка: {e}")
        return None

def read_all_meters():
    """
    Чтение всех значений со всех счетчиков
    """
    data = {}
    
    for device_id, meter_info in HEAT_METERS.items():
        data[device_id] = {
            'name': meter_info['name'],
            'location': meter_info['location'],
            'timestamp': time.time(),
            'values': {}
        }
        
        for register_name in meter_info['registers']:
            value = read_modbus_register(device_id, register_name)
            data[device_id]['values'][register_name] = value
    
    return data

if __name__ == '__main__':
    # Чтение данных в бесконечном цикле
    while True:
        try:
            meters_data = read_all_meters()
            print("\n=== Данные со счетчиков ===")
            for device_id, data in meters_data.items():
                print(f"\n{data['name']} ({data['location']})")
                for key, value in data['values'].items():
                    print(f"  {key}: {value}")
            
            time.sleep(30)  # Чтение каждые 30 секунд
        
        except KeyboardInterrupt:
            logger.info('Выход...')
            break
        except Exception as e:
            logger.error(f"Ошибка цикла: {e}")
            time.sleep(5)
    
    client.close()
```

## Modbus → ThingsBoard Bridge

### Python сервис

```python
#!/usr/bin/env python3
# modbus_thingsboard_bridge.py

import json
import time
import requests
import logging
from pymodbus3.client.serial import ModbusSerialClient
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Конфигурация
MODBUS_PORT = '/dev/ttyUSB0'
MODBUS_BAUDRATE = 9600

TB_HOST = 'localhost'
TB_PORT = 8080
TB_API_VERSION = 'v1'

# Маппинг Modbus устройств на ThingsBoard токены
DEVICE_MAPPING = {
    1: {
        'name': 'Heat Meter Building A',
        'token': 'your_device_token_1',
        'address': 1,
        'registers': {
            'energy': {'address': 0x0000, 'count': 2, 'scale': 0.01},
            'flow': {'address': 0x0002, 'count': 2, 'scale': 0.01},
            'temp_supply': {'address': 0x0004, 'count': 1, 'scale': 0.1},
            'temp_return': {'address': 0x0005, 'count': 1, 'scale': 0.1}
        }
    },
    2: {
        'name': 'Heat Meter Building B',
        'token': 'your_device_token_2',
        'address': 2,
        'registers': {
            'energy': {'address': 0x0000, 'count': 2, 'scale': 0.01},
            'flow': {'address': 0x0002, 'count': 2, 'scale': 0.01},
            'temp_supply': {'address': 0x0004, 'count': 1, 'scale': 0.1},
            'temp_return': {'address': 0x0005, 'count': 1, 'scale': 0.1}
        }
    }
}

class ModbusThingsBoardBridge:
    def __init__(self):
        self.client = None
        self.connect_modbus()
    
    def connect_modbus(self):
        """Подключение к Modbus RTU"""
        try:
            self.client = ModbusSerialClient(
                method='rtu',
                port=MODBUS_PORT,
                baudrate=MODBUS_BAUDRATE,
                bytesize=8,
                parity='N',
                stopbits=1,
                timeout=1
            )
            
            if self.client.connect():
                logger.info(f'Успешно подключено к RS485: {MODBUS_PORT}')
            else:
                logger.error('Ошибка подключения к RS485')
        except Exception as e:
            logger.error(f'Ошибка подключения: {e}')
    
    def read_modbus_registers(self, device_id, register_info):
        """Чтение регистров со счетчика"""
        try:
            device = DEVICE_MAPPING[device_id]
            address = device['address']
            values = {}
            
            for reg_name, reg_config in register_info.items():
                result = self.client.read_holding_registers(
                    address=reg_config['address'],
                    count=reg_config['count'],
                    unit=address
                )
                
                if not result.isError():
                    if reg_config['count'] == 1:
                        raw_value = result.registers[0]
                    else:
                        high = result.registers[0]
                        low = result.registers[1]
                        raw_value = (high << 16) | low
                    
                    # Применить масштабирование
                    value = raw_value * reg_config['scale']
                    values[reg_name] = value
                else:
                    logger.warning(f"Ошибка чтения {reg_name} устройства {device_id}")
            
            return values
        
        except Exception as e:
            logger.error(f"Ошибка чтения регистров: {e}")
            return None
    
    def send_to_thingsboard(self, device_token, telemetry):
        """Отправка данных в ThingsBoard"""
        url = f"http://{TB_HOST}:{TB_PORT}/api/{TB_API_VERSION}/{device_token}/telemetry"
        
        try:
            response = requests.post(
                url,
                json=telemetry,
                headers={'Content-Type': 'application/json'},
                timeout=5
            )
            
            if response.status_code == 200:
                logger.info(f"Данные отправлены на ThingsBoard: {device_token}")
                return True
            else:
                logger.error(f"Ошибка отправки: {response.status_code} - {response.text}")
                return False
        
        except Exception as e:
            logger.error(f"Ошибка подключения к ThingsBoard: {e}")
            return False
    
    def collect_and_send(self):
        """Сбор данных и отправка на ThingsBoard"""
        for device_id, device_config in DEVICE_MAPPING.items():
            logger.info(f"Чтение {device_config['name']}...")
            
            # Чтение регистров
            values = self.read_modbus_registers(device_id, device_config['registers'])
            
            if values:
                # Подготовка телеметрии
                telemetry = {
                    'ts': int(time.time() * 1000),
                    'values': values
                }
                
                # Отправка на ThingsBoard
                self.send_to_thingsboard(device_config['token'], telemetry)
    
    def run(self):
        """Главный цикл"""
        logger.info("Запуск Modbus → ThingsBoard Bridge")
        
        while True:
            try:
                self.collect_and_send()
                time.sleep(30)  # Чтение каждые 30 секунд
            
            except KeyboardInterrupt:
                logger.info("Остановка...")
                break
            except Exception as e:
                logger.error(f"Ошибка: {e}")
                time.sleep(5)
        
        if self.client:
            self.client.close()

if __name__ == '__main__':
    bridge = ModbusThingsBoardBridge()
    bridge.run()
```

## Docker контейнер для Modbus Master

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Установка Python библиотек
RUN pip install \
    pymodbus3==0.4.0 \
    pyserial==3.5 \
    requests==2.31.0

# Копирование скриптов
COPY modbus_thingsboard_bridge.py /app/
COPY config.json /app/

# Запуск
CMD ["python3", "modbus_thingsboard_bridge.py"]
```

### docker-compose.yml дополнение

```yaml
modbus-master:
  image: modbus-master:latest
  container_name: modbus-master
  devices:
    - /dev/ttyUSB0:/dev/ttyUSB0  # Прямой доступ к USB портуRS485
  environment:
    MODBUS_PORT: /dev/ttyUSB0
    MODBUS_BAUDRATE: 9600
    TB_HOST: thingsboard
    TB_PORT: 8080
  depends_on:
    - thingsboard
  networks:
    - water-meter-network
  restart: unless-stopped
```

## Конфигурация счетчиков в ThingsBoard

### 1. Создание устройства

```bash
curl -X POST http://localhost:8080/api/tenant/devices \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Heat Meter Building A",
    "type": "heatMeter",
    "label": "Теплосчётчик здания А",
    "additionalInfo": {
      "description": "Счетчик тепла, протокол Modbus RTU",
      "location": "Building A",
      "protocol": "Modbus RTU",
      "address": 1,
      "baudrate": 9600
    }
  }'
```

### 2. Создание атрибутов

```bash
# Серверные атрибуты (параметры счетчика)
curl -X POST http://localhost:8080/api/tenant/devices/{deviceId}/attributes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "attribute_type": "SHARED_SCOPE",
    "key": "modbus_address",
    "value": 1
  }'

# Клиентские атрибуты (локальная конфигурация)
curl -X POST http://localhost:8080/api/tenant/devices/{deviceId}/attributes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "attribute_type": "CLIENT_SCOPE",
    "key": "poll_interval",
    "value": 30
  }'
```

## Диагностика проблем с RS485

### Пр��верка подключения

```bash
# Linux
lsusb
ls -la /dev/ttyUSB*

# Проверка скорости и параметров
stty -F /dev/ttyUSB0 9600

# Тестирование с minicom
minicom -D /dev/ttyUSB0 -b 9600
```

### Проверка Modbus коммуникации

```python
# test_modbus.py
from pymodbus3.client.serial import ModbusSerialClient

client = ModbusSerialClient(method='rtu', port='/dev/ttyUSB0', baudrate=9600)

if client.connect():
    print("✓ Подключено к RS485")
    
    # Тест чтения с адреса 1
    result = client.read_holding_registers(0, 2, unit=1)
    
    if not result.isError():
        print(f"✓ Устройство ответило: {result.registers}")
    else:
        print(f"✗ Устройство не ответило: {result}")
    
    client.close()
else:
    print("✗ Ошибка подключения к RS485")
```

### Типичные проблемы и решения

```
❌ "Permission denied /dev/ttyUSB0"
✅ sudo usermod -a -G dialout $USER
   newgrp dialout

❌ "Timeout"
✅ - Проверить провода RS485
   - Убедиться, что A/B провода подключены правильно
   - Проверить скорость (должна совпадать 9600/19200)
   - Проверить адрес устройства (от 1 до 247)

❌ "CRC error"
✅ - Проверить качество кабеля
   - Убедиться в правильном терминировании (120 Ом)
   - Переподключить провода
   - Проверить электромагнитные помехи

❌ "No device at address X"
✅ - Проверить адрес устройства на счетчике
   - Убедиться, что счетчик включен
   - Проверить скорость передачи данных
   - Перезагрузить счетчик
```

## Интеграция Modbus + NB-IoT + LoRaWAN

### Единая платформа

```
┌──────────────────┐
│  RS485 Modbus    │
│  Счетчики тепла  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  Modbus Bridge   │      │  NB-IoT Gateway  │      │  LoRaWAN GW      │
└────────┬─────────┘      └────────┬─────────┘      └────────┬─────────┘
         │                         │                         │
         └─────────────────────────┼─────────────────────────┘
                                   │
                                   ▼
                          ┌──────────────────┐
                          │   ThingsBoard    │
                          │  (Единая БД)     │
                          └────────┬─────────┘
                                   │
                          ┌────────┴────────┐
                          ▼                 ▼
                    Dashboard          Rules Engine
```

### Пример правила обработки

```javascript
// Rule: Alert if heat consumption is abnormal

if (msg.data.energy > 5000 && msg.data.temp_supply < 10) {
    // Отправить оповещение
    send_notification(
        'Anomaly',
        'Heat meter abnormal reading: ' + msg.data.energy + ' kWh'
    );
    
    // Логировать событие
    log_event('heat_meter_anomaly', msg.data);
}
```

## Масштабирование

### Несколько Modbus линий

```python
# Для больших систем с несколькими RS485 линиями

MODBUS_DEVICES = {
    '/dev/ttyUSB0': {
        'name': 'Floor 1-5 Heat Meters',
        'baudrate': 9600,
        'devices': [1, 2, 3, 4, 5]
    },
    '/dev/ttyUSB1': {
        'name': 'Floor 6-10 Heat Meters',
        'baudrate': 9600,
        'devices': [1, 2, 3, 4, 5]
    },
    '/dev/ttyUSB2': {
        'name': 'Water & Energy Meters',
        'baudrate': 19200,
        'devices': [10, 20, 30]
    }
}
```

## Безопасность

### Best Practices

1. **Изоляция Modbus сети**
   - Использовать отдельный USB адаптер
   - Экранированные кабели
   - 120 Ом терминирующие резисторы

2. **Защита данных**
   - HTTPS для ThingsBoard
   - Шифрование токенов
   - Ограничение доступа к /dev/ttyUSB*

3. **Мониторинг**
   - Логирование всех ошибок
   - Оповещения при потере связи
   - Резервное копирование конфигурации

4. **Резервная система**
   - Батарейный ИБП
   - Дублирующее оборудование
   - Автоматическое переключение

## Примеры команд

### Проверка связи

```bash
# Запуск тестового скрипта
python3 test_modbus.py

# Проверка логов
tail -f /var/log/modbus_bridge.log

# Проверка статуса контейнера
docker-compose ps
docker-compose logs modbus-master
```

### Получение данных

```bash
# Получить последние значения
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries

# Получить историю за день
START=$(date -d "1 day ago" +%s)000
END=$(date +%s)000
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries?startTs=$START&endTs=$END&limit=1000"
```

---

🌡️ **RS485 Modbus RTU полностью интегрирован в вашу платформу!**

**Теперь вы можете использовать:**
- ✅ Счетчики тепла (RS485 Modbus RTU)
- ✅ Счетчики воды (NB-IoT)
- ✅ Счетчики воды (LoRaWAN)
- ✅ **Все в одной платформе ThingsBoard!**

📚 [Более подробная документация Modbus](https://modbus.org/)
