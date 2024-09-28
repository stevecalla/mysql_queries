USE myproject;
SET @str_date = '2024-01-01',@end_date = '2024-12-31';

-- THIS QUERY IS TO UNDERSTAND THE TABLE LAYOUT/JOINS FROM rental_cars_available, rental_car, rental_cat and rental_car_booking2
SELECT 
	-- TABLE = rental_cars_available
	-- car_available_id in rental_car_booking2 is actually car_asked updated by tech and its standardized category
	-- LEFT JOIN (SELECT id, car_name,cat_id FROM rental_cars_available) AS car ON (rental_car_booking2).car_available_id = car.id
	b.car_available_id AS b_car_avail_id,
    ca.id AS ca_id,
	ca.car_name AS ca_avail_car_name, -- car_requested / car_asked / car available

	-- TABLE = rental_car
	-- you can find the car assigned from
	-- LEFT JOIN (SELECT id, car_name FROM rental_car) AS car2 ON (rental_car_booking2).car_id = car2.id
    b.car_id,
    c.id,
	c.car_name AS c_car_name,
	c.make,
	c.cat_id AS c_car_cat_id,

	-- TABLE = rental_car
	-- IS THIS USED FOR APP DISPLAY?
	-- 	We pick the car category from the rental_cat table, using left join on cat_id from the "rental_cars_available" table
    -- (select id,cat_name from rental_cat) as cat on car.cat_id = cat.id
	cat.cat_name AS cat_car_cat_name,
    
    -- TABLE = rental_car_booking2
	b.id AS booking_id,

	-- TABLE = rental_status
	b.status AS b_status_id, 
	rs.status as rs_status_description

-- BOOKING INFO
FROM myproject.rental_car_booking2 b
-- USER INFO (USED TO EXCLUDE TEST RENTALS IN THE WHERE CLAUSE)
LEFT JOIN myproject.auth_user au ON au.id = b.owner_id 
-- CAR INFO
LEFT JOIN myproject.rental_cars_available ca ON ca.id = b.car_available_id
LEFT JOIN myproject.rental_car c ON c.id = b.car_id
LEFT JOIN myproject.rental_cat cat ON cat.id = ca.cat_id
-- STATUS INFO
LEFT JOIN myproject.rental_status rs on rs.id = b.status 
WHERE 
	-- FOR USE IN MYSQL WITH VARIABLES IN LINE 1
	DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
	-- LOGIC TO EXCLUDE TEST BOOKINGS
	AND COALESCE(b.vendor_id,'') NOT IN (33, 5 , 218, 23086) 
	AND (LOWER(au.first_name) NOT LIKE '%test%' AND LOWER(au.last_name) NOT LIKE '%test%' AND LOWER(au.username) NOT LIKE '%test%' AND LOWER(au.email) NOT LIKE '%test%')
ORDER BY ca.car_name ASC;
-- LIMIT 5000;

-- THE 2 QUERIES BELOW TAKE A LOOK AT THE cat_name FIELD IN THE rent_cat TABLE
-- THE cat_name FIELD IS USED, IN PART, IN THE car_discovery_041724_create_make_model_type.sql TO DETERMINE car_type
SELECT
	id,
	cat_name 
FROM rental_cat;

-- DISTINCT cat-name QUERY
SELECT
	DISTINCT(cat_name),
	COUNT(*) 
FROM rental_cat
GROUP BY cat_name
ORDER BY cat_name;

-- GET cat_name WITH BOOKING COUNT PIVOTED BY BOOKING YEAR (INCLUDES TEST USERS / BOOKINGS)
SELECT
	DISTINCT(cat.cat_name)
	-- , DATE_ADD(rcb.created_on, INTERVAL 4 HOUR)
	-- , DATE_FORMAT(DATE_ADD(rcb.created_on, INTERVAL 4 HOUR), '%Y')
    , FORMAT(SUM(CASE WHEN DATE_FORMAT(DATE_ADD(rcb.created_on, INTERVAL 4 HOUR), '%Y') NOT IN (2021, 2022, 2023, 2024) THEN 1 ELSE 0 END), 0) AS 'Other'
    , FORMAT(SUM(CASE WHEN DATE_FORMAT(DATE_ADD(rcb.created_on, INTERVAL 4 HOUR), '%Y') = 2021 THEN 1 ELSE 0 END), 0) AS '2021'
    , FORMAT(SUM(CASE WHEN DATE_FORMAT(DATE_ADD(rcb.created_on, INTERVAL 4 HOUR), '%Y') = 2022 THEN 1 ELSE 0 END), 0) AS '2022'
    , FORMAT(SUM(CASE WHEN DATE_FORMAT(DATE_ADD(rcb.created_on, INTERVAL 4 HOUR), '%Y') = 2023 THEN 1 ELSE 0 END), 0) AS '2023'
    , FORMAT(SUM(CASE WHEN DATE_FORMAT(DATE_ADD(rcb.created_on, INTERVAL 4 HOUR), '%Y') = 2024 THEN 1 ELSE 0 END), 0) AS '2024'
	, FORMAT(COUNT(*), 0) AS total_bookings
FROM myproject.rental_car_booking2 rcb
-- USER INFO (USED TO EXCLUDE TEST RENTALS IN THE WHERE CLAUSE)
LEFT JOIN myproject.auth_user au ON au.id = rcb.owner_id 
-- CAR INFO
LEFT JOIN myproject.rental_cars_available ca ON ca.id = rcb.car_available_id
LEFT JOIN myproject.rental_car c ON c.id = rcb.car_id
LEFT JOIN myproject.rental_cat cat ON cat.id = ca.cat_id
GROUP BY cat_name WITH ROLLUP
-- GROUP BY cat_name
ORDER BY cat_name, total_bookings ASC;