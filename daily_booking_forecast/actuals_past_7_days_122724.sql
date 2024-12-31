USE myproject;

-- SET TODAY DATE VARIABLES BASED ON CONVERTING NOW UTC INTO GST
    SET @today_date_minus_1_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 1 DAY), '%Y-%m-%d'); -- Set the variable for yesterday's date in GST
    SET @today_date_minus_2_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 2 DAY), '%Y-%m-%d'); -- Set the variable for current date - 2 in GST
    SET @today_date_minus_3_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 3 DAY), '%Y-%m-%d'); -- Set the variable for current date - 3 in GST
    SET @today_date_minus_4_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 4 DAY), '%Y-%m-%d'); -- Set the variable for current date - 4 in GST
    SET @today_date_minus_5_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 5 DAY), '%Y-%m-%d'); -- Set the variable for current date - 5 in GST
    SET @today_date_minus_6_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 6 DAY), '%Y-%m-%d'); -- Set the variable for current date - 6 in GST
    SET @today_date_minus_7_gst = DATE_FORMAT(DATE_SUB(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), INTERVAL 7 DAY), '%Y-%m-%d'); -- Set the variable for current date - 7 in GST
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