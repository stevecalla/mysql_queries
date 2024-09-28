-- rental_early_return_charges discovery
USE myproject;
--															early June	06/24/24
-- STEP #1: DONE == REVIEW EARLY RETURN CHARGES TABLE		106,966		
-- STEP #2: REVIEW RECORDS FOR SAMPLE
-- STEP #3: REVIEW EXTENSION DAYS
-- STEP #4: REVIEW RENTAL CHARGES TABLE
 
-- STEP #1
SELECT * FROM rental_early_return_charges;
 
-- STEP #1
SELECT 
	* 
FROM rental_early_return_charges 
WHERE 
	charge = 0
-- 	AND
-- 	charge_type_id IN ('4')
	AND
	-- booking_id IN ('208353');
	-- booking_id IN ('43646', '67222', '72671', '104647', '94785', '206269', '208353', '228349', '226414', '237124');
	booking_id IN ('51859', '75241', '271272');

-- STEP #2: REVIEW RECORDS FOR SAMPLE
SELECT 
	* 
FROM rental_early_return_charges 
WHERE 
	-- booking_id IN ('29837', '11031') -- 29837 STILL $0 REVENUE AS OF 6/25/24; 11031 HAD NO REVENUE AS OF 6/5/24 BUT DOES AS OF 6/25/24
	booking_id IN ('208353')
	-- booking_id IN ('43646', '67222', '72671', '104647', '94785', '206269', '208353', '228349', '226414', '237124')
	AND
	charge_type_id IN ('4')
ORDER BY booking_id;

-- OTHER EXMAPLES FOR QUERY ABOVE
	-- booking_id IN ('30174'); -- NO RECORDS
	-- booking_id IN ('210299');
	-- booking_id IN ('225443');
	-- booking_id IN ('240709', '240727', '240755'); -- extension days & early return
	-- booking_id IN ('240709');  -- extension days & early return 3334.82, 61 days, 47.61/day
	-- booking_id IN ('240755');  -- extension days & early return 1333.54, 11 days, 114.14/day
	-- booking_id IN ('240727'); -- extension days & early return 1975.15, 19 days, 99.85/day
	-- booking_id IN ('21899'); -- issue with additional driver rate on early return charge table
	-- booking_id IN ('105780'); -- early return; no record in early return charges table
    -- booking_id IN ('101065'); -- early return; no record in early return charges table
	-- type_name = 'Additional Driver' AND total_charge > 100000;

-- STEP #3: REVIEW EXTENSION DAYS
SELECT 
	booking_id,
	SUM(extension_days)
FROM rental_messagesuser m
WHERE 
	-- m.booking_id = '225443'
	-- m.booking_id = '210299'
	booking_id IN ('208353')
	-- m.booking_id IN ('240709', '240727', '240755')
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
	-- booking_id IN ('240727') -- extension days & early return
	-- booking_id IN ('21899') -- issue with additional driver rate on early return charge table
	-- booking_id IN ('208353')
	booking_id IN ('51859', '75241', '271272')
	-- booking_id IN ('105780') -- no record in early return table?
    -- booking_id IN ('101065') -- no record in early return table?
ORDER BY booking_id, from_date, charge_type_id
LIMIT 200;
