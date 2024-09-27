#Specifying where the table is stored
USE sakila;
#################################################################################################################################
#1. Avg. price of food at each resturant
SELECT r.name as restaurants_name, AVG(f.price) AS avg_food_price
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name;
#################################################################################################################################
#2. Maximum Food Price at Each Resturant
SELECT r.name as restaurants_name, MAX(f.price) AS max_food_price
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name;
#################################################################################################################################
#3. Count of Different Food Types Served at Each Resturant
SELECT r.name as restaurants_name, COUNT(f.price) AS food_types
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name;
#################################################################################################################################
#4. Average Price of Foods Served by Each Chef
SELECT c.name as chef_name, AVG(f.price) AS avg_food_price
FROM chefs c
JOIN works w ON c.chefID = w.chefID
JOIN serves s ON w.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY c.name;
#################################################################################################################################
#5. Find the Resturant with the Highest Average Food Price
SELECT r.name as restaurants_name, AVG(f.price) AS avg_food_price
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name
ORDER BY avg_food_price DESC
LIMIT 1;
#################################################################################################################################
