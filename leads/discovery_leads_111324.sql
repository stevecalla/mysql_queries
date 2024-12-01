USE ezhire_crm;

-- 0) BASE DATA
SELECT * FROM leads_master LIMIT 10;
-- SELECT COUNT(*) FROM leads_master;
-- SELECT * FROM lead_sources;

-- 0.A) RECENT DATA
    SELECT 
        *
    FROM leads_master AS lm
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
    WHERE 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') = '2024-11-15'
        -- AND lm.lead_source_id = 4 -- chat
        AND lm.lead_source_id = 8 -- hubspot form
        AND lm.lead_status_id = 13 -- booking confirmed
        AND lm.lead_status_id NOT IN (16) -- remove invalid leads
    GROUP BY 1, 2;
-- **************************

-- #1) LEADS AND BOOKINGS BY CREATED DATE
    SELECT 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst, -- in PST (Pakistan Standard Time), not in UTC so no timezone conversion needed
        DATE_FORMAT(lm.created_on, '%a') AS created_on_pst, -- Weekday abbreviation

        COUNT(*) AS count_leads,
        CAST(SUM(CASE WHEN lm.lead_status_id IN (16) THEN 1 ELSE 0 END) AS SIGNED) AS count_leads_invalid,
        CAST(SUM(CASE WHEN lm.lead_status_id NOT IN (16) THEN 1 ELSE 0 END) AS SIGNED) AS count_leads_valid,

        -- CAST TO ENSURE RESULT IS A NUMBER NOT TEXT
        CAST(SUM(CASE WHEN st.lead_status IN ('Booking Cancelled') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_cancelled,
        CAST(SUM(CASE WHEN st.lead_status IN ('Booking Confirmed') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_confirmed,
        CAST(SUM(CASE WHEN st.lead_status IN ('Booking Cancelled', 'Booking Confirmed') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_total,

    FROM leads_master AS lm
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
        LEFT JOIN booking_master bm ON lm.app_booking_id = bm.booking_id
    -- WHERE 
        -- lm.lead_status_id NOT IN (16) -- remove invalid leads
        -- AND renting_in_country IN ('United Arab Emirates')
    GROUP BY 1, 2
    ORDER BY 1 DESC;
-- *******************************************

-- #2) LEADS BY CREATED DATE, BY SOURCE
    SELECT 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst, -- in PST (Pakistan Standard Time), not in UTC so no timezone conversion needed
        DATE_FORMAT(lm.created_on, '%a, %Y-%m-%d') AS created_on_pst, -- Weekday abbreviation, followed by date
        lm.lead_source_id,
        ls.source_name,
        COUNT(*) AS count_leads
    FROM leads_master AS lm
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
    WHERE renting_in_country IN ('United Arab Emirates')
    GROUP BY 1, 2, 3
    ORDER BY 1 DESC,2 ASC;
-- *******************************************

-- #3) LEADS BY CREATED DATE, BY COUNTRY
    -- SELECT DISTINCT(renting_in_country), COUNT(*) FROM leads_master GROUP BY 1;
    SELECT 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst, -- in PST (Pakistan Standard Time), not in UTC so no timezone conversion needed
        renting_in_country,
        COUNT(*) AS count_leads
    FROM leads_master AS lm
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
    -- WHERE DATE_FORMAT(lm.created_on, '%Y-%m-%d') = '2024-11-14'  
    GROUP BY 1 DESC, 2;
-- *******************************************

-- #4) LEADS BY CREATED DATE, BY COUNTRY, BY SOURCE
    -- SELECT DISTINCT(renting_in_country), COUNT(*) FROM leads_master GROUP BY 1;

    -- LEAD STATUS DEFINES BOOKING CANCELLED, CONFIRMED AND OTHER CATEGORIES
    SELECT * FROM lead_status;

    SELECT 
        lm.lead_status_id,
        ls.lead_status,
        COUNT(*) 
    FROM leads_master AS lm
        LEFT JOIN lead_status AS ls ON lm.lead_status_id = ls.id
    WHERE DATE_FORMAT(lm.created_on, '%Y-%m-%d') = '2024-11-15'
    GROUP BY 1, 2;
-- *******************************************

-- #5) LEADS BY COUNTRY, SOURCE WITH LEADS COUNT, BOOKING COUNTS FOR CANCEL, CONFIRMED, TOTAL
    SELECT 
        DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_pst, -- in PST (Pakistan Standard Time), not in UTC so no timezone conversion needed
        lm.renting_in_country,
        ls.source_name,

        COUNT(*) AS count_leads,
        -- CAST TO ENSURE RESULT IS A NUMBER NOT TEXT
        CAST(SUM(CASE WHEN st.lead_status IN ('Booking Cancelled') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_cancelled,
        CAST(SUM(CASE WHEN st.lead_status IN ('Booking Confirmed') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_confirmed,
        CAST(SUM(CASE WHEN st.lead_status IN ('Booking Cancelled', 'Booking Confirmed') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_total,
        
        -- CURRENT DATE / TIME PST (Pakistan Standard Time)
        DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS queried_at_utc,
        DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 5 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_pst, -- UTC to PST (Pakistan Standard Time)

        -- Max created_on for all records (without per-grouping)
        (SELECT 
            DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s') 
        FROM leads_master 
        WHERE 
            created_on >= CURRENT_DATE() - INTERVAL 1 DAY 
            AND created_on < CURRENT_DATE() + INTERVAL 1 DAY
        ) AS max_created_on_pst

    FROM leads_master AS lm
        LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
        LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
    WHERE 
        -- st.lead_status IN ('Booking Confirmed','Booking Cancelled')
        -- AND 
        lm.created_on >= DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 5 HOUR), '%Y-%m-%d') - INTERVAL 1 DAY -- UTC to PST (Pakistan Standard Time)
        AND lm.lead_status_id NOT IN (16) -- remove invalid leads
    GROUP BY 1, 2, 3;
-- *******************************************
