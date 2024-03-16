-- View the key_metrics table
SELECT * FROM key_metrics LIMIT 10;

-- View key_metrics summary table
SELECT 
    year,
    month,
    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,
    CONCAT('AED ', FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,
    CONCAT('AED ', FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed
FROM key_metrics
GROUP BY year, month
ORDER BY year ASC, month ASC;

-- View key_metrics summary table
SELECT 
    year,
    month,
    day,
    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,
    CONCAT('AED ', FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,
    CONCAT('AED ', FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed
FROM key_metrics
GROUP BY year, month, day
ORDER BY year ASC, month ASC, day ASC;