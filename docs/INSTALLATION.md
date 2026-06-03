# 🔧 Инструкция по установке

## Предварительные требования

### Системные требования
- **ОС**: Linux (Ubuntu 20.04+), macOS, или Windows (с WSL2)
- **Docker**: версия 20.10+
- **Docker Compose**: версия 1.29+
- **RAM**: минимум 4GB
- **CPU**: минимум 2 ядра
- **Место на диске**: минимум 20GB

### Установка Docker

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker
```

#### macOS
```bash
brew install docker docker-compose
```

#### Windows (с WSL2)
```bash
wsl --install
# Установите Docker Desktop для Windows
```

## Установка проекта

### 1. Клонирование репозитория

```bash
git clone https://github.com/infosantehtat-lgtm/water-meter-nbiot.git
cd water-meter-nbiot
```

### 2. Настройка переменных окружения

```bash
# Скопируйте файл .env
cp .env.example .env

# Отредактируйте .env под ваши нужды
nano .env
```

**Важные переменные:**
- `TB_POSTGRES_PASSWORD` - пароль PostgreSQL
- `TB_ADMIN_PASSWORD` - пароль администратора ThingsBoard
- `TB_TENANT_PASSWORD` - пароль тенанта

### 3. Запуск Docker Compose

```bash
# Запустите все сервисы
docker-compose up -d

# Проверьте статус
docker-compose ps
```

### 4. Инициализация системы

```bash
# Дождитесь готовности ThingsBoard (1-2 минуты)
sleep 30

# Запустите скрипт инициализации
bash scripts/init-setup.sh
```

## Доступ к системе

### ThingsBoard
- **URL**: http://localhost:8080
- **Логин**: tenant@thingsboard.org
- **Пароль**: tenant

### PostgreSQL (pgAdmin)
- **URL**: http://localhost:5050
- **Email**: admin@example.com
- **Пароль**: admin

### API Endpoints
- **HTTP**: http://localhost:8080/api
- **MQTT**: localhost:1883
- **CoAP**: localhost:5683

## Проверка установки

### 1. Проверьте контейнеры

```bash
# Все контейнеры должны быть в статусе "Up"
docker-compose ps
```

### 2. Проверьте логи

```bash
# Логи ThingsBoard
docker-compose logs thingsboard

# Логи PostgreSQL
docker-compose logs postgres
```

### 3. Тест API

```bash
# Получите токен
TOKEN=$(curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"tenant@thingsboard.org","password":"tenant"}' \
  | jq -r '.token')

echo "Token: $TOKEN"

# Получите список устройств
curl -X GET http://localhost:8080/api/tenant/devices \
  -H "Authorization: Bearer $TOKEN"
```

## Настройка основных параметров

### 1. Создание типа устройства

```bash
bash scripts/create-device-type.sh
```

### 2. Добавление первого устройства

```bash
bash api/examples/create-device.sh "Water Meter 01"
```

### 3. Создание дашборда

В интерфейсе ThingsBoard:
1. Перейдите в "Dashboards"
2. Нажмите "+ Create new dashboard"
3. Загрузите конфиг: `config/dashboards/water-meter-dashboard.json`

## Резервные копии

### Создание резервной копии

```bash
bash scripts/backup.sh
```

### Восстановление из резервной копии

```bash
bash scripts/restore.sh /path/to/backup.sql
```

## Остановка и удаление

### Остановка сервисов

```bash
docker-compose down
```

### Полное удаление (включая данные)

```bash
docker-compose down -v
```

## Решение проблем

### Порты уже используются

```bash
# Смените порты в docker-compose.yml
# Или освободите занятые порты:
sudo lsof -i :8080
sudo kill -9 <PID>
```

### ThingsBoard не стартует

```bash
# Проверьте логи
docker-compose logs thingsboard | tail -50

# Перезагрузите контейнер
docker-compose restart thingsboard
```

### PostgreSQL не подключается

```bash
# Убедитесь, что PostgreSQL запущен
docker-compose ps postgres

# Проверьте пароль в .env
# Перезагрузите PostgreSQL
docker-compose restart postgres
```

## Обновление

### Обновление ThingsBoard

```bash
# Обновите image
docker-compose pull

# Перезагрузите
docker-compose down
docker-compose up -d
```

## Дальнейшие действия

1. Изучите [документацию API](./API.md)
2. Настройте [NB-IoT интеграцию](./NB-IOT-SETUP.md)
3. Создайте первые устройства
4. Загрузите дашбоарды
5. Настройте правила обработки данных

---

📚 Больше информации в [официальной документации ThingsBoard](https://thingsboard.io/docs/)
