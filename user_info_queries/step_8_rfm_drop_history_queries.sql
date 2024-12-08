USE ezhire_user_data;

-- ********************
-- SELECT 'history', COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data;
-- SELECT 'history backup', COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data_backup;
-- SELECT 'history backup v2', COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data_backup_v2;
-- SELECT * FROM ezhire_user_data.rfm_score_summary_history_data LIMIT 10;
-- SELECT 'history', created_at_date, COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data GROUP BY 2;

-- ********************
-- DONE created_at_date BETWEEN '2024-07-05' AND '2024-07-06'; -- '2024-07-08'
-- DONE created_at_date BETWEEN '2024-07-10' AND '2024-07-21'; -- '2024-07-23'
-- DONE created_at_date BETWEEN '2024-07-24' AND '2024-07-31'; -- '2024-07-23'
-- DONE created_at_date BETWEEN '2024-08-01' AND '2024-09-23'; -- '2024-09-26'
-- DONE created_at_date BETWEEN '2024-09-27' AND '2024-09-30'; -- '2024-09-26'
-- DONE created_at_date BETWEEN '2024-10-01' AND '2024-11-15';
-- DONE created_at_date BETWEEN '2024-11-16' AND '2024-11-30';

-- ********************
DELETE FROM rfm_score_summary_history_data
WHERE created_at_date BETWEEN '2024-07-05' AND '2024-07-06'; -- DONE

DELETE FROM rfm_score_summary_history_data
WHERE created_at_date BETWEEN '2024-07-10' AND '2024-07-21';

DELETE FROM rfm_score_summary_history_data
WHERE created_at_date BETWEEN '2024-07-24' AND '2024-07-31';

DELETE FROM rfm_score_summary_history_data
WHERE created_at_date BETWEEN '2024-08-01' AND '2024-09-23';

DELETE FROM rfm_score_summary_history_data
WHERE created_at_date BETWEEN '2024-09-27' AND '2024-09-30';

DELETE FROM rfm_score_summary_history_data
WHERE created_at_date BETWEEN '2024-10-01' AND '2024-11-30';

SELECT 'history', created_at_date, COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data GROUP BY 2;

-- ********************
DELETE FROM rfm_score_summary_history_data_backup
WHERE created_at_date BETWEEN '2024-07-05' AND '2024-07-06'; -- DONE

DELETE FROM rfm_score_summary_history_data_backup
WHERE created_at_date BETWEEN '2024-07-10' AND '2024-07-21';

DELETE FROM rfm_score_summary_history_data_backup
WHERE created_at_date BETWEEN '2024-07-24' AND '2024-07-31';

DELETE FROM rfm_score_summary_history_data_backup
WHERE created_at_date BETWEEN '2024-08-01' AND '2024-09-23';

DELETE FROM rfm_score_summary_history_data_backup
WHERE created_at_date BETWEEN '2024-09-27' AND '2024-09-30';

DELETE FROM rfm_score_summary_history_data_backup
WHERE created_at_date BETWEEN '2024-10-01' AND '2024-11-30';

SELECT 'history', created_at_date, COUNT(*) FROM rfm_score_summary_history_data_backup GROUP BY 2;

-- **********************
OPTIMIZE TABLE rfm_score_summary_history_data;
OPTIMIZE TABLE rfm_score_summary_history_data_backup;





