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
GROUP BY 1 DESC, 2;

-- #1) LEADS BY CREATED DATE
SELECT 
	DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_gst, -- in GST, not in UST so no timezone conversion needed
    COUNT(*) AS count_leads
FROM leads_master AS lm
	LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
	LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
WHERE lm.lead_status_id NOT IN (16) -- remove invalid leads
GROUP BY 1 
ORDER BY 1 DESC;

-- #2) LEADS BY CREATED DATE, BY SOURCE
SELECT 
	DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_gst, -- in GST, not in UST so no timezone conversion needed
    lm.lead_source_id,
    ls.source_name,
    COUNT(*) AS count_leads
FROM leads_master AS lm
	LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
WHERE renting_in_country IN ('United Arab Emirates')
GROUP BY 1, 2, 3
ORDER BY 1 DESC,2 ASC;

-- #3) LEADS BY CREATED DATE, BY COUNTRY
-- SELECT DISTINCT(renting_in_country), COUNT(*) FROM leads_master GROUP BY 1;
SELECT 
	DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_gst, -- in GST, not in UST so no timezone conversion needed
    renting_in_country,
    COUNT(*) AS count_leads
FROM leads_master AS lm
	LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
-- WHERE DATE_FORMAT(lm.created_on, '%Y-%m-%d') = '2024-11-14'  
GROUP BY 1 DESC, 2;

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

-- LEADS BY COUNTRY, SOURCE WITH LEADS COUNT, BOOKING COUNTS FOR CANCEL, CONFIRMED, TOTAL
SELECT 
	DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_gst, -- in GST, not in UST so no timezone conversion needed
    lm.renting_in_country,
    -- st.lead_status,
    ls.source_name,

    COUNT(*) AS count_leads,
    -- CAST TO ENSURE RESULT IS A NUMBER NOT TEXT
    CAST(SUM(CASE WHEN st.lead_status IN ('Booking Cancelled') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_cancelled,
    CAST(SUM(CASE WHEN st.lead_status IN ('Booking Confirmed') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_confirmed,
    CAST(SUM(CASE WHEN st.lead_status IN ('Booking Cancelled', 'Booking Confirmed') THEN 1 ELSE 0 END) AS SIGNED) AS count_booking_total,
    
    -- CURRENT DATE / TIME GST
    DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS queried_at_utc,
    DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS queried_at_gst,

    -- Max created_on for all records (without per-grouping)
    (SELECT 
        DATE_FORMAT(MAX(created_on), '%Y-%m-%d %H:%i:%s') 
     FROM leads_master 
     WHERE 
		created_on >= CURRENT_DATE() - INTERVAL 1 DAY 
		AND created_on < CURRENT_DATE() + INTERVAL 1 DAY
    ) AS max_created_on_gst

FROM leads_master AS lm
	LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
	LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
WHERE 
    -- st.lead_status IN ('Booking Confirmed','Booking Cancelled')
    -- AND 
    lm.created_on >= DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 4 HOUR), '%Y-%m-%d') - INTERVAL 1 DAY
    AND lm.lead_status_id NOT IN (16) -- remove invalid leads
GROUP BY 1, 2, 3;

-- SAME DAY DISOVERY **************************
    -- COULD NOT GET THESE TO RECONCILE SAME DAY CONFIRMED WITH erp
    -- IF(DATE_FORMAT(lm.created_on, '%Y-%m-%d') = DATE_FORMAT(lm.sale_made_at, '%Y-%m-%d'), 1, 0) AS test,
    -- lm.sale_made_at,
    -- DATE_FORMAT(lm.sale_made_at, '%Y-%m-%d'),
    -- SUM(
    --     CASE 
    --         WHEN lm.booking_status IN (2) THEN 1
    --         -- WHEN st.lead_status IN ('Booking Confirmed') AND DATE_FORMAT(lm.created_on, '%Y-%m-%d') = DATE_FORMAT(lm.sale_made_at, '%Y-%m-%d') THEN 1
    --         -- WHEN lm.sale_made_at IS NULL THEN 0
    --         ELSE 0
    --     END 
    -- ) AS count_booking_confirmed_same_day,

-- *******************************************

-- #5) LEADS BY CREATED DATE, BY SALE MADE
-- NOT ACCURATE AS IT DOESN'T MATCH ERP 
-- SELECT DISTINCT(is_sale_made), COUNT(*) FROM leads_master GROUP BY 1; -- doesn't look accurate
-- SELECT DISTINCT(sale_made_at), COUNT(*) FROM leads_master GROUP BY 1; 
SELECT 
    DISTINCT(booking_status), COUNT(*) 
FROM leads_master AS lm
WHERE 
    DATE_FORMAT(lm.created_on, '%Y-%m-%d') = '2024-11-14'
    AND lm.lead_status_id NOT IN (16) -- remove invalid leads
GROUP BY 1; 

SELECT 
	DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_gst, -- in GST, not in UST so no timezone conversion needed
    COUNT(*) AS count_leads,
	SUM(CASE WHEN lm.sale_made_at IS NOT NULL THEN 1 ELSE 0 END) AS count_sale,
	SUM(CASE WHEN lm.sale_made_at IS NULL THEN 1 ELSE 0 END) AS count_no_sale,
    SUM(CASE WHEN lm.sale_made_at IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) AS conversion_ratio
FROM leads_master AS lm
	LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
-- WHERE DATE_FORMAT(lm.created_on, '%Y-%m-%d') = '2024-11-14'
WHERE lm.lead_status_id NOT IN (16) -- remove invalid leads
GROUP BY 1 DESC;
