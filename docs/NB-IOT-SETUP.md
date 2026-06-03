# 🌐 Настройка NB-IoT интеграции

## Введение

NB-IoT (Narrowband IoT) - это стандарт мобильной связи для устройств IoT, обеспечивающий:
- Низкое энергопотребление
- Широкий охват сигнала
- Низкую стоимость
- Безопасность

## Архитектура NB-IoT системы

```
┌──────────────────────────────────────────────────────────┐
│ Счетчик воды (STM32/ESP32 + NB-IoT модуль)             │
│ - Датчик объема                                         │
│ - Датчик давления                                       │
│ - NB-IoT модуль (Quectel BC65/BC92)                    │
└────────────────┬─────────────────────────────────────────┘
                 │
          NB-IoT Network
                 │
┌────────────────┴─────────────────────────────────────────┐
│ Оператор (МегаФон/МТС/Beeline/YOTA)                    │
│ - NB-IoT Core Network                                   │
│ - LTE Network Integration                               │
└────────────────┬─────────────────────────────────────────┘
                 │
          HTTP/MQTT/CoAP
                 │
┌────────────────┴─────────────────────────────────────────┐
│ ThingsBoard IoT Platform                                │
│ - Device Management                                      │
│ - Data Collection & Processing                          │
│ - Visualization                                         │
└──────────────────────────────────────────────────────────┘
```

## Аппаратное обеспечение

### Микроконтроллеры

#### STM32L476
- **Особенности**: Low-power Cortex-M4, 1MB Flash
- **Цена**: $5-10
- **Документация**: [STM32L476](https://www.st.com/en/microcontrollers-microprocessors/stm32l476.html)

#### ESP32
- **Особенности**: Dual-core, Wi-Fi + Bluetooth
- **Цена**: $3-7
- **Документация**: [ESP32](https://www.espressif.com/en/products/socs/esp32/overview)

### NB-IoT модули

#### Quectel BC65-G (рекомендуется)
```
Работает с: МТС, Beeline
Потребление: 2-5 mA (idle), 60-100 mA (TX)
Температура: -40 to +85°C
Протоколы: HTTP, MQTT, CoAP, TCP/UDP
Приложение: UART/USB
```

**Покупка**: [AliExpress](https://www.aliexpress.com/) или локальные поставщики

#### Quectel BC92
```
Работает с: МегаФон, МТС, Beeline
Потребление: 2-4 mA (idle)
Протоколы: LwM2M, HTTP, MQTT, CoAP
Особенность: встроенная SIM
```

#### SIM7000A
```
Работает с: Все операторы
Потребление: 5-10 mA (idle)
Особенность: поддержка GPS
Протоколы: HTTP, MQTT, TCP/UDP
```

## Датчики

### Датчик объема
- **Импульсный счетчик**: 1 импульс = 1 литр
- **Ультразвуковой**: A02YYUW или DS18B20
- **Индукционный**: менее точный, но долговечный

### Датчик давления (опционально)
- **Диапазон**: 0-1 MPa
- **Выход**: 4-20mA или 0-10V
- **Датчик**: BMP280 или DS18B20

## Операторы NB-IoT в России

### МегаФон
- **APN**: internet.mts.ru
- **Диапазон**: 800 MHz (B32)
- **Покрытие**: Москва, СПб, крупные города
- **Дополнительно**: [Оборудование МегаФон](https://megafon.ru/)

### МТС
- **APN**: MTS
- **Диапазон**: 700 MHz (B28), 800 MHz (B20)
- **Покрытие**: Все регионы
- **Дополнительно**: [NB-IoT МТС](https://www.mts.ru/business/iot)

### Beeline
- **APN**: beeline.internet
- **Диапазон**: 800 MHz (B20)
- **Покрытие**: Основные города
- **Дополнительно**: [IoT Beeline](https://beeline.ru/)

### YOTA (закрыта для новых клиентов)
- **APN**: internet.yota
- **Диапазон**: 700 MHz

## Прошивка устройства

### Arduino для ESP32

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// Конфигурация NB-IoT
const char* NBIOT_APN = "internet.mts.ru";
const char* NBIOT_BAND = "B20";  // 800 MHz

// ThingsBoard
const char* TB_HOST = "192.168.1.100";  // IP вашего ThingsBoard
const int TB_PORT = 8080;
const char* DEVICE_TOKEN = "YOUR_DEVICE_TOKEN";

// Пин датчика
const int SENSOR_PIN = 34;
const int FLOW_PIN = 35;

float water_volume = 0;
float flow_rate = 0;

void setup() {
    Serial.begin(115200);
    
    // Инициализация NB-IoT
    initNBIoT();
    
    // Инициализация датчиков
    pinMode(SENSOR_PIN, INPUT);
    pinMode(FLOW_PIN, INPUT);
}

void loop() {
    // Читаем датчики каждые 15 минут
    readSensors();
    
    // Отправляем данные в ThingsBoard
    sendToThingsBoard();
    
    // Спим 15 минут
    delay(900000);  // 15 * 60 * 1000
}

void initNBIoT() {
    Serial.println("Инициализация NB-IoT модуля...");
    
    // AT команды для Quectel BC65
    Serial.println("AT+CFUN=1");      // Включить модуль
    delay(1000);
    
    Serial.println("AT+CGDCONT=1,\"IP\",\"" + String(NBIOT_APN) + "\"");
    delay(1000);
    
    Serial.println("AT+CGACT=1,1");   // Активировать контекст
    delay(5000);
    
    Serial.println("AT+CGPADDR");     // Получить IP адрес
}

void readSensors() {
    // Чтение объема (кубометры)
    int raw_value = analogRead(SENSOR_PIN);
    water_volume = (raw_value / 4095.0) * 1000;  // 0-1000 л
    
    // Чтение расхода (л/мин)
    int flow_pulses = digitalRead(FLOW_PIN);
    flow_rate = flow_pulses * 0.1;  // каждый импульс = 0.1 л
    
    Serial.print("Объем: ");
    Serial.print(water_volume);
    Serial.println(" л");
    
    Serial.print("Расход: ");
    Serial.print(flow_rate);
    Serial.println(" л/мин");
}

void sendToThingsBoard() {
    if (WiFi.status() == WL_CONNECTED || isNBIoTConnected()) {
        HTTPClient http;
        
        String url = "http://" + String(TB_HOST) + ":" + String(TB_PORT) + 
                     "/api/v1/" + String(DEVICE_TOKEN) + "/telemetry";
        
        StaticJsonDocument<200> doc;
        doc["ts"] = millis();
        JsonObject values = doc.createNestedObject("values");
        values["water_volume"] = water_volume;
        values["flow_rate"] = flow_rate;
        values["temperature"] = 22.5;  // пример
        
        String json;
        serializeJson(doc, json);
        
        http.begin(url);
        http.addHeader("Content-Type", "application/json");
        
        int httpResponseCode = http.POST(json);
        
        if (httpResponseCode == 200) {
            Serial.println("Данные отправлены успешно");
        } else {
            Serial.println("Ошибка отправки: " + String(httpResponseCode));
        }
        
        http.end();
    }
}

bool isNBIoTConnected() {
    // Проверка подключения NB-IoT
    return true;  // Упрощенная проверка
}
```

### STM32 Cube IDE

```c
#include "main.h"
#include "usart.h"
#include "adc.h"
#include <stdio.h>
#include <string.h>

#define TB_IP "192.168.1.100"
#define TB_PORT 8080
#define DEVICE_TOKEN "YOUR_DEVICE_TOKEN"

void NBIOT_Init(void) {
    // AT+CFUN=1
    HAL_UART_Transmit(&huart1, (uint8_t*)"AT+CFUN=1\r\n", 12, 1000);
    HAL_Delay(1000);
    
    // Установка APN
    char apn_cmd[50];
    sprintf(apn_cmd, "AT+CGDCONT=1,\"IP\",\"internet.mts.ru\"\r\n");
    HAL_UART_Transmit(&huart1, (uint8_t*)apn_cmd, strlen(apn_cmd), 1000);
    HAL_Delay(1000);
}

void SendTelemetry(float volume, float flow) {
    char data[200];
    sprintf(data, 
            "{\"ts\":%ld,\"values\":{\"water_volume\":%.1f,\"flow_rate\":%.1f}}",
            HAL_GetTick(), volume, flow);
    
    // Отправка HTTP запроса
    char http_request[512];
    sprintf(http_request,
            "POST /api/v1/%s/telemetry HTTP/1.1\r\n"
            "Host: %s:%d\r\n"
            "Content-Type: application/json\r\n"
            "Content-Length: %d\r\n"
            "\r\n"
            "%s",
            DEVICE_TOKEN, TB_IP, TB_PORT, strlen(data), data);
    
    HAL_UART_Transmit(&huart1, (uint8_t*)http_request, strlen(http_request), 2000);
}

int main(void) {
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();
    MX_USART1_UART_Init();
    MX_ADC1_Init();
    
    NBIOT_Init();
    
    while (1) {
        uint32_t adc_value = HAL_ADC_GetValue(&hadc1);
        float volume = (adc_value / 4095.0) * 1000;
        float flow = 2.5;  // л/мин
        
        SendTelemetry(volume, flow);
        
        HAL_Delay(900000);  // 15 минут
    }
}
```

## Тестирование подключения

### AT команды для тестирования

```bash
# Проверка модуля
AT

# Информация о модуле
ATI

# Включение модуля
AT+CFUN=1

# Установка APN
AT+CGDCONT=1,"IP","internet.mts.ru"

# Активация контекста
AT+CGACT=1,1

# Получение IP адреса
AT+CGPADDR

# Уровень сигнала
AT+CSQ

# Информация о сети
AT+COPS?

# HTTP запрос (Quectel)
AT+QHTTPURL=40,80
http://thingsboard.local:8080/api/
AT+QHTTPPOST=100,80,100
{"test":"data"}
```

### Проверка через консоль

```bash
# Установка соединения с модулем
screen /dev/ttyUSB0 9600

# Linux: minicom
miinicom -D /dev/ttyUSB0 -b 9600

# Windows: PuTTY (COM1, 9600 baud)
```

## Оптимизация энергопотребления

### Режимы экономии

1. **Спящий режим (Sleep Mode)**
   - Потребление: <1 µA
   - Время пробуждения: <100 ms

2. **Глубокий спящий режим (Deep Sleep)**
   - Потребление: 0.1 µA
   - Время пробуждения: >1 s

3. **Активный режим**
   - Потребление: 60-100 mA

### Рекомендации

- Отправляйте данные каждые 15-30 минут
- Используйте режим низкой мощности между отправками
- Оптимизируйте размер передаваемых данных
- Используйте батарею 3.6-5V

## Расчет времени работы

```
Емкость батареи: 10000 mAh (5V)
Средний ток в режиме сна: 0.5 mA
Ток отправки (30 сек): 80 mA
Интервал отправки: 15 минут

Время работы = 10000 / (0.5 + (80 * 30 / (15*60))) ≈ 3 года
```

## Безопасность

### TLS/SSL

```cpp
// Использование HTTPS вместо HTTP
const char* CERTIFICATE = "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----";

HTTPClient http;
http.setInsecure();  // или загрузить сертификат
http.begin(url, CERTIFICATE);
```

### Аутентификация

- Используйте Device Tokens
- Никогда не передавайте credentials
- Ротируйте токены регулярно

## Отладка

### Логирование

```cpp
#define LOG_SERIAL Serial
#define DEBUG_LOG(msg) LOG_SERIAL.println(msg)

DEBUG_LOG("Инициализация");
DEBUG_LOG("Подключение");
DEBUG_LOG("Отправка данных");
```

### Мониторинг

```bash
# Просмотр логов ThingsBoard
docker-compose logs -f thingsboard

# Проверка PostgreSQL
docker exec water-meter-postgres psql -U thingsboard -d thingsboard -c "SELECT * FROM ts_kv;"
```

## Решение проблем

### Нет подключения к сети
1. Проверьте SIM карту
2. Проверьте APN оператора
3. Проверьте уровень сигнала (AT+CSQ)
4. Перезагрузите модуль

### Высокое энергопотребление
1. Отключите отладку
2. Используйте спящий режим
3. Увеличьте интервал отправки

### Данные не попадают на ThingsBoard
1. Проверьте Device Token
2. Проверьте URL и порт
3. Проверьте формат JSON
4. Проверьте логи ThingsBoard

---

📚 Дополнительные ссылки:
- [3GPP NB-IoT Standard](https://www.3gpp.org/)
- [Quectel BC65 Documentation](https://www.quectel.com/)
- [ThingsBoard NB-IoT Integration](https://thingsboard.io/docs/user-guide/integrations/nbiot/)
