USE myproject;

SELECT 
    DATE_FORMAT(CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '-07:00'), '%Y-%m-%d %h:%i:%s %p') AS current_timestamp_mtn,
	DATE_FORMAT(CURRENT_TIMESTAMP(), '%Y-%m-%d %h:%i:%s %p') AS current_timestamp_utc,
    -- Convert CURRENT_TIMESTAMP to Gulf Standard Time (GST)
    DATE_FORMAT(CONVERT_TZ(CURRENT_TIMESTAMP, '+00:00', '+04:00'), '%Y-%m-%d %h:%i:%s %p') AS current_timestamp_gst,

	MAX(created_on) AS last_created, -- UTC
    DATE_FORMAT(DATE_ADD(MAX(created_on), INTERVAL 4 HOUR), '%Y-%m-%d %h:%i:%s %p') AS most_recent_event_created_on_GST, -- gst
    'created_on' AS source_field, 
    
    -- Calculate the difference in hours
    TIMESTAMPDIFF(HOUR, DATE_ADD(MAX(created_on), INTERVAL 4 HOUR), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 HOUR)) AS time_stamp_difference_hour,
    TIMESTAMPDIFF(HOUR, '2024-11-12 11:23:47', DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 HOUR)) AS time_stamp_difference_hour_v2,
    
    TIMESTAMPDIFF(MINUTE, DATE_ADD(MAX(created_on), INTERVAL 4 HOUR), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 HOUR)) AS time_stamp_difference_minute,
    TIMESTAMPDIFF(MINUTE, '2024-11-12 11:23:47', DATE_ADD('2024-11-12 12:54:37', INTERVAL 4 HOUR)) AS time_stamp_difference_minute_v2,
    
    count(*) AS count
FROM myproject.rental_car_booking2;
        
SELECT 
	MAX(updated_on) AS last_updated, 
    DATE_FORMAT(DATE_ADD(MAX(updated_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS most_recent_event_update_on_GST, -- gst
    'updated_on' AS source_field, 
    count(*) AS count
FROM myproject.rental_car_booking2;
        
SELECT 'created_on' AS source_field, MAX(created_on) AS most_recent_event_update, MAX(created_on) AS most_recent_created_on, MAX(updated_on) AS most_recent_updated_on, count(*) AS count
    FROM myproject.rental_car_booking2
UNION ALL
SELECT 'updated_on' AS source_field, MAX(updated_on) AS most_recent_event_update, MAX(created_on) AS most_recent_created_on, MAX(updated_on) AS most_recent_updated_on, count(*) AS count
    FROM myproject.rental_car_booking2;
        
-- FINDS THE MOST RECENT CREATED RECORD AND UPDATED RECORD; INDICATES WHEN THE DB WAS LAST UPDATED
SELECT 
    source_field, 
	DATE_FORMAT(CURRENT_TIMESTAMP(), '%Y-%m-%d %h:%i:%s %p') AS current_timestamp_utc,
    
    -- last updated dates
    most_recent_event_update, -- gst
    DATE_FORMAT(most_recent_event_update, '%Y-%m-%d %h:%i:%s %p GST') AS most_recent_event_update_gst, -- am/pm format

    -- current timestamp dates
    DATE_FORMAT(DATE_ADD(MAX(CURRENT_TIMESTAMP), INTERVAL 4 HOUR), '%Y-%m-%d %h:%i:%s %p GST') AS execution_timestamp_gst, -- am/pm format

    -- variance between last updated and current timestamp
    TIMESTAMPDIFF(HOUR, most_recent_event_update, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 HOUR)) AS time_stamp_difference_hour,
    TIMESTAMPDIFF(MINUTE, most_recent_event_update, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 HOUR)) AS time_stamp_difference_minute,

    CASE
        WHEN TIMESTAMPDIFF(HOUR, most_recent_event_update, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 HOUR)) <= 2 THEN 1
        ELSE 0
    END AS is_within_2_hours,
    CASE
        WHEN TIMESTAMPDIFF(MINUTE, most_recent_event_update, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 4 HOUR)) <= 15 THEN 1
        ELSE 0
    END AS is_within_15_minutes,
    
    most_recent_created_on,
    most_recent_updated_on

FROM 
(
        SELECT 
            'created_on' AS source_field, 
            DATE_FORMAT(DATE_ADD(MAX(created_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS most_recent_event_update, -- gst
            DATE_FORMAT(DATE_ADD(MAX(created_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS most_recent_created_on, -- gst
            DATE_FORMAT(DATE_ADD(MAX(updated_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS most_recent_updated_on, -- gst
            count(*) AS count
        FROM myproject.rental_car_booking2

    UNION ALL

        SELECT 
            'updated_on' AS source_field, 
            DATE_FORMAT(DATE_ADD(MAX(updated_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS most_recent_event_update, -- gst
            DATE_FORMAT(DATE_ADD(MAX(created_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS most_recent_created_on, -- gst
            DATE_FORMAT(DATE_ADD(MAX(updated_on), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS most_recent_updated_on, -- gst
            count(*) AS count
        FROM myproject.rental_car_booking2

    ) AS last_updated_table
GROUP BY source_field
ORDER BY most_recent_event_update DESC
LIMIT 2
; -- keeps most recent created on record