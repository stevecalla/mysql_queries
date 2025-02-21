drop temporary table if exists booking_data;
create temporary table booking_data
#INSERT INTO booking_data
SELECT *
	,ROUND((total_payment_after_refund / (tax_value+1)),2) as total_payment_after_refund_vat
    ,IFNULL(ROUND((total_payment_after_refund / (tax_value+1)),2) * tb.conversion_rate, 0) AS booking_charge_less_discount_aed
FROM (
SELECT 
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
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y-%m-%d') AS booking_date,

            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%Y-%m-%d %H:%i:%s') AS pickup_datetime,

            b.early_return,
            DATE_FORMAT((CASE
                WHEN b.early_return = 1 AND new_return_date THEN DATE_FORMAT(CONCAT(STR_TO_DATE(erb.new_return_date, '%d/%m/%Y'), ' ', erb.new_return_time), '%Y-%m-%d %H:%i:%s')
                ELSE DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')
            END),'%Y-%m-%d') AS return_date,

            CASE
                WHEN b.early_return = 1 AND new_return_date THEN DATE_FORMAT(CONCAT(STR_TO_DATE(erb.new_return_date, '%d/%m/%Y'), ' ', erb.new_return_time), '%Y-%m-%d %H:%i:%s')
                ELSE DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')
            END AS return_datetime,

            (SELECT status FROM myproject.rental_status rs WHERE rs.id = b.status LIMIT 1) AS status, -- CHANGE LIMIT

            -- adjusted for early return
                    (CASE
                        WHEN erb.new_days < 7 THEN 'daily'
                        WHEN erb.new_days > 29 AND is_subscription = 1 THEN 'Subscription'
                        WHEN erb.new_days > 29 THEN 'Monthly'
                        ELSE 'Weekly'
                    END) AS booking_type,

            (CASE   
                WHEN b.vendor_id = 234555 THEN 'Dispatch'
                WHEN b.vendor_id <> 234555 THEN 'MarketPlace'
                ELSE 'N/A'
            END) AS marketplace_or_dispatch,
            (SELECT name FROM myproject.rental_vendors rv WHERE rv.owner_id = b.vendor_id AND b.vendor_id <> 234555 LIMIT 1) AS marketplace_partner, -- CHANGE LIMIT

            b.platform_generated AS booking_channel,
            bs.name AS booking_source,  -- CHANGE

            (CASE 
				WHEN (SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id) > 1 -- owner_id is customer_id
                THEN 'YES'
                ELSE 'NO'
            END) repeated_user,

            IFNULL((SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id), 0) AS no_of_bookings,

            IFNULL((SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id AND bb.status = 8), 0) AS no_of_cancel_bookings,

            IFNULL((SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id AND bb.status = 9), 0) AS no_of_completed_bookings,

            IFNULL((SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id  AND bb.status NOT IN (8 , 9)), 0) AS no_of_started_bookings,
            b.owner_id AS customer_id,
            au.first_name AS first_name,
            au.last_name AS last_name,
            au.email as email,
            au.username as user_name,
            f.date_of_birth,

            TIMESTAMPDIFF(YEAR, STR_TO_DATE(f.date_of_birth, '%d/%m/%Y'), NOW()) age,

            IFNULL((SELECT name FROM myproject.rental_country ct WHERE ct.code = dl_country LIMIT 1), 0) AS customer_driving_country, -- CHANGE LIMIT

            -- adjusted for early return
			IFNULL(erb.new_days, b.days) AS days,

           IFNULL((SELECT name FROM myproject.Allowed_Millage am WHERE am.id = b.millage_id LIMIT 1), 0) AS millage_cap_km, -- CHANGE LIMIT

			(SELECT COALESCE(ROUND(SUM(CASE WHEN charge_type_id = 22 THEN -total_charge ELSE total_charge END),2),0) AS amount
						FROM rental_charges rc
						WHERE booking_id = b.id
						AND charge_type_id IN (24,6,22)
						AND is_rental IN (0,1,3)
				 ) as total_payment_after_refund,

			b.car_available_id car_avail_id,
            
            co.name deliver_country,
            rc.name deliver_city,
            b.delivery_location,
            co.id country_id,
            rc.id city_id,
            (CASE
                WHEN b.self_pickup_status = 1 THEN 'Self'
                ELSE 'Delivery'
            END) deliver_method,
            ct.conversion_rate AS conversion_rate
			,myproject.get_tax_value(b.id,b.city_id,b.rental_type_id,b.delivery_location_lat,b.delivery_location_lng) tax_value
    FROM myproject.rental_car_booking2 b
        INNER JOIN myproject.rental_fuser f ON f.user_ptr_id = b.owner_id
        INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
        INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
        LEFT JOIN myproject.rental_vendors rv ON rv.owner_id = b.vendor_id
        LEFT JOIN myproject.auth_user au ON au.id = b.owner_id
        LEFT JOIN rental_car_booking_source bs ON bs.id = b.car_booking_source_id -- CHANGE
        LEFT JOIN rental_city ci ON ci.id = b.city_id -- CHANGE
        LEFT JOIN country_conversion_rate ct ON ci.CountryID = ct.country_id -- CHANGE
        LEFT JOIN rental_early_return_bookings AS erb ON erb.booking_id = b.id AND erb.is_active = 1
	WHERE 1 = 1 
        AND date(date_add(b.created_on,interval 4 hour)) between '2016-01-01' and '2025-02-28' -- todo change
        AND COALESCE(b.vendor_id,'') NOT IN (5, 33, 218, 23086)
        AND f.is_test_user = 0
		AND b.id IN (47926, 64699)
    ORDER BY b.id
)tb;

-- select COUNT(*) from booking_data;
select * from booking_data;
-- select * from booking_data where booking_id = 125230;
