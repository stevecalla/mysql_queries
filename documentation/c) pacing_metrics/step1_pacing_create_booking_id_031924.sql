-- Switch to the pacing database
USE ezhire_pacing_metrics;

-- Drop the TABLE if it exists
DROP TABLE IF EXISTS pacing_base;

-- CREATE PACING BASE STATS
CREATE TABLE pacing_base AS 
SELECT 
    booking_id,
    booking_date,
    max_booking_datetime, -- ADDED
    DATE_FORMAT(pickup_date, '%Y-%m-01') AS pickup_first_day_of_month,
    TIMESTAMPDIFF(DAY, DATE_FORMAT(pickup_date, '%Y-%m-01'), booking_date) AS days_from_first_day_of_month,

    CONCAT(pickup_year, "-", LPAD(pickup_month, 2, '0')) AS pickup_month_year,
    pickup_date,
    
    1 AS count,
    booking_charge_aed,
    booking_charge_less_discount_aed,
    booking_charge_less_discount_extension_aed,
    extension_charge_aed

FROM ezhire_booking_data.booking_data 
WHERE status NOT LIKE '%Cancel%'
AND pickup_year IN (2023, 2024)
ORDER BY booking_date ASC, pickup_date ASC;
-- LIMIT 10;

-- Select all records with a limit of 10
SELECT * FROM pacing_base;

-- BY WEEK CALCS
-- DATE_ADD(booking_date, INTERVAL (IF(DAYOFWEEK(booking_date) = 1, -6, 2 - DAYOFWEEK(booking_date))) DAY) AS booking_first_day_of_week,
-- TIMESTAMPDIFF(DAY, DATE_ADD(booking_date, INTERVAL (IF(DAYOFWEEK(booking_date) = 1, -6, 2 - DAYOFWEEK(booking_date))) DAY), booking_date) AS days_from_first_day_of_week,