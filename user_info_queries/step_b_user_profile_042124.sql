USE myproject;

-- GET USERS PROFILE INFORMATION
SELECT
	fuser.user_ptr_id,
	auth_user.id,
	rcb.owner_id,

	auth_user.first_name,
	auth_user.last_name,
	auth_user.email,

    -- GET CUSTOMER PROFILE INFORMATION
    -- DOB & AGE; NOTE DOB LOOKS INCORRECT WITH MOST DOB ON 1/1/95, 2/7/1992, 1/1/2020 & 1/1/1970
    CASE
        WHEN fuser.date_of_birth = '20-11' THEN '1900-01-01'
        WHEN STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y'), '%Y-%m-%d')
        WHEN STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth, '%m/%d/%Y'), '%Y-%m-%d')
        WHEN STR_TO_DATE(fuser.date_of_birth,  '%Y-%m-%d %H:%i:%s') THEN DATE_FORMAT(STR_TO_DATE(fuser.date_of_birth,  '%Y-%m-%d %H:%i:%s'), '%Y-%m-%d')
        ELSE NULL
    END AS fuser_date_of_birth_formatted,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(fuser.date_of_birth, '%d/%m/%Y'), NOW()) AS age,

    -- LAST LOGIN
    CASE
        WHEN DATE_ADD(auth_user.last_login, INTERVAL 4 HOUR) THEN DATE_ADD(auth_user.last_login, INTERVAL 4 HOUR)
        ELSE ''
    END AS auth_user_last_login_gst,

    -- IS_RESIDENT
    fuser.is_resident,

    -- IS_VERIFIED (DOCUMENTS)
    IFNULL((CASE
        WHEN fuser.is_verified > 0 THEN 'Yes'
        ELSE 'No'
    END), 0) AS fuser_is_verified,

    -- JOINED COHORT
    fuser.date_join,
    DATE_FORMAT(DATE_ADD(fuser.date_join, INTERVAL 4 HOUR), '%Y-%m-%d') AS date_join_formatted_gst,
    DATE_FORMAT(DATE_ADD(fuser.date_join, INTERVAL 4 HOUR), '%Y-%m') AS date_join_cohort,
    DATE_FORMAT(DATE_ADD(fuser.date_join, INTERVAL 4 HOUR), '%Y') AS date_join_year,
    DATE_FORMAT(DATE_ADD(fuser.date_join, INTERVAL 4 HOUR), '%m') AS date_join_month,

    -- FIRST BOOKING / CREATED ON DATE
    IFNULL((SELECT DATE_FORMAT(MIN(DATE_ADD(created_on, INTERVAL 4 HOUR)), '%Y-%m-%d')
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_first_created_date,
    
    -- JOIN VS FIRST BOOKING / CREATED ON DATE
    IFNULL(TIMESTAMPDIFF(DAY, fuser.date_join, IFNULL((SELECT MIN(DATE_ADD(created_on, INTERVAL 4 HOUR))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0)),'') AS booking_join_vs_first_created,

    -- MOST RECENT BOOKING / CREATED ON DATE
    IFNULL((SELECT DATE_FORMAT(MAX(DATE_ADD(created_on, INTERVAL 4 HOUR)), '%Y-%m-%d')
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_most_recent_created_on,
    
    -- JOIN VS MOST RECENT BOOKING / CREATED ON DATE
    IFNULL(TIMESTAMPDIFF(DAY, fuser.date_join, IFNULL((SELECT MAX(DATE_ADD(created_on, INTERVAL 4 HOUR))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0)),'') AS booking_join_vs_most_recent_created_on,

    -- MOST RECENT PICKUP DATE
    IFNULL((SELECT MAX(STR_TO_DATE(deliver_date_string, '%d/%m/%Y'))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_most_recent_pickup_date,

    -- MOST RECENT RETURN DATE
    IFNULL((SELECT MAX(STR_TO_DATE(return_date_string, '%d/%m/%Y'))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0) AS booking_most_recent_return_date,
    
    -- MOST RECENT RETURN DATE VS NOW
    IFNULL(TIMESTAMPDIFF(DAY, IFNULL((SELECT MAX(STR_TO_DATE(return_date_string, '%d/%m/%Y'))
                FROM rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id), 0), DATE_ADD(now(), INTERVAL 4 HOUR)),'') AS booking_most_recent_return_vs_now,

    DATE_ADD(now(), INTERVAL 4 HOUR) AS date_now_gst, -- converted to gst

    -- REPEAT VS NEW USER
    (CASE
        WHEN
            (SELECT COUNT(1)
                FROM myproject.rental_car_booking2 rcbv2
                WHERE rcbv2.owner_id = rcb.owner_id) > 1
                THEN 'Yes'
        ELSE 'No'
    END) AS is_repeat_user,

    -- BOOKING COUNT STATS
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
                AND rcbv2.status NOT IN (8 , 9)), 0) AS bookings_started_count,

    -- MOST RECENT BOOKING ID
     IFNULL((SELECT rcbv2.id
              FROM rental_car_booking2 rcbv2
              WHERE rcbv2.owner_id = rcb.owner_id
              ORDER BY rcbv2.created_on DESC
              LIMIT 1), '') AS most_recent_booking_id,

    -- MOST RECENT RENTAL STATUS
     IFNULL((SELECT rs.status
              FROM rental_car_booking2 rcbv2
              INNER JOIN rental_status AS rs ON rs.id = rcb.status
              WHERE rcbv2.owner_id = rcb.owner_id
              ORDER BY rcbv2.created_on DESC
              LIMIT 1), '') AS most_recent_booking_status,

    -- MOST RECENT BOOKING TYPE
     IFNULL((SELECT 
                (CASE
                    WHEN days < 7 THEN 'daily'
                    WHEN days > 29 AND is_subscription = 1 THEN 'subscription'
                    WHEN days > 29 THEN 'monthly'
                    ELSE 'weekly'
                END) AS booking_type
              FROM rental_car_booking2 rcbv2
              WHERE rcbv2.owner_id = rcb.owner_id
              ORDER BY rcbv2.created_on DESC
              LIMIT 1), '') AS most_recent_booking_type

    -- rfm score
        -- 0 / 1 in a curent rental
        -- 0 - 5 recency = last login / most recent return
        -- 0 - 5 frequncy = number of rentals / number of days / extension
        -- 0 - 5 monetary = lifetime spend
    -- opt in/out?

    -- cummulative counts of customers/users
    -- cummulative counts of is_verified customers
    -- cummulative counts of customers with booking
    -- cummulative counts of customers with completed/started booking

    -- build capability to see cohorts
    -- - cohort by booking first, second, third.... months
    -- - lifetime value by first, second, third.... months
    -- - lifetime extension

    -- push data into local mysql database
    -- build pivots
FROM
	rental_fuser AS fuser
	LEFT JOIN myproject.auth_user AS auth_user ON auth_user.id = fuser.user_ptr_id
	LEFT JOIN myproject.rental_car_booking2 rcb ON rcb.owner_id = fuser.user_ptr_id
WHERE
    -- DATE FILTER
	-- DATE(fuser.date_join) = '2024-01-01' -- GET SAMPLE DATA
    DATE_FORMAT(DATE_ADD(fuser.date_join, INTERVAL 4 HOUR), '%Y-%m-%d') = '2024-01-01'

	-- LOGIC EXCLUDE TEST USERS FROM auth_user
	AND LOWER(auth_user.first_name) NOT LIKE '%test%'
	AND LOWER(auth_user.last_name) NOT LIKE '%test%'
	AND LOWER(auth_user.username) NOT LIKE '%test%'
	AND LOWER(auth_user.email) NOT LIKE '%test%'
	AND auth_user.last_name NOT LIKE 'N'
	AND auth_user.email NOT LIKE 'abc@gmail.com'
	
    -- LOGIC TO EXCLUDE TEST BOOKINGS
    AND COALESCE(rcb.vendor_id,'') NOT IN (5, 33, 218, 23086)
GROUP BY 1, 2, 3, 4, 5
ORDER BY fuser.user_ptr_id
-- LIMIT 10;