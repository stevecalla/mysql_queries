USE myproject;

SET
	@str_date = '2024-01-01',
	@end_date = '2024-01-31';

-- GET USERS PROFILE INFORMATION
SELECT
	fuser.user_ptr_id,
	auth_user.id,
	rcb.owner_id,

	auth_user.first_name,
	auth_user.last_name,
	auth_user.email,

    -- cutomer profile information

    -- DOB & AGE; NOTE DOB LOOKS INCORRECT WITH MOST DOB ON 1/1/95, 2/7/1992, 1/1/2020 & 1/1/1970
    CASE
        WHEN STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y'), '%Y-%m-%d')
        WHEN STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y'), '%Y-%m-%d')
        ELSE NULL
    END AS fuser_date_of_birth_formatted,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y'), NOW()) age,

    -- last login
    CASE
        WHEN DATE_ADD(auth_user.last_login, INTERVAL 4 HOUR) THEN DATE_ADD(auth_user.last_login, INTERVAL 4 HOUR)
        ELSE ''
    END AS auth_user_last_login_gst,

    -- - is resident
    fuser.is_resident,

    -- - is verified (documents)
    IFNULL((CASE
        WHEN fuser.is_verified > 0 THEN 'Yes'
        ELSE 'No'
    END), 0) AS fuser_is_verified,

    -- - joined cohort
	DATE_FORMAT(fuser.date_join, '%Y-%m-%d') AS date_join_formatted,
    DATE_FORMAT(fuser.date_join, '%Y-%m') AS date_join_cohort,
    DATE_FORMAT(fuser.date_join, '%Y') AS date_join_year,
    DATE_FORMAT(fuser.date_join, '%m') AS date_join_month,

    -- first booking/created on date
    IFNULL((SELECT DATE_FORMAT(MIN(DATE_ADD(created_on, INTERVAL 4 HOUR)), '%Y-%m-%d')
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_first_created_date,
    
    -- join vs first booking/created on date
    IFNULL(TIMESTAMPDIFF(DAY, fuser.date_join, IFNULL((SELECT MIN(DATE_ADD(created_on, INTERVAL 4 HOUR))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0)),'') AS booking_join_vs_first_created,

    -- most recent booking/created on date
    IFNULL((SELECT DATE_FORMAT(MAX(DATE_ADD(created_on, INTERVAL 4 HOUR)), '%Y-%m-%d')
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_most_recent_created_on,
    
    -- join vs most recent booking/created on date
    IFNULL(TIMESTAMPDIFF(DAY, fuser.date_join, IFNULL((SELECT MAX(DATE_ADD(created_on, INTERVAL 4 HOUR))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0)),'') AS booking_join_vs_most_recent_created_on,

    -- most recent pickup date
    IFNULL((SELECT MAX(STR_TO_DATE(deliver_date_string, '%d/%m/%Y'))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_most_recent_pickup_date,

    -- most recent return date
    IFNULL((SELECT MAX(STR_TO_DATE(return_date_string, '%d/%m/%Y'))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_most_recent_return_date,
    
    -- most recent return date vs now
    IFNULL(TIMESTAMPDIFF(DAY, IFNULL((SELECT MAX(STR_TO_DATE(return_date_string, '%d/%m/%Y'))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0), DATE_ADD(now(), INTERVAL 4 HOUR)),'') AS booking_most_recent_return_vs_now,

    DATE_ADD(now(), INTERVAL 4 HOUR) AS date_now_gst, -- converted to gst

    -- booking counts
    IFNULL((SELECT COUNT(1)
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS bookings_total_count,
    IFNULL((SELECT COUNT(1)
            FROM rental_car_booking2 rcbv2
            WHERE rcbv2.owner_id = rcb.owner_id
                AND rcbv2.status = 8), 0) AS bookings_cancel_count,
    IFNULL((SELECT COUNT(1)
            FROM rental_car_booking2 rcbv2
            WHERE rcbv2.owner_id = rcb.owner_id
                AND rcbv2.status = 9), 0) AS bookings_completed_count,
    IFNULL((SELECT COUNT(1)
            FROM rental_car_booking2 rcbv2
            WHERE rcbv2.owner_id = rcb.owner_id
                AND rcbv2.status NOT IN (8 , 9)), 0) AS bookings_started_count

    -- current rental status
    -- app install / download
    -- revenue stats
    -- day stats
    -- rfm score

    -- cummulative counts of customers/users
    -- cummulative counts of is_verified customers
    -- cummulative counts of customers with booking
    -- cummulative counts of customers with completed/started booking
    
    -- build capability to see cohorts
    -- - cohort by booking first, second, third.... months
    -- - lifetime value by first, second, third.... months
    -- - lifetime extension

	-- BOOKING INFO
	-- rcb.id AS booking_id,
	-- rcb.vendor_id AS vendor_id,
	-- rcb.status AS booking_status
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
    AND COALESCE(rcb.vendor_id,'') NOT IN (5, 33, 218, 23086)
GROUP BY fuser.user_ptr_id
-- LIMIT 10;