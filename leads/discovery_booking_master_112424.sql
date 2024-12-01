USE ezhire_crm;

SET @target_date = '2024-11-29';

-- SELECT * FROM booking_master LIMIT 10;
-- SELECT * FROM leads_master LIMIT 10;

-- #1) ALL LEADS CREATED ON TARGET DATE
    SELECT
        lm.lead_id,
        bm.Booking_id,

        bm.booking_created_on AS booking_created_on, -- UTC?
        CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00') AS booking_created_on_pst, -- in PST (Pakistan Standard Time), not in UTC so no timezone conversion

        bm.rental_status,
        lm.created_on AS lm_created_on,
        lm.app_booking_id,
        lm.lead_status_id,
        st.lead_status,
        GROUP_CONCAT(lm.created_on),
        COUNT(lm.lead_id) AS count_lead_id_total,
        COUNT(bm.Booking_id) AS count_booking_id_total
  
    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = @target_date
        -- To remove marketing promo leads
        AND 
        (lm.lead_status_id NOT IN (12,13,14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
        -- To remove marketing promo leads
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
    ;
-- **************************

-- #2) ALL LEADS CREATED ON TARGET DATE THAT HAVE A BOOKING
    SELECT
        bm.Booking_id,

        bm.booking_created_on AS booking_created_on, -- UTC?
        CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00') AS booking_created_on_pst, -- in PST (Pakistan Standard Time), not in UTC so no timezone conversion

        bm.rental_status,
        lm.created_on AS lm_created_on,
        lm.app_booking_id,
        lm.lead_status_id,
        st.lead_status,
        GROUP_CONCAT(lm.created_on),

        COUNT(bm.Booking_id) AS count_booking_id_total
  
    FROM leads_master AS lm
        RIGHT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = @target_date
        -- To remove marketing promo leads
        AND 
        (lm.lead_status_id NOT IN (12,13,14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
        -- To remove marketing promo leads
        AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
    GROUP BY 1, 2, 3, 4, 5, 6, 7
    ;
-- **************************

-- #2a) ALL LEADS CREATED ON TARGET DATE THAT HAS A BOOKING
    SELECT
        bm.Booking_id,
        COUNT(bm.Booking_id) AS count_booking_id_total
  
    FROM leads_master AS lm
        RIGHT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = @target_date
        -- To remove marketing promo leads
        AND 
        (lm.lead_status_id NOT IN (12,13,14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
        -- To remove marketing promo leads
        AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
    GROUP BY 1
    ;
-- **************************

-- #3) ROLLUP/GROUP COUNTS BY CREATED ON, LEAD STATUS WITH DISTINCT COUNTS
    -- REMOVE CANCELLED BASED ON LEAD STATUS
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_date,
        lm.lead_status_id,
        st.lead_status,

        -- Count total records
        COUNT(bm.Booking_id) AS count_booking_id_total,

        -- Count distinct booking IDs where booking_created_on matches target date
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = @target_date 
            THEN bm.Booking_id 
        END) AS count_booking_same_day_distinct, 

        -- Count distinct booking IDs overall
        COUNT(DISTINCT bm.Booking_id) AS count_booking_id_all_day_distinct
  
    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = @target_date
        -- To remove marketing promo leads
        AND 
        (lm.lead_status_id NOT IN (12,13,14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
        -- To remove marketing promo leads
        AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), lm.lead_status_id, st.lead_status
    ;
-- **************************

-- #3A) ROLLUP/GROUP COUNTS BY CREATED ON, RENTAL STATUS WITH DISTINCT COUNTS
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_date,
        GROUP_CONCAT(DISTINCT bm.rental_status),
        
        CASE 
            WHEN bm.rental_status = 8 THEN 'booking_cancelled'
            ELSE 'booking_confirmed'
        END AS rental_status, 

        -- TOTAL LEADS AND BOOKING IDS
        COUNT(bm.Booking_id) AS count_booking_id_total,

        -- SAME DAY DISTINCT
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = @target_date 
            THEN bm.Booking_id 
        END) AS count_booking_same_day_distinct, 

        -- DISTINCT ALL
        COUNT(DISTINCT bm.Booking_id) AS count_booking_id_all_distinct
  
    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = @target_date
        -- To remove marketing promo leads
        AND 
        (lm.lead_status_id NOT IN (12,13,14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
        -- To remove marketing promo leads
        AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), 3
    ;
-- **************************

-- #4) ROLLUP/GROUP COUNTS BY CREATED ON, LEAD STATUS WITH DISTINCT COUNTS
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,

        -- LEAD COUNTS
        COUNT(CASE WHEN lm.lead_status_id IN (16) THEN lm.lead_id END) AS count_leads_invalid,
        COUNT(CASE WHEN lm.lead_status_id NOT IN (16) THEN lm.lead_id END) AS count_leads_valid,

        -- Count distinct booking IDs where booking_created_on matches target date
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = @target_date 
                AND bm.rental_status IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_rental_status_cancelled_distinct, 

        -- Count distinct booking IDs where booking_created_on matches target date
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = @target_date 
                AND bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_not_cancelled_distinct,

        -- Count booking IDs where booking_created_on matches target date
        COUNT(DISTINCT CASE 
            WHEN 
                bm.rental_status IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_id_cancelled_total,

        -- Count booking IDs where booking_created_on matches target date
        COUNT(DISTING CASE 
            WHEN 
                bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_id_not_cancelled_total,

        -- Count booking IDs where booking_created_on matches target date
        COUNT(DISTINCT  CASE 
            WHEN 
                lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_id_total

        -- Count total records
        -- COUNT(bm.Booking_id) AS count_booking_id_total

    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = @target_date  
        -- To remove marketing promo leads
        AND 
        (lm.lead_status_id NOT IN (12,13,14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
        -- To remove marketing promo leads
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d')
    ;
-- **************************

-- #5) ROLLUP/GROUP COUNTS BY CREATED ON FOR MULTIPLE DATES (NOT TARGETING ONE DATE USED FOR TESTING ABOVE)
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,

        -- LEAD COUNTS
        COUNT(lm.lead_id) AS count_leads_total,
        COUNT(CASE WHEN lm.lead_status_id IN (16) THEN lm.lead_id END) AS count_leads_invalid,
        COUNT(CASE WHEN lm.lead_status_id NOT IN (16) THEN lm.lead_id END) AS count_leads_valid,

        -- Count distinct booking IDs where booking_created_on matches lm.created_on
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(lm.created_on, '%Y-%m-%d')
                AND bm.rental_status IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_rental_status_cancelled_distinct, 

        -- Count distinct booking IDs where booking_created_on matches lm.created_on
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(lm.created_on, '%Y-%m-%d')
                AND bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_not_cancelled_distinct,
        
        -- Count distinct booking IDs where booking_created_on matches lm.created_on
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(lm.created_on, '%Y-%m-%d')
                -- AND bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_not_cancelled_distinct_total,

        -- Count booking IDs where booking_created_on matches lm.created_on
        COUNT(CASE 
            WHEN 
                bm.rental_status IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_id_cancelled_total,

        -- Count booking IDs where booking_created_on matches lm.created_on
        COUNT(CASE 
            WHEN 
                bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_id_not_cancelled_total,

        -- Count total booking records
        COUNT(bm.Booking_id) AS count_booking_id_total,
                
        -- CURRENT DATE / TIME PST (Pakistan Standard Time)
        DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS queried_at_utc,
        DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 5 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_pst, -- UTC to PST (Pakistan Standard Time)

        -- Max created_on for all records (without per-grouping)
        (
            SELECT 
                -- DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s') -- pst
                DATE_FORMAT(DATE_SUB(MAX(created_on), INTERVAL 1 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_gst -- PST (Pakistan Standard Time) to GST
            FROM leads_master 
            LIMIT 1
        ) AS max_created_on_pst

    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        -- To remove marketing promo leads
        (
            lm.lead_status_id NOT IN (12, 13, 14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d')
    ORDER BY DATE_FORMAT(lm.created_on, '%Y-%m-%d') DESC
    ;
-- **************************

-- #6) FINAL ROLLUP FOR SLACK PROGRAM
    SELECT
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst,
        lm.renting_in_country,
        ls.source_name,

        -- LEAD COUNTS
        COUNT(lm.lead_id) AS count_leads_total,
        COUNT(CASE WHEN lm.lead_status_id IN (16) THEN lm.lead_id END) AS count_leads_invalid,
        COUNT(CASE WHEN lm.lead_status_id NOT IN (16) THEN lm.lead_id END) AS count_leads_valid,

        -- Count distinct booking IDs where booking_created_on matches lm.created_on
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(lm.created_on, '%Y-%m-%d')
                AND bm.rental_status IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_rental_status_cancelled_distinct, 

        -- Count distinct booking IDs where booking_created_on matches lm.created_on
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(lm.created_on, '%Y-%m-%d')
                AND bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_not_cancelled_distinct,
        
        -- Count distinct booking IDs where booking_created_on matches lm.created_on
        COUNT(DISTINCT CASE 
            WHEN 
                DATE_FORMAT(CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00'), '%Y-%m-%d') = DATE_FORMAT(lm.created_on, '%Y-%m-%d')
                -- AND bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_same_day_distinct_total,

        -- Count booking IDs where booking_created_on matches lm.created_on
        COUNT(CASE 
            WHEN 
                bm.rental_status IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_id_cancelled_total,

        -- Count booking IDs where booking_created_on matches lm.created_on
        COUNT(CASE 
            WHEN 
                bm.rental_status NOT IN (8)
                AND lm.lead_status_id NOT IN (16)
                AND TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            THEN bm.Booking_id 
        END) AS count_booking_id_not_cancelled_total,

        -- Count total booking records
        COUNT(bm.Booking_id) AS count_booking_id_total,
                
        -- CURRENT DATE / TIME PST (Pakistan Standard Time)
        DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS queried_at_utc,
        DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_gst, -- UTC to PST (Pakistan Standard Time)
        DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 5 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_pst, -- UTC to PST (Pakistan Standard Time)

        -- Max created_on for all records (without per-grouping)
        (
            SELECT 
                -- DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s') -- pst
                DATE_FORMAT(DATE_SUB(MAX(created_on), INTERVAL 1 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_gst -- PST (Pakistan Standard Time) to GST
            FROM leads_master 
            LIMIT 1
        ) AS max_created_on_gst

    FROM leads_master AS lm
        LEFT JOIN booking_master AS bm ON lm.app_booking_id = bm.Booking_id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
    WHERE 
        -- To remove marketing promo leads
        (
            lm.lead_status_id NOT IN (12, 13, 14) OR 
            (
                COALESCE(bm.promo_code, '') NOT IN (SELECT promo_code FROM conversion_excluded_promo_codes WHERE is_active = 1) 
                OR COALESCE(bm.promo_code, '') = '' 
                OR TIMESTAMPDIFF(DAY, lm.created_on, CONVERT_TZ(bm.booking_created_on, '+00:00', '+05:00')) <= 7
            )
        )
        -- LIMIT DATA TO LAST TWO DAYS
        AND lm.created_on >= DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL 1 DAY -- UTC to PST (Pakistan Standard Time)
    GROUP BY DATE_FORMAT(lm.created_on, '%Y-%m-%d'), 2, 3
    ORDER BY DATE_FORMAT(lm.created_on, '%Y-%m-%d') DESC
    ;
-- **************************

