SELECT * FROM myproject.rental_cat LIMIT 10;

SELECT * FROM myproject.rental_cat;

SELECT DISTINCT cat_name FROM myproject.rental_cat ORDER BY 1 ASC;

SELECT DISTINCT cat_desc FROM myproject.rental_cat ORDER BY 1 ASC;

-- LEFT JOIN (SELECT id, car_name,cat_id FROM rental_cars_available) AS car ON r.car_available_id = car.id
--     left join ( select id,cat_name from rental_cat) as cat on car.cat_id = cat.id