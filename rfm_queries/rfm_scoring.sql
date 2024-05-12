USE mock_rfm_db;

SELECT * FROM rfm_data;

-- SUMMARIZE DATA BY DAYS SINCE LAST ORDER, TOTAL NUMBER OF ORDERS, TOTAL ORDER VALUE
DROP TABLE IF EXISTS rfm_rollup_data;
CREATE TABLE rfm_rollup_data
SELECT
	customer_id,
	MIN(days_since_last_order) AS days_since_last_order,
    MAX(date_of_order) AS date_of_order,
    COUNT(customer_id) AS total_number_of_orders,
    SUM(order_value) AS total_order_value
FROM rfm_data
GROUP BY customer_id
ORDER BY customer_id;

SELECT customer_id, days_since_last_order, date_of_order, total_number_of_orders, FORMAT(total_order_value, 0) FROM rfm_rollup_data;

-- RANK VALUES FROM rfm_rollup_data TABLE
-- RECENCY SCORE
SELECT 
	customer_id, 
    days_since_last_order, 
    date_of_order,
    FORMAT(percent_rank() OVER (ORDER BY total_number_of_orders), 2) AS recency_rank,
    CASE
		WHEN percent_rank() OVER (ORDER BY days_since_last_order) > 0.66 THEN 1
		WHEN percent_rank() OVER (ORDER BY days_since_last_order) > 0.33 THEN 2
        ELSE 3
	END AS recency_score
FROM rfm_rollup_data
ORDER BY days_since_last_order ASC, date_of_order ASC;

SELECT 
	customer_id, 
    days_since_last_order,
    date_of_order,
    FORMAT(percent_rank() OVER (ORDER BY days_since_last_order), 2) AS recency_rank,
    ROW_NUMBER() OVER (ORDER BY days_since_last_order, date_of_order) AS row_number_id,
    COUNT(*) OVER () AS total_rows,
    ROW_NUMBER() OVER (ORDER BY days_since_last_order, date_of_order) / COUNT(*) OVER () AS row_percent,
    CASE
		WHEN ROW_NUMBER() OVER (ORDER BY days_since_last_order, date_of_order) / COUNT(*) OVER () > 0.66 THEN 1
		WHEN ROW_NUMBER() OVER (ORDER BY days_since_last_order, date_of_order) / COUNT(*) OVER () > 0.33 THEN 2
        ELSE 3
	END AS recency_score_three_parts,
    CASE
		WHEN days_since_last_order BETWEEN 205 AND 208 THEN 3
        WHEN days_since_last_order BETWEEN 209 and 213 THEN 2
        ELSE 1
	END AS recency_score_by_custom_total

FROM rfm_rollup_data
ORDER BY days_since_last_order DESC, date_of_order ASC;

-- FREQUENCY SCORE
SELECT 
	customer_id, 
    total_number_of_orders, 
    date_of_order,
    FORMAT(percent_rank() OVER (ORDER BY total_number_of_orders), 2) AS frequency_rank,
    ROW_NUMBER() OVER (ORDER BY total_number_of_orders, date_of_order) AS row_number_id,
    COUNT(*) OVER () AS total_rows,
    ROW_NUMBER() OVER (ORDER BY total_number_of_orders, date_of_order) / COUNT(*) OVER () AS row_percent,
    CASE
		WHEN ROW_NUMBER() OVER (ORDER BY total_number_of_orders, date_of_order) / COUNT(*) OVER () < 0.33 THEN 1
		WHEN ROW_NUMBER() OVER (ORDER BY total_number_of_orders, date_of_order) / COUNT(*) OVER () < 0.66 THEN 2
        ELSE 3
	END AS frequency_score_three_parts,
    CASE
		WHEN total_number_of_orders BETWEEN 0 AND 10 THEN 1
        WHEN total_number_of_orders BETWEEN 10 and 20 THEN 2
        ELSE 3
	END AS frequency_score_by_custom_total

FROM rfm_rollup_data
ORDER BY total_number_of_orders ASC, date_of_order ASC;

-- MONETARY SCORE
SELECT 
	customer_id, 
    total_order_value, 
    date_of_order,
    FORMAT(percent_rank() OVER (ORDER BY total_order_value), 2) AS monetary_rank, -- base rank i.e. 0, 10%, 20%... for each row
    ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) AS row_number_id, -- row number
    COUNT(*) OVER () AS total_rows, -- total number of rows
    ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) / COUNT(*) OVER () AS row_percent, -- row as a percent of total rows; i.e. row 3 of 10 is 30%
    CASE
		WHEN ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) / COUNT(*) OVER () < 0.33 THEN 1
		WHEN ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) / COUNT(*) OVER () < 0.66 THEN 2
        ELSE 3
	END AS monetary_score_three_parts, -- scoring dividing the data into three equal parts
    CASE
		WHEN ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) / COUNT(*) OVER () < 0.20 THEN 1
		WHEN ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) / COUNT(*) OVER () < 0.40 THEN 2
		WHEN ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) / COUNT(*) OVER () < 0.60 THEN 3
		WHEN ROW_NUMBER() OVER (ORDER BY total_order_value, date_of_order) / COUNT(*) OVER () < 0.80 THEN 4
        ELSE 5
	END AS monetary_score_five_parts, -- scoring dividing the data into three equal parts
    CASE
		WHEN total_order_value BETWEEN 0 AND 5000 THEN 1
        WHEN total_order_value BETWEEN 5001 and 7500 THEN 2
        ELSE 3
	END AS monetary_score_by_custom_total -- scoring using custom buckets... to keep similar customers in same bucket

FROM rfm_rollup_data
ORDER BY total_order_value ASC, date_of_order ASC;
