USE mock_rfm_db;

SELECT * FROM rfm_data;
SELECT * FROM rfm_data_rollup;
SELECT * FROM rfm_score_recency_data ORDER BY days_since_last_order DESC;
SELECT * FROM rfm_score_frequency_data;
SELECT * FROM rfm_score_monetary_data;
SELECT * FROM rfm_score_summary_data ORDER BY score_three_parts;