SET  @str_date = '2024-01-01', @end_date = '2024-01-01';
SELECT 
 booking_id,agreement_number
,booking_datetime
,booking_year
,booking_month
,booking_day_of_week
,booking_day_of_week_v2
,booking_time_bucket
,pickup_datetime
,pickup_year
,pickup_month
,pickup_day_of_week
,pickup_day_of_week_v2
,pickup_time_bucket
,return_datetime
,return_year
,return_month
,return_day_of_week
,return_day_of_week_v2
,return_time_bucket
,status
,booking_type
,marketplace_or_dispatch
,marketplace_partner
,marketplace_partner_summary
,booking_channel
,booking_source
,repeated_user
,total_lifetime_booking_revenue
,no_of_bookings
,no_of_cancel_bookings
,no_of_completed_bookings
,no_of_started_bookings
,customer_id
,date_of_birth
,Age
,customer_driving_country
,customer_doc_vertification_status
,days
,extra_day_calc
,myproject.get_rental_rates(tb.booking_id, tb.millage_id, tb.contract_id, tb.drg, tb.wrg, tb.mrg, tb.dr, tb.wr, tb.mr, tb.days, tb.deliver_date_string) * tb.conversion_rate AS customer_rate
,insurance_rate
,insurance_type
,millage_rate
,millage_cap_km
,rent_charge
,extra_day_charge
,delivery_charge
,collection_charge
,additional_driver_charge
,insurance_charge
,intercity_charge
,millage_charge
,other_rental_charge
,discount_charge
,total_vat
,other_charge
,booking_charge
,booking_charge_less_discount
,base_rental_revenue
,non_rental_charge
,extension_charge
,is_extended
,Promo_Code
,promo_code_discount_amount
,promocode_created_date
,promo_code_description
,requested_car
,car_name
,make
,color
,deliver_country
,deliver_city
,delivery_location
,deliver_method
,delivery_lat
,delivery_lng
,collection_location
,collection_method
,collection_lat
,collection_lng
,nps_score
,nps_comment
FROM (
SELECT 
b.id AS booking_id,agreement_number
,b.millage_id, b.contract_id,b.drg,b.wrg,b.mrg, b.dr, b.wr, b.mr
,b.deliver_date_string
,DATE_FORMAT(DATE_ADD(b.created_on ,INTERVAL 4 HOUR), '%W, %M %e, %Y %H:%i') AS booking_datetime
,DATE_FORMAT(DATE_ADD(b.created_on ,INTERVAL 4 HOUR),'%Y') booking_year
,DATE_FORMAT(DATE_ADD(b.created_on ,INTERVAL 4 HOUR),'%m') booking_month
,DATE_FORMAT(DATE_ADD(b.created_on ,INTERVAL 4 HOUR),'%u') booking_day_of_week
,DATE_FORMAT(DATE_ADD(b.created_on ,INTERVAL 4 HOUR),'%W') booking_day_of_week_v2
,DATE_FORMAT(DATE_ADD(b.created_on ,INTERVAL 4 HOUR),'%H') booking_time_bucket
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string,'%d/%m/%Y'), ' ', b.deliver_time_string), '%W, %M %e, %Y %H:%i') AS pickup_datetime
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string,'%d/%m/%Y'), ' ', b.deliver_time_string),'%Y') pickup_year
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string,'%d/%m/%Y'), ' ', b.deliver_time_string),'%m') pickup_month
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string,'%d/%m/%Y'), ' ', b.deliver_time_string),'%u') pickup_day_of_week
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string,'%d/%m/%Y'), ' ', b.deliver_time_string),'%W') pickup_day_of_week_v2
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.deliver_date_string,'%d/%m/%Y'), ' ', b.deliver_time_string),'%H') pickup_time_bucket
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string,'%d/%m/%Y'), ' ', b.return_time_string), '%W, %M %e, %Y %H:%i') AS return_datetime
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string,'%d/%m/%Y'), ' ', b.return_time_string),'%Y') return_year
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string,'%d/%m/%Y'), ' ', b.return_time_string),'%m') return_month
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string,'%d/%m/%Y'), ' ', b.return_time_string),'%u') return_day_of_week
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string,'%d/%m/%Y'), ' ', b.return_time_string),'%W') return_day_of_week_v2
,DATE_FORMAT(CONCAT(STR_TO_DATE(b.return_date_string,'%d/%m/%Y'), ' ', b.return_time_string),'%H') return_time_bucket
,(SELECT status FROM myproject.rental_status rs WHERE rs.id = b.status) AS status,
(CASE 
WHEN b.days < 7 THEN 'daily' 
WHEN b.days > 29 AND is_subscription=1 THEN 'Subscription'
WHEN b.days > 29 THEN 'Monthly'
ELSE 'Weekly' 
END) AS booking_type
,(CASE 
		WHEN b.vendor_id = 234555 THEN 'Dispatch' 
		WHEN b.vendor_id <> 234555 THEN 'MarketPlace'
ELSE 'N/A'
END) AS marketplace_or_dispatch
,(SELECT name FROM myproject.rental_vendors rv WHERE rv.owner_id = b.vendor_id AND b.vendor_id <> 234555) AS marketplace_partner
,(SELECT name FROM myproject.rental_vendors rv WHERE rv.owner_id = b.vendor_id) AS marketplace_partner_summary
,b.platform_generated AS booking_channel

#,(select name FROM myproject.rental_car_booking_source bs WHERE bs.id = b.car_booking_source_id) as booking_source -- CHANGE
, bs.name AS booking_source  -- CHANGE

,''total_lifetime_booking_revenue
,(CASE WHEN (SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id)> 1 THEN 'YES' ELSE 'NO' END) repeated_user
,(SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id) AS no_of_bookings
,(SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id AND bb.status = 8) AS no_of_cancel_bookings
,(SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id AND bb.status = 9) AS no_of_completed_bookings
,(SELECT COUNT(1) FROM myproject.rental_car_booking2 bb WHERE bb.owner_id = b.owner_id AND bb.status NOT IN (8,9)) AS no_of_started_bookings
,b.owner_id AS customer_id
,f.date_of_birth
,TIMESTAMPDIFF(YEAR,STR_TO_DATE(f.date_of_birth,'%d/%m/%Y'),NOW()) Age
,(SELECT name FROM myproject.rental_country ct WHERE ct.code = dl_country) customer_driving_country
,(CASE WHEN f.is_verified > 0 THEN 'YES' ELSE 'NO' END) customer_doc_vertification_status
,b.days
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (30,31)) AS extra_day_calc
,(CASE WHEN b.days < 7 THEN b.DIR WHEN b.days > 29 THEN b.MIR ELSE b.WIR END) AS insurance_rate
,(CASE WHEN (CASE WHEN b.days < 7 THEN b.DIR WHEN b.days > 29 THEN b.MIR ELSE b.WIR END) > 0 THEN 'Full Insurance' ELSE '' END) insurance_type
,(SELECT ad.rate FROM myproject.cars_available_detail ad WHERE ad.car_available_id = b.car_available_id AND ad.millage_id = b.millage_id AND ad.month_id = b.contract_id) millage_rate
,(SELECT name FROM myproject.Allowed_Millage am WHERE am.id = b.millage_id) millage_cap_km
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id = 4) AS rent_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (31,30)) AS extra_day_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id = 11) AS delivery_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id = 3) AS collection_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (21,40) ) AS additional_driver_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (15,36)) AS insurance_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id = 25) AS intercity_charge
,0  AS millage_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id  IN (15,16,17,18,19,23,26,29,32,37,38,39,41,48,49,50,51,52,56,57)) AS other_rental_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id = 14) AS discount_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id = 20) AS total_vat
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (1,2,8,9,13,14,20,22,24,27,28,44,45,46,47)) AS other_charge
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (3,4,11,15,16,17,18,19,21,23,25,26,29,30,31,32,36,37,38,39,40,41,48,49,50,51,52,56,57)) AS booking_charge
,(SELECT SUM(CASE WHEN charge_type_id IN (14) THEN -(total_charge) ELSE (total_charge) END)  FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (3,4,11,15,16,17,18,19,21,23,25,26,29,30,31,32,36,37,38,39,40,41,48,49,50,51,52,56,57,14)) AS booking_charge_less_discount
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN (3,4,11,15,16,17,18,19,21,23,25,26,29,30,31,32,36,37,38,39,40,41,48,49,50,51,52,56,57)) AS base_rental_revenue
,(SELECT SUM(total_charge) FROM myproject.rental_charges cc WHERE cc.booking_id = b.id AND cc.charge_type_id IN  (1,2,8,9,13,14,20,22,24,27,28,44,45,46,47)) AS non_rental_charge
,0  AS extension_charge
,(SELECT CASE WHEN COUNT(1) >= 1 THEN 'YES' ELSE 'NO' END FROM myproject.rental_invoice_details WHERE type = 'Extension' AND booking_id = b.id) AS is_extended
,pc.Promo_Code
,'' promo_code_discount_amount
,DATE_FORMAT(pc.date_created, '%W, %M %e, %Y %H:%i') promocode_created_date
,b.Promo_Code promo_code_description
,ca.car_name requested_car
,c.car_name
,c.make
,c.color
,co.name deliver_country
,rc.name deliver_city
,b.delivery_location
,(CASE WHEN b.self_pickup_status = 1 THEN 'Self' ELSE 'Delivery' END) deliver_method
,b.delivery_location_lat delivery_lat
,b.delivery_location_lng delivery_lng
,b.collection_location
,(CASE WHEN b.self_return_status = 1 THEN 'Self' ELSE 'Collection' END)  collection_method
,b.return_location_lat collection_lat
,b.return_location_lng collection_lng

#,(SELECT rate FROM myproject.rental_rentalfeedback rf WHERE rf.booking_id = b.id order by rf.id desc limit 1)  nps_score -- CHANGE
,ff.rate nps_score -- CHANGE

#,(SELECT ct.conversion_rate FROM myproject.country_conversion_rate ct, myproject.rental_city c WHERE ct.country_id = c.CountryID AND c.id = b.city_id) AS conversion_rate -- CHANGE
,ct.conversion_rate AS conversion_rate -- CHANGE

#,(SELECT comments FROM myproject.rental_rentalfeedback rf WHERE rf.booking_id = b.id order by rf.id desc limit 1) nps_comment -- CHANGE
,ff.comments nps_comment -- CHANGE

FROM myproject.rental_car_booking2 b
INNER JOIN myproject.rental_fuser f ON f.user_ptr_id = b.owner_id
INNER JOIN myproject.rental_city rc ON rc.id = b.city_id
INNER JOIN myproject.rental_country co ON co.id = rc.CountryID
LEFT JOIN myproject.rental_vendors rv ON rv.owner_id = b.vendor_id 
LEFT JOIN myproject.rental_car c ON c.id = b.car_id
LEFT JOIN myproject.rental_cars_available ca ON ca.id = b.car_available_id
LEFT JOIN myproject.rental_add_promo_codes pc ON pc.id = b.Promo_Code_id

LEFT JOIN (SELECT MAX(id),rate,comments,booking_id FROM myproject.rental_rentalfeedback rf GROUP BY booking_id LIMIT 1) ff ON ff.booking_id = b.id -- CHANGE
LEFT JOIN  rental_city ci ON ci.id = b.city_id -- CHANGE
LEFT JOIN country_conversion_rate ct ON ci.CountryID = ct.country_id -- CHANGE
LEFT JOIN rental_car_booking_source bs ON bs.id = b.car_booking_source_id -- CHANGE

WHERE DATE(DATE_ADD(b.created_on,INTERVAL 4 HOUR))BETWEEN @str_date AND @end_date
ORDER BY b.id 
)tb;