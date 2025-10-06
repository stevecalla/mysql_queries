DROP TEMPORARY TABLE IF EXISTS user_data_key_metrics_rollup;
CREATE TEMPORARY TABLE user_data_key_metrics_rollup AS
        SELECT 
            user_ptr_id,
            GROUP_CONCAT(DISTINCT CASE WHEN status NOT LIKE '%cancelled%' THEN deliver_country END ORDER BY deliver_country ASC SEPARATOR ', ') AS all_countries_distinct,
            GROUP_CONCAT(DISTINCT CASE WHEN status NOT LIKE '%cancelled%' THEN deliver_city END ORDER BY deliver_city ASC SEPARATOR ', ') AS all_cities_distinct,

            -- BOOKING COUNT STATS
            COUNT(booking_id) AS booking_count_total,
            SUM(CASE WHEN status LIKE '%cancelled%' THEN 1 ELSE 0 END) AS booking_count_cancel,
            SUM(CASE WHEN status LIKE '%ended%' THEN 1 ELSE 0 END) AS booking_count_completed,
            SUM(CASE WHEN status LIKE '%started%' THEN 1 ELSE 0 END) AS booking_count_started,
            SUM(CASE WHEN status LIKE '%future%' THEN 1 ELSE 0 END) AS booking_count_future,
            SUM(CASE WHEN status NOT LIKE '%cancelled%' AND status NOT LIKE '%ended%' AND status NOT LIKE '%started%' AND status NOT LIKE '%future%' THEN 1 ELSE 0 END) AS booking_count_other,
            SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN 1 ELSE 0 END) AS booking_count_not_cancel,

            -- REVENUE STATS
            SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_charge_less_discount_aed ELSE 0 END) AS booking_charge_total_less_discount_aed, 
            SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN total_payment_after_refund ELSE 0 END) AS total_payment_after_refund,
            #SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN extension_charge_aed ELSE 0 END) AS booking_charge_extension_only_aed,

            -- DAYS STATS
            SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN days ELSE 0 END) AS booking_days_total,
            #SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN (days - extension_days) ELSE 0 END) AS booking_days_initial_only,
            #SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN extension_days ELSE 0 END) AS booking_days_extension_only,

            -- MOST RECENT DATES (cast as a date as default is varchar, excluded cancelled bookings)
            CASE
                WHEN MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END) IS NULL THEN NULL
                ELSE CAST(IFNULL(MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END), '') AS DATE)
            END AS booking_first_created_date,
            CASE
                WHEN MAX(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END) IS NULL THEN NULL
                ELSE CAST(IFNULL(MAX(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END), '') AS DATE)
            END AS booking_most_recent_created_date,

            CASE
                WHEN MAX(CASE WHEN status NOT LIKE '%cancelled%' THEN return_date ELSE NULL END) IS NULL THEN NULL
                ELSE CAST(IFNULL(MAX(CASE WHEN status NOT LIKE '%cancelled%' THEN return_date ELSE NULL END), '') AS DATE)
            END AS booking_most_recent_return_date,

            -- DATE COMPARISONS (cast as a number; default is varchar, excluded cancelled bookings)
            -- CAST(
            -- 	IFNULL(TIMESTAMPDIFF(DAY, MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN date_join_formatted_gst ELSE NULL END), MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END)), '') 
            -- 	AS DOUBLE
            -- ) AS booking_join_vs_first_created,

            CAST(
                CASE
                    WHEN MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN date_join_formatted_gst ELSE NULL END) IS NOT NULL
                        AND MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END) IS NOT NULL
                        AND MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN date_join_formatted_gst ELSE NULL END) > MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END)
                    THEN 0  -- Set to 0 when date_join_formatted_gst is greater than booking_date
                    ELSE TIMESTAMPDIFF(
                        DAY,
                        MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN date_join_formatted_gst ELSE NULL END),
                        MIN(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END)
                    )
                END AS DOUBLE
            ) AS booking_join_vs_first_created,

            CAST(
                IFNULL(TIMESTAMPDIFF(DAY, DATE_FORMAT(MAX(CASE WHEN status NOT LIKE '%cancelled%' THEN booking_date ELSE NULL END), '%Y-%m-%d'), DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d')), '')
                AS DOUBLE
            ) AS booking_most_recent_created_on_vs_now,
            CAST(
                IFNULL(TIMESTAMPDIFF(DAY, DATE_FORMAT(MAX(CASE WHEN status NOT LIKE '%cancelled%' THEN return_date ELSE NULL END), '%Y-%m-%d'), DATE_FORMAT(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR), '%Y-%m-%d')), '')
                AS DOUBLE
            ) AS booking_most_recent_return_vs_now,

            CASE
                -- all bookings cancelled
                WHEN COUNT(booking_id) <> 0 AND COUNT(booking_id) = SUM(CASE WHEN status LIKE '%cancelled%' THEN 1 ELSE 0 END) THEN 'canceller'
                -- REPEAT = multiple bookings
                WHEN SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN 1 ELSE 0 END) >= 2 THEN 'repeat' 
                -- booking within 48 hours of join datetime
                WHEN DATEDIFF(MIN(booking_date), MIN(date_join_formatted_gst)) <= 2 AND SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN 1 ELSE 0 END) = 1 THEN 'new' 
                -- FIRST = 1 booking after 48 hours of join datetime
                WHEN DATEDIFF(MIN(booking_date), MIN(date_join_formatted_gst)) > 2 AND SUM(CASE WHEN status NOT LIKE '%cancelled%' THEN 1 ELSE 0 END) = 1 THEN 'first' 
                -- LOOKER
                WHEN COUNT(booking_id) = 0 THEN 'looker'
                ELSE 'other'
            END AS is_repeat_new_first,
            -- UTC NOW CONVERTED TO GST
            DATE_ADD(UTC_TIMESTAMP(), INTERVAL 4 HOUR) AS date_now_gst

        FROM user_data_combined_booking_data
        GROUP BY 1
        ORDER BY 1;
        
SELECT * FROM user_data_key_metrics_rollup;