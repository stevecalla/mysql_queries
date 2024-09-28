USE myproject;

-- GET DATE OF BIRTH DISTRIBUTION
SELECT
	fuser.date_of_birth,
	YEAR(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y')),
	YEAR(STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y')),
	(YEAR(UTC_TIMESTAMP) - 80), -- (2024 - 80 = 1944)
	(YEAR(UTC_TIMESTAMP) - 18), -- (2024 - 18 = 2006)
    CASE
        -- WHEN fuser.date_of_birth IN ('20-11', '02/08/0320', '01/03/0620', '06/05/0620', '09/08/1681', '05/10/1907', '07/04/1920', '09/02/1926', '01/1/1995', '07/02/1992', '01/01/2020') THEN '1900-01-01'

		WHEN YEAR(STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y')) <= 1950 THEN '1900-01-01' -- remove bad dates
		WHEN YEAR(STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y')) >= 2010 THEN '1900-01-01' -- remove bad dates

		WHEN YEAR(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y')) <= 1950 THEN '1900-01-01' -- remove bad dates
		WHEN YEAR(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y')) >= (YEAR(UTC_TIMESTAMP) - 18) THEN '1900-01-01' -- remove bad dates
		
        WHEN STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y'), '%Y-%m-%d') -- order matters; assume most common format
        WHEN STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y'), '%Y-%m-%d') -- order matters; assume less common format
        WHEN STR_TO_DATE(fuser.date_of_birth,  '%Y-%m-%d %H:%i:%s') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth,  '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d')
        ELSE NULL
    END AS fuser_date_of_birth_formatted,
	
	-- fuser.is_verified,
	-- PIVOT BY JOIN DATE
    FORMAT(SUM(CASE WHEN DATE_FORMAT(fuser.date_join, '%Y') NOT IN (2021, 2022, 2023, 2024) THEN 1 ELSE 0 END), 0) AS 'Other',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(fuser.date_join, '%Y') = 2021 THEN 1 ELSE 0 END), 0) AS '2021',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(fuser.date_join, '%Y') = 2022 THEN 1 ELSE 0 END), 0) AS '2022',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(fuser.date_join, '%Y') = 2023 THEN 1 ELSE 0 END), 0) AS '2023',
    FORMAT(SUM(CASE WHEN DATE_FORMAT(fuser.date_join, '%Y') = 2024 THEN 1 ELSE 0 END), 0) AS '2024',
	FORMAT(COUNT(*), 0) AS total_count
FROM
	rental_fuser AS fuser
	LEFT JOIN myproject.auth_user AS auth_user ON auth_user.id = fuser.user_ptr_id
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
GROUP BY DATE(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y'))
-- ORDER BY DATE(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y')) ASC;
ORDER BY count(*) DESC;
-- LIMIT 10;