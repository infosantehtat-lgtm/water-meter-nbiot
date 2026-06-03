#!/bin/bash
# Тестирование Modbus подключения

echo "=== Тест Modbus RTU подключения ==="
echo ""

# Проверка прав доступа
if [ ! -c /dev/ttyUSB0 ]; then
    echo "✗ USB RS485 адаптер не найден на /dev/ttyUSB0"
    echo "  Проверьте: lsusb и ls -la /dev/ttyUSB*"
    exit 1
fi

echo "✓ USB RS485 адаптер найден"

# Проверка прав
if ! [ -r /dev/ttyUSB0 ] || ! [ -w /dev/ttyUSB0 ]; then
    echo "✗ Нет прав доступа на /dev/ttyUSB0"
    echo "  Исправить: sudo usermod -a -G dialout $USER && newgrp dialout"
    exit 1
fi

echo "✓ Права доступа в порядке"

# Запуск Python тестового скрипта
python3 << 'EOF'
import sys
try:
    from pymodbus3.client.serial import ModbusSerialClient
    print("✓ Модуль pymodbus3 установлен")
except ImportError:
    print("✗ Модуль pymodbus3 не установлен")
    print("  Исправить: pip3 install pymodbus3 pyserial")
    sys.exit(1)

print("\n=== Подключение к RS485 ===")
client = ModbusSerialClient(
    method='rtu',
    port='/dev/ttyUSB0',
    baudrate=9600,
    bytesize=8,
    parity='N',
    stopbits=1,
    timeout=2
)

if client.connect():
    print("✓ Подключено к RS485")
    
    # Тест чтения с адреса 1
    print("\n=== Тест чтения устройства (адрес 1) ===")
    result = client.read_holding_registers(0, 2, unit=1)
    
    if not result.isError():
        print(f"✓ Устройство ответило")
        print(f"  Регистры: {result.registers}")
    else:
        print(f"✗ Ошибка: {result}")
        print("  Проверьте:")
        print("    - Подключены ли провода A/B")
        print("    - Совпадает ли адрес устройства")
        print("    - Совпадает ли скорость (9600 baud)")
    
    client.close()
else:
    print("✗ Ошибка подключения")
    print("  Проверьте:")
    print("    - Подключен ли адаптер USB-RS485")
    print("    - Правильный ли порт /dev/ttyUSB0")
    sys.exit(1)
EOF

echo ""
echo "✓ Тестирование завершено"
