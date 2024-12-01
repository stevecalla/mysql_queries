-- STEP #7: CREATE RFM HISTOGRAMS FOR CUSTOM RANGES
USE ezhire_user_data;

SET @bin_count = 3;

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

-- Query to calculate descriptive statistics
SELECT 
    COUNT(*) AS count,
    AVG(booking_most_recent_return_vs_now) AS mean,	
    (
        SELECT booking_most_recent_return_vs_now
        FROM (
            SELECT booking_most_recent_return_vs_now, ROW_NUMBER() OVER (ORDER BY booking_most_recent_return_vs_now) AS row_num
            FROM rfm_score_recency_data
            ORDER BY booking_most_recent_return_vs_now
        ) AS subquery
        WHERE row_num = (SELECT CEILING(COUNT(*) / 2) FROM rfm_score_recency_data)
    ) AS median,
	(
        SELECT booking_most_recent_return_vs_now
        FROM rfm_score_recency_data
        GROUP BY booking_most_recent_return_vs_now
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS mode,
    MAX(booking_most_recent_return_vs_now) - MIN(booking_most_recent_return_vs_now) AS x_range,
    MIN(booking_most_recent_return_vs_now) AS min_value,
    MAX(booking_most_recent_return_vs_now) AS max_value,
    SUM(booking_most_recent_return_vs_now) AS sum_value,
    STDDEV_SAMP(booking_most_recent_return_vs_now) AS std_error
FROM rfm_score_recency_data;

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

-- Query to calculate descriptive statistics
SELECT 
    COUNT(*) AS count,
    AVG(total_days_per_completed_and_started_bookings) AS mean,	
    (
        SELECT total_days_per_completed_and_started_bookings
        FROM (
            SELECT total_days_per_completed_and_started_bookings, ROW_NUMBER() OVER (ORDER BY total_days_per_completed_and_started_bookings) AS row_num
            FROM rfm_score_frequency_data
            ORDER BY total_days_per_completed_and_started_bookings
        ) AS subquery
        WHERE row_num = (SELECT CEILING(COUNT(*) / 2) FROM rfm_score_frequency_data)
    ) AS median,
	(
        SELECT total_days_per_completed_and_started_bookings
        FROM rfm_score_frequency_data
        GROUP BY total_days_per_completed_and_started_bookings
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS mode,
    MAX(total_days_per_completed_and_started_bookings) - MIN(total_days_per_completed_and_started_bookings) AS x_range,
    MIN(total_days_per_completed_and_started_bookings) AS min_value,
    MAX(total_days_per_completed_and_started_bookings) AS max_value,
    SUM(total_days_per_completed_and_started_bookings) AS sum_value,
    STDDEV_SAMP(total_days_per_completed_and_started_bookings) AS std_error
FROM rfm_score_frequency_data;

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

-- Query to calculate descriptive statistics
SELECT 
    COUNT(*) AS count,
    AVG(booking_charge__less_discount_aed_per_completed_started_bookings) AS mean,	
    (
        SELECT booking_charge__less_discount_aed_per_completed_started_bookings
        FROM (
            SELECT booking_charge__less_discount_aed_per_completed_started_bookings, ROW_NUMBER() OVER (ORDER BY booking_charge__less_discount_aed_per_completed_started_bookings) AS row_num
            FROM rfm_score_monetary_data
            ORDER BY booking_charge__less_discount_aed_per_completed_started_bookings
        ) AS subquery
        WHERE row_num = (SELECT CEILING(COUNT(*) / 2) FROM rfm_score_monetary_data)
    ) AS median,
	(
        SELECT booking_charge__less_discount_aed_per_completed_started_bookings
        FROM rfm_score_monetary_data
        GROUP BY booking_charge__less_discount_aed_per_completed_started_bookings
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS mode,
    MAX(booking_charge__less_discount_aed_per_completed_started_bookings) - MIN(booking_charge__less_discount_aed_per_completed_started_bookings) AS x_range,
    MIN(booking_charge__less_discount_aed_per_completed_started_bookings) AS min_value,
    MAX(booking_charge__less_discount_aed_per_completed_started_bookings) AS max_value,
    SUM(booking_charge__less_discount_aed_per_completed_started_bookings) AS sum_value,
    STDDEV_SAMP(booking_charge__less_discount_aed_per_completed_started_bookings) AS std_error
FROM rfm_score_monetary_data;


