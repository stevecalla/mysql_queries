USE ezhire_crm;

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
	lm.id,
	DATE_FORMAT(lm.created_on, '%Y-%m-%d') AS created_on_gst, -- in GST, not in UST so no timezone conversion needed
    lm.renting_in_country,
    st.lead_status,
    ls.source_name,
    lm.booking_status,
    IF(DATE_FORMAT(lm.created_on, '%Y-%m-%d') = DATE_FORMAT(lm.sale_made_at, '%Y-%m-%d'), 1, 0) AS test,
    lm.sale_made_at,
    DATE_FORMAT(lm.sale_made_at, '%Y-%m-%d')
FROM leads_master AS lm
	LEFT JOIN lead_sources AS ls ON lm.lead_source_id = ls.id
	LEFT JOIN lead_status AS st ON lm.lead_status_id = st.id
WHERE 
    DATE_FORMAT(lm.created_on, '%Y-%m-%d') = '2024-11-15'
    AND lm.lead_source_id = 4 -- chat
    -- AND lm.lead_source_id = 8 -- hubspot form
    AND lm.lead_status_id = 13 -- booking confirmed
    AND lm.lead_status_id NOT IN (16) -- remove invalid leads
GROUP BY 1, 2, 3;