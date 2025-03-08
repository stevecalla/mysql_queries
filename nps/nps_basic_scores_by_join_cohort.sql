WITH filtered_user_data AS (
    -- Filter out rows with NULL NPS scores
    SELECT *
    FROM user_data_combined_booking_data
    WHERE nps_score IS NOT NULL
),
nps_extracted AS (
    -- Extract relevant fields and include date_join_cohort
    SELECT
        user_ptr_id,
        booking_id,
        booking_type,
        marketplace_or_dispatch,
        is_resident,
        date_join_cohort,
        date_join_year,
        date_join_month,
        return_year,
        return_month,
        nps_score,
        nps_comment
    FROM filtered_user_data
),
nps_categorized AS (
    -- Categorize NPS responses and count them based on date_join_cohort
    SELECT 
        date_join_cohort,
        COUNT(*) AS total_responses,
        SUM(CASE WHEN nps_score BETWEEN 9 AND 10 THEN 1 ELSE 0 END) AS promoters,
        SUM(CASE WHEN nps_score BETWEEN 0 AND 6 THEN 1 ELSE 0 END) AS detractors,
        SUM(CASE WHEN nps_score BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS passives
    FROM nps_extracted
    GROUP BY date_join_cohort
),
nps_calculated AS (
    -- Calculate the final NPS score for each cohort
    SELECT 
        date_join_cohort,
        total_responses,
        promoters,
        detractors,
        passives,
        (promoters - detractors) AS promoters_minus_detractors,
        ROUND(((promoters - detractors) * 100.0 / NULLIF(total_responses, 0)), 0) AS nps_score
    FROM nps_categorized
    WHERE date_join_cohort IS NOT NULL
),
join_cohort_counts AS (
    -- Count total number of joins (distinct customers) per date_join_cohort from the raw data
    SELECT 
        date_join_cohort,
        COUNT(DISTINCT user_ptr_id) AS total_joins
    FROM user_data_combined_booking_data
    WHERE date_join_cohort IS NOT NULL
    GROUP BY date_join_cohort
),
customer_rental_counts AS (
    -- For each join cohort, calculate each customer's lifetime rental count
    SELECT
		date_join_cohort,
        user_ptr_id,
        COUNT(DISTINCT booking_id) AS rental_count
    FROM user_data_combined_booking_data
	WHERE status NOT IN ('Cancelled by User')
		OR status IS NULL
    GROUP BY date_join_cohort, user_ptr_id
),
customer_type_counts AS (
    -- Count the number of customers with multiple vs. single lifetime rentals per join cohort
    SELECT 
        date_join_cohort,
        SUM(CASE WHEN rental_count > 1 THEN 1 ELSE 0 END) AS repeat_customer,
        SUM(CASE WHEN rental_count = 1 THEN 1 ELSE 0 END) AS '1_time_customer',
        SUM(CASE WHEN rental_count = 0 THEN 1 ELSE 0 END) AS looker_customer
    FROM customer_rental_counts
    GROUP BY date_join_cohort
),
nps_joined AS (
    -- Join the NPS calculations, join counts, and customer type counts together
    SELECT 
        nc.date_join_cohort,
        jcc.total_joins,
        ctc.repeat_customer,
        ctc.1_time_customer,
        ctc.looker_customer,
        nc.total_responses,
        nc.promoters,
        nc.detractors,
        nc.passives,
        nc.promoters_minus_detractors,
        nc.nps_score
    FROM nps_calculated nc
    JOIN join_cohort_counts jcc ON nc.date_join_cohort = jcc.date_join_cohort
    JOIN customer_type_counts ctc ON nc.date_join_cohort = ctc.date_join_cohort
),
nps_summary AS (
    -- Calculate the overall totals row
    SELECT 
        'Total' AS date_join_cohort,
        SUM(total_joins) AS total_joins,
        SUM(repeat_customer) AS repeat_customer,
        SUM(1_time_customer) AS '1_time_customer',
        SUM(looker_customer) AS looker_customer,
        SUM(total_responses) AS total_responses,
        SUM(promoters) AS promoters,
        SUM(detractors) AS detractors,
        SUM(passives) AS passives,
        (SUM(promoters) - SUM(detractors)) AS promoters_minus_detractors,
        ROUND(((SUM(promoters) - SUM(detractors)) * 100.0 / NULLIF(SUM(total_responses), 0)), 0) AS nps_score
    FROM nps_joined
)
-- Final result with total row
SELECT * FROM nps_joined
UNION ALL
SELECT * FROM nps_summary
ORDER BY date_join_cohort;
