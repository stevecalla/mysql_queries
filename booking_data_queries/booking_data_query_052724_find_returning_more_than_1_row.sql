USE myproject;

SET @str_date = '2024-06-28', @end_date = '2024-06-28';

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
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%Y') AS booking_year,
            QUARTER(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) AS booking_quarter,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%m') AS booking_month,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%d') AS booking_day_of_month,
            WEEKOFYEAR(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) AS booking_week_of_year,
            DAYOFWEEK(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) AS booking_day_of_week,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%W') AS booking_day_of_week_v2,
            DATE_FORMAT(DATE_ADD(b.created_on, INTERVAL 4 HOUR), '%H') AS booking_time_bucket,
            
            (SELECT 
                    MAX(DATE_ADD(created_on, INTERVAL 4 HOUR))
                FROM
                    myproject.rental_car_booking2
            ) AS max_booking_datetime,
            
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%Y-%m-%d %H:%i:%s') AS pickup_datetime,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%Y') pickup_year,
            QUARTER(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y')) AS pickup_quarter,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%m') pickup_month,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%d') pickup_day_of_month,
            WEEKOFYEAR(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string)) AS pickup_week_of_year,
            DAYOFWEEK(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string)) AS pickup_day_of_week,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%W') pickup_day_of_week_v2,
            DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string, '%d/%m/%Y'), ' ', b.deliver_time_string), '%H') pickup_time_bucket,
            
            b.early_return,
            CASE    
                WHEN b.early_return = 1 AND new_return_date THEN DATE_FORMAT(CONCAT(STR_TO_DATE(erb.new_return_date, '%d/%m/%Y'), ' ', erb.new_return_time), '%Y-%m-%d %H:%i:%s')
                ELSE DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s')
            END AS return_datetime,

            (SELECT 
                    status
                FROM
                    myproject.rental_status rs
                WHERE
                    rs.id = b.status
                LIMIT 1) AS status, -- CHANGE LIMIT

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    CASE
                        WHEN b.days < 7 THEN 'daily'
                        WHEN b.days > 29 AND is_subscription = 1 THEN 'Subscription'
                        WHEN b.days > 29 THEN 'Monthly'
                        ELSE 'Weekly'
                    END
                ELSE 
                    CASE
                        WHEN erb.new_days < 7 THEN 'daily'
                        WHEN erb.new_days > 29 AND is_subscription = 1 THEN 'Subscription'
                        WHEN erb.new_days > 29 THEN 'Monthly'
                        ELSE 'Weekly'
                    END
            END AS booking_type,

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
                        AND b.vendor_id <> 234555
                LIMIT 1) AS marketplace_partner, -- CHANGE LIMIT

            (SELECT 
                    name
                FROM
                    myproject.rental_vendors rv
                WHERE
                    rv.owner_id = b.vendor_id
                LIMIT 1) AS marketplace_partner_summary, -- CHANGE LIMIT

            b.platform_generated AS booking_channel,

            bs.name AS booking_source,

            '' total_lifetime_booking_revenue,

            (CASE
                WHEN
                    (SELECT 
                            COUNT(1)
                        FROM
                            myproject.rental_car_booking2 bb
                        WHERE
                            bb.owner_id = b.owner_id) > 1 -- owner_id is customer_id
                THEN
                    'YES'
                ELSE 'NO'
            END) repeated_user,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id), 0) AS no_of_bookings,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status = 8), 0) AS no_of_cancel_bookings,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status = 9), 0) AS no_of_completed_bookings,

            IFNULL((SELECT 
                    COUNT(1)
                FROM
                    myproject.rental_car_booking2 bb
                WHERE
                    bb.owner_id = b.owner_id
                        AND bb.status NOT IN (8 , 9)), 0) AS no_of_started_bookings,
            b.owner_id AS customer_id,
            au.first_name AS first_name,
            au.last_name AS last_name,
            au.email as email,
            au.username as user_name,

            f.date_of_birth,

            TIMESTAMPDIFF(YEAR, STR_TO_DATE(f.date_of_birth, '%d/%m/%Y'), NOW()) age,

            IFNULL((SELECT 
                    name
                FROM
                    myproject.rental_country ct
                WHERE
                    ct.code = dl_country
                LIMIT 1), 0) AS customer_driving_country, -- CHANGE LIMIT

            IFNULL((CASE
                WHEN f.is_verified > 0 THEN 'YES'
                ELSE 'NO'
            END), 0) AS customer_doc_vertification_status,

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN IFNULL(b.days, 0)
                ELSE IFNULL(erb.new_days, 0)
            END AS days,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (30 , 31)), 0)
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (30 , 31)), 0)
            END AS extra_day_calc,

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
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
                ELSE 
                    IFNULL((
                        SELECT 
                            charge 
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (4)
                        -- ****************************
                        LIMIT 1), 0) -- FIX 07/03/24 #57
                        -- ****************************
            END AS customer_rate, -- in local currency

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((CASE
                        WHEN 
                            (SELECT 
                                SUM(total_charge)
                            FROM
                                myproject.rental_charges cc
                            WHERE
                                cc.booking_id = b.id
                                    AND cc.charge_type_id IN (15 , 36)
                            LIMIT 1) > 0 -- FIX 07/03/24 #56
                                    THEN (
                                        CASE 
                                            WHEN b.days < 7 THEN b.DIR
                                            WHEN b.days > 29 THEN b.MIR
                                            ELSE b.WIR
                                        END)
                        ELSE 0
                    END), 0)
                WHEN b.early_return = 1 THEN
                    IFNULL((CASE
                        WHEN 
                            (SELECT 
                                SUM(total_charge)
                            FROM
                                myproject.rental_early_return_charges as erc
                            WHERE
                                erc.booking_id = b.id
                                    AND erc.charge_type_id IN (15 , 36)
                            LIMIT 1) > 0 -- FIX 07/03/24 #55
                                    THEN (
                                        CASE 
                                            WHEN b.days < 7 THEN b.DIR
                                            WHEN b.days > 29 THEN b.MIR
                                            ELSE b.WIR
                                        END)
                        ELSE 0
                    END), 0)
                ELSE 0
            END AS insurance_rate, -- in local currency

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        CASE
                            WHEN
                                (CASE
                                    WHEN b.days < 7 THEN b.DIR
                                    WHEN b.days > 29 THEN b.MIR
                                    ELSE b.WIR
                                END) > 0
                            THEN
                                'Full Insurance'
                            ELSE ''
                        END), 0) 
                ELSE 
                    IFNULL((
                        CASE
                            WHEN
                                (CASE
                                    WHEN erb.new_days < 7 THEN b.DIR
                                    WHEN erb.new_days > 29 THEN b.MIR
                                    ELSE b.WIR
                                END) > 0
                            THEN
                                'Full Insurance'
                            ELSE ''
                        END), 0) 
            END AS insurance_type,

            IFNULL((
                SELECT 
                    ad.rate
                FROM
                    myproject.cars_available_detail ad
                WHERE
                    ad.car_available_id = b.car_available_id
                        AND ad.millage_id = b.millage_id
                        AND ad.month_id = b.contract_id
                LIMIT 1), 0) AS millage_rate, -- CHANGE LIMIT

           IFNULL((
                SELECT 
                    name
                FROM
                    myproject.Allowed_Millage am
                WHERE
                    am.id = b.millage_id
                LIMIT 1), 0) AS millage_cap_km, -- CHANGE LIMIT

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id = 4
                        LIMIT 1), 0) -- FIX 07/03/24 #54
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id = 4
                        LIMIT 1), 0) -- FIX 07/03/24 #53
            END AS rent_charge,

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (31 , 30)
                        LIMIT 1), 0) -- FIX 07/03/24 #52
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (31 , 30)
                        LIMIT 1), 0) -- FIX 07/03/24 #51
            END AS extra_day_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id = 11
                        LIMIT 1), 0) -- FIX 07/03/24 #50
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id = 11
                        LIMIT 1), 0) -- FIX 07/03/24 #49
            END AS delivery_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id = 3
                        LIMIT 1), 0) -- FIX 07/03/24 #48
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id = 3
                        LIMIT 1), 0) -- FIX 07/03/24 #47
            END AS collection_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (21 , 40)
                        LIMIT 1), 0) -- FIX 07/03/24 #46
                ELSE 
                    IFNULL((
                        SELECT 
                            -- SUM(total_charge) 
                            SUM(charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (21 , 40)
                        LIMIT 1), 0) -- FIX 07/03/24 #45
            END AS additional_driver_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge) / days
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (21 , 40)
                        LIMIT 1), 0) -- FIX 07/03/24 #44
                ELSE 
                    IFNULL((
                        SELECT 
                            -- changed to charge because total_charge had some values over 100,000; see booking_id 21899
                            SUM(charge) / days 
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (21 , 40)
                        LIMIT 1), 0) -- FIX 07/03/24 #43
            END AS additional_driver_rate,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (15 , 36)
                        LIMIT 1), 0) -- FIX 07/03/24 #42
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (15 , 36)
                        LIMIT 1), 0) -- FIX 07/03/24 #41
            END AS insurance_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (19, 41)
                        LIMIT 1), 0) -- FIX 07/03/24 #40
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (19, 41)
                        LIMIT 1), 0) -- FIX 07/03/24 #39
            END AS pai_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge) / days
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (19, 41)
                        LIMIT 1), 0) -- FIX 07/03/24 #38
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge) / days
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (19, 41)
                        LIMIT 1), 0) -- FIX 07/03/24 #37
            END AS pai_rate,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (16)
                        LIMIT 1), 0) -- FIX 07/03/24 #36
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (16)
                        LIMIT 1), 0) -- FIX 07/03/24 #35
            END AS baby_seat,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge) / days
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (16)
                        LIMIT 1), 0) -- FIX 07/03/24 #34
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge) / days
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (16)
                        LIMIT 1), 0) -- FIX 07/03/24 #33
            END AS baby_seat_rate,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (32)
                        LIMIT 1), 0) -- FIX 07/03/24 #32
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (32)
                        LIMIT 1), 0) -- FIX 07/03/24 #31
            END AS long_distance,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (56)
                        LIMIT 1), 0) -- FIX 07/03/24 #30
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (56)
                        LIMIT 1), 0) -- FIX 07/03/24 #29
            END AS premium_delivery,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (29)
                        LIMIT 1), 0) -- FIX 07/03/24 #28
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (29)
                        LIMIT 1), 0) -- FIX 07/03/24 #27
            END AS airport_delivery,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (17)
                        LIMIT 1), 0) -- FIX 07/03/24 #26
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (17)
                        LIMIT 1), 0) -- FIX 07/03/24 #25
            END AS gps_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (51)
                        LIMIT 1), 0) -- FIX 07/03/24 #24
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (51)
                        LIMIT 1), 0) -- FIX 07/03/24 #23
            END AS delivery_update,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id = 25
                        LIMIT 1), 0) -- FIX 07/03/24 #22
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id = 25
                        LIMIT 1), 0) -- FIX 07/03/24 #21
            END AS intercity_charge,

            0 AS millage_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (18, 23, 26, 37, 38, 39, 48, 49, 50, 52, 57)
                        LIMIT 1), 0) -- FIX 07/03/24 #20
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (18, 23, 26, 37, 38, 39, 48, 49, 50, 52, 57)
                        LIMIT 1), 0) -- FIX 07/03/24 #19
            END AS other_rental_charge,

            -- ROLLUP = RETURN THE TOTAL DISCOUNT
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(cc.total_charge) AS total_discount
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (14)
                        LIMIT 1), 0) -- FIX 07/03/24 #18
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(erc.total_charge) AS total_discount
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (14)
                        LIMIT 1), 0) -- FIX 07/03/24 #17
            END AS discount_charge, -- total discount charge
                    
            -- ROLLUP = RETURN ONLY THE EXTENSION DISCOUNT
            -- EXTENTION DISCOUNT ONLY (NOT PERFECT)
            -- BASICALLY LOOKS FOR A DISCOUNT CHARGE ID 14 THAT APPLIED AFTER THE BOOKING CREATED DATE
            -- ATTEMPTED TO USE THE COMMENTS WITH %EXTENSION% BUT WAS LESS ACCURATE DUE TO INCONSISTENT USE OF COMMENTS
            IFNULL((CASE
                WHEN (SELECT 
                            CASE
                                WHEN COUNT(1) >= 1 THEN 'YES'
                                ELSE 'NO'
                            END
                        FROM
                            myproject.rental_invoice_details
                        WHERE
                            type = 'Extension' AND booking_id = b.id) = "YES" THEN (
                                SELECT
                                    SUM(rc.total_charge) AS extension_discount
                                    FROM
                                        myproject.rental_charges rc
                                        JOIN (
                                            SELECT
                                                booking_id,
                                                DATE_FORMAT(MIN(created_on), '%Y-%m-%d') as min_created_date
                                            FROM
                                                myproject.rental_charges
                                            GROUP BY
                                                booking_id
                                            ORDER BY
                                                booking_id
                                        ) AS min_date ON rc.booking_id = min_date.booking_id
                                    WHERE
                                        rc.booking_id = b.id
                                        AND rc.charge_type_id IN (14)
                                        -- if created on date for discount > min_date plus 1 day
                                        AND DATE_FORMAT(rc.created_on, '%Y-%m-%d') > DATE_FORMAT(DATE_ADD(min_date.min_created_date, INTERVAL 1 DAY), '%Y-%m-%d')
                                    LIMIT 1 -- FIX 07/03/24 #16
                                )
                ELSE 0
            END), 0) AS discount_extension_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id = 20
                        LIMIT 1), 0) -- FIX 07/03/24 #15
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id = 20
                        LIMIT 1), 0) -- FIX 07/03/24 #14
            END AS total_vat,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (1 , 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)
                        LIMIT 1), 0) -- FIX 07/03/24 #13
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (1 , 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)
                        LIMIT 1), 0) -- FIX 07/03/24 #12
            END AS other_charge,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (3, 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57)
                        LIMIT 1), 0) -- FIX 07/03/24 #11
                ELSE 
                    IFNULL((
                        SELECT 
                            -- SUM(total_charge)
                            SUM(CASE
                                    WHEN charge_type_id IN (21, 40) THEN (charge)
                                    WHEN charge_type_id IN (15, 36) THEN (charge)
                                    ELSE (total_charge)
                                END)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (3, 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57)
                        LIMIT 1), 0) -- FIX 07/03/24 #10
            END AS booking_charge,

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(CASE
                                    WHEN charge_type_id IN (14) THEN -(total_charge)
                                    ELSE (total_charge)
                                END)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57, 14)
                        LIMIT 1), 0) -- FIX 07/03/24 #9
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
                                AND erc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57, 14) 
                        LIMIT 1), 0) -- FIX 07/03/24 #8
            END AS booking_charge_less_discount,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57)
                        LIMIT 1), 0) -- FIX 07/03/24 #7
                ELSE 
                    IFNULL((
                        SELECT 
                            -- SUM(total_charge)
                            SUM(CASE
                                    WHEN charge_type_id IN (21, 40) THEN (charge)
                                    WHEN charge_type_id IN (15, 36) THEN (charge)
                                    ELSE (total_charge)
                                END)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (3 , 4, 11, 15, 16, 17, 18, 19, 21, 23, 25, 26, 29, 30, 31, 32, 36, 37, 38, 39, 40, 41, 48, 49, 50, 51, 52, 56, 57)
                        LIMIT 1), 0) -- FIX 07/03/24 #6
            END AS base_rental_revenue,
            
            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_charges cc
                        WHERE
                            cc.booking_id = b.id
                                AND cc.charge_type_id IN (1 , 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)
                        LIMIT 1), 0) -- FIX 07/03/24 #5
                ELSE 
                    IFNULL((
                        SELECT 
                            SUM(total_charge)
                        FROM
                            myproject.rental_early_return_charges as erc
                        WHERE
                            erc.booking_id = b.id
                                AND erc.charge_type_id IN (1 , 2, 8, 9, 13, 14, 20, 22, 24, 27, 28, 44, 45, 46, 47)
                        LIMIT 1), 0) -- FIX 07/03/24 #4
            END AS non_rental_charge,

            -- adjusted for early return
            CASE
                WHEN b.early_return = 0 THEN
                    IFNULL((
                        SELECT 
                            SUM(extension_days)
                        FROM rental_messagesuser m
                        WHERE 
                            m.booking_id = b.id
                            AND (m.subject LIKE '%exten%' OR m.subject=CONCAT('Late Rental Return for Booking#', m.booking_id))
                            AND m.extension_days > 0
                            AND m.message LIKE '%Dear Partner%'
                        LIMIT 1), 0) -- FIX 07/03/24 #3
                ELSE
                    IFNULL(
                        (SELECT 
                                CASE 
                                    WHEN SUM(extension_days) <= TIMESTAMPDIFF(DAY, 
                                        DATE_FORMAT(CONCAT(STR_TO_DATE(erb.new_return_date, '%d/%m/%Y'), ' ', erb.new_return_time), '%Y-%m-%d %H:%i:%s'), 
                                        DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s'))
                                    THEN 0
                                    ELSE SUM(extension_days) - TIMESTAMPDIFF(DAY, 
                                        DATE_FORMAT(CONCAT(STR_TO_DATE(erb.new_return_date, '%d/%m/%Y'), ' ', erb.new_return_time), '%Y-%m-%d %H:%i:%s'), 
                                        DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string, '%d/%m/%Y'), ' ', b.return_time_string), '%Y-%m-%d %H:%i:%s'))
                                END
                            FROM 
                                rental_messagesuser m
                            WHERE 
                                m.booking_id = b.id
                                AND (m.subject LIKE '%exten%' OR m.subject = CONCAT('Late Rental Return for Booking#', m.booking_id))
                                AND m.extension_days > 0
                                AND m.message LIKE '%Dear Partner%'
                            LIMIT 1), 0) -- FIX 07/03/24 #2
            END AS extension_days,

            pc.Promo_Code,
            '' promo_code_discount_amount,
            DATE_FORMAT(pc.date_created, '%Y-%m-%d %H:%i:%s') promocode_created_date,
            b.Promo_Code promo_code_description,

			b.car_available_id car_avail_id,
            c.cat_id car_cat_id,
            cat.cat_name car_cat_name,

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

            ct.conversion_rate AS conversion_rate, -- CHANGE

            ff.rate nps_score, -- CHANGE
            ff.comments nps_comment -- CHANGE
                
    FROM myproject.rental_car_booking2 b
    
    INNER JOIN myproject.rental_fuser f ON f.user_ptr_id = b.owner_id
    INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
    INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
    LEFT JOIN myproject.rental_vendors rv ON rv.owner_id = b.vendor_id
    
    LEFT JOIN myproject.rental_car c ON c.id = b.car_id
    LEFT JOIN myproject.rental_cars_available ca ON ca.id = b.car_available_id
    LEFT JOIN myproject.rental_cat cat ON ca.cat_id = cat.id
    
    LEFT JOIN myproject.rental_add_promo_codes pc ON pc.id = b.Promo_Code_id
    LEFT JOIN myproject.auth_user au ON au.id = b.owner_id

    -- NEW JOINS ADDED ON 4/23/24
    LEFT JOIN (SELECT MAX(id),rate,comments,booking_id FROM myproject.rental_rentalfeedback rf GROUP BY booking_id LIMIT 1) ff ON ff.booking_id = b.id -- fix 7/3/24 #1
    LEFT JOIN rental_car_booking_source bs ON bs.id = b.car_booking_source_id -- CHANGE
    LEFT JOIN rental_city ci ON ci.id = b.city_id -- CHANGE
    LEFT JOIN country_conversion_rate ct ON ci.CountryID = ct.country_id -- CHANGE

    -- NEW JOINS ADDED 05/27/24 FOR EARLY RETURNS
    LEFT JOIN rental_early_return_bookings AS erb ON erb.booking_id = b.id AND erb.is_active = 1 -- RETURNS MOST RECENT DATE RECORDS FOR EACH booking_id USING is_active flag 1

	-- FOR USE IN MYSQL WITH VARIABLES IN LINE 1
	WHERE 
        DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
		AND COALESCE(b.vendor_id,'') NOT IN (5, 33, 218, 23086) -- LOGIC TO EXCLUDE TEST BOOKINGS
		AND (LOWER(au.first_name) NOT LIKE '%test%' AND LOWER(au.last_name) NOT LIKE '%test%' AND LOWER(au.username) NOT LIKE '%test%' AND LOWER(au.email) NOT LIKE '%test%')

    ORDER BY b.id
    -- LIMIT 1