USE ezhire_user_data;

-- SELECT * FROM rfm_score_summary_data;

SELECT created_at, count(*) FROM rfm_score_summary_data GROUP BY created_at WITH ROLLUP;

-- UPDATE ezhire_user_data.rfm_score_summary_data
-- SET created_at = '2024-07-25 11:45:00'
-- WHERE created_at = '2024-07-26 15:51:30';

SELECT created_at, count(*) FROM rfm_score_summary_data GROUP BY created_at WITH ROLLUP;

-- SELECT * FROM rfm_score_summary_data_backup;

SELECT created_at, count(*) FROM rfm_score_summary_data_backup GROUP BY created_at WITH ROLLUP;

-- DELETE FROM rfm_score_summary_history_data
-- WHERE created_at_date = '07/05/2024';

-- SELECT * FROM rfm_score_summary_history_data;

SELECT created_at_date, count(*) FROM rfm_score_summary_history_data GROUP BY created_at_date WITH ROLLUP;

-- SELECT * FROM rfm_score_summary_history_data_backup;

-- DELETE FROM rfm_score_summary_history_data_backup
-- WHERE created_at_date = '07/05/2024';

SELECT created_at_date, count(*) FROM rfm_score_summary_history_data_backup GROUP BY created_at_date WITH ROLLUP;

-- SELECT * FROM rfm_score_summary_history_data_backup_v2;

SELECT created_at_date, count(*) FROM rfm_score_summary_history_data_backup_v2 GROUP BY created_at_date WITH ROLLUP;

SELECT min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking GROUP BY min_created_at_date, max_created_at_date ORDER BY count(*);

SELECT min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking_most_recent GROUP BY min_created_at_date, max_created_at_date ORDER BY count(*);

-- SELECT * FROM ezhire_user_data.user_data_combined_booking_data LIMIT 10;

