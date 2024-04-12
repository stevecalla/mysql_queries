-- SCHEME INFO
SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'myproject' AND TABLE_NAME = 'rental_car_booking2'; -- UPDATE_TIME

-- FINDS THE MOST RECENT CREATED RECORD; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT MAX(created_on) FROM myproject.rental_car_booking2 LIMIT 1;

-- FINDS DISTINCT CREATED ON INFO AND USEFUL TO SEE FREQUENCY OF UPDATED ADDED
-- title: WP Named Partnerships
SELECT DISTINCT(created_on), COUNT(*) FROM myproject.rental_car_booking2 GROUP BY created_on ORDER BY created_on DESC LIMIT 100;

-- FINDS DISTINCT UPDATED ON INFO AND USEFUL TO SEE FREQUENCY OF UPDATED ADDED
SELECT DISTINCT(updated_on), COUNT(*) FROM myproject.rental_car_booking2 GROUP BY updated_on ORDER BY updated_on DESC LIMIT 100;

-- FINDS THE MOST 10 DISTINCT UPDATED ON AND CREATED ON RECORDS; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT last_updated, source_field, count
FROM (
    SELECT created_on AS last_updated, count(*) AS count, 'created_on' AS source_field
    FROM myproject.rental_car_booking2
    GROUP BY created_on
    ORDER BY created_on DESC
    LIMIT 10
) AS created_on_table
UNION ALL
SELECT last_updated, source_field, count
FROM (
    SELECT updated_on AS last_updated, count(*) AS count, 'updated_on' AS source_field
    FROM myproject.rental_car_booking2
    GROUP BY updated_on
    ORDER BY updated_on DESC
    LIMIT 10
) AS updated_on_table
ORDER BY last_updated DESC;

-- FINDS THE MOST RECENT CREATED RECORD AND UPDATED RECORD; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT 
    last_updated, -- converts base time via MST + 7 to UTC (converts 10:07:53 to 16:07:53)
    DATE_FORMAT(CONVERT_TZ(last_updated, '+00:00', '+00:00'), '%Y-%m-%d %H:%i:%s UTC') AS last_updated_utc, -- NECESSARY RUNNING QUERY FROM THE SOURCE DB INTO NODE; IN MYSQL WORKBENCH THERE IS NOT DIFFERENCE BETWEEN LAST_UDPATED AND LAST_UPDATED_UTC
    source_field, 
    CURRENT_TIMESTAMP AS execution_timestamp,
    DATE_FORMAT(CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+00:00'), '%Y-%m-%d %H:%i:%s UTC') AS execution_timestampa_utc,
    DATE_FORMAT(CONVERT_TZ(last_updated, '+00:00', '+00:00'), '%Y-%m-%d %H:%i:%s UTC') AS last_updated_utc, -- NECESSARY RUNNING QUERY FROM THE SOURCE DB INTO NODE; IN MYSQL WORKBENCH THERE IS NOT DIFFERENCE BETWEEN LAST_UDPATED AND LAST_UPDATED_UTC
    TIMESTAMPDIFF(HOUR, last_updated, CURRENT_TIMESTAMP()) as time_stamp_difference,
    CASE
        WHEN TIMESTAMPDIFF(HOUR, last_updated, CURRENT_TIMESTAMP()) <= 2 THEN "true"
        ELSE "false"
    END AS is_within_2_hours
FROM (
    SELECT MAX(created_on) AS last_updated, 'created_on' AS source_field, count(*) AS count
    FROM myproject.rental_car_booking2
    UNION ALL
    SELECT MAX(updated_on) AS last_updated, 'updated_on' AS source_field, count(*) AS count
    FROM myproject.rental_car_booking2
) AS last_updated_table
ORDER BY last_updated DESC
LIMIT 2;
