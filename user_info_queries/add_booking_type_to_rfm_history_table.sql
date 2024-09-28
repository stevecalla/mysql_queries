-- SELECT * FROM ezhire_user_data.rfm_score_summary_history_data ORDER BY user_ptr_id LIMIT 10;

-- -- Add new columns to the table
-- ALTER TABLE rfm_score_summary_history_data
-- ADD COLUMN booking_type_all_distinct VARCHAR(255) NULL AFTER all_cities_distinct,
-- ADD COLUMN booking_type_most_recent VARCHAR(255) NULL AFTER booking_type_all_distinct;

-- SELECT * FROM ezhire_user_data.rfm_score_summary_history_data ORDER BY user_ptr_id LIMIT 10;

-- SELECT
-- 	h.user_ptr_id,
--     p.booking_type_all_distinct,
--     p.booking_type_most_recent
-- FROM ezhire_user_data.rfm_score_summary_history_data AS h
-- 	LEFT JOIN ezhire_user_data.user_data_profile AS p ON h.user_ptr_id = p.user_ptr_id
-- LIMIT 10;

-- DROP INDEX idx_user_ptr_id ON ezhire_user_data.rfm_score_summary_history_data;
-- DROP INDEX idx_user_ptr_id ON ezhire_user_data.user_data_profile;
-- CREATE INDEX idx_user_ptr_id ON ezhire_user_data.rfm_score_summary_history_data(user_ptr_id);
-- CREATE INDEX idx_user_ptr_id ON ezhire_user_data.user_data_profile(user_ptr_id);

UPDATE ezhire_user_data.rfm_score_summary_history_data AS h
JOIN ezhire_user_data.user_data_profile AS p
ON h.user_ptr_id = p.user_ptr_id
SET
    h.booking_type_all_distinct = p.booking_type_all_distinct,
    h.booking_type_most_recent = p.booking_type_most_recent;
    
SELECT * FROM ezhire_user_data.rfm_score_summary_history_data ORDER BY user_ptr_id LIMIT 10;
SELECT * FROM ezhire_user_data.rfm_score_summary_history_data ORDER BY user_ptr_id;
