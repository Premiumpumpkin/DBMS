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
pid INT UNSIGNED PRIMARY KEY,
name VARCHAR(50),
category VARCHAR(50),
description VARCHAR(255)
);

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