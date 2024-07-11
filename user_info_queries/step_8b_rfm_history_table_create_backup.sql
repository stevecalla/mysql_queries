-- STEP #8b: CREATE BACKUP OF rfm_score_history_data TABLE
USE ezhire_user_data;

-- DROP TABLE IF EXISTS
DROP TABLE IF EXISTS rfm_score_summary_history_data_backup;

-- CREATE BACKUP
CREATE TABLE rfm_score_summary_history_data_backup LIKE rfm_score_summary_history_data;
INSERT INTO rfm_score_summary_history_data_backup SELECT * FROM rfm_score_summary_history_data;

-- SELECT HISTORY TABLE
SELECT * FROM rfm_score_summary_history_data_backup;