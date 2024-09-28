USE myproject;

SELECT
	early_return,
    id
FROM myproject.rental_car_booking2
WHERE id IN ('208353');

SELECT 
	* 
FROM rental_early_return_charges 
WHERE 
	charge = 0
	AND
	charge_type_id IN ('4');
-- 	AND
-- 	booking_id IN ('208353');
	-- booking_id IN ('43646', '72671', '67222', '104647', '94785', '206269', '208353', '228349', '226414', '237124');