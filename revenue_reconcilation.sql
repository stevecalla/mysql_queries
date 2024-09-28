SET @target_year = '2024';

SELECT 
    booking_id,
    customer_id,
    REPLACE(REPLACE(agreement_number, '"', ''), ',', ' ') AS agreement_number, -- Eliminate extra double quotes within the text string; replace double quotes (") with an empty string ('')
    IFNULL(
        IF(
            DATE_FORMAT(booking_datetime, '%Y-%m-%d') = '0000-00-00', 
            '1900-01-01', 
            DATE_FORMAT(booking_datetime, '%Y-%m-%d')
        ), 
        '1900-01-01'
    ) AS booking_datetime,
    FORMAT(IFNULL(extra_day_calc, 0), 2) AS extra_day_calc,
    -- FORMAT(IFNULL(myproject.get_rental_rates(tb.booking_id, tb.millage_id, tb.contract_id, tb.drg, tb.wrg, tb.mrg, tb.dr, tb.wr, tb.mr, tb.days, tb.deliver_date_string), 0) * tb.conversion_rate, 2) AS customer_rate,
    FORMAT(IFNULL(customer_rate, 0), 2) AS customer_rate,
    FORMAT(IFNULL(insurance_rate, 0), 2) AS insurance_rate,
    IFNULL(insurance_type, 0) AS insurance_type,
    FORMAT(IFNULL(millage_rate, 0), 2) AS millage_rate,
    FORMAT(IFNULL(millage_cap_km, 0), 2) AS millage_cap_km,
    FORMAT(IFNULL(rent_charge, 0), 2) AS rent_charge,
    FORMAT(IFNULL(extra_day_charge, 0), 2) AS extra_day_charge,
    FORMAT(IFNULL(delivery_charge, 0), 2) AS delivery_charge,
    FORMAT(IFNULL(collection_charge, 0), 2) AS collection_charge,
    FORMAT(IFNULL(additional_driver_charge, 0), 2) AS additional_driver_charge,
    FORMAT(IFNULL(insurance_charge, 0), 2) AS insurance_charge,
    FORMAT(IFNULL(intercity_charge, 0), 2) AS intercity_charge,
    FORMAT(IFNULL(millage_charge, 0), 2) AS millage_charge,
    FORMAT(IFNULL(other_rental_charge, 0), 2) AS other_rental_charge,
    FORMAT(IFNULL(discount_charge, 0), 2) AS discount_charge,
    FORMAT(IFNULL(total_vat, 0), 2) AS total_vat,
    FORMAT(IFNULL(other_charge, 0), 2) AS other_charge,
    booking_id,
    FORMAT(IFNULL(booking_charge, 0), 2) AS booking_charge,
    FORMAT(IFNULL(booking_charge_less_discount, 0), 2) AS booking_charge_less_discount,
    FORMAT(IFNULL(base_rental_revenue, 0), 2) AS base_rental_revenue,
    FORMAT(IFNULL(non_rental_charge, 0), 2) AS non_rental_charge,
    FORMAT(IFNULL(extension_charge, 0), 2) AS extension_charge,
    promo_code,
    status,
    is_extended,
    days,
    extra_day_charge

FROM ezhire_booking_data.booking_data
WHERE booking_year = @target_year 
	AND booking_id IN ('240685', '258491', '258490', '244787', '245399', '245689', '246876') 
    OR agreement_number IN ('RAEZ00074381', '1100142414')
ORDER BY booking_id;
