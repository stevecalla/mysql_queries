USE ezhire_key_metrics;

-- View the key_metrics table
SELECT * FROM key_metrics LIMIT 10;

-- View key_metrics summary table
SELECT 
    year,
    month,

    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(pickup_count), 0) AS pickup_count,
    FORMAT(SUM(return_count), 0) AS return_count,

    FORMAT(SUM(trans_on_rent_count),  0) as trans_on_rent_count,
    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,

    CONCAT(FORMAT(SUM(day_in_initial_period), 0)) AS day_in_initial_period,
    CONCAT(FORMAT(SUM(day_in_extension_period), 0)) AS day_in_extension_period,

    CONCAT(FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed,
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,

    CONCAT(FORMAT(SUM(rev_aed_in_initial_period), 0)) AS rev_aed_in_initial_period,
    CONCAT(FORMAT(SUM(rev_aed_in_extension_period), 0)) AS rev_aed_in_extension_period,
    
    CONCAT(FORMAT(SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period), 0)) AS total_initial_plus_extension,
    
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation) - (SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period)), 0)) AS diff
    
FROM key_metrics_data
GROUP BY year, month WITH ROLLUP
ORDER BY year ASC, month ASC;

-- View the key_metrics_core_onrent_days table
SELECT * FROM key_metrics_data;

-- View key_metrics summary table
SELECT
    year,
    month,
    day,

    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(pickup_count), 0) AS pickup_count,
    FORMAT(SUM(return_count), 0) AS return_count,

    FORMAT(SUM(trans_on_rent_count),  0) as trans_on_rent_count,
    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,

    CONCAT(FORMAT(SUM(day_in_initial_period), 0)) AS day_in_initial_period,
    CONCAT(FORMAT(SUM(day_in_extension_period), 0)) AS day_in_extension_period,

    CONCAT(FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed,
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,

    CONCAT(FORMAT(SUM(rev_aed_in_initial_period), 0)) AS rev_aed_in_initial_period,
    CONCAT(FORMAT(SUM(rev_aed_in_extension_period), 0)) AS rev_aed_in_extension_period,
    
    CONCAT(FORMAT(SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period), 0)) AS total_initial_plus_extension,
    
    CONCAT(FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation) - (SUM(rev_aed_in_initial_period) + SUM(rev_aed_in_extension_period)), 0)) AS diff
    
FROM key_metrics_data
GROUP BY year, month, day WITH ROLLUP
ORDER BY year ASC, month ASC, day ASC;