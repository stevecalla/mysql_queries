-- CALCULATE EARLY RETURN EXTENSION DAYS
USE myproject;

-- STEP #1:     DONE == GET NEW & OLD RETURN DATE FROM rental_car_bookings2 & rental_early_return_bookings
-- STEP #2:     DONE == GET EXTENSION DAYS FROM rental_messagesuser
-- STEP #3:     COMBINE rental_messageuser w

-- STEP #1:     GET NEW & OLD RETURN DATE FROM rental_car_bookings2 & rental_early_return_bookings
SELECT 
    b.id,
    er.new_return_date,
    er.new_return_time,
    er.old_return_date,
    er.old_return_time,

    TIMESTAMPDIFF(DAY, DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s'), DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')) AS date_difference_days,
    
    CASE    
		WHEN new_return_date THEN DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s')
        ELSE DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')
	END AS return_date
FROM rental_car_booking2 AS b
    LEFT JOIN rental_early_return_bookings AS er ON er.booking_id = b.id AND er.is_active = 1 -- RETURNS MOST RECENT DATE RECORDS FOR EACH booking_id using is_active flag 1
WHERE
    b.id IN ('240709', '240727', '240755', '204831') -- extension days & early return
LIMIT 10;

-- STEP #2:     GET EXTENSION DAYS FROM rental_messagesuser
SELECT * FROM rental_messagesuser AS m WHERE m.booking_id IN ('240709');
SELECT * FROM rental_messagesuser AS m WHERE m.booking_id IN ('204831');

-- STEP #2a:    GET ROLLUP OF EXTENSION DAYS
SELECT 
	booking_id,
	SUM(extension_days)
FROM rental_messagesuser m
WHERE 
	-- m.booking_id = '225443'
	-- m.booking_id = '210299'
	m.booking_id IN ('240709', '240727', '240755', '204831')
        AND (m.subject LIKE '%exten%' OR m.subject=CONCAT('Late Rental Return for Booking#', m.booking_id))
        AND m.extension_days > 0
        AND m.message LIKE '%Dear Partner%'
GROUP BY m.booking_id
ORDER BY m.booking_id;

-- STEP #3:     COMBINE BOOKING & EXTENSION DAYS TABLE
SELECT 
    b.id,
    b.status,
    rs.status,
    b.early_return,
    DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%Y-%m-%d %H:%i:%s') AS pickup_datetime,
    DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s') as new_return_date,
    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s') AS old_return_date,
    CASE    
        WHEN new_return_date THEN DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s')
        ELSE DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')
    END AS return_date,
    (
        SELECT 
            SUM(extension_days)
        FROM rental_messagesuser m
        WHERE 
            m.booking_id = b.id
            AND (m.subject LIKE '%exten%' OR m.subject = CONCAT('Late Rental Return for Booking#', m.booking_id))
            AND m.extension_days > 0
            AND m.message LIKE '%Dear Partner%'
    ) AS extension_days_total,
    TIMESTAMPDIFF(DAY, 
        DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s'), 
        DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')) 
    AS early_return_date_vs_original_return_date,
    (
        SELECT 
            SUM(extension_days) - TIMESTAMPDIFF(DAY, 
                DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s'), 
                DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s'))
        FROM 
            rental_messagesuser m
        WHERE 
            m.booking_id = b.id
            AND (m.subject LIKE '%exten%' OR m.subject = CONCAT('Late Rental Return for Booking#', m.booking_id))
            AND m.extension_days > 0
            AND m.message LIKE '%Dear Partner%'
    ) AS early_return_extension_days_negative,
    (
        SELECT 
            CASE 
                WHEN SUM(extension_days) <= TIMESTAMPDIFF(DAY, 
                    DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s'), 
                    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s'))
                THEN 0
                ELSE SUM(extension_days) - TIMESTAMPDIFF(DAY, 
                    DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s'), 
                    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s'))
            END
        FROM 
            rental_messagesuser m
        WHERE 
            m.booking_id = b.id
            AND (m.subject LIKE '%exten%' OR m.subject = CONCAT('Late Rental Return for Booking#', m.booking_id))
            AND m.extension_days > 0
            AND m.message LIKE '%Dear Partner%'
    ) AS early_return_extension_days,
    b.days AS old_days_total,
    er.new_days AS new_days_total
FROM 
    rental_car_booking2 AS b
    LEFT JOIN rental_early_return_bookings AS er ON er.booking_id = b.id AND er.is_active = 1
    LEFT JOIN rental_status AS rs ON rs.id = b.status
WHERE b.id IN ('240709', '240727', '240755', '277097')
-- WHERE b.early_return = 1
HAVING extension_days_total IS NOT NULL
ORDER BY early_return_extension_days ASC;
-- LIMIT 10;







