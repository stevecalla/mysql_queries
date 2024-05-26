USE myproject;

-- STEP #1: DONE == REVIEW EARLY RETURN TABLE; RECORDS 16,889
-- STEP #2: DONE == SUMMARIZE DUPLICATE RECORDS; RECORDS 1,150 HAVE MORE THAN 1 RECORD
-- STEP #3: DONE == REVIEW DUPLIATE RECORDS DETAIL; TOTAL RECORDS WITHOUT GROUPING IS 2,486
-- STEP #4: DONE == ONLY RETURN THE MOST RECENT EARLY RETURN RECORD; RECORDS 15,552
-- STEP #5: DONE == JOIN THE EARLY RETURN & BOOKING TABLE

-- STEP #1
SELECT * FROM rental_early_return_bookings;

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
    SELECT booking_id
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
    booking_id IN ('225443', '210299', '30174')
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
	LEFT JOIN (SELECT MAX(booking_id), booking_id, old_return_date, new_return_date, new_return_time FROM rental_early_return_bookings AS er GROUP BY booking_id) er ON er.booking_id = b.id
WHERE 
	-- early_return = 1 -- CAN'T USE AS FILTER BECAUSE SOME BOOKINGS (SUCH AS 30174) NOT CODED AS EARLY RETURN = 1
	-- AND
    -- b.id IN ('30174') -- NOT CODE IN rental_car_bookingv2 as early_return;
    b.id IN ('225443', '210299', '30174')
ORDER BY STR_TO_DATE(b.return_date_string, '%d/%m/%Y') DESC;
-- LIMIT 10;
