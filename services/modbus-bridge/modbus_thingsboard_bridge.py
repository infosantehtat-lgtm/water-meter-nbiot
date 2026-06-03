#!/usr/bin/env python3
"""
Modbus RTU → ThingsBoard Bridge
Сбор данных со счетчиков тепла через RS485 и отправка на ThingsBoard
"""

import json
import time
import requests
import logging
import os
from pymodbus3.client.serial import ModbusSerialClient
from pymodbus3.exceptions import ModbusException
from datetime import datetime

# Логирование
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/modbus_bridge.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Конфигурация из переменных окружения
MODBUS_PORT = os.getenv('MODBUS_PORT', '/dev/ttyUSB0')
MODBUS_BAUDRATE = int(os.getenv('MODBUS_BAUDRATE', '9600'))
TB_HOST = os.getenv('TB_HOST', 'thingsboard')
TB_PORT = int(os.getenv('TB_PORT', '8080'))
TB_API_VERSION = os.getenv('TB_API_VERSION', 'v1')
POLL_INTERVAL = int(os.getenv('POLL_INTERVAL', '30'))

# Конфигурация устройств
DEVICE_CONFIG = {
    1: {
        'name': 'Heat Meter Building A',
        'token': 'heat_meter_1_token',
        'registers': {
            'energy': {'address': 0x0000, 'count': 2, 'scale': 0.01, 'unit': 'kWh'},
            'flow': {'address': 0x0002, 'count': 2, 'scale': 0.01, 'unit': 'm3/h'},
            'temp_supply': {'address': 0x0004, 'count': 1, 'scale': 0.1, 'unit': 'C'},
            'temp_return': {'address': 0x0005, 'count': 1, 'scale': 0.1, 'unit': 'C'}
        }
    },
    2: {
        'name': 'Heat Meter Building B',
        'token': 'heat_meter_2_token',
        'registers': {
            'energy': {'address': 0x0000, 'count': 2, 'scale': 0.01, 'unit': 'kWh'},
            'flow': {'address': 0x0002, 'count': 2, 'scale': 0.01, 'unit': 'm3/h'},
            'temp_supply': {'address': 0x0004, 'count': 1, 'scale': 0.1, 'unit': 'C'},
            'temp_return': {'address': 0x0005, 'count': 1, 'scale': 0.1, 'unit': 'C'}
        }
    }
}

class ModbusThingsBoardBridge:
    def __init__(self):
        self.client = None
        self.last_error_time = {}
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
                timeout=2
            )
            
            if self.client.connect():
                logger.info(f'✓ Успешно подключено к RS485: {MODBUS_PORT} @ {MODBUS_BAUDRATE} baud')
                return True
            else:
                logger.error(f'✗ Ошибка подключения к RS485: {MODBUS_PORT}')
                return False
        except Exception as e:
            logger.error(f'✗ Исключение при подключении: {e}')
            return False
    
    def read_modbus_registers(self, device_id):
        """Чтение регистров со счетчика"""
        try:
            if not self.client or not self.client.is_socket_open():
                if not self.connect_modbus():
                    return None
            
            device_config = DEVICE_CONFIG[device_id]
            values = {}
            
            for reg_name, reg_info in device_config['registers'].items():
                try:
                    result = self.client.read_holding_registers(
                        address=reg_info['address'],
                        count=reg_info['count'],
                        unit=device_id
                    )
                    
                    if not result.isError():
                        if reg_info['count'] == 1:
                            # 16-bit значение
                            raw_value = result.registers[0]
                        else:
                            # 32-bit значение (два регистра)
                            high = result.registers[0]
                            low = result.registers[1]
                            raw_value = (high << 16) | low
                        
                        # Применить масштабирование
                        value = raw_value * reg_info['scale']
                        values[reg_name] = value
                        logger.debug(f"Device {device_id} {reg_name}: {value} {reg_info['unit']}")
                    else:
                        logger.warning(f"Ошибка чтения {reg_name} устройства {device_id}: {result}")
                
                except ModbusException as e:
                    logger.error(f"Modbus исключение при чтении {reg_name} устройства {device_id}: {e}")
            
            return values if values else None
        
        except Exception as e:
            logger.error(f"Ошибка чтения регистров устройства {device_id}: {e}")
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
                logger.debug(f"✓ Данные отправлены на ThingsBoard: {device_token}")
                return True
            else:
                logger.error(f"✗ Ошибка отправки на ThingsBoard: {response.status_code} - {response.text}")
                return False
        
        except requests.exceptions.ConnectionError:
            logger.error(f"✗ Ошибка подключения к ThingsBoard: {TB_HOST}:{TB_PORT}")
            return False
        except Exception as e:
            logger.error(f"✗ Ошибка отправки: {e}")
            return False
    
    def collect_and_send(self):
        """Сбор данных и отправка на ThingsBoard"""
        for device_id, device_config in DEVICE_CONFIG.items():
            logger.info(f"Чтение {device_config['name']} (адрес {device_id})...")
            
            # Чтение регистров
            values = self.read_modbus_registers(device_id)
            
            if values:
                # Подготовка телеметрии
                telemetry = {
                    'ts': int(time.time() * 1000),
                    'values': values
                }
                
                # Отправка на ThingsBoard
                if self.send_to_thingsboard(device_config['token'], telemetry):
                    logger.info(f"✓ {device_config['name']}: успешно отправлено")
                else:
                    logger.warning(f"✗ {device_config['name']}: ошибка отправки")
            else:
                logger.warning(f"✗ {device_config['name']}: не удалось прочитать данные")
    
    def run(self):
        """Главный цикл"""
        logger.info("="*60)
        logger.info(f"Запуск Modbus → ThingsBoard Bridge")
        logger.info(f"RS485 Port: {MODBUS_PORT}")
        logger.info(f"ThingsBoard: {TB_HOST}:{TB_PORT}")
        logger.info(f"Poll Interval: {POLL_INTERVAL} сек")
        logger.info(f"Устройства: {len(DEVICE_CONFIG)}")
        logger.info("="*60)
        
        error_count = 0
        max_errors = 5
        
        while True:
            try:
                self.collect_and_send()
                error_count = 0  # Сброс счетчика ошибок
                time.sleep(POLL_INTERVAL)
            
            except KeyboardInterrupt:
                logger.info("Получен сигнал остановки (Ctrl+C)")
                break
            except Exception as e:
                error_count += 1
                logger.error(f"Ошибка в главном цикле ({error_count}/{max_errors}): {e}")
                
                if error_count >= max_errors:
                    logger.critical(f"Максимальное количество ошибок ({max_errors}) достигнуто. Остановка.")
                    break
                
                time.sleep(5)
        
        self.cleanup()
    
    def cleanup(self):
        """Очистка ресурсов"""
        logger.info("Закрытие соединения...")
        if self.client:
            self.client.close()
        logger.info("Modbus Bridge остановлен.")

if __name__ == '__main__':
    try:
        bridge = ModbusThingsBoardBridge()
        bridge.run()
    except Exception as e:
        logger.critical(f"Критическая ошибка: {e}")
        exit(1)
