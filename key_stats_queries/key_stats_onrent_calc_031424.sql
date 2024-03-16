-- Switch to the newly created database
USE ezhire_key_metrics;

-- Drop key_metrics_core_onrent_days if exists
DROP TABLE IF EXISTS key_metrics_core_onrent_days;

-- DONE
-- add on-rent by country
-- return date >= 2023 not the pickup date? & keep calendar the same?
-- add booking count
-- add booking charge fields to key metric base table

-- TODO
-- add revenue allocation for booking_charge and booking_charge_with_discount
-- add field for pickup month, year, week, day of month

-- create a table of the output
-- dynamic statement / javascript to create sql on the fly
-- car rollup

-- Set parameters
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
SET @gbr = 'United Kingdom'; -- 10

-- Calculate fleet count
SET @fleet_count = 2000;

-- Create onrent by segment by day
CREATE TABLE key_metrics_core_onrent_days
SELECT
    NOW() AS created_at,
    ct.calendar_date,
    YEAR(ct.calendar_date) AS year,
    QUARTER(ct.calendar_date) AS quarter,
    MONTH(ct.calendar_date) AS month,
    WEEK(ct.calendar_date) AS week,
    DAY(ct.calendar_date) AS day,

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
    ) AS type_on_rent_daily,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND booking_type LIKE 'Weekly' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND booking_type LIKE 'Weekly' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND booking_type LIKE 'Weekly' THEN 1
            ELSE 0
        END
    ) AS type_on_rent_weekly,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND booking_type LIKE 'Monthly' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND booking_type LIKE 'Monthly' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND booking_type LIKE 'Monthly' THEN 1
            ELSE 0
        END
    ) AS type_on_rent_monthly,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND booking_type LIKE 'Subscription' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND booking_type LIKE 'Subscription' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND booking_type LIKE 'Subscription' THEN 1
            ELSE 0
        END
    ) AS type_on_rent_subscription,
    
    -- REPEAT VS NEW BREAKOUT
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND is_repeat LIKE 'Yes' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND is_repeat LIKE 'Yes' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND is_repeat LIKE 'Yes' THEN 1
            ELSE 0
        END
    ) AS user_on_rent_repeat,
    
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND is_repeat LIKE 'No' THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND is_repeat LIKE 'No' THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND is_repeat LIKE 'No' THEN 1
            ELSE 0
        END
    ) AS user_on_rent_new,
    
    -- COUNTRY BREAKOUT
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@uae) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@uae) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@uae) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_uae,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@bhr) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@bhr) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@bhr) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_bhr,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@sau) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@sau) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@sau) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_sau,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@qat) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@qat) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@qat) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_qat,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@kwt) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@kwt) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@kwt) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_kwt,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@pak) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@pak) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@pak) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_pak,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@geo) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@geo) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@geo) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_geo,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@omn) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@omn) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@omn) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_omn,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@sbr) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@sbr) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@sbr) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_sbr,
    SUM(
        CASE
            WHEN ct.calendar_date = km.pickup_date AND LOWER(country) LIKE LOWER(@gbr) THEN km.pickup_fraction_of_day
            WHEN ct.calendar_date = km.return_date AND LOWER(country) LIKE LOWER(@gbr) THEN km.return_fraction_of_day
            WHEN ct.calendar_date BETWEEN km.pickup_date AND km.return_date AND LOWER(country) LIKE LOWER(@gbr) THEN 1
            ELSE 0
        END
    ) AS country_on_rent_gbr

FROM
    (SELECT calendar_date FROM calendar_table WHERE calendar_date >= @pickup_date) ct
INNER JOIN
    -- (SELECT * FROM key_metrics_base WHERE pickup_date >= @pickup_date AND status NOT LIKE @status) km
    (SELECT * FROM key_metrics_base WHERE return_date >= @return_date AND status NOT LIKE @status) km
    ON ct.calendar_date >= km.pickup_date AND ct.calendar_date <= km.return_date
-- WHERE km.booking_id = 240667
GROUP BY
    ct.calendar_date
ORDER BY
	ct.calendar_date ASC;

-- Add a new column named 'created_at' to the existing table
-- ALTER TABLE combined_metrics
-- ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- View the table
SELECT * FROM key_metrics_core_onrent_days LIMIT 10;
