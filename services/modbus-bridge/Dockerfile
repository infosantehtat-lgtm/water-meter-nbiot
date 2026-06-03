FROM python:3.9-slim

WORKDIR /app

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Установка Python библиотек
RUN pip install --no-cache-dir \
    pymodbus3==0.4.0 \
    pyserial==3.5 \
    requests==2.31.0

# Копирование скриптов
COPY modbus_thingsboard_bridge.py /app/

# Создание директории для логов
RUN mkdir -p /var/log && chmod 777 /var/log

# Запуск
CMD ["python3", "modbus_thingsboard_bridge.py"]
