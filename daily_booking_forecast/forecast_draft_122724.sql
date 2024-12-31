USE myproject;

-- C:\Users\calla\development\ezhire\mysql_queries\daily_booking_forecast\forecast_draft_122724.sql

SET @today_timestamp_utc = UTC_TIMESTAMP();
SET @today_date_gst = DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d');
SET @today_timestamp_gst = DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR);
SET @today_current_hour_gst = DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%H');
SET @today_current_dayofweek_gst = DAYOFWEEK(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR));
SET @same_day_last_week = DATE_FORMAT(DATE_SUB(@today_date_gst, INTERVAL 7 DAY), '%Y-%m-%d');

WITH actual_last_7_days AS (
        SELECT
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') AS booking_date,
            "actual" AS segment_major,
            "actual_last_7_days" AS segment_minor,
            COUNT(*) AS hourly_bookings
        FROM rental_car_booking2 AS b
            LEFT JOIN rental_status AS rs ON b.status = rs.id
            INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
            INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
        WHERE 
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') BETWEEN 
            DATE_FORMAT(DATE_SUB(@today_date_gst, INTERVAL 7 DAY), '%Y-%m-%d') AND @today_date_gst
        AND rs.status != "Cancelled by User"
        AND co.name IN ('United Arab Emirates')
        GROUP BY booking_date, booking_time_bucket
        ORDER BY booking_date, booking_time_bucket
)
, actual_today AS (
    SELECT
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') AS booking_date,
        "actual" AS segment_major,
        "actual_today" AS segment_minor,
        COUNT(*) AS hourly_bookings
    FROM rental_car_booking2 AS b
    LEFT JOIN rental_status AS rs ON b.status = rs.id
    INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
    INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE 
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_gst
        AND rs.status != "Cancelled by User"
        AND co.name IN ('United Arab Emirates')
    GROUP BY booking_time_bucket
    ORDER BY booking_time_bucket
)
    -- SELECT * FROM actual_today;
, actual_7_days_ago AS ( -- same day last week
    SELECT
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') AS booking_date,
        "actual" AS segment_major,
        "actual_7_days_ago" AS segment_minor,
        COUNT(*) AS hourly_bookings
    FROM rental_car_booking2 AS b
    LEFT JOIN rental_status AS rs ON b.status = rs.id
    INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
    INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE 
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @same_day_last_week
        AND rs.status != "Cancelled by User"
        AND co.name IN ('United Arab Emirates')
    GROUP BY booking_time_bucket
    ORDER BY booking_time_bucket
)
    -- SELECT * FROM actual_7_days_ago;
, actuals_same_day_last_4_weeks AS (
	SELECT
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') AS booking_date,
        "actual" AS segment_major,
        "actuals_same_day_last_4_weeks" AS segment_minor,
        COUNT(*) AS hourly_bookings
    FROM rental_car_booking2 AS b
		LEFT JOIN rental_status AS rs ON b.status = rs.id
		INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
		INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE 
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') BETWEEN 
            DATE_FORMAT(DATE_SUB(@today_date_gst, INTERVAL 28 DAY), '%Y-%m-%d') AND DATE_SUB(@today_date_gst, INTERVAL 7 DAY)
        AND rs.status != "Cancelled by User"
        AND co.name IN ('United Arab Emirates')
        AND DAYOFWEEK(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) = DAYOFWEEK(@today_date_gst) -- Filter for the same day of the week
    GROUP BY booking_date, booking_time_bucket
    ORDER BY booking_date, booking_time_bucket
)
    -- SELECT * FROM actuals_same_day_last_4_weeks;
, average_last_7_days AS (
    SELECT
        booking_time_bucket,
        NULL AS booking_date,
        "average" AS segment_major,
        "average_last_7_days" AS segment_minor,
        ROUND(AVG(hourly_bookings), 0) AS hourly_bookings
    FROM actual_last_7_days
    GROUP BY booking_time_bucket
    ORDER BY booking_time_bucket
)
    -- SELECT * FROM average_last_7_days;
, average_same_day_last_4_weeks AS (
    SELECT
        booking_time_bucket,
        NULL AS booking_date,
        "average" AS segment_major,
        "average_same_day_last_4_weeks" AS segment_minor,
        ROUND(AVG(hourly_bookings), 0) AS hourly_bookings
    FROM actuals_same_day_last_4_weeks
    GROUP BY booking_time_bucket
    ORDER BY booking_time_bucket
)
    -- SELECT * FROM average_same_day_last_4_weeks;
, estimate_last_7_days AS (
    SELECT
        l7.booking_time_bucket,
        NULL AS booking_date,
        "estimate" AS segment_major,
        "estimate_last_7_days" AS segment_minor,
        CASE
            WHEN l7.booking_time_bucket < @today_current_hour_gst THEN ac_today.hourly_bookings
            ELSE ROUND(AVG(l7.hourly_bookings))
        END AS hourly_bookings -- estimate_last_7_days
    FROM average_last_7_days AS l7
        LEFT JOIN actual_today AS ac_today ON l7.booking_time_bucket = ac_today.booking_time_bucket
    GROUP BY l7.booking_time_bucket
    ORDER BY l7.booking_time_bucket
)
    -- SELECT * FROM actuals_same_day_last_4_weeks;
, estimate_same_day_last_4_weeks AS (
    SELECT
        l4.booking_time_bucket,
        NULL AS booking_date,
        "estimate" AS segment_major,
        "estimate_same_day_last_4_weeks" AS segment_minor,
        CASE
            WHEN l4.booking_time_bucket < @today_current_hour_gst THEN ac_today.hourly_bookings
            ELSE ROUND(AVG(l4.hourly_bookings))
        END AS hourly_bookings -- estimate_same_day_last_4_weeks
    FROM average_same_day_last_4_weeks AS l4
        LEFT JOIN actual_today AS ac_today ON l4.booking_time_bucket = ac_today.booking_time_bucket
    GROUP BY l4.booking_time_bucket
    ORDER BY l4.booking_time_bucket
)
    -- SELECT * FROM actuals_same_day_last_4_weeks;
, estimate_same_day_7_days_ago AS (
    SELECT
        ac7.booking_time_bucket,
        NULL AS booking_date,
        "estimate" AS segment_major,
        "estimate_same_day_7_days_ago" AS segment_minor,
        CASE
            WHEN ac7.booking_time_bucket < @today_current_hour_gst THEN ac_today.hourly_bookings
            ELSE ROUND(AVG(ac7.hourly_bookings))
        END AS hourly_bookings -- estimate_same_day_7_days_ago
    FROM actual_7_days_ago AS ac7
        LEFT JOIN actual_today AS ac_today ON ac7.booking_time_bucket = ac_today.booking_time_bucket
    GROUP BY ac7.booking_time_bucket
    ORDER BY ac7.booking_time_bucket
)
    -- SELECT * FROM estimate_same_day_7_days_ago;
, union_all_data AS (
    SELECT 
        *
    FROM (
        SELECT 
            -- INSERTED '0000-01-01' AS DEFAULT TO ENSURE WHEN INSERTING DATA INTO THE FORECAST SUMMARY METRICS TABLE THAT VALUE IS NOT NULL SINCE NULL VALUES ARE TREATED AS UNIQUE MEANING THAT DUPLICATE ROWS WILL BE WRITTEN TO THE TABLE
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket,
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM actual_last_7_days
        
        UNION ALL

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket, 
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM actual_today

        UNION ALL

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket, 
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM actual_7_days_ago

        UNION ALL 

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket, 
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM actuals_same_day_last_4_weeks

        UNION ALL 

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket,
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM average_last_7_days

        UNION ALL

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket, 
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM average_same_day_last_4_weeks

        UNION ALL 

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket,
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM estimate_last_7_days

        UNION ALL 

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket,
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM estimate_same_day_last_4_weeks

        UNION ALL 

        SELECT 
            -- booking_date, 
            IFNULL(booking_date, '0000-01-01') AS booking_date, -- Replace NULL with a default value
            booking_time_bucket,
            segment_major,
            segment_minor, 
            hourly_bookings
        FROM estimate_same_day_7_days_ago

    ) combined_results
    ORDER BY booking_date ASC, segment_minor, booking_time_bucket
    -- ORDER BY booking_time_bucket ASC, booking_date ASC, segment_minor;
)
, final_data_table AS (
    SELECT 
        un.*, 
        DAYOFWEEK(un.booking_date) AS booking_date_day_of_week,
        @today_date_gst AS today_date_gst,
        @today_timestamp_utc AS today_timestamp_utc,
        @today_timestamp_gst AS today_timestamp_gst,
        @today_current_hour_gst AS today_current_hour_gst,
        IF(booking_time_bucket < @today_current_hour_gst, "yes", "no") AS booking_time_bucket_flag,
        @today_current_dayofweek_gst AS today_current_day_of_week_gst,
        @same_day_last_week AS same_day_last_week,
        @today_timestamp_gst AS created_at_gst
    FROM union_all_data AS un
)
-- SELECT * FROM final_data_table;
-- SELECT DISTINCT(segment_minor) AS segment_minor, COUNT(*) FROM final_data_table GROUP BY segment_minor;
SELECT  -- sum by segment_minor
    segment_minor, 
    today_current_hour_gst,
    SUM(CASE WHEN booking_time_bucket_flag IN ("yes") THEN hourly_bookings ELSE 0 END) booking_total_prior_to_current_hour,
    SUM(hourly_bookings) AS booking_total
FROM final_data_table 
WHERE segment_minor NOT IN ('actual_last_7_days', 'actuals_same_day_last_4_weeks')
GROUP BY segment_minor, today_current_hour_gst;

-- FORMATTED BY COLUMN
-- , hourly_estimate AS (
--     SELECT
--         @today_date_gst,
--         @today_timestamp_utc,
--         @today_timestamp_gst,
--         @today_current_hour_gst,
--         @today_current_dayofweek_gst,
--         @same_day_last_week,
--         l7.booking_time_bucket,
        
--         ROUND(AVG(l7.hourly_bookings)) AS average_last_7_days, 
--         ROUND(AVG(l4.hourly_bookings)) AS average_same_day_last_4_weeks, 
--         ROUND(AVG(ac7.hourly_bookings)) AS actual_7_days_ago, 
--         ac_today.hourly_bookings AS actual_today,
        
--         CASE
--             WHEN l7.booking_time_bucket < @today_current_hour_gst THEN ac_today.hourly_bookings
--             ELSE ROUND(AVG(l7.hourly_bookings))
--         END AS estimate_last_7_days,

--         CASE
--             WHEN l7.booking_time_bucket < @today_current_hour_gst THEN ac_today.hourly_bookings
--             ELSE ROUND(AVG(l4.hourly_bookings))
--         END AS estimate_same_day_last_4_weeks,
        
--         CASE
--             WHEN l7.booking_time_bucket < @today_current_hour_gst THEN ac_today.hourly_bookings
--             ELSE ROUND(AVG(ac7.hourly_bookings))
--         END AS estimate_same_day_7_days_ago

--     FROM actual_last_7_days AS l7
--         LEFT JOIN actuals_same_day_last_4_weeks AS l4 ON l7.booking_time_bucket = l4.booking_time_bucket
--         LEFT JOIN actual_7_days_ago AS ac7 ON l7.booking_time_bucket = ac7.booking_time_bucket
--         LEFT JOIN actual_today AS ac_today ON l7 .booking_time_bucket = ac_today.booking_time_bucket
--     GROUP BY l7.booking_time_bucket
--     ORDER BY l7.booking_time_bucket
-- )
-- SELECT * FROM hourly_estimate;
-- SELECT 
--     SUM(average_last_7_days) AS average_last_7_days,
--     SUM(average_same_day_last_4_weeks) AS actuals_same_day_last_4_weeks,
--     SUM(actual_7_days_ago) AS average_same_day_last_week,
    
--     SUM(CASE WHEN booking_time_bucket < @today_current_hour_gst THEN average_last_7_days END) AS current_hour_average_last_7_days,
--     SUM(CASE WHEN booking_time_bucket < @today_current_hour_gst THEN average_same_day_last_4_weeks END) AS current_hour_same_day_last_4_weeks,
--     SUM(CASE WHEN booking_time_bucket < @today_current_hour_gst THEN actual_7_days_ago END) AS current_hour_same_day_last_week,
--     SUM(CASE WHEN booking_time_bucket < @today_current_hour_gst THEN actual_today END) AS current_hour_hourly_today,
    
--     SUM(actual_today) AS today_total_actual_bookings,
    
--     SUM(estimate_last_7_days) AS estimate_last_7_days,
--     SUM(estimate_same_day_last_4_weeks) AS estimate_same_day_last_4_weeks,
--     SUM(estimate_same_day_7_days_ago) AS estimate_same_day_7_days_ago
    
-- FROM hourly_estimate
-- ;