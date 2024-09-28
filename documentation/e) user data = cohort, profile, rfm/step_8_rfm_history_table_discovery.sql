-- STEP #8: CREATE RFM HISTORY DATA
USE ezhire_user_data;

-- UPDATE rfm_score_summary_data WITH CORRECT created_at DATE
UPDATE rfm_score_summary_data
SET created_at = '2024-07-01 15:22:10';

SELECT * FROM rfm_score_summary_data;

-- DROP TABLE IF EXISTS
DROP TABLE IF EXISTS rfm_score_summary_history_data_backup;

-- CREATE BACKUP
CREATE TABLE rfm_score_summary_history_data_backup LIKE rfm_score_summary_history_data;
INSERT INTO rfm_score_summary_history_data_backup SELECT * FROM rfm_score_summary_history_data;

SELECT * FROM rfm_score_summary_history_data_backup;

-- DROP TABLE IF EXISTS
DROP TABLE IF EXISTS rfm_score_summary_history_data;

-- CREATE TABLE
CREATE TABLE rfm_score_summary_history_data
    SELECT
        *,
        DATE_FORMAT(created_at, '%m/%d/%Y') AS created_at_date
        -- DATE_FORMAT('2024-07-01', '%m/%d/%Y') AS created_at_date
FROM rfm_score_summary_data;

-- INSERT MOST RECENT RECORDS FROM DAILY SUMMARY TABLE INTO THE HISTORY TABLE
-- INSERT INTO rfm_score_summary_history_data (user_ptr_id,date_join_cohort,email,mobile,telephone,all_countries_distinct,all_cities_distinct,booking_count_total,booking_count_cancel,booking_count_completed,booking_count_started,booking_count_future,booking_count_other,is_currently_started,is_repeat_new_first,is_renter,is_looker,is_canceller,booking_most_recent_return_date,booking_most_recent_return_vs_now,recency_rank,row_number_id,total_rows,row_percent,recency_score_three_parts,recency_score_five_parts,created_at,total_days_per_completed_and_started_bookings,booking_charge__less_discount_aed_per_completed_started_bookings,score_three_parts,three_parts_first_recency_amount,three_parts_last_recency_amount,three_parts_first_frequency_amount,three_parts_last_frequency_amount,three_parts_first_monetary_amount,three_parts_last_monetary_amount,score_five_parts,five_parts_first_recency_amount,five_parts_last_recency_amount,five_parts_first_frequency_amount,five_parts_last_frequency_amount,five_parts_first_monetary_amount,five_parts_last_monetary_amount,created_at_date)
-- SELECT 
-- 	*,
--  DATE_FORMAT(created_at, '%m/%d/%Y') AS created_at_date
-- 	DATE_FORMAT('2024-07-02', '%m/%d/%Y') AS created_at_date
-- FROM rfm_score_summary_data;

-- GET COUNT OF RECORDS
SELECT COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data;

-- DISPLAY THE SCORE BY CREATED DATE
SELECT
    score_five_parts,
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '07/01/2024',
    SUM(CASE WHEN created_at_date = '07/02/2024' THEN 1 ELSE 0 END) AS '07/02/2024',
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN 1 ELSE 0 END) - SUM(CASE WHEN created_at_date = '07/02/2024' THEN 1 ELSE 0 END) AS difference
    
FROM ezhire_user_data.rfm_score_summary_history_data
GROUP BY score_five_parts
ORDER BY score_five_parts ASC;
    
-- DISPLAY THE SCORE BY CREATED DATE
SELECT
    user_ptr_id,
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN score_five_parts ELSE 0 END) AS '07/01/2024',
    SUM(CASE WHEN created_at_date = '07/02/2024' THEN score_five_parts ELSE 0 END) AS '07/02/2024',
    SUM(CASE WHEN created_at_date = '07/01/2024' THEN score_five_parts ELSE 0 END) - SUM(CASE WHEN created_at_date = '07/02/2024' THEN score_five_parts ELSE 0 END) AS difference
    
FROM ezhire_user_data.rfm_score_summary_history_data
GROUP BY  user_ptr_id
ORDER BY user_ptr_id ASC;

-- DISPLAY THE SCORE BY CREATED DATE
SELECT
    score_five_parts,
    SUM(CASE WHEN score_five_parts = '111' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '111',
    SUM(CASE WHEN score_five_parts = '112' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '112',
    SUM(CASE WHEN score_five_parts = '113' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '113',
    SUM(CASE WHEN score_five_parts = '114' AND created_at_date = '07/01/2024' THEN 1 ELSE 0 END) AS '114'
FROM ezhire_user_data.rfm_score_summary_history_data
GROUP BY score_five_parts
ORDER BY score_five_parts ASC;





