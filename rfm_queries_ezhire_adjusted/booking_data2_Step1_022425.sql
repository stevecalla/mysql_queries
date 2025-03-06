drop temporary table if exists booking_data;
create temporary table booking_data
#INSERT INTO booking_data
SELECT *
	#,ROUND((total_payment_after_refund / (tax_value+1)),2) as total_payment_after_refund_vat
    ,IFNULL(booking_charge_less_discount,0) AS booking_charge_less_discount_aed
FROM (
SELECT 
        b.id AS booking_id,
        f.user_ptr_id,
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
		
        (CASE
			-- WHEN b.early_return = 0 THEN
			-- 	(SELECT COALESCE(ROUND(SUM(CASE WHEN charge_type_id IN (14) THEN -total_charge ELSE total_charge END),2),0) AS amount
			-- 	FROM rental_charges rc
			-- 	WHERE booking_id = b.id
			-- 	AND (charge_type_id IN (SELECT id FROM rental_charge_types ct WHERE ct.id = rc.charge_type_id AND ct.is_rental = 1)
			-- 	OR charge_type_id in (35,43))
			-- 	AND charge_type_id NOT IN (1,34,20,9,34,22,2,12,8,81)
			-- 	)

            WHEN b.early_return = 0 THEN
                IFNULL((
                    SELECT 
                        SUM(CASE WHEN charge_type_id IN (14) THEN - (total_charge) ELSE (total_charge) END)
                    FROM
                        myproject.rental_charges cc
                    WHERE
                        cc.booking_id = b.id
                            AND cc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 35, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57, 14)), 0)
			-- fix  8/3/24
                ELSE
                    CASE
                        -- Fetch the charge for early return
                        WHEN IFNULL((
                            SELECT
                                charge
                            FROM
                                myproject.rental_early_return_charges as erc
                            WHERE
                                erc.booking_id = b.id
                                    AND erc.charge_type_id IN (4)
                            LIMIT 1
                        ), 0) = 0 THEN
                            -- Use the original WHEN clause value
                            IFNULL(
                                myproject.get_rental_rates(
                                    b.id,
                                    b.millage_id,
                                    b.contract_id,
                                    b.drg,
                                    b.wrg,
                                    b.mrg,
                                    b.dr,
                                    b.wr,
                                    b.mr,
                                    b.days,
                                    b.deliver_date_string
                                ), 0)
                                -- adjusted for early return
                                * CASE
                                    WHEN b.early_return = 0 THEN IFNULL(b.days, 0)
                                    ELSE IFNULL(erb.new_days, b.days)
                                END
                                + IFNULL((
                                    SELECT
                                        SUM(CASE
                                                WHEN charge_type_id IN (14) THEN -(total_charge)
                                                WHEN charge_type_id IN (21, 40) THEN (charge)
                                                WHEN charge_type_id IN (15, 36) THEN (charge)
                                                ELSE (total_charge)
                                            END)
                                    FROM
                                        myproject.rental_early_return_charges as erc
                                    WHERE
                                        erc.booking_id = b.id
                                            AND erc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 35, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57, 14)), 0)
                        ELSE
                            IFNULL((
                                SELECT
                                    SUM(CASE
                                            WHEN charge_type_id IN (14) THEN -(total_charge)
                                            WHEN charge_type_id IN (21, 40) THEN (charge)
                                            WHEN charge_type_id IN (15, 36) THEN (charge)
                                            ELSE (total_charge)
                                        END)
                                FROM
                                    myproject.rental_early_return_charges as erc
                                WHERE
                                    erc.booking_id = b.id
                                        AND erc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 35, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57, 14)), 0)
                    END
				END)
                as booking_charge_less_discount,
       

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
        AND date(date_add(b.created_on,interval 4 hour)) between '2016-01-01' and '2025-02-28'
        AND COALESCE(b.vendor_id,'') NOT IN (5, 33, 218, 23086)
        AND f.is_test_user = 0
        
		-- AND booking_id IN (70713,71220,248667,251309,49462,47926,64699,304017) -- 1st sample set
        AND f.user_ptr_id IN (276033,220300,433284,90574,230847,424927,256050,389223,192627) -- 2nd sample set
        
        #AND f.user_ptr_id IN (428486, 62195, 143953, 295647, 283202)
		#AND b.id = 361630
    ORDER BY b.id
)tb;

SELECT user_ptr_id, booking_id, early_return, days, booking_charge_less_discount FROM booking_data ORDER BY 1, 2;