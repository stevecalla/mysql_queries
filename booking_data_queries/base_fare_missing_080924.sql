USE myproject;

SELECT 
	*
FROM rental_charges
WHERE 
    booking_id IN ('168712') -- base fare missing
ORDER BY booking_id, from_date, charge_type_id
LIMIT 200;

USE myproject;

SELECT
	rental_type_id,
    COUNT(*)
FROM myproject.rental_car_booking2
GROUP BY rental_type_id
LIMIT 10;
-- WHERE id IN ('208353');

-- 0 should be treated as 1

SELECT * FROM myproject.rental_rentaltypes;

-- '151091'
-- '134561'
-- '87679'