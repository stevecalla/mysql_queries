USE myproject;

-- SET DATE VARIABLES
    SET @start_date = '2024-09-10';

    -- SET CURRENT DATE BASED ON b.created_on DATE FROM RENTAL CAR BOOKINGS TABLE
    SELECT MAX(DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d'))
    INTO @current_date_gst
    FROM rental_car_booking2 AS b;

    -- TEST DATES
    SELECT 
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL -6 HOUR) AS current_datetime_mst, -- convert from utc to gst
        UTC_TIMESTAMP() AS current_datetime_ust, -- in utc
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS current_datetime_gst, -- convert from utc to gst
        DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL -6 HOUR), '%Y-%m-%d') AS formatted_date_mtn,
        DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d') AS formatted_date_utc,
        DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d') AS formatted_date_gst;

-- SET TODAY DATE VARIABLES BASED ON CONVERTING NOW UTC INTO GST

    SET @today_date_minus_1_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 1 DAY), '%Y-%m-%d'); -- Set the variable for yesterday's date in GST
    SET @today_date_minus_2_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 2 DAY), '%Y-%m-%d'); -- Set the variable for current date - 2 in GST
    SET @today_date_minus_3_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 3 DAY), '%Y-%m-%d'); -- Set the variable for current date - 3 in GST
    SET @today_date_minus_4_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 4 DAY), '%Y-%m-%d'); -- Set the variable for current date - 4 in GST
    SET @today_date_minus_5_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 5 DAY), '%Y-%m-%d'); -- Set the variable for current date - 5 in GST
    SET @today_date_minus_6_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 6 DAY), '%Y-%m-%d'); -- Set the variable for current date - 6 in GST
    SET @today_date_minus_7_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 7 DAY), '%Y-%m-%d'); -- Set the variable for current date - 7 in GST
-- END

-- VIEW RENTAL CAR BOOKING 2 TABLE
    SELECT * FROM rental_car_booking2 LIMIT 10;
-- END

-- BOOKING COUNT FOR MOST RECENT TODAY PLUS PRIOR 7 DAYS
    SELECT
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') AS booking_date_gst,
        (
            SELECT 
                DATE_FORMAT(DATE_ADD(MAX(created_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s')
            FROM rental_car_booking2 AS b
        ) AS date_most_recent_created_on_gst,

        -- COUNT OF BOOKINGS
        COUNT(*) AS current_bookings,

        -- CURRENT DATE / TIME GST    
        DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS created_at_gst,
        co.name AS delivery_country

    FROM rental_car_booking2 AS b
        LEFT JOIN rental_status AS rs ON b.status = rs.id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID

    WHERE 
        rs.status != "Cancelled by User"
        AND
        -- CREATED ON DATE IS WITHIN THE LAST 7 DAYS

        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') >= (
            SELECT 
                DATE_FORMAT(DATE_SUB(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), INTERVAL 7 DAY), '%Y-%m-%d')
            FROM rental_car_booking2 AS b
        )
        AND 
        co.name IN ('United Arab Emirates')

        -- CREATED ON DATE IS EQUAL TO THE MAX CREATED ON DATE (WHICH SHOULD BE TODAY)
        -- DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = (
        -- 	SELECT 
        -- 		DATE_FORMAT(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), '%Y-%m-%d')
        -- 	FROM rental_car_booking2 AS b
        -- )
    GROUP BY booking_date_gst
    ORDER BY booking_date_gst
    LIMIT 10;
-- END

-- RAW BOOKING DATA
    SELECT
        b.id,
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS booking_datetime_utc,
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS booking_datetime_gst,
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') AS booking_date_gst,
        DAYNAME(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) AS day_of_week_gst,
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket_gst,
        CASE
            WHEN DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d') = DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') THEN 1
            ELSE 0
        END AS is_today,
        -- MAX DATE
        (
        SELECT DATE_ADD(MAX(created_on), INTERVAL 4 HOUR)
            FROM rental_car_booking2 AS b
        ) AS date_most_recent_created_on_gst,
        -- 7 DAYS / 1 WEEK AGO
        (
        SELECT DATE_FORMAT(DATE_SUB(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), INTERVAL 7 DAY), '%Y-%m-%d')
            FROM rental_car_booking2 AS b
        ) AS date_7_days_ago_gst,
        1 AS count,
        rs.status,
        co.name,
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS created_at,
        MOD(HOUR(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR)), 20) AS current_hour -- MOD WITH , 20 ENSURES THE HOUR WRAPS TO 0 AT 20 (BECAUSE 20 + 4 = MIDNIGHT OR ZERO)
    FROM rental_car_booking2 AS b
        LEFT JOIN rental_status AS rs ON b.status = rs.id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') >= (
        SELECT DATE_FORMAT(DATE_SUB(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), INTERVAL 7 DAY), '%Y-%m-%d')
        FROM rental_car_booking2 AS b
    )
    ORDER BY booking_datetime_gst DESC, booking_time_bucket_gst DESC;
-- END

-- BOOKINGS BY STATUS BY DATE
    SELECT
        rs.status,
        -- Pivot for each unique booking_date EXCLUDING CANCELLED
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-13' THEN 1 ELSE 0 END) AS '2024-09-13',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-14' THEN 1 ELSE 0 END) AS '2024-09-14',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-15' THEN 1 ELSE 0 END) AS '2024-09-15',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-16' THEN 1 ELSE 0 END) AS '2024-09-16',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-17' THEN 1 ELSE 0 END) AS '2024-09-17',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-18' THEN 1 ELSE 0 END) AS '2024-09-18',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-19' THEN 1 ELSE 0 END) AS '2024-09-19',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-20' THEN 1 ELSE 0 END) AS '2024-09-20',
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS date_time_now,
        MOD(HOUR(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR)), 20) AS current_hour -- MOD WITH , 20 ENSURES THE HOUR WRAPS TO 0 AT 20 (BECAUSE 20 + 4 = MIDNIGHT OR ZERO)
    FROM rental_car_booking2 AS b
        LEFT JOIN rental_status AS rs ON b.status = rs.id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') >= (
            SELECT 
                DATE_FORMAT(DATE_SUB(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), INTERVAL 7 DAY), '%Y-%m-%d')
            FROM rental_car_booking2 AS b
        )
        -- AND 
        -- DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') < (HOUR(UTC_TIMESTAMP()) + 4)
    GROUP BY rs.status WITH ROLLUP
    ORDER BY rs.status;
-- END

-- BOOKINGS BY COUNTRY BY DATE
    SELECT
        co.name,
        -- Pivot for each unique booking_date EXCLUDING CANCELLED
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-13' THEN 1 ELSE 0 END) AS '2024-09-13',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-14' THEN 1 ELSE 0 END) AS '2024-09-14',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-15' THEN 1 ELSE 0 END) AS '2024-09-15',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-16' THEN 1 ELSE 0 END) AS '2024-09-16',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-17' THEN 1 ELSE 0 END) AS '2024-09-17',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-18' THEN 1 ELSE 0 END) AS '2024-09-18',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-19' THEN 1 ELSE 0 END) AS '2024-09-19',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-20' THEN 1 ELSE 0 END) AS '2024-09-20',
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS date_time_now,
        MOD(HOUR(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR)), 20) AS current_hour -- MOD WITH , 20 ENSURES THE HOUR WRAPS TO 0 AT 20 (BECAUSE 20 + 4 = MIDNIGHT OR ZERO)
    FROM rental_car_booking2 AS b
        LEFT JOIN rental_status AS rs ON b.status = rs.id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE 
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') > @start_date
        -- AND 
        -- DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') < (HOUR(UTC_TIMESTAMP()) + 4)
    GROUP BY co.name WITH ROLLUP
    ORDER BY co.name;
-- END

-- BOOKINGS BY HOUR BUCKET BY DAY OF THE WEEK; UNTIL THE CURRENT HOUR BUCKET (EXCLUDES FUTURE HOUR BUCKETS)
    SELECT
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
        -- FORMAT(COUNT(*), 0) AS total_count,
        -- Pivot for each unique booking_date EXCLUDING CANCELLED
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-13' THEN 1 ELSE 0 END) AS '2024-09-13',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-14' THEN 1 ELSE 0 END) AS '2024-09-14',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-15' THEN 1 ELSE 0 END) AS '2024-09-15',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-16' THEN 1 ELSE 0 END) AS '2024-09-16',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-17' THEN 1 ELSE 0 END) AS '2024-09-17',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-18' THEN 1 ELSE 0 END) AS '2024-09-18',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-19' THEN 1 ELSE 0 END) AS '2024-09-19',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-20' THEN 1 ELSE 0 END) AS '2024-09-20',
        -- SUM(CASE WHEN rs.status != "Cancelled by User" THEN 1 ELSE 0 END) AS total_count_excluding_cancel,
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS date_time_now,
        MOD(HOUR(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR)), 20) AS current_hour -- MOD WITH , 20 ENSURES THE HOUR WRAPS TO 0 AT 20 (BECAUSE 20 + 4 = MIDNIGHT OR ZERO)
    FROM rental_car_booking2 AS b
        LEFT JOIN rental_status AS rs ON b.status = rs.id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') >= (
            SELECT 
                DATE_FORMAT(DATE_SUB(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), INTERVAL 7 DAY), '%Y-%m-%d')
            FROM rental_car_booking2 AS b
        )
        AND 
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') < (HOUR(UTC_TIMESTAMP()) + 4)
    GROUP BY DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') WITH ROLLUP
    ORDER BY DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H');
-- END 

-- BOOKINGS BY HOUR BUCKET BY DAY OF THE WEEK; FOR ALL HOUR BOOKING
    SELECT
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
        -- FORMAT(COUNT(*), 0) AS total_count,
        -- Pivot for each unique booking_date EXCLUDING CANCELLED
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-12' THEN 1 ELSE 0 END) AS '2024-09-12',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-13' THEN 1 ELSE 0 END) AS '2024-09-13',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-14' THEN 1 ELSE 0 END) AS '2024-09-14',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-15' THEN 1 ELSE 0 END) AS '2024-09-15',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-16' THEN 1 ELSE 0 END) AS '2024-09-16',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-17' THEN 1 ELSE 0 END) AS '2024-09-17',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-18' THEN 1 ELSE 0 END) AS '2024-09-18',
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-09-19' THEN 1 ELSE 0 END) AS '2024-09-19',
        -- SUM(CASE WHEN rs.status != "Cancelled by User" THEN 1 ELSE 0 END) AS total_count_excluding_cancel,
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS date_time_now_gst,
        DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d') AS date_now_gst,
        MOD(HOUR(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR)), 20) AS current_hour -- MOD WITH , 20 ENSURES THE HOUR WRAPS TO 0 AT 20 (BECAUSE 20 + 4 = MIDNIGHT OR ZERO)
        
    FROM rental_car_booking2 AS b
        LEFT JOIN rental_status AS rs ON b.status = rs.id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') >= (
            SELECT 
                DATE_FORMAT(DATE_SUB(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), INTERVAL 8 DAY), '%Y-%m-%d')
            FROM rental_car_booking2 AS b
        )
        AND 
        co.name IN ('United Arab Emirates')
        -- AND 
        -- DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') < (HOUR(UTC_TIMESTAMP()) + 4)
    GROUP BY DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') WITH ROLLUP
    ORDER BY DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H');
    -- LIMIT 1000;
-- END

-- BOOKINGS BY HOUR BUCKET BY DAY OF THE WEEK; FOR ALL HOUR BOOKING
    SELECT
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
        -- FORMAT(COUNT(*), 0) AS total_count,
        -- Pivot for each unique booking_date EXCLUDING CANCELLED
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_minus_7_gst THEN 1 ELSE 0 END) AS today_minus_7,
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_minus_6_gst THEN 1 ELSE 0 END) AS today_minus_6,
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_minus_5_gst THEN 1 ELSE 0 END) AS today_minus_5,
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_minus_4_gst THEN 1 ELSE 0 END) AS today_minus_4,
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_minus_3_gst THEN 1 ELSE 0 END) AS today_minus_3,
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_minus_2_gst THEN 1 ELSE 0 END) AS today_minus_2,
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_minus_1_gst THEN 1 ELSE 0 END) AS today_minus_1,
        SUM(CASE WHEN rs.status != "Cancelled by User" AND DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') = @today_date_gst THEN 1 ELSE 0 END) AS today,
        -- SUM(CASE WHEN rs.status != "Cancelled by User" THEN 1 ELSE 0 END) AS total_count_excluding_cancel,
        DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS date_time_now_gst,
        @today_date_gst,
        MOD(HOUR(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR)), 20) AS current_hour -- MOD WITH , 20 ENSURES THE HOUR WRAPS TO 0 AT 20 (BECAUSE 20 + 4 = MIDNIGHT OR ZERO)
        
    FROM rental_car_booking2 AS b
        LEFT JOIN rental_status AS rs ON b.status = rs.id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    WHERE 
        DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') >= (
            SELECT 
                DATE_FORMAT(DATE_SUB(DATE_ADD(MAX(b.created_on), INTERVAL 4 HOUR), INTERVAL 8 DAY), '%Y-%m-%d')
            FROM rental_car_booking2 AS b
        )
        AND 
        co.name IN ('United Arab Emirates')
        -- AND 
        -- DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') < (HOUR(UTC_TIMESTAMP()) + 4)
    GROUP BY DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') WITH ROLLUP
    ORDER BY DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H');
    -- LIMIT 1000;
-- END