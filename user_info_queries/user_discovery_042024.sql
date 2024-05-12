USE myproject;

-- SET
-- 	@str_date = '2024-01-01',
-- 	@end_date = '2024-01-31';

-- RENTAL USER TABLE
SELECT 
	*
FROM rental_fuser;
-- LIMIT 10;

-- AUTH USER TABLE
SELECT 
	*
FROM auth_user;
-- LIMIT 10;

-- GET ALL RECORDS WITH TEST USERS REMOVED
-- SELECT
-- 	fuser.user_ptr_id,
-- 	DATE_FORMAT(fuser.date_join, '%m-%d-%Y') AS date_join,
-- 	auth_user.first_name,
-- 	auth_user.last_name,
-- 	auth_user.email
-- FROM
-- 	rental_fuser AS fuser
-- 	-- LEFT JOIN myproject.auth_user au ON au.id = b.owner_id
-- 	LEFT JOIN myproject.auth_user AS auth_user ON auth_user.id = fuser.user_ptr_id

-- WHERE
-- 	-- LOGIC EXCLUDE TEST USERS FROM auth_user
-- 	LOWER(auth_user.first_name) NOT LIKE '%test%'
-- 	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
-- 	AND LOWER(auth_user.username) NOT LIKE '%test%'
-- 	AND LOWER(auth_user.email) NOT LIKE '%test%'
-- 	AND auth_user.last_name NOT LIKE 'N'
-- 	AND auth_user.email NOT LIKE 'abc@gmail.com';
	
--     -- DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
--     -- LOGIC TO EXCLUDE TEST BOOKINGS
--     -- AND COALESCE(b.vendor_id,'') NOT IN (33, 5 , 218, 23086) 
-- -- LIMIT 10;

-- records with no limit 	= 589,620
-- test users excluded 		= 588,293