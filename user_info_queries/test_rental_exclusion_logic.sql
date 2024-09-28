SELECT * FROM myproject.rental_car_booking2 LIMIT 5;
    
SELECT 
    owner_id, b.id, au.first_name, au.last_name, au.username
FROM
    myproject.rental_car_booking2 b
        LEFT JOIN
    myproject.auth_user au ON au.id = b.owner_id
WHERE
    LOWER(au.first_name) LIKE '%test%'
        OR LOWER(au.last_name) LIKE '%test%'
        OR LOWER(au.username) LIKE '%test%'
        OR LOWER(au.email) LIKE '%test%';
    -- LIMIT 1;
    
-- 	Burhan Khan what tech team is do when they make test booking , usually they assigned to particular vendor  therefore we exclude it from our query..
-- 		AND COALESCE(vendor_id,'') NOT IN (33, 5 , 218, 23086)
-- 		moreover, we also exclude this
-- 		first_name not LIKE '%test%' and last_name not like '%test%'
--      you can get the detail from user table.
--      select id, first_name, last_name,email from myproject.auth_user

-- 	Burhan Khan what tech team is do when they make test booking , usually they assigned to particular vendor  therefore we exclude it from our query..
-- 		AND COALESCE(vendor_id,'') NOT IN (33, 5 , 218, 23086)
-- 		moreover, we also exclude this
-- 		first_name not LIKE '%test%' and last_name not like '%test%'
--      you can get the detail from user table.
--      select id, first_name, last_name,email from myproject.auth_user

-- See booking_data_query_031424 or the latest version; logic is as below with a join to the auth.user table then WHERE that excludes certain vendors and users
--     FROM myproject.rental_car_booking2 b
-- 		LEFT JOIN myproject.rental_vendors rv ON rv.owner_id = b.vendor_id
--     	LEFT JOIN myproject.auth_user au ON au.id = b.owner_id

	-- FOR USE IN MYSQL WITH VARIABLES IN LINE 1
-- 	WHERE DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
-- 		AND COALESCE(b.vendor_id,'') NOT IN (33, 5 , 218, 23086) -- LOGIC TO EXCLUDE TEST BOOKINGS
-- 		-- AND COALESCE(b.vendor_id,'') IN (33, 5 , 218, 23086) -- LOGIC TO EXCLUDE TEST BOOKINGS
-- 		AND (LOWER(au.first_name) NOT LIKE '%test%' AND LOWER(au.last_name) NOT LIKE '%test%' AND LOWER(au.username) NOT LIKE '%test%' AND LOWER(au.email) NOT LIKE '%test%')