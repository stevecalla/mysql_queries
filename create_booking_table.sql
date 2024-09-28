-- Drop the database if it exists
DROP DATABASE IF EXISTS ezhire_booking_data;
-- CREATE RENTAL RECORD TABLE
CREATE DATABASE ezhire_booking_data;
-- Switch to the newly created database
USE ezhire_booking_data;

-- Create the table
CREATE TABLE booking_data (
    booking_id INT NOT NULL DEFAULT 0,
    agreement_number VARCHAR(30),
    booking_datetime DATETIME,
	booking_year VARCHAR(4),
    booking_month VARCHAR(2),
    booking_day_of_month VARCHAR(64),
	booking_day_of_week VARCHAR(64),
    booking_day_of_week_v2 VARCHAR(64),
	booking_time_bucket VARCHAR(7),
    pickup_datetime DATETIME,
    pickup_year VARCHAR(4),
    pickup_month VARCHAR(64),
    pickup_day_of_month VARCHAR(2),
    pickup_day_of_week VARCHAR(64),
    pickup_day_of_week_v2 VARCHAR(64),
    pickup_time_bucket VARCHAR(7),
    return_datetime DATETIME,
    return_year VARCHAR(4),
    return_month VARCHAR(64),
    return_day_of_month VARCHAR(2),
    return_day_of_week VARCHAR(2),
    return_day_of_week_v2 VARCHAR(64),
    return_time_bucket VARCHAR(64),
    status VARCHAR(50),
    booking_type VARCHAR(12) NOT NULL,
    marketplace_or_dispatch VARCHAR(11) NOT NULL,
    marketplace_partner VARCHAR(100),
    marketplace_partner_summary VARCHAR(100),
    booking_channel VARCHAR(15),
    booking_source VARCHAR(100),
    repeated_user VARCHAR(64) NOT NULL,
    total_lifetime_booking_revenue CHAR(64) NOT NULL,
    no_of_bookings BIGINT NOT NULL DEFAULT 0,
    no_of_cancel_bookings BIGINT,
    no_of_completed_bookings BIGINT,
    no_of_started_bookings BIGINT,
    customer_id INT,
    date_of_birth VARCHAR(25) NOT NULL,
    age BIGINT,
    customer_driving_country VARCHAR(50),
    customer_doc_vertification_status VARCHAR(3) NOT NULL,
	days DOUBLE,
    -- extra_day_calc DOUBLE,
    extra_day_calc DOUBLE DEFAULT 0,
    customer_rate DOUBLE,
    insurance_rate DOUBLE,
    insurance_type VARCHAR(14) NOT NULL,
    millage_rate DOUBLE,
    millage_cap_km VARCHAR(15),
    rent_charge DOUBLE,
    extra_day_charge DOUBLE,
    delivery_charge DOUBLE,
    collection_charge DOUBLE,
    additional_driver_charge DOUBLE,
    insurance_charge DOUBLE,
    intercity_charge DOUBLE,
    millage_charge INT NOT NULL DEFAULT 0,
    other_rental_charge DOUBLE,
    discount_charge DOUBLE,
    total_vat DOUBLE,
    other_charge DOUBLE,
    booking_charge DOUBLE,
    booking_charge_less_discount DOUBLE,
    base_rental_revenue DOUBLE,
    non_rental_charge DOUBLE,
    extension_charge INT NOT NULL DEFAULT 0,
    is_extended VARCHAR(3),
    promo_code VARCHAR(25),
    promo_code_discount_amount CHAR(0) NOT NULL,
    promocode_created_date VARCHAR(150),
    promo_code_description VARCHAR(200),
    requested_car VARCHAR(50),
    car_name VARCHAR(50),
    make VARCHAR(30),
    color VARCHAR(20),
    deliver_country VARCHAR(50) NOT NULL,
    deliver_city VARCHAR(50) NOT NULL,
    delivery_location VARCHAR(200),
    deliver_method VARCHAR(8) NOT NULL,
    delivery_lat VARCHAR(200),
    delivery_lng VARCHAR(200),
    collection_location VARCHAR(200),
    collection_method VARCHAR(10) NOT NULL,
    collection_lat VARCHAR(200),
    collection_lng VARCHAR(200),
    nps_score VARCHAR(4),
    nps_comment TEXT
);

-- Render the table fields
SHOW COLUMNS FROM ezhire_booking_data.booking_data;

-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_test.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010117_123117.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010118_123118.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010119_123119.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010120_123120.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010121_063021.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_070121_123121.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010122_063022.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_070122_103122.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_110122_123122.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010123_033123.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_040123_063023.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_070123_093023.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_100123_123123.csv'

-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/booking_data/booking_data_010124_123124.csv'
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data/booking_data_010124_123124.csv'
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data/test.csv'

INTO TABLE booking_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    booking_id, 
    agreement_number,
    @booking_datetime, -- Variable to capture booking_datetime as string
    booking_year,
    booking_month,
    booking_day_of_month,
    booking_day_of_week,
    booking_day_of_week_v2,
    booking_time_bucket,
    @pickup_datetime, -- Variable to capture pickup_datetime as string
    pickup_year,
    pickup_month,
    pickup_day_of_month,
    pickup_day_of_week,
    pickup_day_of_week_v2,
    pickup_time_bucket,
    @return_datetime, -- Variable to capture return_datetime as string
    return_year,
    return_month,
    return_day_of_month,
    return_day_of_week,
    return_day_of_week_v2,
    return_time_bucket,
    status,
    booking_type,
    marketplace_or_dispatch,
    marketplace_partner,
    marketplace_partner_summary,
    booking_channel,
    booking_source,
    repeated_user,
    total_lifetime_booking_revenue,
    no_of_bookings,
    no_of_cancel_bookings,
    no_of_completed_bookings,
    no_of_started_bookings,
    customer_id,
    date_of_birth,
    age,
    customer_driving_country,
    customer_doc_vertification_status,
    days,
    extra_day_calc,
    customer_rate,
    insurance_rate,
    insurance_type,
    millage_rate,
    millage_cap_km,
    rent_charge,
    extra_day_charge,
    delivery_charge,
    collection_charge,
    additional_driver_charge,
    insurance_charge,
    intercity_charge,
    millage_charge,
    other_rental_charge,
    discount_charge,
    total_vat,
    other_charge,
    booking_charge,
    booking_charge_less_discount,
    base_rental_revenue,
    non_rental_charge,
    extension_charge,
    is_extended,
    Promo_Code,
    promo_code_discount_amount,
    @promocode_created_date,  -- Variable to capture promocode_created_date as string
    promo_code_description,
    requested_car,
    car_name,
    make,
    color,
    deliver_country,
    deliver_city,
    delivery_location,
    deliver_method,
    delivery_lat,
    delivery_lng,
    collection_location,
    collection_method,
    collection_lat,
    collection_lng,
    nps_score,
    nps_comment
)
SET booking_datetime = STR_TO_DATE(@booking_datetime, "%Y-%m-%d %H:%i:%s"),
    pickup_datetime = STR_TO_DATE(@pickup_datetime, "%Y-%m-%d %H:%i:%s"),
    return_datetime = STR_TO_DATE(@return_datetime, "%Y-%m-%d %H:%i:%s");
    -- promocode_created_date = STR_TO_DATE(@promocode_created_date, "%Y-%m-%d %H:%i:%s");

-- Render the table fields
SELECT * FROM ezhire_booking_data.booking_data;