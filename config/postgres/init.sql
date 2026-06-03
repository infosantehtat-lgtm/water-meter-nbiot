-- PostgreSQL initialization script for water meter platform

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "json";

-- Create additional tables for water meter specific data
CREATE TABLE IF NOT EXISTS water_meter_readings (
    id SERIAL PRIMARY KEY,
    device_id UUID NOT NULL,
    timestamp BIGINT NOT NULL,
    volume DOUBLE PRECISION NOT NULL,
    flow_rate DOUBLE PRECISION,
    temperature DOUBLE PRECISION,
    pressure DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_reading UNIQUE (device_id, timestamp)
);

-- Create index for faster queries
CREATE INDEX idx_water_readings_device_ts ON water_meter_readings(device_id, timestamp DESC);
CREATE INDEX idx_water_readings_timestamp ON water_meter_readings(timestamp DESC);

-- Create table for daily aggregates
CREATE TABLE IF NOT EXISTS water_meter_daily (
    id SERIAL PRIMARY KEY,
    device_id UUID NOT NULL,
    date DATE NOT NULL,
    total_volume DOUBLE PRECISION NOT NULL,
    min_flow DOUBLE PRECISION,
    max_flow DOUBLE PRECISION,
    avg_flow DOUBLE PRECISION,
    readings_count INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_daily UNIQUE (device_id, date)
);

-- Create index for daily data
CREATE INDEX idx_water_daily_device_date ON water_meter_daily(device_id, date DESC);

-- Create table for alerts
CREATE TABLE IF NOT EXISTS water_meter_alerts (
    id SERIAL PRIMARY KEY,
    device_id UUID NOT NULL,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL,
    message TEXT,
    timestamp BIGINT NOT NULL,
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for alerts
CREATE INDEX idx_alerts_device_ts ON water_meter_alerts(device_id, timestamp DESC);
CREATE INDEX idx_alerts_severity ON water_meter_alerts(severity, created_at DESC);

-- Create table for device settings
CREATE TABLE IF NOT EXISTS water_meter_settings (
    id SERIAL PRIMARY KEY,
    device_id UUID NOT NULL,
    alert_flow_threshold DOUBLE PRECISION DEFAULT 50.0,
    daily_limit DOUBLE PRECISION DEFAULT 100.0,
    notification_enabled BOOLEAN DEFAULT TRUE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_settings UNIQUE (device_id)
);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO thingsboard;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO thingsboard;
