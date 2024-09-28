-- SET @extension_id = '250964';
SET @extension_id = '267093'; -- only should have been charged 2 days; rental ended late due to vendor issue
-- Using multiple SET statements
SET @extension_id1 = '257685'; -- legit $40 extension discont
SET @extension_id2 = '244042'; -- legit $115 extension discount & $100 initial discount
SET @extension_id3 = '240885'; -- legit $172 extension discount 
SET @extension_id4 = '241700'; -- not an extension
SET @extension_id4 = '241916'; -- not an extension
SET @extension_id5 = '245544'; -- negative less extension charge; adjusted date formula to Y-M-D
SET @extension_id6 = '247185'; -- discount applied within 24 hours; don't consider extension discount
SET @extension_id7 = '247214'; -- legit extension discount; comment doesn't include extension
SET @extension_id8 = '267093'; -- only should have been charged 2 days; rental ended late due to vendor issue

-- #1) GET RENTAL CHARGES HISTORY
SELECT
    *
FROM
    myproject.rental_charges
    -- WHERE booking_id IN ("257685")
WHERE
    booking_id IN (@extension_id)
ORDER BY
    booking_id,
    from_date,
    charge_type_id
LIMIT
    200;

-- #2) ROLLUP = SELECT ONLY IDS WITH CHARGE TYPE 14
SELECT
    rc.booking_id,
    min_date.min_created_date,
    count(rc.booking_id) AS count_of_discount_ids,
    SUM(rc.total_charge) AS extension_discount,
    (
        SELECT
            SUM(total_charge)
        FROM
            myproject.rental_charges as src
        WHERE
            charge_type_id IN (14)
            AND rc.booking_id = src.booking_id
    ) AS total_discount
FROM
    myproject.rental_charges rc
    JOIN (
        SELECT
            booking_id,
            DATE_FORMAT(MIN(created_on), '%Y-%m-%d') as min_created_date
        FROM
            myproject.rental_charges
            -- WHERE
            -- created_on >= '2024-01-01'
            -- AND charge_type_id IN (14)
        GROUP BY
            booking_id
        ORDER BY
            booking_id
    ) AS min_date ON rc.booking_id = min_date.booking_id
WHERE
    -- created_on >= '2024-01-01'
    rc.booking_id IN (@extension_id1, @extension_id2, @extension_id3, @extension_id4, @extension_id5, @extension_id6, @extension_id7, @extension_id8)
    AND rc.charge_type_id IN (14)
    -- if created on date for discount > min_date plus 1 day
    AND DATE_FORMAT(rc.created_on, '%Y-%m-%d') > DATE_FORMAT(DATE_ADD(min_date.min_created_date, INTERVAL 1 DAY), '%Y-%m-%d')
GROUP BY
    rc.booking_id,
    min_date.min_created_date
ORDER BY
    rc.booking_id,
    rc.charge_type_id,
    rc.created_on;

-- #3) ROLLUP = RETURN ONLY THE EXTENSION DISCOUNT
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
    rc.booking_id IN (@extension_id)
    AND rc.charge_type_id IN (14)
    -- if created on date for discount > min_date plus 1 day
    AND DATE_FORMAT(rc.created_on, '%Y-%m-%d') > DATE_FORMAT(DATE_ADD(min_date.min_created_date, INTERVAL 1 DAY), '%Y-%m-%d');

-- #4) ROLLUP = RETURN ONLY THE TOTAL DISCOUNT
SELECT
    SUM(rc.total_charge) AS total_discount
FROM
    myproject.rental_charges rc
WHERE
    rc.booking_id IN (@extension_id)
    AND rc.charge_type_id IN (14);

-- *****************************************
-- OTHER DISCOVERY MOSTLY ON COMMENT WITH EXTENSION (BUT DIDN'T WORK VERY WELL TO CAPTURE ALL DISCOUNT)
-- *****************************************
-- -- SELECT ONLY IDS WITH CHARGE TYPE 14 and COMMENT CONTAINS EXTENSION
-- SELECT 
--     *, booking_id
-- FROM
--     myproject.rental_charges
-- WHERE
--     -- booking_id IN ('257685')
--     created_on >= '2024-01-01'
--     -- AND comments LIKE '%extension%'
--     AND comments LIKE '%2 weeks%'
--     AND charge_type_id IN (14)
-- ORDER BY booking_id, charge_type_id, created_on;
-- -- LIMIT 200;
-- -- IDENTIFY DISTINCT COMMENTS
-- SELECT 
--     DISTINCT comments,
--     SUM(total_charge)
-- FROM
--     myproject.rental_charges
-- WHERE
--     created_on >= '2024-01-01'
--     AND charge_type_id IN (14)
-- GROUP BY comments
-- ORDER BY comments;
-- -- LIMIT 200;
-- -- IDENTIFY DISTINCT COMMENTS WITH EXTENSION
-- SELECT 
--     DISTINCT comments,
--     SUM(total_charge)
-- FROM
--     myproject.rental_charges
-- WHERE
--     created_on >= '2024-01-01'
--     AND comments LIKE '%extension%'
--     AND charge_type_id IN (14)
-- GROUP BY comments
-- ORDER BY comments;
-- -- LIMIT 200;
-- -- ROLLUP = SELECT ONLY IDS WITH CHARGE TYPE 14 and COMMENT CONTAINS EXTENSION
-- SELECT 
--     booking_id, 
--     charge_type_id, 
--     COUNT(charge_type_id) AS count_charge_type,
--     SUM(total_charge)
-- FROM
--     myproject.rental_charges
-- WHERE
--     created_on >= '2024-01-01'
--     AND comments LIKE '%extension%'
--     AND charge_type_id IN (14)
-- GROUP BY booking_id, charge_type_id
-- ORDER BY booking_id, charge_type_id, created_on;