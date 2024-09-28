USE myproject;

-- REVIEW COUNT/DISTRIBUTION FOR VARIOUS FIELDS
SELECT
	is_verified, -- 576K not verified, 16K verified
    
	-- what do country & country_code represent? for example, lots of country 1 with country_code 971? is country = country of residence? and country code phone number code?
	-- country,
	-- country_code,
	-- SELECT * FROM myproject.rental_countries; & SELECT * FROM myproject.rental_countries_new;
	-- SELECT * FROM myproject.rental_countries; -- residence_join
	-- SELECT * FROM myproject.rental_country; -- only countries with eZhire rental history
    
	-- what does is_resident represent? is it the country of primary residence or country currently residing or something else? what's the correct join?
	-- is_resident,

	-- what does renting_in represent? what is the correct join?
	-- renting_in,

	-- what is role_type? what is the correct join?
	-- role_type,

	-- dl_expiration_date,
	-- int_dl_issue_date,
	-- passport_exp_date,

	-- for Payment_Det_Added is 0 no and 1 yes? same for payment_det_added_bank? it does look like Payment_Det_Added 1 = yes, but payment_det_added_bank looks the opposite?
	-- Payment_Det_Added,
	-- payment_det_added_bank,

	-- is user_source1 the downloaded source?
	-- user_source1, -- android, ios, web, website

	-- is app_version / ios_version accurate? what is the insight from older versions?
	-- app_version,
	-- os_version,
    
	-- social_uid - is this field accurate? how can it be leveraged?
    -- social_uid,
    -- CASE
	-- 	WHEN social_uid IS NOT NULL THEN 'yes'
	-- 	ELSE 'no'
 	-- END has_social_uid,
    
	-- user_source, -- seems like invalid field

	-- is firebase token unique? is the source of firebase token a download? why do some tokens have count > 1?
	-- firebase_token,
    -- CASE
 	-- 	WHEN firebase_token IS NOT NULL THEN 'yes'
    --      ELSE 'no'
 	-- END has_firebase_token,

	-- user status = what is this field? is it useful?
	-- user_status,

	-- - is_online = is this accurate? has all 0?
	-- is_online,

	-- - what are the app languages? maybe 1 = english and 2 = arabic?
	-- app_language,

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
GROUP BY 1
ORDER BY 1 ASC;
-- LIMIT 10;