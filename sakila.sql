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

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 'Movie'
FROM film
WHERE language_id = (
	SELECT language_id
	FROM language
    WHERE name = "English"
    )
    AND (title LIKE 'K%' OR title LIKE 'Q%')
ORDER BY title;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT concat(first_name, ' ', last_name) AS 'Actors in Alone Trip'
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id = (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
        )
	);
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name AS 'First Name', last_name AS 'Last Name', email AS 'Email'
FROM customer
WHERE address_id IN (
	SELECT address_id
    FROM address
    WHERE city_id IN (
		SELECT city_id
        FROM city
        WHERE country_id = (
			SELECT country_id
            FROM country
            WHERE country = 'Canada'
            )
		)
	);
        

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title AS 'Family Movies'
FROM film
WHERE film_id IN (
	SELECT film_id 
    FROM film_category
    WHERE category_id IN (
		SELECT category_id  
        FROM category
        WHERE UPPER(name) = 'FAMILY'
	)
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title AS 'Movie', count(f.film_id) AS 'Rental_Count'
FROM film f 
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.film_id
ORDER BY Rental_Count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT  s.store_id AS 'Store ID', SUM(p.total_amount) AS 'Total Payment Amount ($)'
FROM staff s
JOIN (
	SELECT SUM(amount) AS total_amount, staff_id
	FROM payment
	GROUP BY staff_id) p 
ON s.staff_id = p.staff_id
GROUP by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS 'Store ID', c.city AS 'City', co.country AS 'Country'
FROM store s
LEFT JOIN address a ON s.address_id = a.address_id
LEFT JOIN city c ON a.city_id = c.city_id
LEFT JOIN country co ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name AS 'Genres', SUM(p.amount) AS 'Revenue'
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY Genres
ORDER BY Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genres_view AS 
SELECT name AS 'Genres', SUM(p.amount) AS 'Revenue'
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY Genres
ORDER BY Revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_5_genres_view;
 
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP view top_5_genres_view;