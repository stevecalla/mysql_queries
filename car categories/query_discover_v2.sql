SELECT 
	* 
FROM myproject.rental_car_booking2 
LIMIT 10;

SELECT
	b.id,
	b.car_id,
	b.car_available_id
FROM myproject.rental_car_booking2 AS b
WHERE b.id IN ("246414", '240667')
LIMIT 10;