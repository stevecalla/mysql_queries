SET  @str_date = '2024-01-01',@end_date = '2024-01-01';

-- CHANGE LOG ********* START **************
-- adjusted a variety of fields to clean data for export / import / analytics
-- added country_id
-- added city_id
-- adjusted definition of booking_day_of_week as it was returning week of the year
-- removed the currency conversion from local to AED on customer rate
-- added booking_charge_less_discount_aed, -- converted from local currency to UAE/AED
-- added booking_charge_less_aed, -- converted from local currency to UAE/AED
-- CHANGE LOG ********* END **************

SELECT 
    booking_id,
    REPLACE(REPLACE(agreement_number, '"', ''),
        ',',
        ' ') AS agreement_number,
    IFNULL(IF(DATE_FORMAT(booking_datetime, '%Y-%m-%d %H:%i:%s') = '0000-00-00 00:00:00',
                '1900-01-01 12:00:00',
                booking_datetime),
            '1900-01-01 12:00:00') AS booking_datetime,
    booking_year,
    booking_month,
    booking_day_of_month,
    booking_day_of_week,
    booking_day_of_week_v2,
    booking_time_bucket,
    IFNULL(IF(DATE_FORMAT(pickup_datetime, '%Y-%m-%d %H:%i:%s') = '0000-00-00 00:00:00',
                '1900-01-01 12:00:00',
                pickup_datetime),
            '1900-01-01 12:00:00') AS pickup_datetime,
    pickup_year,
    pickup_month,
    pickup_day_of_month,
    pickup_day_of_week,
    pickup_day_of_week_v2,
    pickup_time_bucket,
    IFNULL(IF(DATE_FORMAT(return_datetime, '%Y-%m-%d %H:%i:%s') = '0000-00-00 00:00:00',
                '1900-01-01 12:00:00',
                return_datetime),
            '1900-01-01 12:00:00') AS return_datetime,
    return_year,
    return_month,
    return_day_of_month,
    return_day_of_week,
    return_day_of_week_v2,
    return_time_bucket,
    status,
    booking_type,
    marketplace_or_dispatch,
    marketplace_partner,
    marketplace_partner_summary,
    booking_channel,
    booking_source,
    repeated_user,
    total_lifetime_booking_revenue,
    no_of_bookings,
    no_of_cancel_bookings,
    no_of_completed_bookings,
    no_of_started_bookings,
    customer_id,
    date_of_birth,
    age,
    customer_driving_country,
    customer_doc_vertification_status,
    days,
    IFNULL(extra_day_calc, 0) AS extra_day_calc,
--     IFNULL(myproject.get_rental_rates(tb.booking_id,
--                     tb.millage_id,
--                     tb.contract_id,
--                     tb.drg,
--                     tb.wrg,
--                     tb.mrg,
--                     tb.dr,
--                     tb.wr,
--                     tb.mr,
--                     tb.days,
--                     tb.deliver_date_string),
--             0) * tb.conversion_rate AS customer_rate_v2, -- converted to UAE/AED
    IFNULL(myproject.get_rental_rates(tb.booking_id,
                    tb.millage_id,
                    tb.contract_id,
                    tb.drg,
                    tb.wrg,
                    tb.mrg,
                    tb.dr,
                    tb.wr,
                    tb.mr,
                    tb.days,
                    tb.deliver_date_string),
            0) AS customer_rate, -- in local currency
    IFNULL(insurance_rate, 0) AS insurance_rate,
    IFNULL(insurance_type, 0) AS insurance_type,
    IFNULL(millage_rate, 0) AS millage_rate,
    IFNULL(millage_cap_km, 0) AS millage_cap_km,
    IFNULL(rent_charge, 0) AS rent_charge,
    IFNULL(extra_day_charge, 0) AS extra_day_charge,
    IFNULL(delivery_charge, 0) AS delivery_charge,
    IFNULL(collection_charge, 0) AS collection_charge,
    IFNULL(additional_driver_charge, 0) AS additional_driver_charge,
    IFNULL(insurance_charge, 0) AS insurance_charge,
    IFNULL(intercity_charge, 0) AS intercity_charge,
    IFNULL(millage_charge, 0) AS millage_charge,
    IFNULL(other_rental_charge, 0) AS other_rental_charge,
    IFNULL(discount_charge, 0) AS discount_charge,
    IFNULL(total_vat, 0) AS total_vat,
    IFNULL(other_charge, 0) AS other_charge,
    IFNULL(booking_charge, 0) AS booking_charge,
    IFNULL(booking_charge_less_discount, 0) AS booking_charge_less_discount,
    IFNULL(booking_charge, 0) * tb.conversion_rate AS booking_charge_aed, -- converted from local currency to UAE/AED
    IFNULL(booking_charge_less_discount, 0) * tb.conversion_rate AS booking_charge_less_discount_aed, -- converted from local currency to UAE/AED
    IFNULL(base_rental_revenue, 0) AS base_rental_revenue,
    IFNULL(non_rental_charge, 0) AS non_rental_charge,
    IFNULL(extension_charge, 0) AS extension_charge,
    is_extended,

    Promo_Code AS promo_code,
    promo_code_discount_amount,
    IFNULL(IF(DATE_FORMAT(promocode_created_date,
                        '%Y-%m-%d %H:%i:%s') = '0000-00-00 00:00:00',
                '1900-01-01 12:00:00',
                promocode_created_date),
            '1900-01-01 12:00:00') AS promocode_created_date,
    promo_code_description,

    requested_car,
    car_name,
    make,
    REPLACE(color, ',', '') AS color,

    deliver_country,
    deliver_city,
    country_id,
    city_id,
    REPLACE(REPLACE(REPLACE(delivery_location,
                '
                ',
                ''),
            ',',
            ''),
        '"',
        '') AS delivery_location,
    deliver_method,
    delivery_lat,
    delivery_lng,

    REPLACE(REPLACE(REPLACE(collection_location,
                '
                ',
                ''),
            ',',
            ''),
        '"',
        '') AS collection_location,
    collection_method,
    IFNULL(SUBSTRING_INDEX(collection_lat, ',', 1),
            collection_lat) AS collection_lat,
    IFNULL(SUBSTRING_INDEX(collection_lng, ',', 1),
            collection_lat) AS collection_lng,

    nps_score,
	NULLIF(REPLACE(REPLACE(REPLACE(nps_comment, '\n', ''), ',', ''), '"', ''), '') AS nps_comment
FROM
    (SELECT 
        b.id AS booking_id,
            agreement_number,
            b.millage_id,
            b.contract_id,
            b.drg,
            b.wrg,
            b.mrg,
            b.dr,
            b.wr,
            b.mr,
            b.deliver_date_string,
            
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d %H:%i:%s') AS booking_datetime,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y') booking_year,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%m') booking_month,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%d') booking_day_of_month,
            -- DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%u') booking_day_of_week, -- returning week of the year
            DAYOFWEEK(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) AS booking_day_of_week,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%W') booking_day_of_week_v2,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') booking_time_bucket,
            
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%Y-%m-%d %H:%i:%s') AS pickup_datetime,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%Y') pickup_year,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%m') pickup_month,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%d') pickup_day_of_month,
            -- DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%u') pickup_day_of_week, -- returning week of the year
            DAYOFWEEK(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string)) AS pickup_day_of_week,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%W') pickup_day_of_week_v2,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%H') pickup_time_bucket,
            
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s') AS return_datetime,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y') return_year,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%m') return_month,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%d') return_day_of_month,
            -- DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%u') return_day_of_week, -- returning week of the year
            DAYOFWEEK(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string)) AS return_day_of_week,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%W') return_day_of_week_v2,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%H') return_time_bucket,
            (SELECT 
                    status
                FROM
                    myproject.rental_status rs
                WHERE
                    rs.id = b.status) AS status,
            (CASE
                WHEN b.days < 7 THEN 'daily'
                WHEN b.days > 29 AND is_subscription = 1 THEN 'Subscription'
                WHEN b.days > 29 THEN 'Monthly'
                ELSE 'Weekly'
            END) AS booking_type,
            (CASE
                WHEN b.vendor_id = 234555 THEN 'Dispatch'
                WHEN b.vendor_id <> 234555 THEN 'MarketPlace'
                ELSE 'N/A'
            END) AS marketplace_or_dispatch,
            (SELECT 
                    name
                FROM
                    myproject.rental_vendors rv
                WHERE
                    rv.owner_id = b.vendor_id
                        AND b.vendor_id <> 234555) AS marketplace_partner,
            (SELECT 
                    name
                FROM
                    myproject.rental_vendors rv
                WHERE
                    rv.owner_id = b.vendor_id) AS marketplace_partner_summary,
            b.platform_generated AS booking_channel,
            (SELECT 
                    name
                FROM
                    myproject.rental_car_booking_source bs
                WHERE
                    bs.id = b.car_booking_source_id) AS booking_source,
            '' total_lifetime_booking_revenue,
            (CASE
                WHEN
                    (SELECT 
                            COUNT(1)
                        FROM
                            myproject.rental_car_booking2 bb
                        WHERE
                            bb.owner_id = b.owner_id) > 1
                THEN
                    'YES'
                ELSE 'NO'
            END) repeated_user,
            (SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id) AS no_of_bookings,
            (SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status = 8) AS no_of_cancel_bookings,
            (SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status = 9) AS no_of_completed_bookings,
            (SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status NOT IN (8 , 9)) AS no_of_started_bookings,
            b.owner_id AS customer_id,
            f.date_of_birth,
            TIMESTAMPDIFF(YEAR, STR_TO_DATE(f.date_of_birth, '%d/%m/%Y'), NOW()) age,
            (SELECT 
                    name
                FROM
                    myproject.rental_country ct
                WHERE
                    ct.code = dl_country) customer_driving_country,
            (CASE
                WHEN f.is_verified > 0 THEN 'YES'
                ELSE 'NO'
            END) customer_doc_vertification_status,
            b.days,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (30 , 31)) AS extra_day_calc,
            (CASE
                WHEN b.days < 7 THEN b.DIR
                WHEN b.days > 29 THEN b.MIR
                ELSE b.WIR
            END) AS insurance_rate,
            (CASE
                WHEN
                    (CASE
                        WHEN b.days < 7 THEN b.DIR
                        WHEN b.days > 29 THEN b.MIR
                        ELSE b.WIR
                    END) > 0
                THEN
                    'Full Insurance'
                ELSE ''
            END) insurance_type,
            (SELECT 
                    ad.rate
                FROM
                    myproject.cars_available_detail ad
                WHERE
                    ad.car_available_id = b.car_available_id
                        AND ad.millage_id = b.millage_id
                        AND ad.month_id = b.contract_id) millage_rate,
            (SELECT 
                    name
                FROM
                    myproject.Allowed_Millage am
                WHERE
                    am.id = b.millage_id) millage_cap_km,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id = 4) AS rent_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (31 , 30)) AS extra_day_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id = 11) AS delivery_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id = 3) AS collection_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (21 , 40)) AS additional_driver_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (15 , 36)) AS insurance_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id = 25) AS intercity_charge,
            0 AS millage_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (15 , 16, 17, 18, 19, 23, 26, 29, 32, 37, 38, 39, 41, 48, 49, 50, 51, 52, 56, 57)) AS other_rental_charge,
            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id = 14) AS discount_charge,

            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id = 20) AS total_vat,

            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (1 , 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)) AS other_charge,

            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57)) AS booking_charge,

            (SELECT 
                    SUM(CASE
                            WHEN charge_type_id IN (14) THEN - (total_charge)
                            ELSE (total_charge)
                        END)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57, 14)) AS booking_charge_less_discount,

            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57)) AS base_rental_revenue,

            (SELECT 
                    SUM(total_charge)
                FROM
                    myproject.rental_charges cc
                WHERE
                    cc.booking_id = b.id
                        AND cc.charge_type_id IN (1 , 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)) AS non_rental_charge,
            0 AS extension_charge,

            (SELECT 
                    CASE
                            WHEN COUNT(1) >= 1 THEN 'YES'
                            ELSE 'NO'
                        END
                FROM
                    myproject.rental_invoice_details
                WHERE
                    type = 'Extension' AND booking_id = b.id) AS is_extended,

            pc.Promo_Code,
            '' promo_code_discount_amount,
            DATE_FORMAT(pc.date_created, '%Y-%m-%d %H:%i:%s') promocode_created_date,
            b.Promo_Code promo_code_description,

            ca.car_name requested_car,
            c.car_name,
            c.make,
            c.color,

            co.name deliver_country,
            rc.name deliver_city,
            b.delivery_location,
            co.id country_id,
            rc.id city_id,
            (CASE
                WHEN b.self_pickup_status = 1 THEN 'Self'
                ELSE 'Delivery'
            END) deliver_method,
            b.delivery_location_lat delivery_lat,
            b.delivery_location_lng delivery_lng,

            b.collection_location,
            (CASE
                WHEN b.self_return_status = 1 THEN 'Self'
                ELSE 'Collection'
            END) collection_method,
            b.return_location_lat collection_lat,
            b.return_location_lng collection_lng,

            (SELECT 
                    rate
                FROM
                    myproject.rental_rentalfeedback rf
                WHERE
                    rf.booking_id = b.id
                ORDER BY rf.id DESC
                LIMIT 1) nps_score,

            (SELECT 
                    ct.conversion_rate
                FROM
                    myproject.country_conversion_rate ct, myproject.rental_city c
                WHERE
                    ct.country_id = c.CountryID
                        AND c.id = b.city_id) AS conversion_rate,

            (SELECT 
                    comments
                FROM
                    myproject.rental_rentalfeedback rf
                WHERE
                    rf.booking_id = b.id
                ORDER BY rf.id DESC
                LIMIT 1) nps_comment
    FROM
        myproject.rental_car_booking2 b
    INNER JOIN myproject.rental_fuser f ON f.user_ptr_id = b.owner_id
    INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
    INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    LEFT JOIN myproject.rental_vendors rv ON rv.owner_id = b.vendor_id
    LEFT JOIN myproject.rental_car c ON c.id = b.car_id
    LEFT JOIN myproject.rental_cars_available ca ON ca.id = b.car_available_id
    LEFT JOIN myproject.rental_add_promo_codes pc ON pc.id = b.Promo_Code_id

	-- FOR USE IN MYSQL WITH VARIABLES IN LINE 1
    WHERE DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
        
    -- TEST BOOKING EXCLUSION LOGIC FROM BURHAN KHAN
    -- what tech team is do when they make test booking , usually they assigned to particular vendor  therefore we exclude it from our query..
	    AND COALESCE(vendor_id,'') NOT IN (33, 5 , 218, 23086)
	-- moreover, we also exclude this
	-- first_name not LIKE '%test%' and last_name not like '%test%'
	
	-- FOR TESTING / AUDITING ******* START *********
	-- WHERE date(date_add(b.created_on,interval 4 hour)) between '2024-01-01' and '2024-01-01' 
	-- AND pc.Promo_Code IS NOT NULL
	-- AND b.id = "218138"
    -- WHERE b.id = "163847"
	-- FOR TESTING / AUDITING ******* END *********
	
	-- FOR USE IN NODE / JAVASCRIPT AS SQL VARIABLES DON'T WORK ******* START *********
	-- WHERE date(date_add(b.created_on,interval 4 hour)) between 'startDateVariable' and 'endDateVariable'
	-- FOR USE IN NODE / JAVASCRIPT AS SQL VARIABLES DON'T WORK ******* END *********

    ORDER BY b.id
    -- LIMIT 1
    ) tb;