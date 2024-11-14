USE ezhire_user_data;

-- REVIEW KEY METRICS ROLLUP TABLE
SELECT * FROM user_data_key_metrics_rollup LIMIT 10;
SELECT COUNT(*) FROM user_data_key_metrics_rollup;

-- REVIEW USER DATA PROFILE TABLE
SELECT * FROM user_data_profile LIMIT 10;
SELECT COUNT(*) FROM user_data_profile;

-- REVIEW RECENCY DATA TABLE
SELECT * FROM rfm_score_recency_data LIMIT 10;
SELECT COUNT(*) FROM rfm_score_recency_data;

-- REVIEW SCORE SUMMARY DATA TABLE
SELECT * FROM rfm_score_summary_data LIMIT 10;
SELECT COUNT(*) FROM rfm_score_summary_data;

-- REVIEW SUMMARY HISTORY DATA TABLE
SELECT * FROM rfm_score_summary_history_data LIMIT 10;
SELECT FORMAT(COUNT(*), 0) FROM rfm_score_summary_history_data LIMIT 10;
SELECT created_at_date, count(*) FROM rfm_score_summary_history_data GROUP BY created_at_date WITH ROLLUP;

-- DELETE OLD RECORDS FOR TODAY
-- DELETE FROM rfm_score_summary_history_data 
-- WHERE created_at_date = '2024-10-11';
-- SELECT created_at_date, count(*) FROM rfm_score_summary_history_data GROUP BY created_at_date WITH ROLLUP;

-- ALTER TABLE TO ADD COLUMNS
-- SELECT * FROM rfm_score_summary_history_data LIMIT 10;
-- ALTER TABLE rfm_score_summary_history_data
-- ADD COLUMN all_promo_codes_distinct VARCHAR(255) AFTER all_cities_distinct,
-- ADD COLUMN promo_code_on_most_recent_booking VARCHAR(255) AFTER all_promo_codes_distinct,
-- ADD COLUMN used_promo_code_last_14_days_flag VARCHAR(255) AFTER promo_code_on_most_recent_booking,
-- ADD COLUMN used_promo_code_on_every_booking VARCHAR(255) AFTER used_promo_code_last_14_days_flag;
-- SELECT * FROM rfm_score_summary_history_data LIMIT 10;
-- SELECT * FROM rfm_score_summary_history_data WHERE created_at_date = '2024-10-11';
SELECT COUNT(*) FROM rfm_score_summary_history_data WHERE all_promo_codes_distinct IS NOT NULL;

-- REVIEW SCORE SUMMARY DATA TABLE
SELECT * FROM rfm_score_summary_history_data_tracking;
SELECT COUNT(*) FROM rfm_score_summary_history_data_tracking WHERE all_promo_codes_distinct IS NOT NULL;

