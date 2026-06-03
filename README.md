# 💧 NB-IoT Smart Water Meter Platform

Полная платформа для управления и мониторинга счетчиков воды с использованием технологии NB-IoT и ThingsBoard.

## 📋 Описание

Эта платформа позволяет:
- 📊 Собирать данные со счетчиков воды в реальном времени
- 📈 Анализировать потребление воды
- 🚨 Получать оповещения об утечках и аномалиях
- 📱 Просматривать данные через веб-интерфейс
- 🔌 Интегрировать с внешними системами через REST API

## 🏗️ Архитектура

```
┌─────────────────────────────────────────┐
│   NB-IoT Счетчики Воды (Устройства)    │
│  (STM32/ESP32 + Quectel BC65/BC92)      │
└────────────┬────────────────────────────┘
             │ HTTP/MQTT/CoAP
             ↓
┌─────────────────────────────────────────┐
│    ThingsBoard IoT Platform             │
│  (Backend, API, Processing)             │
└────────────┬────────────────────────────┘
             │
      ┌──────┴──────┬──────────┐
      ↓             ↓          ↓
  PostgreSQL   Дашбоард    REST API
```

## 🚀 Быстрый старт

### Предварительные требования
- Docker и Docker Compose
- Git
- curl или Postman (для тестирования API)

### Установка и запуск

1. **Клонируйте репозиторий**
   ```bash
   git clone https://github.com/infosantehtat-lgtm/water-meter-nbiot.git
   cd water-meter-nbiot
   ```

2. **Запустите Docker Compose**
   ```bash
   docker-compose up -d
   ```

3. **Доступ к платформе**
   - ThingsBoard: http://localhost:8080
   - Логин: tenant@thingsboard.org
   - Пароль: tenant

4. **Запустите инициализацию**
   ```bash
   bash scripts/init-setup.sh
   ```

## 📁 Структура проекта

```
water-meter-nbiot/
├── docker-compose.yml           # Docker конфигурация
├── .env                         # Переменные окружения
├── README.md                    # Документация
├── docs/
│   ├── INSTALLATION.md          # Инструкция установки
│   ├── API.md                   # API документация
│   ├── NB-IOT-SETUP.md          # Настройка NB-IoT
│   └── TROUBLESHOOTING.md       # Решение проблем
├── scripts/
│   ├── init-setup.sh            # Инициализация
│   ├── backup.sh                # Резервная копия БД
│   └── restore.sh               # Восстановление БД
├── config/
│   ├── thingsboard/
│   │   ├── thingsboard.yml      # Конфигурация TB
│   │   └── docker.env           # Переменные TB
│   └── postgres/
│       └── init.sql             # Инициализация БД
├── devices/
│   ├── firmware/
│   │   ├── water-meter.ino      # Arduino код
│   │   └── water-meter.c        # STM32 код
│   └── examples/
│       ├── device-config.json   # Конфиг устройства
│       └── data-format.json     # Формат данных
└── api/
    ├── postman/
    │   └── collection.json      # Postman коллекция
    └── examples/
        ├── send-telemetry.sh    # Отправка данных
        └── create-device.sh     # Создание устройства
```

## 🔧 Основные компоненты

### ThingsBoard
- Платформа IoT для управления устройствами
- Веб-интерфейс для мониторинга
- REST API для интеграции
- Правила обработки данных
- Визуализация данных

### PostgreSQL
- База данных для хранения данных
- Исторические данные
- Метрики и статистика

### Устройства (NB-IoT)
- Счетчики воды с модулями NB-IoT
- Отправка показаний каждые 15 минут
- Поддержка протоколов: HTTP, MQTT, CoAP

## 📊 Использование

### 1. Добавление устройства

```bash
curl -X POST http://localhost:8080/api/device \
  -H "Content-Type: application/json" \
  -d @devices/examples/device-config.json
```

### 2. Отправка данных со счетчика

```bash
curl -X POST http://localhost:8080/api/v1/{deviceToken}/telemetry \
  -H "Content-Type: application/json" \
  -d '{"ts": 1633024800000, "values": {"water_volume": 1234.5}}'
```

### 3. Получение данных

```bash
curl -X GET http://localhost:8080/api/plugins/telemetry/DEVICE/{deviceId}/values/timeseries
```

## 🚨 Настройка алертов

### Утечка воды
Алерт срабатывает при превышении 50 л/мин

### Отключение устройства
Алерт срабатывает при отсутствии данных более 1 часа

### Превышение нормы
Алерт при превышении суточной нормы потребления

## 📱 NB-IoT Интеграция

### Поддерживаемые модули
- Quectel BC65-G
- Quectel BC92
- SIM7000
- u-blox SARA-N

### Операторы
- МегаФон
- МТС
- Beeline
- YOTA

Детальную информацию см. в `docs/NB-IOT-SETUP.md`

## 🔐 Безопасность

- HTTPS/TLS для всех коммуникаций
- Аутентификация по токенам
- Шифрование пароля в базе данных
- Резервные копии данных

## 📈 Масштабируемость

- Поддержка тысяч устройств
- Horizontal scaling через Docker Swarm или Kubernetes
- Распределенная база данных
- Кэширование данных Redis

## 🤝 Контрибьютинг

Мы приветствуем вклад в проект! Пожалуйста:
1. Форкните репозиторий
2. Создайте feature branch
3. Отправьте Pull Request

## 📞 Поддержка

- GitHub Issues: Для баг репортов и фич реквестов
- Email: support@example.com
- Документация: `/docs`

## 📄 Лицензия

MIT License - смотрите файл LICENSE

## 🎯 Дорожная карта

- [ ] Поддержка LoRaWAN
- [ ] Мобильное приложение
- [ ] Предсказание потребления ML
- [ ] Интеграция с системами учета
- [ ] Многоязычная поддержка
- [ ] SMS уведомления

---

**Создано с ❤️ для умного управления водой**
