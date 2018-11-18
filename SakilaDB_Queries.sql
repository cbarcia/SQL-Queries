USE sakila;

/*1a. Display the first and last names of all actors from the table actor. */

SELECT 	first_name, last_name
FROM	actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. */

SELECT 	UPPER(CONCAT(first_name, ' , ', last_name)) AS 'Actors'
FROM	actor;

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

/* 2b. Find all actors whose last name contain the letters GEN:*/
SELECT *
FROM	actor
WHERE	last_name LIKE '%GEN%';
/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:*/
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name , first_name;
/* 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan' , 'Bangladesh', 'China');
/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).*/
ALTER TABLE actor
ADD description BLOB;
SELECT *
FROM actor;

/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
ALTER TABLE actor
DROP COLUMN description;
SELECT *
FROM actor;
/* 4a. List the last names of actors, as well as how many actors have that last name.*/
SELECT last_name, 
COUNT(last_name) AS 'Last Name Occurances'
FROM actor
GROUP BY last_name;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
SELECT last_name, 
COUNT(last_name) AS 'Last Name Occurances'
FROM actor
GROUP BY last_name
HAVING COUNT (last_name) >= 2;
/* 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.*/ 
SELECT *
FROM actor
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';
UPDATE actor 
SET first_name = 'HARPO'
WHERE actor_id = 172;
SELECT *
FROM actor
WHERE actor_id = 172;
/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO */
UPDATE actor 
SET first_name = 'GROUCHO'
WHERE actor_id = 172; 
SELECT *
FROM actor
WHERE actor_id = 172; 
/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/
SHOW CREATE TABLE address;
/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:*/

SELECT staff.first_name, staff.last_name, address.address
FROM staff

LEFT JOIN address USING (address_id);
/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. */
SELECT staff.staff_id, staff.first_name, staff.last_name,
FORMAT(SUM(payment.amount), 2) AS 'Sum of Payment'
FROM staff
JOIN payment USING (staff_id)
WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY staff_id;
/*6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join. */
SELECT film.title,
COUNT(film_actor.actor_id) AS '# of actors listed '
FROM film
JOIN film_actor USING (film_id)
GROUP BY title;
/*6d. How many copies of the film Hunchback Impossible exist in the inventory system? */
SELECT f.title, COUNT(i.film_id) AS 'Copies available'
FROM inventory i
JOIN film f USING (film_id)
WHERE f.title = 'Hunchback Impossible';
/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.  List the customers alphabetically by last name: */

SELECT c.customer_id, c.first_name, c.last_name,
FORMAT(SUM(p.amount), 2) AS 'Total Payment Amount'
FROM customer c
JOIN payment p USING (customer_id)
GROUP BY customer_id
ORDER BY last_name ASC;
/*7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
SELECT f.title
FROM film f
WHERE language_id IN (
	SELECT 	language_id					
	FROM	language					
	WHERE	name = 'ENGLISH'
                    )
AND f.title LIKE 'K%' OR f.title LIKE 'Q%';

/* 7b. Use subqueries to display all actors who appear in the film Alone Trip. */

SELECT a.actor_id,
CONCAT(first_name, ' ', last_name) AS 'Actors in film Alone Trip'
FROM actor a
WHERE actor_id IN(
	SELECT 	actor_id				
	FROM	film_actor fa				
	WHERE	film_id IN (
		SELECT 	film_id					
		FROM	film f               
		WHERE	title = 'Alone Trip'
						)
					);

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/
SELECT c.email AS 'Email', c.first_name AS 'First Name', c.last_name AS 'Last Name',country.country AS 'Country'
FROM customer c
JOIN address a ON (c.address_id = a.address_id)
JOIN city ON (a.city_id = city.city_id)
JOIN country ON (city.country_id = country.country_id)
WHERE country.country = 'CANADA';
/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.*/
SELECT f.title, cat.name AS 'Movie Category'
FROM film f
JOIN film_category fc ON (f.film_id = fc.film_id)
JOIN category cat ON (fc.category_id = cat.category_id)
WHERE cat.name = 'family';
/*7e. Display the most frequently rented movies in descending order.*/

SELECT f.title, 
COUNT(f.title) AS 'Rental_Frequency'
FROM film f
JOIN inventory i ON (f.film_id = i.film_id)
JOIN rental r ON (i.inventory_id = r.inventory_id)
GROUP BY f.title
ORDER BY Rental_Frequency DESC;
/* 7f. Write a query to display how much business, in dollars, each store brought in.*/
SELECT s.store_id, 
FORMAT(SUM(amount), 2) AS 'Revenue'
FROM payment p
JOIN staff st ON (p.staff_id = st.staff_id)
JOIN store s ON (st.store_id = s.store_id)
GROUP BY store_id
ORDER BY 	Revenue asc;
/*7g. Write a query to display for each store its store ID, city, and country.*/
SELECT st.store_id, ci.city AS 'City', co.country AS 'Country'
FROM country co
JOIN city ci ON (co.country_id = ci.country_id)
JOIN address a ON (ci.city_id = a.city_id)
JOIN store ON (a.address_id = store.address_id);

/*7h. List the top five genres in gross revenue in descending order.(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT cat.name, 
FORMAT(SUM(amount), 2) AS 'Gross_Revenue'
FROM payment p
JOIN rental r ON (p.rental_id = r.rental_id)
JOIN inventory i ON (r.inventory_id = i.inventory_id)
JOIN film_category fc ON (i.film_id = fc.film_id)
JOIN category cat ON (fc.category_id = cat.category_id)
GROUP BY cat.name
ORDER BY Gross_Revenue desc
LIMIT 5;
/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
DROP VIEW IF EXISTS topFive;
CREATE VIEW topFive AS
SELECT cat.name, FORMAT(SUM(amount), 2) AS 'Gross_Revenue'
FROM payment p
JOIN rental r ON (p.rental_id = r.rental_id)
JOIN inventory i ON (r.inventory_id = i.inventory_id)
JOIN film_category fc ON (i.film_id = fc.film_id)
JOIN category cat ON (fc.category_id = cat.category_id)
GROUP BY cat.name
ORDER BY Gross_Revenue DESC
LIMIT 5;
/* 8b. How would you display the view that you created in 8a?*/
SELECT *
FROM topFive;
/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW IF EXISTS topFive;
SELECT 	*
FROM topFive;