SELECT * FROM myproject.rental_cars_available LIMIT 10;

SELECT * FROM myproject.rental_cars_available WHERE id = 12 OR id = 286 OR id = 480 LIMIT 10;

-- LEFT JOIN (SELECT id, car_name,cat_id FROM rental_cars_available) AS car ON r.car_available_id = car.id
--     left join ( select id,cat_name from rental_cat) as cat on car.cat_id = cat.id

-- SELECT * FROM myproject.rental_cat LIMIT 10;

SELECT DISTINCT cat_id FROM myproject.rental_cars_available ORDER BY cat_id ASC;