-- THIS VERSION WORKS BUT IT TAKES A WHILE TO EXECUTE
-- DID NOT UPDATE WITH MAX BOOKING DATE OR IS_TODAY

-- Select database
USE ezhire_pacing_metrics;

-- Drop temporary tables if no longer needed
DROP TEMPORARY TABLE IF EXISTS temp_1_calendar_parts;
DROP TEMPORARY TABLE IF EXISTS temp_2_key_stats;
DROP TEMPORARY TABLE IF EXISTS temp_3_running_total_booking_count;
DROP TEMPORARY TABLE IF EXISTS temp_4_running_total_booking_charge_aed;
DROP TEMPORARY TABLE IF EXISTS temp_5_running_total_booking_charge_less_discount_aed;
DROP TEMPORARY TABLE IF EXISTS temp_6_running_total_booking_charge_less_discount_extension_aed;
DROP TEMPORARY TABLE IF EXISTS temp_7_running_total_extension_charge_aed;
DROP TABLE IF EXISTS pacing_base_groupby_test;

-- Query 1: Get date parts and store in a temporary table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_1_calendar_parts AS
SELECT
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month
FROM ezhire_pacing_metrics.pacing_base pb
GROUP BY 
    pb.pickup_month_year,
    pb.booking_date,  
    pb.days_from_first_day_of_month
ORDER BY pb.pickup_month_year ASC;

-- Query 2: Get key stats and store in a temporary table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_2_key_stats AS
SELECT
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month,

    -- SUM KEY STATS BY PICKUP MONTH YEAR
    SUM(count) AS count,
    FORMAT(SUM(pb.booking_charge_aed), 0) AS total_booking_charge_aed,
    FORMAT(SUM(pb.booking_charge_less_discount_aed), 0) AS total_booking_charge_less_discount_aed,
    FORMAT(SUM(pb.booking_charge_less_discount_extension_aed), 0) AS total_booking_charge_less_discount_extension_aed,
    FORMAT(SUM(pb.extension_charge_aed), 0) AS total_extension_charge_aed

FROM ezhire_pacing_metrics.pacing_base pb
GROUP BY 
    pb.pickup_month_year,
    pb.booking_date,  
    pb.days_from_first_day_of_month
ORDER BY pb.pickup_month_year ASC;

-- Query 3: Get running total for booking count and store in a temporary table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_3_running_total_booking_count AS
SELECT
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month,
    
    -- CREATE RUNNING TOTAL FOR BOOKING COUNT
    FORMAT((SELECT SUM(count)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_count

FROM ezhire_pacing_metrics.pacing_base pb
GROUP BY 
    pb.pickup_month_year,
    pb.booking_date,  
    pb.days_from_first_day_of_month
ORDER BY pb.pickup_month_year ASC;

-- Query 4: Get running total for booking count and store in a temporary table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_4_running_total_booking_charge_aed AS
SELECT
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month,

    -- CREATE RUNNING TOTAL FOR running_total_booking_charge_aed
    FORMAT((SELECT SUM(booking_charge_aed)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_charge_aed

FROM ezhire_pacing_metrics.pacing_base pb
GROUP BY 
    pb.pickup_month_year,
    pb.booking_date,  
    pb.days_from_first_day_of_month
ORDER BY pb.pickup_month_year ASC;

-- Query 5: Get running total for booking count and store in a temporary table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_5_running_total_booking_charge_less_discount_aed AS
SELECT
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month,

    -- CREATE RUNNING TOTAL FOR running_total_booking_charge_less_discount_aed
    FORMAT((SELECT SUM(booking_charge_less_discount_aed)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_charge_less_discount_aed

FROM ezhire_pacing_metrics.pacing_base pb
GROUP BY 
    pb.pickup_month_year,
    pb.booking_date,  
    pb.days_from_first_day_of_month
ORDER BY pb.pickup_month_year ASC;

-- Query 6: Get running total for booking count and store in a temporary table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_6_running_total_booking_charge_less_discount_extension_aed AS
SELECT
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month,

    -- CREATE RUNNING TOTAL FOR running_total_booking_charge_less_discount_extension_aed
    FORMAT((SELECT SUM(booking_charge_less_discount_extension_aed)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_charge_less_discount_extension_aed

FROM ezhire_pacing_metrics.pacing_base pb
GROUP BY 
    pb.pickup_month_year,
    pb.booking_date,  
    pb.days_from_first_day_of_month
ORDER BY pb.pickup_month_year ASC;

-- Query 7: Get running total for booking count and store in a temporary table
CREATE TEMPORARY TABLE IF NOT EXISTS temp_7_running_total_extension_charge_aed AS
SELECT
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month,

    -- CREATE RUNNING TOTAL FOR running_total_extension_charge_aed

    FORMAT((SELECT SUM(extension_charge_aed)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_extension_charge_aed

FROM ezhire_pacing_metrics.pacing_base pb
GROUP BY 
    pb.pickup_month_year,
    pb.booking_date,  
    pb.days_from_first_day_of_month
ORDER BY pb.pickup_month_year ASC;

-- Create a new table using the combined query result
CREATE TABLE pacing_base_groupby_test AS
SELECT
    t1.pickup_month_year,
    t1.booking_date,
    t1.days_from_first_day_of_month,

    t2.count,
    t2.total_booking_charge_aed,
    t2.total_booking_charge_less_discount_aed,
    t2.total_booking_charge_less_discount_extension_aed,
    t2.total_extension_charge_aed,

    t3.running_total_booking_count,
    t4.running_total_booking_charge_aed,
    t5.running_total_booking_charge_less_discount_aed,
    t6.running_total_booking_charge_less_discount_extension_aed,
    t7.running_total_extension_charge_aed

FROM
    temp_1_calendar_parts t1
    
INNER JOIN temp_2_key_stats t2
    ON t1.pickup_month_year = t2.pickup_month_year
    AND t1.booking_date = t2.booking_date
    AND t1.days_from_first_day_of_month = t2.days_from_first_day_of_month
    
INNER JOIN temp_3_running_total_booking_count t3
    ON t1.pickup_month_year = t3.pickup_month_year
    AND t1.booking_date = t3.booking_date
    AND t1.days_from_first_day_of_month = t3.days_from_first_day_of_month
    
INNER JOIN temp_4_running_total_booking_charge_aed t4
    ON t1.pickup_month_year = t4.pickup_month_year
    AND t1.booking_date = t4.booking_date
    AND t1.days_from_first_day_of_month = t4.days_from_first_day_of_month
    
INNER JOIN temp_5_running_total_booking_charge_less_discount_aed t5
    ON t1.pickup_month_year = t5.pickup_month_year
    AND t1.booking_date = t5.booking_date
    AND t1.days_from_first_day_of_month = t5.days_from_first_day_of_month
    
INNER JOIN temp_6_running_total_booking_charge_less_discount_extension_aed t6
    ON t1.pickup_month_year = t6.pickup_month_year
    AND t1.booking_date = t6.booking_date
    AND t1.days_from_first_day_of_month = t6.days_from_first_day_of_month
    
INNER JOIN temp_7_running_total_extension_charge_aed t7
    ON t1.pickup_month_year = t7.pickup_month_year
    AND t1.booking_date = t7.booking_date
    AND t1.days_from_first_day_of_month = t7.days_from_first_day_of_month

ORDER BY
    t1.pickup_month_year ASC,
    t1.booking_date ASC,
    t1.days_from_first_day_of_month ASC;

-- -- Drop temporary tables if no longer needed
-- DROP TEMPORARY TABLE IF EXISTS temp_1_calendar_parts;
-- DROP TEMPORARY TABLE IF EXISTS temp_2_key_stats;
-- DROP TEMPORARY TABLE IF EXISTS temp_3_running_total_booking_count;
-- DROP TEMPORARY TABLE IF EXISTS temp_4_running_total_booking_charge_aed;
-- DROP TEMPORARY TABLE IF EXISTS temp_5_running_total_booking_charge_less_discount_aed;
-- DROP TEMPORARY TABLE IF EXISTS temp_6_running_total_booking_charge_less_discount_extension_aed;
-- DROP TEMPORARY TABLE IF EXISTS temp_7_running_total_extension_charge_aed;

-- View the key_metrics_core_onrent_days table
SELECT * FROM temp_1_calendar_parts;
SELECT * FROM temp_2_key_stats;
SELECT * FROM temp_3_running_total_booking_count;
SELECT * FROM temp_4_running_total_booking_charge_aed;
SELECT * FROM temp_5_running_total_booking_charge_less_discount_aed;
SELECT * FROM temp_6_running_total_booking_charge_less_discount_extension_aed;
SELECT * FROM temp_7_running_total_extension_charge_aed;
SELECT * FROM pacing_base_groupby_test;
