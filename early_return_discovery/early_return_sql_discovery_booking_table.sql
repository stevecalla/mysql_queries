-- discovery to join rental_car_booking2 and early return table / data
USE myproject;
--																					06/24/24
-- STEP #1:     DONE == FIND EARLY RETURN FLAG = early_return
-- STEP #2:     DONE == COUNT OF EARLY RETURN; 										285,022, NOT EARLY RETURN = 269,981, 1 IS EARLY RETURN = 15,041
-- STEP #4:     DONE == GET A SAMPLE OF EARLY RETURNS
-- STEP #4A:    DONE == DON'T USE THE rental_end_date_string; DOESN'T LOOK ACCURATE
-- STEP #5:     DONE == JOIN BOOKING TABLE WITH EARLY RETURN TABLE
-- STEP #6:     DONE == CREATE NEW RETURN DATE FIELD; IF EARY RETURN DATE EXISTS USE IT; OTHERWISE USE RETURN DATE STRING
-- STEP #7:     DONE == REVIEW BOOKINGS WITH early_return = 0; THESE RECORDS SHOULDN'T HAVE new_return_date / new_return_time FROM EARLY RETURN TABLE
-- STEP #8:     CALCULATE EARLY RETURN EXTENSION DAYS

-- STEP #1
SHOW COLUMNS FROM rental_car_booking2;

-- STEP #2
SELECT DISTINCT(early_return), COUNT(*) FROM rental_car_booking2 GROUP BY early_return WITH ROLLUP LIMIT 10;

-- STEP #4: GET A SAMPLE OF EARLY RETURNS
SELECT 
    *, early_return AS v2 
FROM rental_car_booking2 
WHERE 
    -- id IN ('225443', '210299', '30174', '267504', '264106', '240667') 
    id IN ('210299', '30174', '267504', '264106', '240667') 
LIMIT 10;
-- NOTE THAT 30174 early_return flag = 0 BUT IT DOES HAVE A RECORD IN THE EARLY RETURN TABLE; IGNORE EARLY RETURN RECORD GIVEN EARLY RETURN FLAG = 0
-- NOTE THAT 267504 A& 264106 ARE TEST BOOKINGS

-- STEP #5 JOIN BOOKING TABLE WITH EARLY RETURN TABLE
-- STEP #6: CREATE NEW RETURN DATE FIELD; IF EARY RETURN DATE EXISTS USE IT; OTHERWISE USE RETURN DATE STRING
SELECT 
	b.id,
    b.early_return,
    b.status,
    rs.status,
    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s') AS return_datetime,
    er.new_return_date,
    er.new_return_time,
    CASE    
		WHEN new_return_date THEN DATE_FORMAT(CONCAT(STR_TO_DATE(er.new_return_date, '%d/%m/%Y'), ' ', er.new_return_time), '%Y-%m-%d %H:%i:%s')
        ELSE DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')
	END AS return_date
FROM rental_car_booking2 AS b
    LEFT JOIN rental_status AS rs ON rs.id = b.status
	-- LEFT JOIN (SELECT MAX(booking_id), booking_id, old_return_date, new_return_date, new_return_time FROM rental_early_return_bookings AS er GROUP BY booking_id) er ON er.booking_id = b.id -- RETURNS MOST RECENT RECORD FOR EACH booking_id

    LEFT JOIN rental_early_return_bookings AS er ON er.booking_id = b.id AND er.is_active = 1 -- RETURNS MOST RECENT DATE RECORDS FOR EACH booking_id using is_active flag 1
WHERE 
	b.early_return = 1
    -- AND
    -- b.id IN ('225443', '210299', '30174', '240667')
    -- b.id IN ('210299', '30174', '240667')
ORDER BY STR_TO_DATE(b.return_date_string, '%d/%m/%Y') DESC;
-- LIMIT 10;

-- STEP #7
SELECT 
	b.id,
    b.early_return,
    b.status,
    rs.status,
    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s') AS return_datetime,
    er.new_return_date,
    er.new_return_time
FROM rental_car_booking2 AS b
    LEFT JOIN rental_status AS rs ON rs.id = b.status
	LEFT JOIN (SELECT MAX(booking_id), booking_id, old_return_date, new_return_date, new_return_time FROM rental_early_return_bookings AS er GROUP BY booking_id) er ON er.booking_id = b.id -- RETURNS MOST RECENT RECORD FOR EACH booking_id
WHERE b.early_return = 0
    AND b.status <> 8
ORDER BY STR_TO_DATE(b.return_date_string, '%d/%m/%Y') DESC
LIMIT 10;

-- STEP #8: CALCULATE EARLY RETURN EXTENSION DAYS
-- a) SUBTRACT NEW RETURN DATE FROM OLD RETURN DAY
-- b) SUBTRACT RESULT OF ABOVE a) FROM OLD EXTENSION DAYS
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
    booking_id IN ('240709', '240727', '240755') -- extension days & early return
LIMIT 10;

SELECT 
	booking_id,
	SUM(extension_days)
FROM rental_messagesuser m
WHERE 
	-- m.booking_id = '225443'
	-- m.booking_id = '210299'
	m.booking_id IN ('240709', '240727', '240755')
	AND 
	(m.subject LIKE '%exten%' OR m.subject=CONCAT('Late Rental Return for Booking#', m.booking_id))
	AND m.extension_days > 0
	AND m.message LIKE '%Dear Partner%'
GROUP BY booking_id;





