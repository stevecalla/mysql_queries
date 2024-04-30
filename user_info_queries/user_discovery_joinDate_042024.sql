USE myproject;

-- GET COUNT BY JOIN DATE
SELECT
	DATE_FORMAT(fuser.date_join, '%m-%d-%Y') AS join_date,
	FORMAT(COUNT(*), 0) AS count
FROM
	rental_fuser AS fuser
	LEFT JOIN myproject.auth_user AS auth_user ON auth_user.id = fuser.user_ptr_id
WHERE
	-- LOGIC EXCLUDE TEST USERS FROM auth_user
	LOWER(auth_user.first_name) NOT LIKE '%test%'
	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
	AND LOWER(auth_user.username) NOT LIKE '%test%'
	AND LOWER(auth_user.email) NOT LIKE '%test%'
	AND auth_user.last_name NOT LIKE 'N'
	AND auth_user.email NOT LIKE 'abc@gmail.com'
GROUP BY DATE(fuser.date_join)
ORDER BY DATE(fuser.date_join) DESC;
-- LIMIT 10;

-- GET COUNT BY JOIN YEAR
SELECT
	YEAR(fuser.date_join) AS join_year,
	FORMAT(COUNT(*), 0) AS count
FROM
	rental_fuser AS fuser
	LEFT JOIN myproject.auth_user AS auth_user ON auth_user.id = fuser.user_ptr_id
WHERE
	-- LOGIC EXCLUDE TEST USERS FROM auth_user
	LOWER(auth_user.first_name) NOT LIKE '%test%'
	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
	AND LOWER(auth_user.username) NOT LIKE '%test%'
	AND LOWER(auth_user.email) NOT LIKE '%test%'
	AND auth_user.last_name NOT LIKE 'N'
	AND auth_user.email NOT LIKE 'abc@gmail.com'
GROUP BY YEAR(fuser.date_join)
ORDER BY YEAR(fuser.date_join) ASC;
-- LIMIT 10;

-- GET COUNT BY JOIN DATE for '2024-01-01' SAMPLE DATA
SELECT
	DATE_FORMAT(fuser.date_join, '%m-%d-%Y') AS join_date,
	FORMAT(COUNT(*), 0) AS count
FROM
	rental_fuser AS fuser
	LEFT JOIN myproject.auth_user AS auth_user ON auth_user.id = fuser.user_ptr_id
WHERE
	DATE(fuser.date_join) = '2024-01-01'
	-- LOGIC EXCLUDE TEST USERS FROM auth_user
	AND LOWER(auth_user.first_name) NOT LIKE '%test%'
	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
	AND LOWER(auth_user.username) NOT LIKE '%test%'
	AND LOWER(auth_user.email) NOT LIKE '%test%'
	AND auth_user.last_name NOT LIKE 'N'
	AND auth_user.email NOT LIKE 'abc@gmail.com'
GROUP BY DATE(fuser.date_join)
ORDER BY DATE(fuser.date_join) ASC;
-- LIMIT 10;