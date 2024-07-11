-- STEP #8a: CREATE RFM HISTORY TABLE
-- ONLY NECESSARY TO CREATE THE INITIAL TABLE
-- THEREAFTER DATA WILL BE INSERTED EACH TIME

USE ezhire_user_data;

-- DROP TABLE IF EXISTS
DROP TABLE IF EXISTS rfm_score_summary_history_data;

-- CREATE TABLE
CREATE TABLE rfm_score_summary_history_data
    SELECT
        *,
        DATE_FORMAT(created_at, '%m/%d/%Y') AS created_at_date
FROM rfm_score_summary_data;

-- SELECT HISTORY TABLE
SELECT * FROM rfm_score_summary_history_data;