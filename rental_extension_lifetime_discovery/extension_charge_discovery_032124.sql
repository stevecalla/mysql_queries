USE myproject;
-- ***********************************************
SET @p_st_date = '2023-12-31';
SET @p_end_date = '2024-12-31';
SELECT 
	m.*,
    extension_days,
    DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') AS TEST,
    IF(DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') < '2024-01-01', 1, 0) AS TEST4,
    IF(DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') < @p_st_date, 1, 0) AS TEST4a,
    IF(DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') >= @p_st_date, 1, 0) AS TEST4b,
    @p_st_date AS TEST3,
    IF(DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') BETWEEN STR_TO_DATE(@p_st_date, '%Y-%m-%d') AND STR_TO_DATE(@p_ed_date, '%Y-%m-%d'), 1, 0) AS TEST5,
    IF(DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') BETWEEN @p_st_date AND @p_end_date, 1, 0) AS TEST5a
FROM rental_messagesuser m
-- #1) ORIGINAL LOGIC
-- WHERE  
-- 	(DATE_ADD(m.updated_on,INTERVAL 4 HOUR) BETWEEN STR_TO_DATE(@p_st_date, '%d/%m/%Y') AND STR_TO_DATE(@p_ed_date, '%d/%m/%Y'))
-- 	AND (m.subject LIKE '%exten%' OR m.subject=CONCAT('Late Rental Return for Booking#', m.booking_id))
-- 	AND m.extension_days > 0
-- 	AND m.message LIKE '%Dear Partner%'
-- #2) REVISED TO ADD DATA_FORMAT; original logic returning no records
WHERE  
	DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') BETWEEN @p_st_date AND @p_end_date
	AND (m.subject LIKE '%exten%' OR m.subject=CONCAT('Late Rental Return for Booking#', m.booking_id))
	AND m.extension_days > 0
	AND m.message LIKE '%Dear Partner%'
	AND booking_id IN ("240667", "246876", "240842", "246867", '248667', '264404', '257685')
	-- AND booking_id IN ('248667')
	-- AND booking_id IN ("246867")
GROUP BY booking_id, total_old_days;
-- LIMIT 10;
-- ******************************************
SELECT 
	m.booking_id,
    SUM(extension_amount),
    SUM(extension_days)
FROM rental_messagesuser m
WHERE  
	DATE_FORMAT(DATE_ADD(m.updated_on,INTERVAL 4 HOUR), '%Y-%m-%d') BETWEEN @p_st_date AND @p_end_date
	AND (m.subject LIKE '%exten%' OR m.subject=CONCAT('Late Rental Return for Booking#', m.booking_id))
	AND m.extension_days > 0
	AND m.message LIKE '%Dear Partner%'
	AND booking_id IN ("240667", "246876", "240842", "246867", "248667", "264404")
	-- AND booking_id IN ("246876")
GROUP BY booking_id;
-- LIMIT 10;