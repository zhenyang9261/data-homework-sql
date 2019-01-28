USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name AS 'First Name', last_name AS 'Last Name' 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id AS 'ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE first_name = 'Joe';
 
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id AS 'ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id AS 'ID', first_name AS 'First Name', last_name AS 'Last Name'
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id AS 'ID', country AS 'Country'
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China')

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB(300);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name AS 'Last Name', COUNT(last_name) AS 'Count'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name AS 'Last Name', COUNT(last_name) AS 'Count'
FROM actor
GROUP BY last_name
HAVING count(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name='HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name='GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS'

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name AS 'First Name', s.last_name AS 'Last Name', a.address AS 'Address', a.address2 AS 'Address (cont.)'
FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT concat(s.first_name, ' ', s.last_name) AS 'Staff Name', psum.total_amount AS 'Total Amount'
FROM staff s
JOIN (
	SELECT p.staff_id, SUM(p.amount) as 'total_amount'
	FROM (
		SELECT * 
		FROM payment 
		WHERE payment_date >= '2005-08-01' AND payment_date < '2005-08-31'
		) p
	GROUP BY p.staff_id
    ) psum
ON s.staff_id = psum.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title AS 'Film', fa.actor_count AS 'Number of Actors'
FROM film f
INNER JOIN (
	SELECT COUNT(actor_id) as 'actor_count', film_id 
    FROM film_actor 
    GROUP BY film_id
    ) fa
ON f.film_id = fa.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) AS 'Copies of <Hunchback Impossible>'
FROM inventory
WHERE film_id = (
	SELECT film_id
    FROM film
    WHERE title = 'Hunchback Impossible'
    );
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name AS 'First Name', c.last_name AS 'Last Name', psum.total_amount AS 'Total Amount Paid'
FROM customer c
INNER JOIN (
	SELECT sum(amount) as 'total_amount', customer_id 
    FROM payment 
    GROUP BY customer_id
    ) psum
ON c.customer_id = psum.customer_id
ORDER BY c.last_name;


