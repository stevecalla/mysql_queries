USE ezhire_user_data;

-- UPDATE rfm_score_summary_data WITH CORRECT created_at DATE
-- UPDATE rfm_score_summary_data
-- SET created_at = '2024-07-01 15:22:10';

SELECT * FROM rfm_score_summary_data;

SELECT * FROM rfm_score_summary_history_data;

SELECT * FROM rfm_score_summary_history_data_backup;

-- DROP TABLE IF EXISTS
-- DROP TABLE IF EXISTS rfm_score_summary_data_backup;
-- CREATE BACKUP
-- CREATE TABLE rfm_score_summary_data_backup LIKE rfm_score_summary_data;
-- INSERT INTO rfm_score_summary_data_backup SELECT * FROM rfm_score_summary_data;
-- SELECT * FROM rfm_score_summary_data_backup;

-- DROP TABLE IF EXISTS
DROP TABLE IF EXISTS rfm_score_summary_history_data_backup_v2;
-- CREATE BACKUP
CREATE TABLE rfm_score_summary_history_data_backup_v2 LIKE rfm_score_summary_history_data;
INSERT INTO rfm_score_summary_history_data_backup_v2 SELECT * FROM rfm_score_summary_history_data;
SELECT * FROM rfm_score_summary_history_data_backup_v2;