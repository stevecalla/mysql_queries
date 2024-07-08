-- STEP #6: CREATE RFM SCORES
USE ezhire_user_data;

-- RANK VALUES FROM user_data_profile TABLE

-- CREATE RECENCY RANKING BASE
DROP TABLE IF EXISTS rfm_score_recency_data;
CREATE TABLE rfm_score_recency_data
    SELECT 
        user_ptr_id,
        date_join_cohort,
        email,
        mobile,
        telephone,
        first_name,
        last_name,
        
        -- COUNTRY / CITY
        all_countries_distinct,
        all_cities_distinct,

        booking_count_total,
        booking_count_cancel,
        booking_count_completed,
        booking_count_started,
        booking_count_future,
        booking_count_other,

        is_currently_started,
        is_repeat_new_first,
        is_renter,
        is_looker,
        is_canceller,
        booking_most_recent_return_date,
        rfm_recency_metric AS booking_most_recent_return_vs_now,

        FORMAT(percent_rank() OVER (ORDER BY rfm_recency_metric), 2) AS recency_rank,
        ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) AS row_number_id,
        COUNT(*) OVER () AS total_rows,
        ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () AS row_percent,

        NTILE(3) OVER (ORDER BY rfm_recency_metric DESC) AS recency_score_three_parts,
        -- SAME AS USING NTILE(3)
        -- CASE
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () > 0.66 THEN 1
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () > 0.33 THEN 2
        --     ELSE 3
        -- END AS recency_score_three_parts,
        
        NTILE(5) OVER (ORDER BY rfm_recency_metric DESC) AS recency_score_five_parts
        -- CASE
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () > 0.80 THEN 1
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () > 0.60 THEN 2
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () > 0.40 THEN 3
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_recency_metric, booking_most_recent_return_date) / COUNT(*) OVER () > 0.20 THEN 4
        --     ELSE 5
        -- END AS recency_score_five_parts, -- scoring dividing the data into three equal parts
        -- CASE
        -- 	WHEN rfm_recency_metric BETWEEN 205 AND 208 THEN 3
        --     WHEN rfm_recency_metric BETWEEN 209 and 213 THEN 2
        --     ELSE 1
        -- END AS recency_score_custom_parts

    FROM user_data_profile

    --  TOTAL WITH NO FILTER = 594,998
    WHERE 
        is_renter = "yes" -- 95,129 row(s) IN ('repeat', 'first', 'new')
            AND is_currently_started LIKE "no" -- 92,200 row(s)
            AND booking_count_future = 0 
            AND booking_count_other = 0 -- 91,989 row(s)
            AND booking_most_recent_return_date IS NOT NULL -- 91,984 row(s)
            AND rfm_recency_metric >= 0 -- 91,950 row(s)
            AND booking_charge__less_discount_aed_per_completed_started_bookings >= 0 -- 91,813 row(s)
            AND total_days_per_completed_and_started_bookings >= 0 -- 91,813
            AND all_countries_distinct LIKE '%United Arab Emirates%' -- 80,487 UAE combined with other countries
            -- AND all_countries_distinct LIKE 'United Arab Emirates' -- 80,105 only UAE (not UAE and other countries)
    ORDER BY rfm_recency_metric DESC, booking_most_recent_return_date ASC;


-- CREATE FREQUENY RANKING BASE
DROP TABLE IF EXISTS rfm_score_frequency_data;
CREATE TABLE rfm_score_frequency_data
    SELECT 
        user_ptr_id,
        is_currently_started,
        is_renter,
        is_looker,
        is_canceller,
        booking_most_recent_return_date,
        rfm_frequency_metric AS total_days_per_completed_and_started_bookings,

        FORMAT(percent_rank() OVER (ORDER BY rfm_frequency_metric), 2) AS frequency_rank,
        ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) AS row_number_id,
        COUNT(*) OVER () AS total_rows,
        ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) / COUNT(*) OVER () AS row_percent,

        NTILE(3) OVER (ORDER BY rfm_frequency_metric ASC) AS frequency_score_three_parts,
        -- CASE
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.33 THEN 1
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.66 THEN 2
        --     ELSE 3
        -- END AS frequency_score_three_parts,

        NTILE(5) OVER (ORDER BY rfm_frequency_metric ASC) AS frequency_score_five_parts
        -- CASE
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.20 THEN 1
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.40 THEN 2
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.60 THEN 3
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_frequency_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.80 THEN 4
        --     ELSE 5
        -- END AS frequency_score_five_parts, -- scoring dividing the data into three equal parts
        -- CASE
        -- 	WHEN rfm_frequency_metric BETWEEN 205 AND 208 THEN 3
        --     WHEN rfm_frequency_metric BETWEEN 209 and 213 THEN 2
        --     ELSE 1
        -- END AS frequency_score_custom_parts

    FROM user_data_profile
    --  TOTAL WITH NO FILTER = 594,998
    WHERE 
        is_renter = "yes" -- 95,129 row(s) IN ('repeat', 'first', 'new')
            AND is_currently_started LIKE "no" -- 92,200 row(s)
            AND booking_count_future = 0 
            AND booking_count_other = 0 -- 91,989 row(s)
            AND booking_most_recent_return_date IS NOT NULL -- 91,984 row(s)
            AND rfm_recency_metric >= 0 -- 91,950 row(s)
            AND booking_charge__less_discount_aed_per_completed_started_bookings >= 0 -- 91,813 row(s)
            AND total_days_per_completed_and_started_bookings >= 0 -- 91,813
            AND all_countries_distinct LIKE '%United Arab Emirates%' -- 80,487 UAE combined with other countries
            -- AND all_countries_distinct LIKE 'United Arab Emirates' -- 80,105 only UAE (not UAE and other countries)
    ORDER BY rfm_frequency_metric, booking_most_recent_return_date ASC;


-- CREATE MONETARY RANKING BASE
DROP TABLE IF EXISTS rfm_score_monetary_data;
CREATE TABLE rfm_score_monetary_data
    SELECT 
        user_ptr_id,
        is_currently_started,
        is_renter,
        is_looker,
        is_canceller,
        booking_most_recent_return_date,
        rfm_monetary_metric AS booking_charge__less_discount_aed_per_completed_started_bookings,

        FORMAT(percent_rank() OVER (ORDER BY rfm_monetary_metric), 2) AS monetary_rank,
        ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) AS row_number_id,
        COUNT(*) OVER () AS total_rows,
        ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) / COUNT(*) OVER () AS row_percent,

        NTILE(3) OVER (ORDER BY rfm_monetary_metric ASC) AS monetary_score_three_parts,
        -- CASE
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.33 THEN 1
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.66 THEN 2
        --     ELSE 3
        -- END AS monetary_score_three_parts,

        NTILE(5) OVER (ORDER BY rfm_monetary_metric ASC) AS monetary_score_five_parts
        -- CASE
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.20 THEN 1
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.40 THEN 2
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.60 THEN 3
        -- 	WHEN ROW_NUMBER() OVER (ORDER BY rfm_monetary_metric, booking_most_recent_return_date) / COUNT(*) OVER () < 0.80 THEN 4
        --     ELSE 5
        -- END AS monetary_score_five_parts, -- scoring dividing the data into three equal parts
        -- CASE
        -- 	WHEN rfm_monetary_metric BETWEEN 205 AND 208 THEN 3
        --     WHEN rfm_monetary_metric BETWEEN 209 and 213 THEN 2
        --     ELSE 1
        -- END AS monetary_score_custom_parts

    FROM user_data_profile
    --  TOTAL WITH NO FILTER = 594,998
    WHERE 
        is_renter = "yes" -- 95,129 row(s) IN ('repeat', 'first', 'new')
            AND is_currently_started LIKE "no" -- 92,200 row(s)
            AND booking_count_future = 0 
            AND booking_count_other = 0 -- 91,989 row(s)
            AND booking_most_recent_return_date IS NOT NULL -- 91,984 row(s)
            AND rfm_recency_metric >= 0 -- 91,950 row(s)
            AND booking_charge__less_discount_aed_per_completed_started_bookings >= 0 -- 91,813 row(s)
            AND total_days_per_completed_and_started_bookings >= 0 -- 91,813
            AND all_countries_distinct LIKE '%United Arab Emirates%' -- 80,487 UAE combined with other countries
            -- AND all_countries_distinct LIKE 'United Arab Emirates' -- 80,105 only UAE (not UAE and other countries)
    ORDER BY rfm_monetary_metric, booking_most_recent_return_date ASC;


SELECT * FROM rfm_score_recency_data ORDER BY booking_most_recent_return_vs_now DESC;
SELECT * FROM rfm_score_frequency_data;      
SELECT * FROM rfm_score_monetary_data;

-- CREATE RFM SUMMARY SCORE DATA
DROP TABLE IF EXISTS rfm_score_summary_data;
CREATE TABLE rfm_score_summary_data
    SELECT
        r.*,    
        -- r.booking_most_recent_return_vs_now,
        f.total_days_per_completed_and_started_bookings,
        m.booking_charge__less_discount_aed_per_completed_started_bookings,

        -- FIRST & LAST VALUE - THREE PARTS
        CONCAT(r.recency_score_three_parts, f.frequency_score_three_parts, m.monetary_score_three_parts) AS score_three_parts,
        
        FIRST_VALUE(r.booking_most_recent_return_vs_now) OVER (PARTITION BY r.recency_score_three_parts ORDER BY r.booking_most_recent_return_vs_now DESC) AS three_parts_first_recency_amount,    
        LAST_VALUE(r.booking_most_recent_return_vs_now) OVER (
            PARTITION BY r.recency_score_three_parts 
            ORDER BY r.booking_most_recent_return_vs_now DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS three_parts_last_recency_amount,
        
        FIRST_VALUE(f.total_days_per_completed_and_started_bookings) OVER (PARTITION BY f.frequency_score_three_parts ORDER BY f.total_days_per_completed_and_started_bookings DESC) AS three_parts_first_frequency_amount,    
        LAST_VALUE(f.total_days_per_completed_and_started_bookings) OVER (
            PARTITION BY f.frequency_score_three_parts 
            ORDER BY f.total_days_per_completed_and_started_bookings DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS three_parts_last_frequency_amount,
        
        FIRST_VALUE(m.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (PARTITION BY m.monetary_score_three_parts ORDER BY m.booking_charge__less_discount_aed_per_completed_started_bookings DESC) AS three_parts_first_monetary_amount,    
        LAST_VALUE(m.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (
            PARTITION BY m.monetary_score_three_parts 
            ORDER BY m.booking_charge__less_discount_aed_per_completed_started_bookings DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS three_parts_last_monetary_amount,

        -- FIRST & LAST VALUE - FIVE PARTS
        CONCAT(r.recency_score_five_parts, f.frequency_score_five_parts, m.monetary_score_five_parts) AS score_five_parts,

        FIRST_VALUE(r.booking_most_recent_return_vs_now) OVER (PARTITION BY r.recency_score_five_parts ORDER BY r.booking_most_recent_return_vs_now DESC) AS five_parts_first_recency_amount,    
        LAST_VALUE(r.booking_most_recent_return_vs_now) OVER (
            PARTITION BY r.recency_score_five_parts 
            ORDER BY r.booking_most_recent_return_vs_now DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS five_parts_last_recency_amount,
        
        FIRST_VALUE(f.total_days_per_completed_and_started_bookings) OVER (PARTITION BY f.frequency_score_five_parts ORDER BY f.total_days_per_completed_and_started_bookings DESC) AS five_parts_first_frequency_amount,    
        LAST_VALUE(f.total_days_per_completed_and_started_bookings) OVER (
            PARTITION BY f.frequency_score_five_parts 
            ORDER BY f.total_days_per_completed_and_started_bookings DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS five_parts_last_frequency_amount,
        
        FIRST_VALUE(m.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (PARTITION BY m.monetary_score_five_parts ORDER BY m.booking_charge__less_discount_aed_per_completed_started_bookings DESC) AS five_parts_first_monetary_amount,    
        LAST_VALUE(m.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (
            PARTITION BY m.monetary_score_five_parts 
            ORDER BY m.booking_charge__less_discount_aed_per_completed_started_bookings DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS five_parts_last_monetary_amount,

        CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group

        -- -- FIRST & LAST VALUE - CUSTOM PARTS
        -- CONCAT(r.recency_score_custom_parts, f.frequency_score_custom_parts, m.monetary_score_custom_parts) AS score_custom_parts,

        -- FIRST_VALUE(r.booking_most_recent_return_vs_now) OVER (PARTITION BY r.recency_score_custom_parts ORDER BY r.booking_most_recent_return_vs_now DESC) AS custom_parts_first_recency_amount,    
        -- LAST_VALUE(r.booking_most_recent_return_vs_now) OVER (
        --     PARTITION BY r.recency_score_custom_parts 
        --     ORDER BY r.booking_most_recent_return_vs_now DESC
        --     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        -- ) AS custom_parts_last_recency_amount,
        
        -- FIRST_VALUE(f.total_days_per_completed_and_started_bookings) OVER (PARTITION BY f.frequency_score_custom_parts ORDER BY f.total_days_per_completed_and_started_bookings DESC) AS custom_parts_first_frequency_amount,    
        -- LAST_VALUE(f.total_days_per_completed_and_started_bookings) OVER (
        --     PARTITION BY f.frequency_score_custom_parts 
        --     ORDER BY f.total_days_per_completed_and_started_bookings DESC
        --     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        -- ) AS custom_parts_last_frequency_amount,
        
        -- FIRST_VALUE(m.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (PARTITION BY m.monetary_score_custom_parts ORDER BY m.booking_charge__less_discount_aed_per_completed_started_bookings DESC) AS custom_parts_first_monetary_amount,    
        -- LAST_VALUE(m.booking_charge__less_discount_aed_per_completed_started_bookings) OVER (
        --     PARTITION BY m.monetary_score_custom_parts 
        --     ORDER BY m.booking_charge__less_discount_aed_per_completed_started_bookings DESC
        --     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        -- ) AS custom_parts_last_monetary_amount


FROM rfm_score_recency_data as r
    INNER JOIN rfm_score_frequency_data AS f ON r.user_ptr_id = f.user_ptr_id
    INNER JOIN rfm_score_monetary_data AS m ON r.user_ptr_id = m.user_ptr_id
ORDER BY r.booking_most_recent_return_date DESC;

SELECT * FROM rfm_score_summary_data;
