-- THIS VERSION WORKS BUT IT TAKES ABOUT 6 MINUTES TO EXECUTE

-- Select database
USE ezhire_pacing_metrics;

-- Drop the TABLE if it exists
DROP TABLE IF EXISTS pacing_base_groupby;

-- CREATE PACING BASE STATS ROLLUP WITH GROUPING AND SUM
CREATE TABLE pacing_base_groupby AS
SELECT 
    pb.pickup_month_year,
    pb.booking_date,
    pb.days_from_first_day_of_month,
    
    -- SUM KEY STATS BY PICKUP MONTH YEAR
    SUM(count) AS count,
    FORMAT(SUM(pb.booking_charge_aed), 0) AS total_booking_charge_aed,
    FORMAT(SUM(pb.booking_charge_less_discount_aed), 0) AS total_booking_charge_less_discount_aed,
    FORMAT(SUM(pb.booking_charge_less_discount_extension_aed), 0) AS total_booking_charge_less_discount_extension_aed,
    FORMAT(SUM(pb.extension_charge_aed), 0) AS total_extension_charge_aed,
    
    -- CREATE RUNNING TOTAL FOR KEY STATS
    FORMAT((SELECT SUM(count)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_count,

    FORMAT((SELECT SUM(booking_charge_aed)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_charge_aed,

    FORMAT((SELECT SUM(booking_charge_less_discount_aed)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_charge_less_discount_aed,

    FORMAT((SELECT SUM(booking_charge_less_discount_extension_aed)
            FROM ezhire_pacing_metrics.pacing_base
            WHERE pickup_month_year = pb.pickup_month_year
            AND days_from_first_day_of_month <= pb.days_from_first_day_of_month), 0) AS running_total_booking_charge_less_discount_extension_aed,

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

-- Select all records
SELECT * FROM pacing_base_groupby;
