-- MUCH FASTER VERSION OF STEP 2

-- Select database
USE ezhire_pacing_metrics;

-- Drop the TABLE if it exists
DROP TABLE IF EXISTS pacing_base_groupby;

-- CREATE PACING BASE STATS ROLLUP WITH GROUPING AND SUM
CREATE TABLE pacing_base_groupby AS
SELECT
    max_booking_datetime, -- ADDED
    pickup_month_year,
    booking_date,
    days_from_first_day_of_month,
    
    -- SUM KEY STATS BY PICKUP MONTH YEAR
    count,
    FORMAT(booking_charge_aed, 0) AS total_booking_charge_aed,
    FORMAT(booking_charge_less_discount_aed, 0) AS total_booking_charge_less_discount_aed,
    FORMAT(booking_charge_less_discount_extension_aed, 0) AS total_booking_charge_less_discount_extension_aed,
    FORMAT(extension_charge_aed, 0) AS total_extension_charge_aed,
    
    FORMAT(CASE
        WHEN @prev_month_year = pickup_month_year THEN 
            @running_total_booking_count := @running_total_booking_count + count
        ELSE 
            @running_total_booking_count := count
    END, 0) AS running_total_booking_count,
    FORMAT(CASE
        WHEN @prev_month_year = pickup_month_year THEN 
            @running_total_booking_charge_aed := @running_total_booking_charge_aed + booking_charge_aed
        ELSE 
            @running_total_booking_charge_aed := booking_charge_aed
    END, 0) AS running_total_booking_charge_aed,
    FORMAT(CASE
        WHEN @prev_month_year = pickup_month_year THEN 
            @running_total_booking_charge_less_discount_aed := @running_total_booking_charge_less_discount_aed + booking_charge_less_discount_aed
        ELSE 
            @running_total_booking_charge_less_discount_aed := booking_charge_less_discount_aed
    END, 0) AS running_total_booking_charge_less_discount_aed,
    FORMAT(CASE
        WHEN @prev_month_year = pickup_month_year THEN 
            @running_total_booking_charge_less_discount_extension_aed := @running_total_booking_charge_less_discount_extension_aed + booking_charge_less_discount_extension_aed
        ELSE 
            @running_total_booking_charge_less_discount_extension_aed := booking_charge_less_discount_extension_aed
    END, 0) AS running_total_booking_charge_less_discount_extension_aed,
    FORMAT(CASE
        WHEN @prev_month_year = pickup_month_year THEN 
            @running_total_extension_charge_aed := @running_total_extension_charge_aed + extension_charge_aed
        ELSE 
            @running_total_extension_charge_aed := extension_charge_aed
    END, 0) AS running_total_extension_charge_aed,
    @prev_month_year := pickup_month_year AS dummy_variable  -- used to restart the totals for each pickup_month_year combo
FROM (
    SELECT
        pb.max_booking_datetime, -- ADDED
        pb.pickup_month_year,
        pb.booking_date,
        pb.days_from_first_day_of_month,
        SUM(count) AS count,
        SUM(booking_charge_aed) AS booking_charge_aed,
        SUM(booking_charge_less_discount_aed) AS booking_charge_less_discount_aed,
        SUM(booking_charge_less_discount_extension_aed) AS booking_charge_less_discount_extension_aed,
        SUM(extension_charge_aed) AS extension_charge_aed
    FROM ezhire_pacing_metrics.pacing_base pb
    GROUP BY 
        pb.max_booking_datetime, -- ADDED
        pb.pickup_month_year,
        pb.booking_date,  
        pb.days_from_first_day_of_month
    ORDER BY pb.pickup_month_year ASC, days_from_first_day_of_month ASC
    -- LIMIT 1000
) AS subquery
JOIN (SELECT 
        @running_total_booking_count := 0, 
        @running_total_booking_charge_aed := 0,
        @running_total_booking_charge_less_discount_aed := 0,
        @running_total_booking_charge_less_discount_extension_aed := 0,
        @running_total_extension_charge_aed := 0,
        @prev_month_year := NULL
    ) AS init;

-- WARNINGS
SHOW WARNINGS;

-- Select all records
SELECT * FROM pacing_base_groupby;