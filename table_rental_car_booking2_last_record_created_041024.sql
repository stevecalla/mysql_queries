-- SCHEME INFO
SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'myproject' AND TABLE_NAME = 'rental_car_booking2'; -- UPDATE_TIME-- SCHEME INFO
SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'myproject' AND TABLE_NAME = 'rental_fuser'; -- UPDATE_TIME
SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'myproject' AND TABLE_NAME = 'auth_user'; -- UPDATE_TIME

-- SELECT * FROM myproject.rental_car_booking2 LIMIT 1;
SELECT * FROM myproject.rental_fuser WHERE user_ptr_id >= 574800 AND user_ptr_id <= 574997;
SELECT * FROM myproject.auth_user WHERE email LIKE '%calla%';

SELECT * FROM myproject.rental_fuser WHERE user_ptr_id = 574997;
SELECT * FROM myproject.auth_user WHERE email = 'callasteven@gmail.com';

SHOW COLUMNS FROM myproject.rental_fuser;
SHOW COLUMNS FROM myproject.auth_user;

-- FINDS THE MOST RECENT CREATED RECORD; INDICATES WHEN THE DB WAS LAST UPDATED
-- SELECT MAX(created_on) FROM myproject.rental_car_booking2 LIMIT 1;
SELECT created_on, id,'rental_car_booking2_created_on' as source_field, COUNT(*)
FROM myproject.rental_car_booking2
GROUP BY created_on
ORDER BY created_on DESC
LIMIT 1;

SELECT updated_on, id,'rental_car_booking2_updated_on' as source_field, COUNT(*)
FROM myproject.rental_car_booking2
GROUP BY updated_on
ORDER BY updated_on DESC
LIMIT 1;

SELECT date_join, user_ptr_id AS id, 'rental_fuser_join' as source_field, COUNT(*)
FROM myproject.rental_fuser
GROUP BY date_join
ORDER BY date_join DESC
LIMIT 1;

SELECT date_joined, id, 'auth_user_joined' as source_field, COUNT(*)
FROM myproject.auth_user
GROUP BY date_joined
ORDER BY date_joined DESC
LIMIT 1;

-- FINDS DISTINCT CREATED ON INFO AND USEFUL TO SEE FREQUENCY OF UPDATED ADDED
-- title: WP Named Partnerships
--  DISTINCT(created_on), COUNT(*) FROM myproject.rental_car_booking2 GROUP BY created_on ORDER BY created_on DESC LIMIT 100;

-- FINDS DISTINCT UPDATED ON INFO AND USEFUL TO SEE FREQUENCY OF UPDATED ADDED
-- SELECT DISTINCT(updated_on), COUNT(*) FROM myproject.rental_car_booking2 GROUP BY updated_on ORDER BY updated_on DESC LIMIT 100;

-- FINDS THE MOST 10 DISTINCT UPDATED ON AND CREATED ON RECORDS; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT last_updated, source_field, id, count
FROM (
    SELECT created_on AS last_updated, id, count(*) AS count, 'created_on' AS source_field
    FROM myproject.rental_car_booking2
    GROUP BY created_on
    ORDER BY created_on DESC
    LIMIT 10
) AS created_on_table
UNION ALL
SELECT last_updated, source_field, id, count
FROM (
    SELECT updated_on AS last_updated, id, count(*) AS count, 'updated_on' AS source_field
    FROM myproject.rental_car_booking2
    GROUP BY updated_on
    ORDER BY updated_on DESC
    LIMIT 10
) AS updated_on_table
ORDER BY last_updated DESC;

-- FINDS THE MOST RECENT CREATED RECORD AND UPDATED RECORD; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT 
	id,
    source_field,
    UTC_TIMESTAMP() as timestamp_utc,
    DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS timestamp_gst,
    DATE_ADD(UTC_TIMESTAMP(), INTERVAL -6 HOUR) AS timestamp_mst,
    
    last_updated, -- converts base time via MST + 7 to UTC (converts 10:07:53 to 16:07:53)
    DATE_FORMAT(CONVERT_TZ(last_updated, '+00:00', '+00:00'), '%Y-%m-%d %H:%i:%s UTC') AS last_updated_utc, -- NECESSARY RUNNING QUERY FROM THE SOURCE DB INTO NODE; IN MYSQL WORKBENCH THERE IS NOT DIFFERENCE BETWEEN LAST_UDPATED AND LAST_UPDATED_UTC

    CURRENT_TIMESTAMP AS execution_timestamp,
    DATE_FORMAT(CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+00:00'), '%Y-%m-%d %H:%i:%s UTC') AS execution_timestamp_utc,
    
    TIMESTAMPDIFF(HOUR, last_updated, CURRENT_TIMESTAMP()) as time_stamp_difference,
    CASE
        WHEN TIMESTAMPDIFF(HOUR, last_updated, CURRENT_TIMESTAMP()) <= 2 THEN "true"
        ELSE "false"
    END AS is_within_2_hours
FROM (
    (SELECT created_on AS last_updated, id, 'rental_car_booking2_created_on' as source_field, COUNT(*) as count
		FROM myproject.rental_car_booking2
		GROUP BY created_on
		ORDER BY created_on DESC
		LIMIT 1)
    UNION ALL
    (SELECT updated_on AS last_updated, id, 'rental_car_booking2_updated_on' as source_field, COUNT(*) as count
		FROM myproject.rental_car_booking2
		GROUP BY updated_on
		ORDER BY updated_on DESC
		LIMIT 1)
    UNION ALL
    (SELECT date_join, user_ptr_id AS id, 'rental_fuser_join' as source_field, COUNT(*)
		FROM myproject.rental_fuser
		GROUP BY date_join
		ORDER BY date_join DESC
		LIMIT 1)
    UNION ALL
    (SELECT date_joined, id, 'auth_user_joined' as source_field, COUNT(*)
		FROM myproject.auth_user
		GROUP BY date_joined
		ORDER BY date_joined DESC
		LIMIT 1)
) AS last_updated_table
ORDER BY source_field DESC, last_updated DESC
LIMIT 10;
