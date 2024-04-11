-- Switch to ezhire_key_metrics database
USE ezhire_key_metrics;

-- Drop key_metrics_core_onrent_days if exists
DROP TABLE IF EXISTS key_metrics_core_onrent_days;

-- Set parameters
SET @booking_date = '2023-01-01';
SET @pickup_date = '2023-01-01';
SET @return_date = '2023-01-01';
SET @status = '%Cancel%';
SET @uae = 'United Arab Emirates'; -- 1
SET @bhr = 'Bahrain'; -- 2
SET @sau = 'Saudi Arabia'; -- 3
SET @qat = 'Qatar'; -- 4
SET @kwt = 'Kuwait'; -- 5
SET @pak = 'Pakistan'; -- 6
SET @geo = 'Georgia'; -- 6
SET @omn = 'Oman'; -- 8
SET @sbr = 'Serbia'; -- 9

-- Create onrent by segment by day
CREATE TABLE key_metrics_core_onrent_days
SELECT
    NOW() AS created_at,
    ct.calendar_date,
    ct.year AS year,
    ct.quarter AS quarter,
    ct.month AS month,
    ct.week_of_year AS week,
    ct.day_of_year AS day,
    km.max_booking_datetime,

    -- CALC IS_TODAY
    CASE
        WHEN ct.calendar_date = DATE_FORMAT(km.max_booking_datetime, '%Y-%m-%d') THEN "yes"
        ELSE "no"
    END AS is_today,

    -- TOTAL ON-RENT CALCULATION
    COUNT(km.id) AS days_on_rent_whole_day,

    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date THEN 1
            ELSE 0
        END
    ) AS days_on_rent_fraction,

    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date THEN 1
            WHEN ct.calendar_date > km.pickup_date AND ct.day_of_year = 1 THEN 1
            ELSE 0
        END
    ) AS trans_on_rent_count,  

    -- BOOKING COUNT
    SUM(
        CASE
            WHEN ct.calendar_date = km.booking_date THEN 1
            ELSE 0
        END
    ) AS booking_count,

    -- PICKUP COUNT
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date THEN 1
            ELSE 0
        END
    ) AS pickup_count,

    -- RETURN COUNT
    SUM(
        CASE
            WHEN ct.calendar_date = km.return_date THEN 1
            ELSE 0
        END
    ) AS return_count,

    -- INITIAL RENTAL PERIOD DAYS
    SUM(
        CASE
            WHEN extension_days > 0
                AND ct.calendar_date BETWEEN 
                km.pickup_date AND DATE_ADD(km.pickup_date, INTERVAL (km.days_less_extension_days - 1) DAY)
                THEN 1

            WHEN extension_days = 0
                AND ct.calendar_date BETWEEN             
                    km.pickup_date AND
                    km.return_date
                THEN 1

            ELSE 0
        END
    ) AS day_in_initial_period,

    -- EXTENSION PERIOD DAYS
    SUM(
        CASE
            WHEN extension_days > 0
                AND ct.calendar_date BETWEEN 
                DATE_ADD(km.pickup_date, INTERVAL (km.days_less_extension_days) DAY)
                AND km.return_date
                THEN 1
            ELSE 0
        END
    ) AS day_in_extension_period,

    -- REVENUE ALLOCATION FOR EACH DAY
    SUM(
        CASE
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date THEN booking_charge_aed_per_day
            ELSE 0
        END
    ) AS booking_charge_aed_rev_allocation,

    SUM(
        CASE
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date THEN booking_charge_less_discount_aed_per_day
            ELSE 0
        END
    ) AS booking_charge_less_discount_aed_rev_allocation,

    -- INITIAL PERIOD REVENUE ALLOCATION
    SUM(
        CASE
            WHEN extension_days > 0
                AND ct.calendar_date BETWEEN 
                km.pickup_date AND DATE_ADD(km.pickup_date, INTERVAL (km.days_less_extension_days - 1) DAY)
                THEN booking_charge_less_discount_aed_per_day

            WHEN extension_days = 0
                AND ct.calendar_date BETWEEN             
                    km.pickup_date AND
                    km.return_date
                THEN booking_charge_less_discount_aed_per_day

            ELSE 0
        END
    ) AS rev_aed_in_initial_period,

    -- EXTENSION PERIOD REVENUE ALLOCATION
    SUM(
        CASE
            WHEN extension_days > 0
                AND ct.calendar_date BETWEEN 
                DATE_ADD(km.pickup_date, INTERVAL (km.days_less_extension_days) DAY)
                AND km.return_date
                THEN booking_charge_less_discount_aed_per_day
            ELSE 0
        END
    ) AS rev_aed_in_extension_period,

    -- MARKETPLACE VS DISPATCH
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND vendor LIKE 'Dispatch' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND vendor LIKE 'Dispatch' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND vendor LIKE 'Dispatch' THEN 1
            ELSE 0
        END
    ) AS vendor_on_rent_dispatch,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND vendor LIKE 'MarketPlace' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND vendor LIKE 'MarketPlace' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND vendor LIKE 'MarketPlace' THEN 1
            ELSE 0
        END
    ) AS vendor_on_rent_marketplace,
    
    -- BOOKING TYPE BREAKOUT
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND booking_type LIKE 'Daily' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND booking_type LIKE 'Daily' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND booking_type LIKE 'Daily' THEN 1
            ELSE 0
        END
    ) AS booking_type_on_rent_daily,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND booking_type LIKE 'Weekly' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND booking_type LIKE 'Weekly' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND booking_type LIKE 'Weekly' THEN 1
            ELSE 0
        END
    ) AS booking_type_on_rent_weekly,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND booking_type LIKE 'Monthly' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND booking_type LIKE 'Monthly' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND booking_type LIKE 'Monthly' THEN 1
            ELSE 0
        END
    ) AS booking_type_on_rent_monthly,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND booking_type LIKE 'Subscription' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND booking_type LIKE 'Subscription' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND booking_type LIKE 'Subscription' THEN 1
            ELSE 0
        END
    ) AS booking_type_on_rent_subscription,
    
    -- REPEAT VS NEW BREAKOUT
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND is_repeat LIKE 'Yes' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND is_repeat LIKE 'Yes' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND is_repeat LIKE 'Yes' THEN 1
            ELSE 0
        END
    ) AS is_repeat_on_rent_yes,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND is_repeat LIKE 'No' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND is_repeat LIKE 'No' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND is_repeat LIKE 'No' THEN 1
            ELSE 0
        END
    ) AS is_repeat_on_rent_no,
    
    -- COUNTRY BREAKOUT
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@uae) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@uae) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@uae) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_united_arab_emirates,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@bhr) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@bhr) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@bhr) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_bahrain,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@sau) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@sau) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@sau) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_saudia_arabia,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@qat) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@qat) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@qat) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_qatar,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@kwt) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@kwt) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@kwt) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_kuwait,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@pak) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@pak) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@pak) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_pakistan,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@geo) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@geo) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@geo) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_georgia,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@omn) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@omn) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@omn) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_oman,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@sbr) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@sbr) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@sbr) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_serbia

FROM
    calendar_table ct
INNER JOIN 
    key_metrics_base km
    ON ct.calendar_date >= @booking_date -- Ensure calendar date is after booking date
    AND km.return_date >= @return_date -- Ensure return date is after or equal to specified return date
    AND ct.calendar_date >= km.booking_date -- Ensure calendar date is after or equal to booking date
    AND ct.calendar_date <= km.return_date -- Ensure calendar date is before or equal to return date
    AND km.status NOT LIKE @status -- Exclude rows with status matching the specified pattern

-- ************** TESTING EXAMPLES
-- WHERE booking_id IN ('240667') -- 30 INITIAL PERIOD / 60 DAY EXTENSION
-- WHERE booking_id IN ('240682') -- 1 DAY NO EXTENSOIN
-- WHERE booking_id IN ('246867') -- 30 INITIAL PERIOD / 29 DAY EXTENSION
-- WHERE booking_id IN ('246876') -- 7 INITIAL PERIOD / 1 DAY EXTENSION
-- WHERE booking_id IN ('240842') -- 0 DAY EXTENSION; no booking info
-- WHERE booking_id IN ('240082')
-- WHERE booking_id IN ('240671')
-- WHERE booking_id IN ('240667', '246867', '246876', '240842',  '240682', '240082', '240671')
-- WHERE km.return_date >= @return_date AND km.status NOT LIKE @status
-- TESTING EXAMPLES ************

GROUP BY km.created_at, ct.calendar_date, km.max_booking_datetime

ORDER BY ct.calendar_date ASC;

-- View key_metrics summary table
SELECT 
    year,
    month,

    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(pickup_count), 0) AS pickup_count,
    FORMAT(SUM(return_count), 0) AS return_count,

    FORMAT(SUM(trans_on_rent_count),  0) as trans_on_rent_count,
    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,

    CONCAT(FORMAT(SUM(day_in_initial_period), 0)) AS day_in_initial_period,
    CONCAT(FORMAT(SUM(day_in_extension_period), 0)) AS day_in_extension_period,

    CONCAT(FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed,
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,

    CONCAT(FORMAT(SUM(rev_aed_in_initial_period), 0)) AS rev_aed_in_initial_period,
    CONCAT(FORMAT(SUM(rev_aed_in_extension_period), 0)) AS rev_aed_in_extension_period,
    
    CONCAT(FORMAT(SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period), 0)) AS total_initial_plus_extension,
    
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation) - (SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period)), 0)) AS diff
    
FROM key_metrics_core_onrent_days
GROUP BY year, month WITH ROLLUP
ORDER BY year ASC, month ASC;

-- View the key_metrics_core_onrent_days table
SELECT * FROM key_metrics_core_onrent_days;

-- View key_metrics summary table
SELECT
    year,
    month,
    day,

    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(pickup_count), 0) AS pickup_count,
    FORMAT(SUM(return_count), 0) AS return_count,

    FORMAT(SUM(trans_on_rent_count),  0) as trans_on_rent_count,
    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,

    CONCAT(FORMAT(SUM(day_in_initial_period), 0)) AS day_in_initial_period,
    CONCAT(FORMAT(SUM(day_in_extension_period), 0)) AS day_in_extension_period,

    CONCAT(FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed,
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,

    CONCAT(FORMAT(SUM(rev_aed_in_initial_period), 0)) AS rev_aed_in_initial_period,
    CONCAT(FORMAT(SUM(rev_aed_in_extension_period), 0)) AS rev_aed_in_extension_period,
    
    CONCAT(FORMAT(SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period), 0)) AS total_initial_plus_extension,
    
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation) - (SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period)), 0)) AS diff
    
FROM key_metrics_core_onrent_days
GROUP BY year, month, day WITH ROLLUP
ORDER BY year ASC, month ASC, day ASC;