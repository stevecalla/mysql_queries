WITH filtered_user_data AS (
    -- Filter out NULL NPS scores from the dataset
    SELECT
        *
    FROM user_data_combined_booking_data
    WHERE nps_score IS NOT NULL
),
nps_extracted AS (
    -- Extract relevant fields and format return_year_month
    SELECT
        user_ptr_id,
        booking_id,
        booking_type,
        marketplace_or_dispatch,
        is_resident, -- telephone prefix
        -- join with profile to get is_repeat_new_first & other dimensions
        date_join_cohort,
        date_join_year,
        date_join_month,
        CONCAT(return_year, '-', LPAD(return_month, 2, '0')) AS return_year_month,
        return_year,
        return_month,
        nps_score,
        nps_comment
    FROM filtered_user_data
),
nps_categorized AS (
    -- Categorize NPS responses and count them
    SELECT 
        return_year_month,
        COUNT(*) AS total_responses,
        SUM(CASE WHEN nps_score BETWEEN 9 AND 10 THEN 1 ELSE 0 END) AS promoters,
        SUM(CASE WHEN nps_score BETWEEN 0 AND 6 THEN 1 ELSE 0 END) AS detractors,
        SUM(CASE WHEN nps_score BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS passives
    FROM nps_extracted
    GROUP BY return_year_month
),
nps_calculated AS (
    -- Calculate the final NPS score for each month
    SELECT 
        return_year_month,
        total_responses,
        promoters,
        detractors,
        passives,
        (promoters - detractors) AS promoters_minus_detractors,
        ROUND(((promoters - detractors) * 100.0 / NULLIF(total_responses, 0)), 0) AS nps_score
    FROM nps_categorized
    WHERE 
        return_year_month IS NOT NULL
        AND return_year_month <> "0-00"
        AND return_year_month <> "2028-07"
),
nps_summary AS (
    -- Calculate the total row
    SELECT 
        'Total' AS return_year_month,
        SUM(total_responses) AS total_responses,
        SUM(promoters) AS promoters,
        SUM(detractors) AS detractors,
        SUM(passives) AS passives,
        (SUM(promoters) - SUM(detractors)) AS promoters_minus_detractors,
        ROUND(((SUM(promoters) - SUM(detractors)) * 100.0 / NULLIF(SUM(total_responses), 0)), 0) AS nps_score
    FROM nps_calculated
)
-- Final result with total row
SELECT * FROM nps_calculated
UNION ALL
SELECT * FROM nps_summary
ORDER BY return_year_month;
