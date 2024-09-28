USE myproject;

-- SELECT * FROM myproject.auth_user 
-- WHERE   LOWER(first_name) LIKE '%test%' 
--         AND 
--         (LOWER(last_name) NOT LIKE '%test%' OR LOWER(username) NOT LIKE '%test%' OR email NOT LIKE '%test%');


-- SELECT * FROM myprojnodect.auth_user 
-- WHERE   LOWER(last_name) LIKE '%test%' 
--         AND 
--         (LOWER(first_name) NOT LIKE '%test%' OR LOWER(username) NOT LIKE '%test%'  OR email NOT LIKE '%test%');

-- SELECT * FROM myproject.auth_user 
-- WHERE   LOWER(username) LIKE '%test%' 
--         AND 
--         (LOWER(first_name) NOT LIKE '%test%' OR LOWER(last_name) NOT LIKE '%test%' OR email NOT LIKE '%test%');

-- SELECT * FROM myproject.auth_user 
-- WHERE   LOWER(email) LIKE '%test%' 
--         AND 
--         (LOWER(first_name) NOT LIKE '%test%' OR LOWER(last_name) NOT LIKE '%test%' OR username NOT LIKE '%test%');

-- SELECT * FROM myproject.auth_user 
-- WHERE   LOWER(first_name) LIKE '%test%' OR LOWER(last_name) LIKE '%test%' OR LOWER(username) LIKE '%test%' OR LOWER(email) LIKE '%test%';

SELECT 
    *
FROM auth_user
ORDER BY date_joined DESC
LIMIT 10;

SELECT 
    DATE_FORMAT(last_login, '%Y-%m'),

	-- PIVOT BY JOIN DATE
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') NOT IN (2021, 2022, 2023, 2024) THEN 1 ELSE 0 END), 0) AS 'Other',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2021 THEN 1 ELSE 0 END), 0) AS '2021',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2022 THEN 1 ELSE 0 END), 0) AS '2022',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2023 THEN 1 ELSE 0 END), 0) AS '2023',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2024 THEN 1 ELSE 0 END), 0) AS '2024',

	FORMAT(COUNT(*), 0) AS total_count

FROM  auth_user
WHERE
	-- DATE(fuser.date_join) = '2024-01-01'
	-- is_verified = 1
	-- AND 
	-- LOGIC EXCLUDE TEST USERS FROM auth_user
	LOWER(auth_user.first_name) NOT LIKE '%test%'
	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
	AND LOWER(auth_user.username) NOT LIKE '%test%'
	AND LOWER(auth_user.email) NOT LIKE '%test%'
	AND auth_user.last_name NOT LIKE 'N'
	AND auth_user.email NOT LIKE 'abc@gmail.com'
GROUP BY 1 WITH ROLLUP
ORDER BY 1 DESC;
-- LIMIT 10;

SELECT 
    YEAR(last_login),

	-- PIVOT BY JOIN DATE
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') NOT IN (2021, 2022, 2023, 2024) THEN 1 ELSE 0 END), 0) AS 'Other',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2021 THEN 1 ELSE 0 END), 0) AS '2021',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2022 THEN 1 ELSE 0 END), 0) AS '2022',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2023 THEN 1 ELSE 0 END), 0) AS '2023',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(date_joined, '%Y') = 2024 THEN 1 ELSE 0 END), 0) AS '2024',

	FORMAT(COUNT(*), 0) AS total_count

FROM  auth_user
WHERE
	-- DATE(fuser.date_join) = '2024-01-01'
	-- is_verified = 1
	-- AND 
	-- LOGIC EXCLUDE TEST USERS FROM auth_user
	LOWER(auth_user.first_name) NOT LIKE '%test%'
	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
	AND LOWER(auth_user.username) NOT LIKE '%test%'
	AND LOWER(auth_user.email) NOT LIKE '%test%'
	AND auth_user.last_name NOT LIKE 'N'
	AND auth_user.email NOT LIKE 'abc@gmail.com'
GROUP BY 1 WITH ROLLUP
ORDER BY 1 ASC;
-- LIMIT 10;
