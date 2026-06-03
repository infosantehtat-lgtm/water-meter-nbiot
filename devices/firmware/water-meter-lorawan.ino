/*
 * LoRaWAN Water Meter Firmware
 * Compatible with: Arduino MKR WAN 1300, Arduino MKR WAN 1310
 * Libraries required:
 * - MCCI LoRaWAN LMIC library
 * - IBM LMIC framework
 * - ArduinoJson
 * - Adafruit Unified Sensor
 * - Adafruit BMP280
 */

#include <lmic.h>
#include <hal/hal.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_BMP280.h>
#include <ArduinoJson.h>

// Configuration
#define FLOW_PIN A0
#define VOLUME_PIN A1
#define SEND_INTERVAL 600  // 10 minutes in seconds

// LoRaWAN Configuration - Replace with your keys
static const u1_t PROGMEM APPKEY[16] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static const u1_t PROGMEM NWKSKEY[16] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static const u1_t PROGMEM APPSKEY[16] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static const u4_t DEVADDR = 0x00000000;

// Pin mapping for SX1276
const lmic_pinmap lmic_pins = {
    .nss = 8,
    .rxtx = LMIC_UNUSED_PIN,
    .rst = 4,
    .dio = {2, 3, LMIC_UNUSED_PIN},
};

// Global variables
float water_volume = 0.0;
float flow_rate = 0.0;
float temperature = 0.0;
float pressure = 0.0;
Adafruit_BMP280 bmp280;
static osjob_t sendjob;

void setup() {
    Serial.begin(9600);
    while (!Serial);
    
    Serial.println(F("\n\nStarting LoRaWAN Water Meter..."));
    
    // Initialize BMP280
    if (!bmp280.begin()) {
        Serial.println(F("BMP280 not found!"));
    }
    
    // Initialize LMIC
    os_init();
    LMIC_reset();
    
    // Set static session parameters
    uint8_t appskey[sizeof(APPKEY)];
    uint8_t nwkskey[sizeof(NWKSKEY)];
    memcpy_P(appskey, APPKEY, sizeof(APPKEY));
    memcpy_P(nwkskey, NWKSKEY, sizeof(NWKSKEY));
    LMIC_setSession(0x1, DEVADDR, nwkskey, appskey);
    
    // Disable link check mode
    LMIC_setLinkCheckMode(0);
    
    // Set data rate and transmit power for uplink
    LMIC_setDrTxpow(DR_SF7, 14);
    
    // Start job
    do_send(&sendjob);
}

void loop() {
    os_runloop_once();
}

void onEvent(ev_t ev) {
    Serial.print(os_getTime());
    Serial.print(": ");
    switch(ev) {
        case EV_JOINING:
            Serial.println(F("EV_JOINING"));
            break;
        case EV_JOINED:
            Serial.println(F("EV_JOINED"));
            break;
        case EV_JOIN_FAILED:
            Serial.println(F("EV_JOIN_FAILED"));
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
            os_setTimedCallback(&sendjob, os_getTime()+sec2osticks(SEND_INTERVAL), do_send);
            break;
        case EV_RXCOMPLETE:
            Serial.println(F("EV_RXCOMPLETE"));
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
    
    // Build LPP payload
    uint8_t lpp_data[20];
    int lpp_index = 0;
    
    // Channel 1: Water Volume (Analog Input - 0x02)
    lpp_data[lpp_index++] = 1;      // Channel
    lpp_data[lpp_index++] = 0x02;   // Type
    int16_t vol = (int16_t)(water_volume * 100);
    lpp_data[lpp_index++] = (vol >> 8) & 0xFF;
    lpp_data[lpp_index++] = vol & 0xFF;
    
    // Channel 2: Flow Rate (Analog Input - 0x02)
    lpp_data[lpp_index++] = 2;
    lpp_data[lpp_index++] = 0x02;
    int16_t flow = (int16_t)(flow_rate * 100);
    lpp_data[lpp_index++] = (flow >> 8) & 0xFF;
    lpp_data[lpp_index++] = flow & 0xFF;
    
    // Channel 3: Temperature (Temperature - 0x67)
    lpp_data[lpp_index++] = 3;
    lpp_data[lpp_index++] = 0x67;
    int16_t temp = (int16_t)(temperature * 10);
    lpp_data[lpp_index++] = (temp >> 8) & 0xFF;
    lpp_data[lpp_index++] = temp & 0xFF;
    
    // Channel 4: Pressure (Barometric Pressure - 0x73)
    lpp_data[lpp_index++] = 4;
    lpp_data[lpp_index++] = 0x73;
    uint16_t pres = (uint16_t)(pressure / 2);  // 1/2 Pa resolution
    lpp_data[lpp_index++] = (pres >> 8) & 0xFF;
    lpp_data[lpp_index++] = pres & 0xFF;
    
    // Send it off
    LMIC_setTxData2(1, lpp_data, lpp_index, 0);
    Serial.print(F("Packet sent: "));
    Serial.print(lpp_index);
    Serial.println(F(" bytes"));
}

void readSensors() {
    // Read water volume from analog sensor
    int raw_vol = analogRead(VOLUME_PIN);
    water_volume = (raw_vol / 1023.0) * 1000.0;  // 0-1000 liters
    
    // Read flow rate from analog sensor
    int raw_flow = analogRead(FLOW_PIN);
    flow_rate = (raw_flow / 1023.0) * 100.0;  // 0-100 L/min
    
    // Read temperature and pressure from BMP280
    temperature = bmp280.readTemperature();
    pressure = bmp280.readPressure();
    
    // Print for debugging
    Serial.print(F("Volume: "));
    Serial.print(water_volume, 1);
    Serial.print(F(" L, Flow: "));
    Serial.print(flow_rate, 1);
    Serial.print(F(" L/min, Temp: "));
    Serial.print(temperature, 1);
    Serial.print(F(" C, Pressure: "));
    Serial.print(pressure / 100.0, 1);
    Serial.println(F(" hPa"));
}
