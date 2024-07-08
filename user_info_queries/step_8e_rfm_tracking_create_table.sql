USE ezhire_user_data;

-- COMPARE MIN DATE VS MAX DATE
SET @min_created_at_date = (SELECT MIN(created_at_date) FROM rfm_score_summary_history_data);

-- MAX DATE IS ALWAYS THE DAY... THE MOST RECENT
SET @max_created_at_date = (SELECT MAX(created_at_date) FROM rfm_score_summary_history_data);
SET @max_created_at_date_plus_1 = DATE_ADD(@max_created_at_date, INTERVAL 1 DAY);

DROP TABLE IF EXISTS rfm_score_summary_history_data_tracking;

CREATE TABLE rfm_score_summary_history_data_tracking AS
SELECT 
    *,
	-- RFM SEGMENTS
    CASE
        WHEN score_three_parts_as_of_initial_date = 0 THEN 'new'
        WHEN booking_count > 0 THEN 'booker'
        WHEN score_three_parts_difference = 0 THEN 'same'
        WHEN score_three_parts_difference <> 0 THEN 'migrated'
        ELSE 'unknown'
    END AS rfm_segment_three_parts,
    CASE
        WHEN score_five_parts_as_of_initial_date = 0 THEN 'new'
        WHEN booking_count > 0 THEN 'booker'
        WHEN score_five_parts_difference = 0 THEN 'same'
        WHEN score_five_parts_difference <> 0 THEN 'migrated'
        ELSE 'unknown'
    END AS rfm_segment_five_parts
FROM (
    SELECT
        rfm.user_ptr_id,
        rfm.date_join_cohort,
        
        rfm.is_repeat_new_first,
        rfm.all_cities_distinct,
        rfm.all_countries_distinct, 
        rfm.booking_count_total,
        rfm.booking_count_cancel,
        rfm.booking_count_completed,
        rfm.booking_count_started,
        rfm.booking_count_future,
        rfm.booking_count_other,
        rfm.is_currently_started,
        
        b.booking_id,
        b.status,
        b.booking_type,
        b.deliver_method,
        b.car_cat_name,
        marketplace_or_dispatch,
        b.promo_code,
        CASE
            WHEN b.promo_code IS NULL THEN "no"
            ELSE "yes"
        END AS has_promo_code,
        b.booking_date,
        b.pickup_date,
        b.return_date,
        b.days,
        b.booking_charge_less_discount,

        -- RFM TEST GROUPS
        rfm.test_group AS test_group_at_min_created_at_date,

        -- RFM SCORE METRICS
        rfm.booking_most_recent_return_vs_now AS booking_most_recent_return_vs_now,
        rfm.total_days_per_completed_and_started_bookings AS total_days_per_completed_and_started_bookings,
        rfm.booking_charge__less_discount_aed_per_completed_started_bookings AS booking_charge_less_discount_aed_per_completed_started_bookings,

        -- SCORE THREE PART COMPARISON
        rfm.score_three_parts AS score_three_parts_as_of_initial_date,
        rfm_v2.score_three_parts AS score_three_parts_as_of_most_recent_created_at_date,
        rfm.score_three_parts - rfm_v2.score_three_parts AS score_three_parts_difference,

        -- SCORE FIVE PART COMPARISON
        rfm.score_five_parts AS score_five_parts_as_of_initial_date,
        rfm_v2.score_five_parts AS score_five_parts_as_of_most_recent_created_at_date,
        rfm.score_five_parts - rfm_v2.score_five_parts AS score_five_parts_difference,
        
        COUNT(b.booking_id) AS booking_count,
        @min_created_at_date AS min_created_at_date,
        @max_created_at_date AS max_created_at_date
        
    FROM rfm_score_summary_history_data AS rfm
    LEFT JOIN user_data_combined_booking_data AS b ON rfm.user_ptr_id = b.user_ptr_id
        AND rfm.created_at_date = @min_created_at_date
        AND b.booking_date >= @min_created_at_date
        AND b.booking_date <= @max_created_at_date_plus_1
        AND b.status NOT IN ('Cancelled by User')
    LEFT JOIN rfm_score_summary_history_data AS rfm_v2 ON rfm.user_ptr_id = rfm_v2.user_ptr_id
        AND rfm_v2.created_at_date = @max_created_at_date
    WHERE rfm.created_at_date = @min_created_at_date
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
    ORDER BY rfm.user_ptr_id, b.return_date
) AS a;

-- SELECT * FROM rfm_score_summary_history_data_tracking;
-- SELECT min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking GROUP BY min_created_at_date, max_created_at_date ORDER BY count(*);
-- SELECT rfm_segment_three_parts, min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking GROUP BY rfm_segment_three_parts, min_created_at_date, max_created_at_date WITH ROLLUP ORDER BY count(*);
-- SELECT rfm_segment_five_parts, min_created_at_date, max_created_at_date, count(*) FROM rfm_score_summary_history_data_tracking GROUP BY rfm_segment_five_parts, min_created_at_date, max_created_at_date WITH ROLLUP ORDER BY count(*);
