USE ezhire_crm;

-- Main query that aggregates and pivots the data with shift stats and called/not-called conversions
SELECT 
    DATE(lm_summary.created_on_pst_lm) AS created_on_pst,
    COUNT(DISTINCT lm_summary.lead_id_lm) AS total_leads,
    SUM(CASE WHEN lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) AS total_bookings,
    SUM(CASE WHEN lm_summary.min_created_on_cl IS NOT NULL THEN 1 ELSE 0 END) AS total_called,
    COUNT(DISTINCT lm_summary.lead_id_lm) - 
        SUM(CASE WHEN lm_summary.min_created_on_cl IS NOT NULL THEN 1 ELSE 0 END) AS total_not_called,
    COUNT(DISTINCT lm_summary.lead_id_lm) - 
        SUM(CASE WHEN lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) AS total_not_booked,
    
    -- Booking conversion ratio
    CONCAT(
        ROUND(
            (SUM(CASE WHEN lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / 
            COUNT(DISTINCT lm_summary.lead_id_lm), 0
        ),
        '%'
    ) AS booking_conversion,

    -- Percentage of leads called
    CONCAT(
        ROUND(
            (SUM(CASE WHEN lm_summary.min_created_on_cl IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / 
            COUNT(DISTINCT lm_summary.lead_id_lm), 0
        ),
        '%'
    ) AS percentage_called,

    -- Conversion percentage for those called
    CONCAT(
        ROUND(
            (SUM(CASE WHEN lm_summary.min_created_on_cl IS NOT NULL AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / 
            NULLIF(SUM(CASE WHEN lm_summary.min_created_on_cl IS NOT NULL THEN 1 ELSE 0 END), 0), 0
        ),
        '%'
    ) AS conversion_called,

    -- Conversion percentage for those not called
    CONCAT(
        ROUND(
            (SUM(CASE WHEN lm_summary.min_created_on_cl IS NULL AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / 
            NULLIF(SUM(CASE WHEN lm_summary.min_created_on_cl IS NULL THEN 1 ELSE 0 END), 0), 0
        ),
        '%'
    ) AS conversion_not_called,

    -- Shift stats
    SUM(CASE WHEN lm_summary.shift = 'AM Shift 12a-8a' THEN 1 ELSE 0 END) AS shift_am_leads,
    SUM(CASE WHEN lm_summary.shift = 'AM Shift 12a-8a' AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) AS shift_am_bookings,
    CONCAT(
        ROUND(
            (SUM(CASE WHEN lm_summary.shift = 'AM Shift 12a-8a' AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / 
            NULLIF(SUM(CASE WHEN lm_summary.shift = 'AM Shift 12a-8a' THEN 1 ELSE 0 END), 0), 0
        ),
        '%'
    ) AS shift_am_conversion,

    SUM(CASE WHEN lm_summary.shift = 'Day Shift 8a-4p' THEN 1 ELSE 0 END) AS shift_day_leads,
    SUM(CASE WHEN lm_summary.shift = 'Day Shift 8a-4p' AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) AS shift_day_bookings,
    CONCAT(
        ROUND(
            (SUM(CASE WHEN lm_summary.shift = 'Day Shift 8a-4p' AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / 
            NULLIF(SUM(CASE WHEN lm_summary.shift = 'Day Shift 8a-4p' THEN 1 ELSE 0 END), 0), 0
        ),
        '%'
    ) AS shift_day_conversion,

    SUM(CASE WHEN lm_summary.shift = 'Night Shift 4p-12a' THEN 1 ELSE 0 END) AS shift_night_leads,
    SUM(CASE WHEN lm_summary.shift = 'Night Shift 4p-12a' AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) AS shift_night_bookings,
    CONCAT(
        ROUND(
            (SUM(CASE WHEN lm_summary.shift = 'Night Shift 4p-12a' AND lm_summary.booking_id_bm IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / 
            NULLIF(SUM(CASE WHEN lm_summary.shift = 'Night Shift 4p-12a' THEN 1 ELSE 0 END), 0), 0
        ),
        '%'
    ) AS shift_night_conversion
FROM (
    SELECT 
        lm.lead_id AS lead_id_lm,
        lm.created_on AS created_on_pst_lm,
        cl.min_created_on_cl,
        bm.Booking_id AS booking_id_bm,
        
        -- SHIFT BASED ON CREATED TIME
        CASE 
            WHEN (CAST(lm.created_on AS TIME) BETWEEN '00:00:00' AND '07:59:59') THEN 'AM Shift 12a-8a'
            WHEN (CAST(lm.created_on AS TIME) BETWEEN '08:00:00' AND '15:59:59') THEN 'Day Shift 8a-4p'
            WHEN (CAST(lm.created_on AS TIME) BETWEEN '16:00:00' AND '23:59:59') THEN 'Night Shift 4p-12a'
            ELSE NULL
        END AS shift
    FROM leads_master AS lm
    LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
    LEFT JOIN (
        SELECT 
            Lead_id,
            MIN(CREATED_On) AS min_created_on_cl
        FROM lead_aswat_Call_Logs
        GROUP BY Lead_id
    ) AS cl ON lm.lead_id = cl.Lead_id
) AS lm_summary
GROUP BY DATE(lm_summary.created_on_pst_lm)
ORDER BY DATE(lm_summary.created_on_pst_lm) DESC;
