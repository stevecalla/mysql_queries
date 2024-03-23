-- Switch to ezhire_key_metrics database
USE ezhire_key_metrics;

-- View key_metrics summary table
SELECT 
    year,
    month,

    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(pickup_count), 0) AS pickup_count,
    FORMAT(SUM(return_count), 0) AS return_count,

    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,

    CONCAT('AED ', FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,
    CONCAT('AED ', FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed,

    CONCAT('AED ', FORMAT(SUM(booking_charge_less_discount_extension_aed_allocation), 0)) AS booking_charge_less_discount_extension_aed,
    CONCAT('AED ', FORMAT(SUM(extension_charge_aed_per_day_allocation), 0)) AS extension_charge_aed,
    
    CONCAT('AED ', FORMAT(SUM(booking_charge_less_discount_extension_aed_allocation) + SUM(extension_charge_aed_per_day_allocation), 0)) AS total_booking_charge_extension
    
FROM key_metrics_core_onrent_days
GROUP BY year, month
ORDER BY year ASC, month ASC;

-- View key_metrics summary table
SELECT 
    year,
    month,
    day,

    FORMAT(SUM(booking_count), 0) AS booking_count,
    FORMAT(SUM(pickup_count), 0) AS pickup_count,
    FORMAT(SUM(return_count), 0) AS return_count,

    FORMAT(SUM(days_on_rent_fraction), 0) AS days_on_rent_fraction,
    FORMAT(SUM(days_on_rent_whole_day), 0) AS days_on_rent_whole_day,

    CONCAT('AED ', FORMAT(SUM(booking_charge_Less_discount_aed_rev_allocation), 0)) AS booking_charge_Less_discount_aed,
    CONCAT('AED ', FORMAT(SUM(booking_charge_aed_rev_allocation), 0)) AS booking_charge_aed,

    CONCAT('AED ', FORMAT(SUM(booking_charge_less_discount_extension_aed_allocation), 0)) AS booking_charge_less_discount_extension_aed,
    CONCAT('AED ', FORMAT(SUM(extension_charge_aed_per_day_allocation), 0)) AS extension_charge_aed,
    
    CONCAT('AED ', FORMAT(SUM(booking_charge_less_discount_extension_aed_allocation) + SUM(extension_charge_aed_per_day_allocation), 0)) AS total_booking_charge_extension
    
FROM key_metrics_core_onrent_days
GROUP BY year, month, day
ORDER BY year ASC, month ASC, day ASC;