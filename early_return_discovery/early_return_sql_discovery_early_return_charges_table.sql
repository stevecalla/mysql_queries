USE myproject;

-- STEP #1: DONE == REVIEW EARLY RETURN CHARGES TABLE; RECORDS 106,966
-- STEP #2: REVIEW RECORDS FOR SAMPLE
-- STEP #3: REVIEW EXTENSION DAYS
-- STEP #4:

-- STEP #1
SELECT * FROM rental_early_return_charges LIMIT 10;

-- STEP #2
SELECT 
	* 
FROM rental_early_return_charges 
WHERE 
	-- booking_id IN ('30174'); -- NO RECORDS
	-- booking_id IN ('210299');
	booking_id IN ('225443');

-- STEP #3
SELECT 
	booking_id,
	SUM(extension_days)
FROM rental_messagesuser m
WHERE 
	m.booking_id = '225443'
	AND 
	(m.subject LIKE '%exten%' OR m.subject=CONCAT('Late Rental Return for Booking#', m.booking_id))
	AND m.extension_days > 0
	AND m.message LIKE '%Dear Partner%'
GROUP BY booking_id;
