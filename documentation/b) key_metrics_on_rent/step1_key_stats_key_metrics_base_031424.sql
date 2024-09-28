-- Switch to the newly created database
USE ezhire_key_metrics;

-- Drop the database if it exists
DROP TABLE IF EXISTS key_metrics_base;

-- ****************** START --- CREATE BOOKING BASE DATA START ********************
-- Step 1: Create the table structure (assuming the structure of booking_data is known)
CREATE TABLE IF NOT EXISTS key_metrics_base (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT,
    status VARCHAR(64),
    booking_type VARCHAR(64),
    vendor VARCHAR(64),
    is_repeat VARCHAR(64),
    country VARCHAR(64),

    -- BOOKING DATE FIELD
    booking_date DATE,
    max_booking_datetime DATETIME,

    -- PICKUP DATE FIELDS
    pickup_date DATE,
    pickup_datetime DATETIME,
    pickup_time TIME AS (TIME(pickup_datetime)),

    return_date DATE,
    return_datetime DATETIME,
    return_time TIME AS (TIME(return_datetime)),

    -- CONSTANT MINUTES IN A DAY
    total_minutes_in_day INT DEFAULT (24 * 60),

    -- DAYS CALCULATION
    minutes_rented DECIMAL(20, 4) AS (TIMESTAMPDIFF(MINUTE, pickup_datetime, return_datetime)),
    days_rented DECIMAL(20, 4) AS ((TIMESTAMPDIFF(MINUTE, pickup_datetime, return_datetime)) / total_minutes_in_day) STORED,
    days_less_extension_days DECIMAL(10, 4) AS (((TIMESTAMPDIFF(MINUTE, pickup_datetime, return_datetime)) / total_minutes_in_day) - extension_days),
    extension_days DECIMAL(10, 4),

    -- PICKUP MINUTE FRACTION CALC
    pickup_hours_to_midnight INT AS (HOUR(TIMEDIFF('24:00:00', pickup_time))) VIRTUAL,
    pickup_minutes_to_midnight INT AS (MINUTE(TIMEDIFF('24:00:00', pickup_time))) VIRTUAL,
    pickup_total_minutes_to_midnight INT AS (pickup_hours_to_midnight * 60 + pickup_minutes_to_midnight) VIRTUAL,
    pickup_fraction_of_day DECIMAL(5, 4) AS (pickup_total_minutes_to_midnight / total_minutes_in_day ) STORED,
    
    -- RETURN MINUTE FRACTION CALC
    return_hours_to_midnight INT AS (HOUR(return_time)) VIRTUAL,
    return_minutes_to_midnight INT AS (MINUTE(return_time)) VIRTUAL,
    return_total_minutes_to_midnight INT AS (return_hours_to_midnight * 60 + return_minutes_to_midnight) VIRTUAL,
    return_fraction_of_day DECIMAL(5, 4) AS (return_total_minutes_to_midnight / total_minutes_in_day ) STORED,

    -- REVENUE CALCULATION
    booking_charge_aed DOUBLE,
    booking_charge_less_discount_aed DOUBLE,
    booking_charge_less_discount_extension_aed DOUBLE,
    extension_charge_aed DOUBLE,

    -- BOOKING CHARGE AED PER DAY
    booking_charge_aed_per_day DOUBLE AS (
        CASE
            WHEN pickup_date = return_date THEN booking_charge_aed
            WHEN pickup_date <> return_date AND days_rented <= 2 THEN booking_charge_aed / 2
            WHEN days_rented > 0 THEN booking_charge_aed / ROUND((days_rented + 1), 0)
            ELSE 0            
        END
    ),

    -- BOOKING CHARGE LESS DISCOUNT AED PER DAY
    booking_charge_less_discount_aed_per_day DOUBLE AS (
        CASE
            WHEN pickup_date = return_date THEN booking_charge_less_discount_aed
            WHEN pickup_date <> return_date AND days_rented <= 2 THEN booking_charge_less_discount_aed / 2
            WHEN days_rented > 0 THEN booking_charge_less_discount_aed / ROUND((days_rented + 1), 0)
            ELSE 0
        END
    ),

    -- Create indexes on pickup_date, return_date, and status in key_metrics_base
    INDEX idx_pickup_date (pickup_date),
    INDEX idx_return_date (return_date),
    INDEX idx_status (status),
    INDEX idx_pickup_return_date (pickup_date, return_date)
);

SHOW INDEXES FROM key_metrics_base;

-- Step 2: Insert data from ezhire_booking_data.booking_data into key_metrics table
INSERT INTO key_metrics_base (booking_id, status, booking_type, vendor, is_repeat, country, booking_date, max_booking_datetime, pickup_date, pickup_datetime, return_date, return_datetime, extension_days, booking_charge_aed, booking_charge_less_discount_aed, extension_charge_aed, booking_charge_less_discount_extension_aed)

SELECT booking_id, status, booking_type, marketplace_or_dispatch AS vendor, repeated_user AS is_repeat, deliver_country AS country, booking_date, max_booking_datetime, pickup_date, pickup_datetime, return_date, return_datetime, extension_days, booking_charge_aed, booking_charge_less_discount_aed, extension_charge_aed, booking_charge_less_discount_extension_aed

FROM ezhire_booking_data.booking_data;

ALTER TABLE key_metrics_base
    ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Select all records with a limit of 10
SELECT * FROM key_metrics_base LIMIT 10;
-- ****************** END --- CREATE BOOKING BASE DATA ---- END ********************