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
-- SET has_promo_code = IF(promo_code IS NULL OR promo_code = '', 'no', 'yes');

SELECT * FROM rfm_score_summary_history_data_tracking;
