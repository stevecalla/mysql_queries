USE rental_car;

SELECT * FROM rental_car AS cr LIMIT 10;

SELECT 
	cr.user_id,
    COUNT(*)
FROM rental_car AS cr;

SELECT * FROM myproject.rental_booking_car_driver_status LIMIT 10;