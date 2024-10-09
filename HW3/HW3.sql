CREATE SCHEMA IF NOT EXISTS ECONOMY;
USE ECONOMY;

CREATE TABLE IF NOT EXISTS merchants(
mid INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(2)
);

INSERT INTO merchants(name, city, state)
VALUES
('Paul', 'Philadelphia', 'PA'),
('Michela', 'Camden', 'NJ'),
('Antonio', 'Philadelphia', 'PA'),
('Remi', 'Denvor', 'CO');

CREATE TABLE IF NOT EXISTS products(
pid INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50),
category VARCHAR(50),
description VARCHAR(255)
);

INSERT INTO products(name, category, description)
VALUES
('Printer', 'Computer', 'A device that prints virtual images on pieces of paper'),
('Ethernet Adapter', 'Converts Ethernet wire into USB-A wired connection'),
('Desktop', 'Computer', 'A stand-alone computer, usually really powerful but requires a keyboard, a mouse, and monitor'),
('Hard Drive', 'Computer', 'Either an SSD or HDD, used to store data in either Desktops or Laptops'),
('Router', 'Networking', 'Used for generating Wi-Fi connections for computers, usually requires a membership'),
('Network Card', 'Networking', 'A card for computers that allows to send and recieve Wi-Fi connections')
('Super Drive', 'Computer', 'A drive that allows for DVD/CDs to be inserted into and accessed via a computer'),
('Laptop', 'Computer', 'A computer that comes built in with a monitor, a mouse-like pad known a s a trackpad, and a keyboard!'),
('Monitor', 'Peripheral', 'A screen that can be attached to a computer to gain visual access to either a Desktop or a Laptop');

CREATE TABLE IF NOT EXISTS sell(
mid INT UNSIGNED,
pid INT UNSIGNED,
name VARCHAR(50),
category VARCHAR(50),
state VARCHAR(2),
FOREIGN KEY (mid) REFERENCES merchants(mid),
FOREIGN KEY (pid) REFERENCES merchants(pid)
);

CREATE TABLE IF NOT EXISTS orders(
oid INT UNSIGNED,
shipping_method VARCHAR(50),
shipping_cost INT
);

CREATE TABLE IF NOT EXISTS contain(
oid INT UNSIGNED,
pid INT UNSIGNED,
FOREIGN KEY (oid) REFERENCES orders(oid),
FOREIGN KEY (pid) REFERENCES products(pid)
);

CREATE TABLE IF NOT EXISTS customers(
cid INT UNSIGNED,
fullname VARCHAR(50),
city VARCHAR(50),
state VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS place(
cid INT UNSIGNED,
oid INT UNSIGNED,
order_date DATE
)