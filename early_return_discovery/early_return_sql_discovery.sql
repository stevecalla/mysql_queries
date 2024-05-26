USE myproject;

-- STEP #1: DONE == FIND EARLY RETURN FLAG = early_return
-- STEP #2: DONE == EARLY RETURN DISTINCT FIELDS; result is 0 NOT EARLY RETURN & 1 EARLY RETURN
-- STEP #3: DONE == COUNT OF EARLY RETURN; total = 274,430; 0 NOT EARLY RETURN = 260,148, 1 IS EARLY RETURN = 14,282

-- STEP #1
SHOW COLUMNS FROM rental_car_booking2;

-- STEP #2 & #3
SELECT DISTINCT(early_return), COUNT(*) FROM rental_car_booking2 GROUP BY early_return WITH ROLLUP LIMIT 10;

-- REVIEW rental_end_date_string
	-- DONE == DOES IT INCLUDE A TIME - RESULT == NO; 14,282 records
    -- DONE == IS IT ALWAYS POPULATED - RESULT == NO; 94 records
SELECT 
	b.id,
    b.early_return,
    b.status,
    rs.status,
    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s') AS return_datetime,
    DATE_FORMAT(STR_TO_DATE(b.rental_end_date_string, '%d/%m/%Y'), '%Y-%m-%d %H:%i:%s') AS rental_end_date,
	TIMESTAMPDIFF(DAY, STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), STR_TO_DATE(b.rental_end_date_string, '%d/%m/%Y')) AS date_diff
FROM rental_car_booking2 AS b
    LEFT JOIN rental_status AS rs ON rs.id = b.status
WHERE b.early_return = 1
    AND b.rental_end_date_string IS NULL
ORDER BY STR_TO_DATE(b.return_date_string, '%d/%m/%Y') DESC;
-- LIMIT 10;

-- CHECK NOT EARLY RETURN
    -- DONE == DOES IT MATCH return_date_string WHEN EARLY RETURN FLAG IS 0?
    -- RESULT == rental_end_date_string IS BLANK IN THIS SCENARIO
SELECT 
	b.id,
    b.early_return,
    b.status,
    rs.status,
    DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s') AS return_datetime,
    DATE_FORMAT(STR_TO_DATE(b.rental_end_date_string, '%d/%m/%Y'), '%Y-%m-%d %H:%i:%s') AS rental_end_date,
	TIMESTAMPDIFF(DAY, STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), STR_TO_DATE(b.rental_end_date_string, '%d/%m/%Y')) AS date_diff
FROM rental_car_booking2 AS b
    LEFT JOIN rental_status AS rs ON rs.id = b.status
WHERE b.early_return = 0
    AND b.status <> 8
ORDER BY STR_TO_DATE(b.return_date_string, '%d/%m/%Y') DESC
LIMIT 10;

-- REVENUE?
-- rental_early_return_charges

SELECT * FROM rental_car_booking2 WHERE id IN ('225443', '210299', '30174') AND early_return = 1 LIMIT 10;





