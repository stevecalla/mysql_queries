-- STEP #7: CREATE RFM HISTOGRAMS FOR CUSTOM RANGES
USE ezhire_user_data;

SET @bin_count = 5;

-- RECENCY BINS
WITH recency_binned_data AS (
    SELECT
        booking_most_recent_return_vs_now,
        NTILE(@bin_count) OVER (ORDER BY booking_most_recent_return_vs_now) AS bin_number
    FROM rfm_score_recency_data
)
SELECT
    bin_number,
    MIN(booking_most_recent_return_vs_now) AS min,
    MAX(booking_most_recent_return_vs_now) AS max,
    COUNT(*) AS frequency
FROM recency_binned_data
GROUP BY bin_number WITH ROLLUP
ORDER BY bin_number;

-- FREQUENCY BINS
WITH frequency_binned_data AS (
    SELECT
        total_days_per_completed_and_started_bookings,
        NTILE(@bin_count) OVER (ORDER BY total_days_per_completed_and_started_bookings) AS bin_number
    FROM rfm_score_frequency_data
)
SELECT
    bin_number,
    MIN(total_days_per_completed_and_started_bookings) AS min,
    MAX(total_days_per_completed_and_started_bookings) AS max,
    COUNT(*) AS frequency
FROM frequency_binned_data
GROUP BY bin_number WITH ROLLUP
ORDER BY bin_number;

-- MONETARY BINS
WITH monetary_binned_data AS (
    SELECT
        booking_charge__less_discount_aed_per_completed_started_bookings,
        NTILE(@bin_count) OVER (ORDER BY booking_charge__less_discount_aed_per_completed_started_bookings) AS bin_number
    FROM rfm_score_monetary_data
)
SELECT
    bin_number,
    MIN(booking_charge__less_discount_aed_per_completed_started_bookings) AS min,
    MAX(booking_charge__less_discount_aed_per_completed_started_bookings) AS max,
    COUNT(*) AS frequency
FROM monetary_binned_data
GROUP BY bin_number WITH ROLLUP
ORDER BY bin_number;


