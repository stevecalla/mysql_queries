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
        status,
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
)
SELECT * FROM nps_extracted
;
