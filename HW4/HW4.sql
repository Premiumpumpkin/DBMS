CREATE SCHEMA IF NOT EXISTS homework4;
USE homework4;

#Table Creation
CREATE TABLE IF NOT EXISTS country (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS city (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city VARCHAR(50) NOT NULL,
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

CREATE TABLE IF NOT EXISTS address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(100) NOT NULL,
    address2 VARCHAR(100),
    city_id INT,
    postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE IF NOT EXISTS store (
    store_id INT PRIMARY KEY AUTO_INCREMENT,
    address_id INT,
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE IF NOT EXISTS staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    store_id INT,
    address_id INT,
    active TINYINT(1) DEFAULT 1 CHECK (active IN (0, 1)),
    username VARCHAR(16) NOT NULL,
    password VARCHAR(40),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE IF NOT EXISTS customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    address_id INT,
    active TINYINT(1) DEFAULT 1 CHECK (active IN (0, 1)),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE IF NOT EXISTS category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name ENUM('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music') NOT NULL
);

CREATE TABLE IF NOT EXISTS language (
    language_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS film (
    film_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year YEAR,
    language_id INT,
    rental_duration TINYINT UNSIGNED CHECK (rental_duration BETWEEN 2 AND 8),
    rental_rate DECIMAL(4, 2) CHECK (rental_rate BETWEEN 0.99 AND 6.99),
    length SMALLINT UNSIGNED CHECK (length BETWEEN 30 AND 200),
    replacement_cost DECIMAL(5, 2) CHECK (replacement_cost BETWEEN 5.00 AND 100.00),
    rating ENUM('PG', 'G', 'NC-17', 'PG-13', 'R'),
    special_features SET('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers'),
    FOREIGN KEY (language_id) REFERENCES language(language_id)
);

CREATE TABLE IF NOT EXISTS actor (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL
);

CREATE TABLE IF NOT EXISTS film_actor (
    actor_id INT,
    film_id INT,
    PRIMARY KEY (actor_id, film_id),
    FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id)
);

CREATE TABLE IF NOT EXISTS film_category (
    film_id INT,
    category_id INT,
    PRIMARY KEY (film_id, category_id),
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    film_id INT,
    store_id INT,
    FOREIGN KEY (film_id) REFERENCES film(film_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

CREATE TABLE IF NOT EXISTS rental (
    rental_id INT PRIMARY KEY AUTO_INCREMENT,
    rental_date DATETIME NOT NULL,
    inventory_id INT,
    customer_id INT,
    return_date DATETIME,
    staff_id INT,
    UNIQUE (rental_date, inventory_id),
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE IF NOT EXISTS payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    staff_id INT,
    rental_id INT,
    amount DECIMAL(5, 2) CHECK (amount >= 0),
    payment_date DATETIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
);

#Queriers
#1
SELECT c.name AS category,
AVG(f.length) AS avg_length #getting average length of films
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id # joining the film id with the film category
JOIN category c ON fc.category_id = c.category_id #joining the category id with the film category
ORDER BY c.name; #ordering alphabetically

#2
WITH category_avg_length AS (
    SELECT c.name AS category,
	AVG(f.length) AS avg_length
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id #same thing as above in querery 1, just priming the data
    GROUP BY c.name
)
SELECT category, avg_length
FROM category_avg_length
WHERE avg_length = (SELECT MAX(avg_length) FROM category_avg_length) OR avg_length = (SELECT MIN(avg_length) FROM category_avg_length);  #here we look at the highest and the lowest avergage length of each category

#3
SELECT cu.customer_id, cu.first_name, cu.last_name
FROM customer cu
JOIN rental r ON cu.customer_id = r.customer_id #joining customers, inventory, and film categories together to validate them
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Action' AND cu.customer_id NOT IN( #essentially checking for action movies rented and NOT comedy/classics
	SELECT cu2.customer_id #below is just the same thing up top just doing the opposite (making sure customers do NOT have comedy or classics movies rented)
    FROM customer cu2
    JOIN rental r2 ON cu2.customer_id = r2.customer_id
    JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
    JOIN film_category fc2 ON i2.film_id = fc2.film_id
    JOIN category c2 ON fc2.category_id = c2.category_id
    WHERE c2.name IN ('Comedy', 'Classics')
    );

#4
SELECT a.actor_id, a.first_name, a.last_name, COUNT(*) AS film_count #counting the amount of times an actor appears period.
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id 
JOIN film f ON fa.film_id = f.film_id
JOIN language l ON f.language_id = l.language_id
WHERE l.name = 'English' #filtering for movies to be English language
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY film_count DESC #ordering by most appearances
LIMIT 1; #showing ONLY the most appeared actor.

#5
SELECT COUNT(DISTINCT i.film_id) AS distinct_movies_10_days #getting a count on all distinct movies
FROM rental r
JOIN staff s ON r.staff_id = s.staff_id
JOIN inventory i ON r.inventory_id = i.inventory_id
WHERE DATEDIFF(r.return_date, r.rental_date) = 10 AND s.first_name = 'Mike'; #this is where we then check to see if rental date - return date is equal to 10 days, and if it was mike who done it.

#6
WITH movie_actor_count AS( #collecting a list of movies with their actor counts
SELECT f.film_id, COUNT(fa.actor_id) AS actor_count
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
	GROUP BY f.film_id
)
SELECT a.first_name, a.last_name #selecting our first name and last name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id = (#This is where we select the film with the highest actor count
	SELECT film_id
    FROM movie_actor_count
    ORDER BY actor_count DESC LIMIT 1 #we Limit to 1 and descending to get essentially our highest acount count here
)
ORDER BY a.first_name, a.last_name; #ordering by alphabetical
