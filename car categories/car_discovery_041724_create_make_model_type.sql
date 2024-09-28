USE myproject;
SET @str_date = '2017-01-01',@end_date = '2024-12-31';

-- THE PURPOSE OF THIS QUERY IS TO CREATE MAKE, MODEL, MAKE/MODEL AND CAR TYPE FROM EXISTING REFERENCE DATA
SELECT 
	DISTINCT(ca.car_name) AS ca_available_car_name,
	count(*),

	-- CREATE CAR MAKE, MODEL
	CASE 
		WHEN ca.car_name LIKE '%coming soon%'  THEN 'not applicable' 
		WHEN ca.car_name LIKE '%test%'  THEN 'not applicable' 

		WHEN ca.car_name LIKE '%altima%' THEN 'Nissan'
		WHEN ca.car_name LIKE '%attrage%' THEN 'Mitsubishi'
		WHEN ca.car_name LIKE '%aqua%' THEN 'Toyota'
		WHEN ca.car_name LIKE '%corolla%' THEN 'Toyota'
		WHEN ca.car_name LIKE '%Ecosport%' THEN 'Ford'
		WHEN ca.car_name LIKE '%figo%' THEN 'Ford'
		WHEN ca.car_name LIKE '%kicks%' THEN 'Nissan'
		WHEN ca.car_name LIKE '%micra%' THEN 'Nissan'
		WHEN ca.car_name LIKE '%OUTLANDER 2.4L%' THEN 'Mitsubishi'
		WHEN ca.car_name LIKE '%OUTLANDER 2.5L%' THEN 'Mitsubishi'
		WHEN ca.car_name LIKE '%Outlander GLX%' THEN 'Mitsubishi'
		WHEN ca.car_name LIKE '%pajero%' THEN 'Mitsubishi Pajero'
		WHEN ca.car_name LIKE '%patrol%' THEN 'Nissan Patrol'
		WHEN ca.car_name LIKE '%QX 70%' THEN 'Infinity'
		WHEN ca.car_name LIKE '%sentra%' THEN 'Nissan'
		WHEN ca.car_name LIKE '%skoda kushaq%' THEN 'Skoda'
		WHEN ca.car_name LIKE '%sorento%' THEN 'Kia'
		WHEN ca.car_name LIKE '%spark%' THEN 'Chevrolet'
		WHEN ca.car_name LIKE '%sunny%' THEN 'Nissan'
		WHEN ca.car_name LIKE '%symbol%' THEN 'Renualt'
		WHEN ca.car_name LIKE '%Tesla  X%' THEN 'Tesla'
		WHEN ca.car_name LIKE '%Tesla Model 3%' THEN 'Tesla'
		WHEN ca.car_name LIKE '%Tesla Model Y%' THEN 'Tesla'
		WHEN ca.car_name LIKE '%xpander cross%' THEN 'Mitsubishi'
		WHEN ca.car_name LIKE '%Xtrail%' THEN 'Nissan'
		WHEN ca.car_name LIKE '%X Trail%' THEN 'Nissan'
		WHEN ca.car_name LIKE '%yaris%' THEN 'Toyota'

		WHEN ca.car_name LIKE '%-turbo%' THEN REPLACE(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), '-Turbo', '')
		WHEN ca.car_name LIKE '%-manual%' THEN REPLACE(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), '-Manual', '')
		WHEN ca.car_name LIKE '%/Similar CC_Old%' THEN REPLACE(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), '/Similar CC_Old', '')
		WHEN ca.car_name LIKE '%/Similar_Old%' THEN REPLACE(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), '/Similar_Old', '')
		WHEN ca.car_name LIKE '%_Old%' THEN REPLACE(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), '_Old', '')
		WHEN ca.car_name LIKE  '% -%' THEN REPLACE(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' -', '')

		ELSE TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1))
	END AS car_make,

	CASE 
		WHEN ca.car_name LIKE '%coming soon%'  THEN 'not applicable' 
		WHEN ca.car_name LIKE '%test%'  THEN 'not applicable' 

		WHEN ca.car_name LIKE '%altima%' THEN 'Altima'
		WHEN ca.car_name LIKE '%attrage%' THEN 'Attrage'
		WHEN ca.car_name LIKE '%aqua%' THEN 'Aqua'
		WHEN ca.car_name LIKE '%corolla%' THEN 'Corolla'
		WHEN ca.car_name LIKE '%Ecosport%' THEN 'Ecosports'
		WHEN ca.car_name LIKE '%figo%' THEN 'Figo'
		WHEN ca.car_name LIKE '%kicks%' THEN 'Kicks'
		WHEN ca.car_name LIKE '%micra%' THEN 'Micra'
		WHEN ca.car_name LIKE '%OUTLANDER 2.4L%' THEN 'Outlander 2.4L'
		WHEN ca.car_name LIKE '%OUTLANDER 2.5L%' THEN 'Outlander 2.5L'
		WHEN ca.car_name LIKE '%Outlander GLX%' THEN 'Outlander GLX'
		WHEN ca.car_name LIKE '%pajero%' THEN 'Pajero'
		WHEN ca.car_name LIKE '%patrol%' THEN 'Patrol'
		WHEN ca.car_name LIKE '%QX 70%' THEN 'QX70'
		WHEN ca.car_name LIKE '%sentra%' THEN 'Sentra'
		WHEN ca.car_name LIKE '%skoda kushaq%' THEN 'Kushaq'
		WHEN ca.car_name LIKE '%sorento%' THEN 'Sorento'
		WHEN ca.car_name LIKE '%spark%' THEN 'Spark'
		WHEN ca.car_name LIKE '%sunny%' THEN 'Sunny'
		WHEN ca.car_name LIKE '%symbol%' THEN 'Symbol'
		WHEN ca.car_name LIKE '%Tesla  X%' THEN 'Model X'
		WHEN ca.car_name LIKE '%Tesla Model 3%' THEN 'Model 3'
		WHEN ca.car_name LIKE '%Tesla Model Y%' THEN 'Model Y'
		WHEN ca.car_name LIKE '%xpander cross%' THEN 'Xpander Cross'
		WHEN ca.car_name LIKE '%Xtrail%' THEN 'X Trail'
		WHEN ca.car_name LIKE '%X Trail%' THEN 'X Trail'
		WHEN ca.car_name LIKE '%yaris%' THEN 'Toyota Yaris'

		WHEN ca.car_name LIKE '%-turbo%' THEN REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1)), '-Turbo', '')
		WHEN ca.car_name LIKE '%-manual%' THEN REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1)), '-Manual', '')
		WHEN ca.car_name LIKE '%/Similar CC_Old%' THEN REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1)), '/Similar CC_Old', '')
		WHEN ca.car_name LIKE '%/Similar_Old%' THEN REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1)), '/Similar_Old', '')
		WHEN ca.car_name LIKE '%_Old%' THEN REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1)), '_Old', '')
		WHEN ca.car_name LIKE  '% -%' THEN REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1)), ' -', '')

		ELSE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1))
	END AS car_model,

	CASE 
		WHEN ca.car_name LIKE '%coming soon%'  THEN 'not applicable' 
		WHEN ca.car_name LIKE '%test%'  THEN 'not applicable' 

		WHEN ca.car_name LIKE '%altima%' THEN 'Nissan Altima'
		WHEN ca.car_name LIKE '%attrage%' THEN 'Mitsubishi Attrage'
		WHEN ca.car_name LIKE '%aqua%' THEN 'Toyota Aqua'
		WHEN ca.car_name LIKE '%corolla%' THEN 'Toyota Corolla'
		WHEN ca.car_name LIKE '%Ecosport%' THEN 'Ford Ecosports'
		WHEN ca.car_name LIKE '%figo%' THEN 'Ford Figo'
		WHEN ca.car_name LIKE '%kicks%' THEN 'Nissan Kicks'
		WHEN ca.car_name LIKE '%micra%' THEN 'Nissan Micra'
		WHEN ca.car_name LIKE '%OUTLANDER 2.4L%' THEN 'Mitsubishi Outlander 2.4L'
		WHEN ca.car_name LIKE '%OUTLANDER 2.5L%' THEN 'Mitsubishi Outlander 2.5L'
		WHEN ca.car_name LIKE '%Outlander GLX%' THEN 'Mitsubishi Outlander GLX'
		WHEN ca.car_name LIKE '%pajero%' THEN 'Mitsubishi Pajero'
		WHEN ca.car_name LIKE '%patrol%' THEN 'Nissan Patrol'
		WHEN ca.car_name LIKE '%QX 70%' THEN 'Infinity QX70'
		WHEN ca.car_name LIKE '%sentra%' THEN 'Nissan Sentra'
		WHEN ca.car_name LIKE '%skoda kushaq%' THEN 'Skoda Kushaq'
		WHEN ca.car_name LIKE '%sorento%' THEN 'Kia Sorento'
		WHEN ca.car_name LIKE '%spark%' THEN 'Chevrolet Spark'
		WHEN ca.car_name LIKE '%sunny%' THEN 'Nissan Sunny'
		WHEN ca.car_name LIKE '%symbol%' THEN 'Renualt Symbol'
		WHEN ca.car_name LIKE '%Tesla  X%' THEN 'Tesla Model X'
		WHEN ca.car_name LIKE '%Tesla Model 3%' THEN 'Tesla Model 3'
		WHEN ca.car_name LIKE '%Tesla Model Y%' THEN 'Tesla Model Y'
		WHEN ca.car_name LIKE '%xpander cross%' THEN 'Mitsubishi Xpander Cross'
		WHEN ca.car_name LIKE '%Xtrail%' THEN 'Nissan X Trail'
		WHEN ca.car_name LIKE '%X Trail%' THEN 'Nissan X Trail'
		WHEN ca.car_name LIKE '%yaris%' THEN 'Toyota Yaris'
		
		WHEN ca.car_name LIKE '%-turbo%' THEN REPLACE(CONCAT(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' ', TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1))), '-Turbo', '')
		WHEN ca.car_name LIKE '%-manual%' THEN REPLACE(CONCAT(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' ', TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1))), '-Manual', '')
		WHEN ca.car_name LIKE '%/Similar CC_Old%' THEN REPLACE(CONCAT(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' ', TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1))), '/Similar CC_Old', '')
		WHEN ca.car_name LIKE '%/Similar_Old%' THEN REPLACE(CONCAT(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' ', TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1))), '/Similar_Old', '')
		WHEN ca.car_name LIKE '%_Old%' THEN REPLACE(CONCAT(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' ', TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1))), '_Old', '')
		WHEN ca.car_name LIKE  '% -%' THEN REPLACE(CONCAT(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' ', TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1))), ' -', '')

		ELSE CONCAT(TRIM(SUBSTRING_INDEX(ca.car_name, ' ', 1)), ' ', TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ca.car_name, ' ', 2), ' ', -1)))
	END AS car_make_model,

	-- CREATE CAR TYPE (i.e. sedan, suv et al)
	-- cat.cat_name AS cat_car_cat_name, -- USED TO CONSTRUCT THE car_type BELOW
	CASE
	
		WHEN ca.car_name LIKE '%coming soon%'  THEN 'not applicable' 
		WHEN ca.car_name LIKE '%test%'  THEN 'not applicable' 

		-- SPECIFIC cat.cat_name
		WHEN cat.cat_name LIKE '%suv%' THEN 'SUV'
		WHEN cat.cat_name LIKE '%sedan%' THEN 'Sedan'
		WHEN cat.cat_name LIKE '%van%' THEN 'Van'
		WHEN cat.cat_name LIKE '%7 Seater%' THEN 'SUV'
		WHEN cat.cat_name LIKE '%hatchback' THEN 'Hatchback'

		-- USE ca.car_name
		WHEN ca.car_name LIKE '%Aston Martin%' THEN 'Sedan'
		WHEN ca.car_name LIKE '%attrage%' THEN 'Hatchback'
		WHEN ca.car_name LIKE '%a3%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%a4%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%a5%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%a6%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%a8%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%q7%'  THEN 'SUV'
		WHEN ca.car_name LIKE '%q8%'  THEN 'SUV'
		WHEN ca.car_name LIKE '%bmw 4%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%bmw 5%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%bmw 7%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%bmw x%'  THEN 'SUV'
		WHEN ca.car_name LIKE '%Chevrolet Camaro%' THEN 'Sport'
		WHEN ca.car_name LIKE '%Chevrolet Captiva%' THEN 'SUV'
		WHEN ca.car_name LIKE '%dodge charger%'  THEN 'Sedan'
		WHEN ca.car_name LIKE '%ecosport%'  THEN 'SUV'
		WHEN ca.car_name LIKE '%Fiat 500%' THEN 'Hatchback'
		WHEN ca.car_name LIKE '%Hilux Revo%' THEN 'Pickup Truck'
		WHEN ca.car_name LIKE '%Hongqi H9%'  THEN 'Sedan' 
		WHEN ca.car_name LIKE '%Hyundai i10%' THEN 'Hatchback'
        WHEN ca.car_name LIKE '%Lamborghini%' THEN 'Sports Car'
		WHEN ca.car_name LIKE '%Land Rover Defende%'  THEN 'SUV'
        WHEN ca.car_name LIKE '%Mercedes%' AND (ca.car_name LIKE '%C%' OR ca.car_name LIKE '%S%') THEN 'Sedan'
        WHEN ca.car_name LIKE '%Mercedes%' AND (ca.car_name LIKE '%G%' OR ca.car_name LIKE '%GL%') THEN 'SUV'
		WHEN ca.car_name LIKE '%MG-5%' THEN 'Hatchback'
        WHEN ca.car_name LIKE '%Mini%' THEN 'Hatchback'
		WHEN ca.car_name LIKE '%mustang%'  THEN 'Sport'
        WHEN ca.car_name LIKE '%Nissan Patrol%' OR ca.car_name LIKE '%Toyota Fortuner%' THEN 'SUV'
        WHEN ca.car_name LIKE '%peugeot 508%' THEN 'Sedan'
		WHEN ca.car_name LIKE '%Porsche Cayenne%' THEN 'SUV'
        WHEN ca.car_name LIKE '%Porsche Panamera%' THEN 'Sedan'
        WHEN ca.car_name LIKE '%Porsche Targa%' THEN 'Sport'
        WHEN ca.car_name LIKE '%Range Rover Sports%' THEN 'SUV'
        WHEN ca.car_name LIKE '%Range Rover Velar%' THEN 'SUV'
		WHEN ca.car_name LIKE '%Rolls Royce Cullinan%' THEN 'SUV'
		WHEN ca.car_name LIKE '%SKY Well ET5-EV%' THEN 'SUV'
		WHEN ca.car_name LIKE '%sunny%' THEN 'Sedan'
		WHEN ca.car_name LIKE '%Suzuki Alto%' THEN 'Hatchback'
        WHEN ca.car_name LIKE '%Suzuki Ciaz%' THEN 'Sedan'
        WHEN ca.car_name LIKE '%Tesla Model 3%' THEN 'Sedan'
        WHEN ca.car_name LIKE '%Tesla Model x%' THEN 'Sedan'
        WHEN ca.car_name LIKE '%Tesla  X%' THEN 'Sedan'
        WHEN ca.car_name LIKE '%Tesla Model Y%' THEN 'SUV'
        WHEN ca.car_name LIKE '%Toyota Fortuner%' THEN 'SUV'
        WHEN ca.car_name LIKE '%Toyota Prado%' THEN 'SUV'
        WHEN ca.car_name LIKE '%Yaris%' THEN 'Sedan'

		-- CARS TO ASSIGN TYPE
		WHEN cat.cat_name LIKE '%featured%' THEN 'Needs to be assigned'
		WHEN cat.cat_name LIKE '%luxury%' THEN 'Needs to be assigned'

		ELSE "Other"
	END AS car_type

-- BOOKING INFO
FROM myproject.rental_car_booking2 b
-- USER INFO (USED TO EXCLUDE TEST RENTALS IN THE WHERE CLAUSE)
LEFT JOIN myproject.auth_user au ON au.id = b.owner_id 
-- CAR INFO
LEFT JOIN myproject.rental_cars_available ca ON ca.id = b.car_available_id
LEFT JOIN myproject.rental_car c ON c.id = b.car_id
LEFT JOIN myproject.rental_cat cat ON ca.cat_id = cat.id
-- STATUS INFO
LEFT JOIN myproject.rental_status rs on rs.id = b.status 
WHERE 
	-- FOR USE IN MYSQL WITH VARIABLES IN LINE 1
	DATE(DATE_ADD(b.created_on, INTERVAL 4 HOUR)) BETWEEN @str_date AND @end_date
	-- LOGIC TO EXCLUDE TEST BOOKINGS
	AND COALESCE(b.vendor_id,'') NOT IN (33, 5 , 218, 23086) 
	AND (LOWER(au.first_name) NOT LIKE '%test%' AND LOWER(au.last_name) NOT LIKE '%test%' AND LOWER(au.username) NOT LIKE '%test%' AND LOWER(au.email) NOT LIKE '%test%')
GROUP BY ca.car_name
ORDER BY ca.car_name ASC;
-- LIMIT 5000;