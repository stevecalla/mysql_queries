-- SHOW GRANTS FOR 'root'@'localhost';
CREATE DATABASE IF NOT EXISTS ezhire_user_data;

SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'ezhire_user_data' AND TABLE_NAME = 'user_data_base';
SELECT * FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'ezhire_booking_data' AND TABLE_NAME = 'booking_data';

SHOW COLUMNS FROM ezhire_user_data.user_data_base;
SHOW COLUMNS FROM ezhire_booking_data.booking_data;

-- QUERY ENTIRE user_data DB
SELECT * FROM ezhire_user_data.user_data_base;

-- USER COUNT
-- RECONCILE WITH user_profile_042123 sql query
SELECT
	user.*
FROM ezhire_user_data.user_data_base AS user
WHERE
	-- DATE FILTER
	DATE_FORMAT(user.date_join_gst, '%Y-%m-%d') = '2024-01-01';
-- LIMIT 10;

-- STEP #1: COMBINED USERS & BOOKINGS COUNT
SELECT
	user.*,
    booking.*
FROM ezhire_user_data.user_data_base AS user
	LEFT JOIN ezhire_booking_data.booking_data AS booking ON booking.customer_id = user.user_ptr_id
WHERE
	-- DATE FILTER
	DATE_FORMAT(user.date_join_gst, '%Y-%m-%d') = '2024-01-01';
-- LIMIT 10;
