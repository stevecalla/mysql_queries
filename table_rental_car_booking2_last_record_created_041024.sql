-- FINDS THE MOST RECENT CREATED RECORD; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT MAX(created_on) FROM myproject.rental_car_booking2 LIMIT 1;

-- SCHEME INFO
SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'myproject' AND TABLE_NAME = 'rental_car_booking2'; -- UPDATE_TIME

-- FINDS DISTINCT CREATED ON INFO AND USEFUL TO SEE FREQUENCY OF UPDATED ADDED
SELECT DISTINCT(created_on), COUNT(*) FROM myproject.rental_car_booking2 GROUP BY created_on ORDER BY created_on DESC LIMIT 100;

-- FINDS DISTINCT CREATED ON INFO AND USEFUL TO SEE FREQUENCY OF UPDATED ADDED
SELECT DISTINCT(updated_on), COUNT(*) FROM myproject.rental_car_booking2 GROUP BY updated_on ORDER BY updated_on DESC LIMIT 100;

-- FINDS THE MOST RECENT CREATED RECORD AND UPDATED RECORD; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT last_updated, source_field
FROM (
    SELECT MAX(created_on) AS last_updated, 'created_on' AS source_field
    FROM myproject.rental_car_booking2
    UNION ALL
    SELECT MAX(updated_on) AS last_updated, 'updated_on' AS source_field
    FROM myproject.rental_car_booking2
) AS last_updated_table
ORDER BY last_updated DESC
LIMIT 100;

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
SELECT last_updated, source_field
FROM (
    SELECT updated_on AS last_updated, count(*) AS count, 'updated_on' AS source_field
    FROM myproject.rental_car_booking2
    GROUP BY updated_on
    ORDER BY updated_on DESC
    LIMIT 10
) AS updated_on_table
ORDER BY last_updated DESC;
