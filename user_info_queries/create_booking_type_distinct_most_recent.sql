-- Query to fetch all booking details for a specific user, excluding cancelled bookings
-- This helps in understanding the individual booking records including the return date and status
SELECT 
    user_ptr_id, 
    booking_type, 
    booking_id,
    return_date,
    status
FROM 
    ezhire_user_data.user_data_combined_booking_data 
WHERE 
    user_ptr_id IN (8) -- Filter by specific user ID(s)
    AND status NOT IN ('Cancelled by User') -- Exclude cancelled bookings
ORDER BY 
    return_date; -- Order by return date for chronological context

-- Query to get aggregated booking types for a specific user
-- Provides a comprehensive view of all booking types (including duplicates) and distinct booking types
-- Useful for summarizing the variety of booking types associated with a user
SELECT 
    user_ptr_id,
    -- Concatenate all booking types excluding cancelled ones
    GROUP_CONCAT(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_type END ORDER BY booking_type ASC SEPARATOR ', ') AS booking_type_all,
    -- Concatenate distinct booking types excluding cancelled ones
    GROUP_CONCAT(DISTINCT CASE WHEN status NOT LIKE '%cancelled%' THEN booking_type END ORDER BY booking_type ASC SEPARATOR ', ') AS booking_type_all_distinct
FROM 
    ezhire_user_data.user_data_combined_booking_data 
WHERE 
    user_ptr_id IN (8) -- Filter by specific user ID(s)
    AND status NOT IN ('Cancelled by User') -- Exclude cancelled bookings
GROUP BY 
    user_ptr_id; -- Group by user ID to aggregate booking types for each user

-- Create indexes to improve query performance on user_ptr_id, status, and return_date columns
-- Indexes help speed up lookups and join operations involving these columns
DROP INDEX idx_user_ptr_id_status ON ezhire_user_data.user_data_combined_booking_data;
DROP INDEX idx_user_ptr_id_return_date ON ezhire_user_data.user_data_combined_booking_data;
DROP INDEX idx_user_ptr_id_dates ON ezhire_user_data.user_data_combined_booking_data;-- Drop index if it exists, to avoid errors if the index does not exist

CREATE INDEX idx_user_ptr_id_dates ON ezhire_user_data.user_data_combined_booking_data (user_ptr_id, booking_date, pickup_date, return_date);
CREATE INDEX idx_user_ptr_id_status ON ezhire_user_data.user_data_combined_booking_data (user_ptr_id, status);
CREATE INDEX idx_user_ptr_id_return_date ON ezhire_user_data.user_data_combined_booking_data (user_ptr_id, return_date);

-- Optimized query to fetch booking details along with the most recent booking type and aggregated booking types
-- Uses derived tables to precompute values and joins to combine results, improving performance
SELECT 
    d.user_ptr_id,
    d.booking_type,
    d.booking_id,
    d.return_date,
    d.status,
    -- Subquery to get the most recent booking type based on the most recent return date
    (SELECT booking_type
     FROM ezhire_user_data.user_data_combined_booking_data AS inner_data
     WHERE inner_data.user_ptr_id = d.user_ptr_id
       AND inner_data.return_date = (
           SELECT MAX(return_date)
           FROM ezhire_user_data.user_data_combined_booking_data AS inner_data2
           WHERE inner_data2.user_ptr_id = inner_data.user_ptr_id
             AND inner_data2.status NOT IN ('Cancelled by User')
       )
       AND inner_data.status NOT IN ('Cancelled by User')
     LIMIT 1) AS booking_type_most_recent,
     
    -- Aggregate all booking types for the user
    (SELECT GROUP_CONCAT(CASE WHEN status NOT IN ('Cancelled by User') THEN booking_type END ORDER BY booking_type ASC SEPARATOR ', ')
     FROM ezhire_user_data.user_data_combined_booking_data AS inner_data
     WHERE inner_data.user_ptr_id = d.user_ptr_id
     AND inner_data.status NOT IN ('Cancelled by User')) AS booking_type_all,
     
    -- Aggregate distinct booking types for the user
    (SELECT GROUP_CONCAT(DISTINCT CASE WHEN status NOT IN ('Cancelled by User') THEN booking_type END ORDER BY booking_type ASC SEPARATOR ', ')
     FROM ezhire_user_data.user_data_combined_booking_data AS inner_data
     WHERE inner_data.user_ptr_id = d.user_ptr_id
     AND inner_data.status NOT IN ('Cancelled by User')) AS booking_type_all_distinct
FROM 
    ezhire_user_data.user_data_combined_booking_data AS d
WHERE 
    d.user_ptr_id IN (8) -- Filter by specific user ID(s)
    AND d.status NOT IN ('Cancelled by User') -- Exclude cancelled bookings
ORDER BY 
    d.return_date; -- Order by return date for chronological context
    
-- QUERIES TO CHECK ALL WORK
-- update step 2
	-- DONE = update step 2 indexes
    -- DONE = update key metrics rollup
-- update step 3
    -- DONE = update profile data
    -- DONE = double check above / run full code
-- DONE = update step 6
-- DONE = update step 8
-- DONE = tracking update?
-- bq load update?
    
-- UPDATE INDEX
SELECT * FROM ezhire_user_data.user_data_combined_booking_data;
SELECT COUNT(*) FROM ezhire_user_data.user_data_combined_booking_data;
SHOW INDEX FROM ezhire_user_data.user_data_combined_booking_data;

-- UPDATE WITH BOOKING TYPE
SELECT * FROM ezhire_user_data.user_data_key_metrics_rollup;
SELECT COUNT(*) FROM ezhire_user_data.user_data_key_metrics_rollup;

-- UPDATE WITH BOOKING TYPE
SELECT * FROM ezhire_user_data.user_data_profile;
SELECT COUNT(*) FROM ezhire_user_data.user_data_profile;

-- UPDATE WITH BOOKING TYPE
SELECT * FROM ezhire_user_data.rfm_score_recency_data;
SELECT COUNT(*) FROM ezhire_user_data.rfm_score_recency_data;

-- UPDATE WITH BOOKING TYPE
SELECT * FROM ezhire_user_data.rfm_score_summary_data;
SELECT COUNT(*) FROM ezhire_user_data.rfm_score_summary_data;

-- UPDATE WITH BOOKING TYPE
SELECT * FROM ezhire_user_data.rfm_score_summary_history_data LIMIT 10;
SELECT COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data;
SELECT created_at_date, COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data GROUP BY created_at_date ORDER BY created_at_date;
SELECT * FROM ezhire_user_data.rfm_score_summary_history_data WHERE created_at_date = '2024-08-06';
SELECT * FROM ezhire_user_data.rfm_score_summary_history_data WHERE created_at_date = '2024-08-07';

-- DELETE FROM ezhire_user_data.rfm_score_summary_history_data
-- WHERE created_at_date = '2024-08-07';

SELECT * FROM ezhire_user_data.rfm_score_summary_history_data_backup;
SELECT COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data_backup;
SELECT * FROM ezhire_user_data.rfm_score_summary_history_data_backup_v2;
SELECT COUNT(*) FROM ezhire_user_data.rfm_score_summary_history_data_backup_v2;

SELECT * FROM ezhire_user_data.rfm_score_summary_history_data_tracking;
