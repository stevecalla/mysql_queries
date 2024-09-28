DROP DATABASE IF EXISTS mydb_store_arabic_char;

CREATE DATABASE IF NOT EXISTS mydb_store_arabic_char;

USE mydb_store_arabic_char;

CREATE TABLE IF NOT EXISTS `categories` (
  `category_id` tinyint(2) NOT NULL AUTO_INCREMENT,
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`category_id`)
);

INSERT INTO `categories` (`category_id`, `category_name`) VALUES (1, 'کتگوری');

SELECT * FROM mydb_store_arabic_char.categories;