CREATE SCHEMA IF NOT EXISTS ECONOMY; #creating and using a schema
USE ECONOMY;

CREATE TABLE IF NOT EXISTS merchants( #creating the merchant table
mid INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(2)
);

#insertion of data
INSERT INTO merchants(name, city, state)
VALUES
('Amazon', 'Philadelphia', 'PA'),
('Ebay', 'Camden', 'NJ'),
('NewEgg', 'Philadelphia', 'PA'),
('BestBuy Halloween', 'Denvor', 'CO'),
('Acer', 'Philadelphia', 'PA'),
('Gamestop', 'Modesto', 'CA'),
('HP', 'Pinehurst', 'TX'),
('Fios', 'Lancaster', 'PA'),
('Xfinfity', 'Richmond', 'VA');

#creating the products table
CREATE TABLE IF NOT EXISTS products(
pid INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50),
category VARCHAR(50),
description VARCHAR(255)
);

#insertion of data
INSERT INTO products(name, category, description)
VALUES
('Printer', 'Computer', 'A device that prints virtual images on pieces of paper'),
('Ethernet Adapter', 'Network', 'Converts Ethernet wire into USB-A wired connection'),
('Desktop', 'Computer', 'A stand-alone computer, usually really powerful but requires a keyboard, a mouse, and monitor'),
('Hard Drive', 'Computer', 'Either an SSD or HDD, used to store data in either Desktops or Laptops'),
('Router', 'Networking', 'Used for generating Wi-Fi connections for computers, usually requires a membership'),
('Network Card', 'Networking', 'A card for computers that allows to send and recieve Wi-Fi connections'),
('Super Drive', 'Computer', 'A drive that allows for DVD/CDs to be inserted into and accessed via a computer'),
('Laptop', 'Computer', 'A computer that comes built in with a monitor, a mouse-like pad known a s a trackpad, and a keyboard!'),
('Monitor', 'Peripheral', 'A screen that can be attached to a computer to gain visual access to either a Desktop or a Laptop');

#creating the sell table
CREATE TABLE IF NOT EXISTS sell(
mid INT UNSIGNED,
pid INT UNSIGNED,
price INT UNSIGNED,
quantity_available INT UNSIGNED,
FOREIGN KEY (mid) REFERENCES merchants(mid),
FOREIGN KEY (pid) REFERENCES products(pid)
);

#insertion of data
INSERT INTO sell(mid, pid, price, quantity_available)
VALUES
(1, 1, 200, 0),
(2, 2, 30, 20),
(3, 3, 1865, 3),
(4, 4, 50, 26),
(5, 5, 100, 12),
(6, 6, 40, 34),
(7, 7, 29, 4),
(8, 8, 799, 17),
(9, 9, 649, 43);

#creating the orders table
CREATE TABLE IF NOT EXISTS orders(
oid INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
shipping_method VARCHAR(50),
shipping_cost INT UNSIGNED
);

#insertion of data
INSERT INTO orders(shipping_method, shipping_cost)
VALUES
('UPS', 50),
('FedEx', 40),
('USPS', 90);

#creating the contain table
CREATE TABLE IF NOT EXISTS contain(
oid INT UNSIGNED,
pid INT UNSIGNED,
FOREIGN KEY (oid) REFERENCES orders(oid),
FOREIGN KEY (pid) REFERENCES products(pid)
);

#insertion of data
INSERT INTO contain (oid, pid)
SELECT o.oid, p.pid
FROM orders o
CROSS JOIN products p;

#creating the customers table
CREATE TABLE IF NOT EXISTS customers(
cid INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
fullname VARCHAR(50),
city VARCHAR(50),
state VARCHAR(2)
);

#insertion of data
INSERT INTO customers(fullname, city, state)
VALUES
('Breanne Nunn', 'Camden', 'NJ'),
('Andrew Navaroli', 'York', 'PA'),
('Uriel Whitney', 'Red Lion', 'PA');

#creating the place table
CREATE TABLE IF NOT EXISTS place(
cid INT UNSIGNED,
oid INT UNSIGNED,
order_date DATE,
FOREIGN KEY (oid) REFERENCES orders(oid),
FOREIGN KEY (cid) REFERENCES customers(cid)
);

INSERT INTO place (cid, oid, order_date)
SELECT c.cid, o.oid, d.order_date
FROM customers c
JOIN orders o ON o.oid IN (1, 2, 3, 4, 5, 6, 7, 8, 9)  -- Ensure you have valid oids
JOIN (
    SELECT '2024-09-14' AS order_date UNION ALL
    SELECT '2024-02-16' UNION ALL
    SELECT '2024-06-22' UNION ALL
    SELECT '2023-04-21' UNION ALL
    SELECT '2023-01-12' UNION ALL
    SELECT '2023-02-04' UNION ALL
    SELECT '2022-04-03' UNION ALL
    SELECT '2021-07-14' UNION ALL
    SELECT '2022-12-25'
) AS d ON d.order_date IS NOT NULL;  -- Use your own logic to match order dates if needed
##############################################
#Queries
#1
SELECT p.name AS product_name, m.name AS seller_name #selecting product and seller names from respective tables
FROM products p
JOIN sell s ON p.pid = s.pid  #Inner joining the ids between sell and products
JOIN merchants m ON s.mid = m.mid #Inner joining the ids between sell and merchants
WHERE s.quantity_available = 0; #then checking if the quantity available IS 0.


#2
SELECT p.name, p.description #selecting name and description from products
FROM products p 
LEFT JOIN sell s ON p.pid = s.pid #Inner joining the ids between sell and products
WHERE s.pid IS NULL; #Checking if sells id is null to see if the item WAS sold.

#3
SELECT COUNT(DISTINCT c.cid) AS customer_count #getting the total count of customers
FROM customers c
JOIN place pl ON c.cid = pl.cid #Inner joining ids between place and customers
JOIN contain co ON pl.oid = co.oid #Inner joining ids between contain and place
JOIN products p1 ON co.pid = p1.pid #Inner joining ids between  place and contain
WHERE p1.name LIKE '%Hard Drive%'  #Checking to see if products name after comparison is Hard Drive
AND c.cid NOT IN ( #specifically implying that this condtion should NOT be met.
  SELECT c2.cid #selecting customers again
  FROM customers c2
  JOIN place pl2 ON c2.cid = pl2.cid #essentially doing the same from above
  JOIN contain co2 ON pl2.oid = co2.oid
  JOIN products p2 ON co2.pid = p2.pid 
  WHERE p2.name LIKE '%Router%' #this time, we are looking for products named Router, and if so, unselecting this customer.
);

#4
UPDATE sell s #selecting sells table
JOIN products p ON s.pid = p.pid #Inner joining ids between products and sell
SET s.price = s.price * 0.80 #Giving the price a 20% discount
WHERE p.category = 'Networking' AND p.name LIKE '%HP%'; #If the item is HP and is a networking item

#5
SELECT p.name AS product_name, s.price AS product_price #selecting Customers name and sell price
FROM customers c
JOIN place pl ON c.cid = pl.cid  # Inner joining ids between place and customers
JOIN contain co ON pl.oid = co.oid #Inner joining ids between contain and place
JOIN products p ON co.pid = p.pid  #Inner joining ids between products and contain
JOIN sell s ON p.pid = s.pid  #Inner joining ids between products and sell
JOIN merchants m ON s.mid = m.mid  #Inner joining ids between merchants and sell
WHERE c.fullname = 'Uriel Whitney' AND m.name LIKE '%Acer%';  # We then filter by Euriel Whitne, the customer, and Acer the merchant

#6
SELECT m.name AS company_name, YEAR(pl.order_date) AS year, SUM(s.price) * COUNT(DISTINCT pl.oid) AS total_sales #selecting the needed tables
FROM merchants m 
JOIN sell s ON m.mid = s.mid #Inner joining Sell and Merchant IDs
JOIN contain co ON s.pid = co.pid #Inner joining place and contain IDs
JOIN place pl ON co.oid = pl.oid #Inner joining place and contain IDs
GROUP BY m.name, YEAR(pl.order_date); #grouping by the merchants name and the year of order

#7
SELECT m.name AS company_name, YEAR(pl.order_date) AS year, SUM(s.price * s.quantity_available) AS total_sales
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN contain co ON s.pid = co.pid
JOIN place pl ON co.oid = pl.oid
GROUP BY m.name, YEAR(pl.order_date)
ORDER BY total_sales DESC #same as above but order by highest sales and limit by 1.
LIMIT 1;

#8
SELECT shipping_method, AVG(shipping_cost) AS avg_shipping_cost # Selecting respective tables
FROM orders
GROUP BY shipping_method #groups shipping methods together
ORDER BY avg_shipping_cost #then order them by the cheapest shipping cost
LIMIT 1; #limit 1 to finalize our answer

#9
SELECT m.name AS company_name, p.category, SUM(s.price * s.quantity_available) AS total_sales
FROM merchants m
JOIN sell s ON m.mid = s.mid #Inner Joining sell and merchants
JOIN products p ON s.pid = p.pid #Innerjoining products and sell
GROUP BY m.name, p.category #group each company with the category
ORDER BY total_sales DESC;	#ordering by high to low

#10
WITH CustomerSpending AS (
  SELECT m.name AS company_name, c.fullname AS customer_name, SUM(s.price * s.quantity_available) AS total_spent
  FROM merchants m
  JOIN sell s ON m.mid = s.mid
  JOIN contain co ON s.pid = co.pid
  JOIN place pl ON co.oid = pl.oid
  JOIN customers c ON pl.cid = c.cid
  GROUP BY m.name, c.fullname
)
SELECT company_name, customer_name, total_spent
FROM CustomerSpending
WHERE total_spent = (SELECT MIN(total_spent) FROM CustomerSpending)
   OR total_spent = (SELECT MAX(total_spent) FROM CustomerSpending)
ORDER BY company_name;
