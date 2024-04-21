USE myproject;

SET
	@str_date = '2024-01-01',
	@end_date = '2024-01-31';

-- GET USERS BOOKING HISTORY
SELECT
	fuser.user_ptr_id,
	auth_user.id,
	rcb.owner_id,

	DATE_FORMAT(fuser.date_join, '%m-%d-%Y') AS date_join,

	auth_user.first_name,
	auth_user.last_name,
	auth_user.email

	-- BOOKING INFO
	rcb.id AS booking_id,
	rcb.vendor_id AS vendor_id,
	rcb.status AS booking_status
FROM
	rental_fuser AS fuser
	LEFT JOIN myproject.auth_user AS auth_user ON auth_user.id = fuser.user_ptr_id
	LEFT JOIN myproject.rental_car_booking2 rcb ON rcb.owner_id = fuser.user_ptr_id
WHERE
	DATE(fuser.date_join) = '2024-01-01'
	-- LOGIC EXCLUDE TEST USERS FROM auth_user
	AND LOWER(auth_user.first_name) NOT LIKE '%test%'
	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
	AND LOWER(auth_user.username) NOT LIKE '%test%'
	AND LOWER(auth_user.email) NOT LIKE '%test%'
	AND auth_user.last_name NOT LIKE 'N'
	AND auth_user.email NOT LIKE 'abc@gmail.com'
	
    -- DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
    -- LOGIC TO EXCLUDE TEST BOOKINGS
    AND COALESCE(rcb.vendor_id,'') NOT IN (5, 33, 218, 23086);
-- LIMIT 10;