-- rental_early_return_bookings discovery
USE myproject;
--                                                                      early June      06/24/24
-- STEP #1: DONE == REVIEW EARLY RETURN TABLE                           16,889          17,653
-- STEP #2: DONE == SUMMARIZE MULTIPLE RECORDS                          1,150           1,154
-- STEP #3: DONE == REVIEW MULTIPLE RECORDS DETAIL                      2,486           2,494
-- STEP #4: DONE == ONLY RETURN THE MOST RECENT EARLY RETURN RECORD     15,552          16,312
-- STEP #5: DONE == JOIN THE EARLY RETURN & BOOKING TABLE                               15,044

-- STEP #1
SELECT * FROM rental_early_return_bookings;
SELECT * FROM rental_early_return_bookings WHERE booking_id IN ('208353');

-- STEP #2
SELECT 
    booking_id,
    COUNT(*) AS duplicate_count
FROM rental_early_return_bookings
GROUP BY booking_id WITH ROLLUP
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
-- LIMIT 10;

-- STEP #3
SELECT *
FROM rental_early_return_bookings
WHERE booking_id IN (
    SELECT 
		booking_id
    FROM rental_early_return_bookings
    GROUP BY booking_id
    HAVING COUNT(*) > 1
);

-- STEP #4
SELECT
	*,
    booking_id, 
    MAX(date_created) AS most_recent_created_on
FROM rental_early_return_bookings
WHERE 
    -- booking_id IN ('225443', '210299', '30174')
    -- booking_id IN ('240709', '240727', '240755') -- extension days & early return
    -- booking_id IN ('240727') -- extension days & early return
    booking_id IN ('208353')
GROUP BY booking_id
ORDER BY booking_id;

-- STEP #5
SELECT 
	b.id,
    b.early_return,
    b.status,
    rs.status,
    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s') AS return_datetime,
    er.booking_id,
    er.new_return_date,
    er.new_return_time,
    er.old_return_date
FROM rental_car_booking2 AS b
    LEFT JOIN rental_status AS rs ON rs.id = b.status
    -- LEFT JOIN rental_early_return_bookings AS er ON b.id = er.booking_id -- NEED TO GET THE MOST RECENT RECORD TO ACCOUNT FOR DUPLICATES
	-- LEFT JOIN (SELECT MAX(booking_id), booking_id, old_return_date, new_return_date, new_return_time FROM rental_early_return_bookings AS er GROUP BY booking_id) er ON er.booking_id = b.id

    LEFT JOIN rental_early_return_bookings AS er ON er.booking_id = b.id AND er.is_active = 1 -- RETURNS MOST RECENT DATE RECORDS FOR EACH booking_id using is_active flag 1
WHERE 
	early_return = 1 -- THIS IT THE KEY FILTER; IF BOOKING EXISTS IN EARLY RETURN TABLE BUT NOT CODED AS 1 THEN NOT EARLY RETURN (SUCH AS 30174) 
	AND
    -- b.id IN ('30174') -- NO CODE IN rental_car_bookingv2 as early_return; ignore if no early return flag
    -- b.id IN ('225443', '210299', '30174')
    -- b.id IN ('240709', '240727', '240755') -- extension days & early return
    booking_id IN ('208353')
ORDER BY STR_TO_DATE(b.return_date_string, '%d/%m/%Y') DESC;
-- LIMIT 10;

SELECT 
	*,
	booking_id
FROM rental_charges
WHERE 
	-- booking_id IN ("210299")
	-- booking_id IN ('240709', '240727', '240755') -- extension days & early return
	-- booking_id IN ('240727') -- extension days & early return
    -- booking_id IN ('208353')
    booking_id IN ('168712') -- base fare missing
ORDER BY booking_id, from_date, charge_type_id
LIMIT 200;

SELECT 
	*,
	booking_id
FROM rental_charges
WHERE 
	charge_type_id = 35
ORDER BY booking_id, from_date, charge_type_id;
-- LIMIT 200;
