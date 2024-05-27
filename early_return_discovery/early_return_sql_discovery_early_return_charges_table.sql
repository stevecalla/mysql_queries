USE myproject;

-- STEP #1: DONE == REVIEW EARLY RETURN CHARGES TABLE; RECORDS 106,966
-- STEP #2: REVIEW RECORDS FOR SAMPLE
-- STEP #3: REVIEW EXTENSION DAYS
-- STEP #4: REVIEW RENTAL CHARGES TABLE

-- STEP #1
SELECT * FROM rental_early_return_charges LIMIT 10;

-- STEP #2: REVIEW RECORDS FOR SAMPLE
SELECT 
	* 
FROM rental_early_return_charges 
WHERE 
	-- booking_id IN ('30174'); -- NO RECORDS
	-- booking_id IN ('210299');
	-- booking_id IN ('225443');
	-- booking_id IN ('240709', '240727', '240755'); -- extension days & early return
	booking_id IN ('240709');  -- extension days & early return 3334.82, 61 days, 47.61/day
	-- booking_id IN ('240755');  -- extension days & early return 1333.54, 11 days, 114.14/day
	-- booking_id IN ('240727'); -- extension days & early return 1975.15, 19 days, 99.85/day

-- STEP #3: REVIEW EXTENSION DAYS
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

-- STEP #4 - REVIEW RENTAL CHARGES TABLE
SELECT 
	*,
	booking_id
FROM myproject.rental_charges
WHERE 
	-- booking_id IN ("225443")
	-- booking_id IN ("210299")
	-- booking_id IN ('240709', '240727', '240755') -- extension days & early return
	booking_id IN ('240727') -- extension days & early return
ORDER BY booking_id, from_date, charge_type_id
LIMIT 200;
