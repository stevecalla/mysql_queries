USE ezhire_user_data;
-- none
-- most_recent
-- offer

SELECT * FROM rfm_score_summary_history_data_tracking;

-- ALTER TABLE rfm_score_summary_history_data_tracking
-- ADD COLUMN is_repeat_new_first VARCHAR(255) AFTER date_join_cohort,
-- ADD COLUMN all_cities_distinct VARCHAR(255) AFTER is_repeat_new_first,
-- ADD COLUMN all_countries_distinct VARCHAR(255) AFTER all_cities_distinct,
-- ADD COLUMN booking_count_total INT AFTER all_countries_distinct,
-- ADD COLUMN booking_count_cancel INT AFTER booking_count_total,
-- ADD COLUMN booking_count_completed INT AFTER booking_count_cancel,
-- ADD COLUMN booking_count_started INT AFTER booking_count_completed,
-- ADD COLUMN booking_count_future INT AFTER booking_count_started,
-- ADD COLUMN booking_count_other INT AFTER booking_count_future,
-- ADD COLUMN is_currently_started VARCHAR(255) AFTER booking_count_other;

-- ALTER TABLE rfm_score_summary_history_data_tracking
-- ADD COLUMN booking_most_recent_return_vs_now_at_min_date VARCHAR(255) AFTER test_group_at_min_date,
-- ADD COLUMN total_days_per_completed_and_started_bookings_at_min_date VARCHAR(255) AFTER booking_most_recent_return_vs_now_at_min_date,
-- ADD COLUMN booking_charge__less_discount_aed_per_completed_started_bookings_at_min_date VARCHAR(255) AFTER total_days_per_completed_and_started_bookings_at_min_date;

SELECT * FROM rfm_score_summary_history_data_tracking;

-- ALTER TABLE rfm_score_summary_history_data_tracking
-- ADD COLUMN has_promo_code VARCHAR(3) DEFAULT 'no' AFTER promo_code;

-- UPDATE rfm_score_summary_history_data_tracking
-- SET has_promo	_code = IF(promo_code IS NULL OR promo_code = '', 'no', 'yes');

SELECT * FROM rfm_score_summary_history_data_tracking;

USE ezhire_user_data;

-- STEP #1: update rfm summary data with first_name, last_name
	-- update query_create_rfm_ranking.js & step_6_create_rfm_ranking.sql
    -- run_step_5 in step_0_process_user_data_042524.js
    -- 623,430 & 86,501
    
	-- 	SELECT * FROM user_data_profile;
	-- 	SELECT * FROM rfm_score_recency_data;
	-- 	SELECT * FROM rfm_score_frequency_data;
	-- 	SELECT * FROM rfm_score_monetary_data;
	-- SELECT * FROM rfm_score_summary_data;
    
-- STEP #2: adjust created at back to the orginal data / time
	-- UPDATE rfm_score_summary_data
	-- UPDATE rfm_score_recency_data
	-- UPDATE rfm_score_frequency_data
	-- UPDATE rfm_score_monetary_data
	-- SET created_at = '2024-07-07 21:29:46';
	-- WHERE created_at = '2024-07-07 00:17:01';
    
	-- SELECT * FROM rfm_score_recency_data;
	-- SELECT * FROM rfm_score_frequency_data;
	-- SELECT * FROM rfm_score_monetary_data;
	-- SELECT * FROM rfm_score_summary_data;

-- STEP #3: update rfm score summary history data with new fields column
	-- 516,679
	-- 	SELECT * FROM rfm_score_summary_data LIMIT 10;
	-- 	SELECT * FROM rfm_score_summary_history_data LIMIT 10;
 
	--  ALTER TABLE rfm_score_summary_history_data
	-- 	ADD COLUMN first_name VARCHAR(255) AFTER telephone,
	-- 	ADD COLUMN last_name VARCHAR(255) AFTER first_name;
 
	-- SELECT * FROM rfm_score_summary_data LIMIT 10;
	-- SELECT * FROM rfm_score_summary_history_data;

-- STEP #4: populate rfm score summary history data new fields columns with data
	-- 516,679
    -- SHOW PROCESSLIST;
	-- KILL 379;

	-- ADD INDEX TO ENSURE UPDATE QUERY RUNS QUICKLY (OTHERWISE IT TAKES FOREVER)
	-- ALTER TABLE rfm_score_summary_history_data ADD INDEX idx_user_ptr_id (user_ptr_id);
	-- ALTER TABLE user_data_profile ADD INDEX idx_user_ptr_id (user_ptr_id);
	-- ALTER TABLE rfm_score_summary_history_data ADD INDEX idx_created_at_date (created_at_date);
	
    -- SELECT * FROM rfm_score_summary_history_data;
    
	-- UPDATE rfm_score_summary_history_data AS rfm
	-- 	JOIN user_data_profile AS udp ON rfm.user_ptr_id = udp.user_ptr_id
	-- 	SET rfm.first_name = udp.first_name,
	--  		rfm.last_name = udp.last_name;
	-- WHERE created_at_date = '07/01/2024';

	SELECT * FROM rfm_score_summary_history_data WHERE first_name IS NULL;	
    SELECT * FROM rfm_score_summary_history_data;

-- STEP #5: upload data to bigquery
	-- Adjust move_data_to_bigquery step 1, 3 & 4 to only update the necessary table ("rfm_data")
    
-- STEP #6: add to the looker report
	-- Reconnect data in looker to add the new field
    
-- CHANGE THE DATE IN THE RFM HISTORY DATA FROM 7/1/2024 TO FORMAT 2024-07-01
-- SELECT * FROM rfm_score_summary_history_data LIMIT 10;

-- Start transaction for safety
-- START TRANSACTION;

-- Update the table to convert date format
-- UPDATE rfm_score_summary_history_data
-- SET created_at_date = STR_TO_DATE(created_at_date, '%m/%d/%Y')
-- WHERE user_ptr_id <> 340707;

-- Commit the transaction
-- COMMIT;

-- SELECT * FROM rfm_score_summary_history_data;
