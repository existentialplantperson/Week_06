-- WK06 Homework
--Angela Spencer, October 27, 2021

--1.	Show all customers whose last names start with T. Order them by first name from A-Z.
SELECT first_name, last_name    --selecting two columns to show
FROM customer                   -- from the customer table
WHERE last_name LIKE 'T%'       --where last name begins with T
ORDER BY first_name;            --alphabetical order by first name

-----------------------------------------------------------------------------
--2.	Show all rentals returned from 5/28/2005 to 6/1/2005
SELECT *                                --select all columns
FROM rental                             --from rental table
WHERE return_date                       --where return date
BETWEEN '2005-05-28' AND '2005-06-01';  --is between given values

-----------------------------------------------------------------------------
--3.	How would you determine which movies are rented the most?
--select title, and a count of the inventory_id
SELECT f.title, COUNT(r.inventory_id) AS rental_count
--join rental, inventory, and film tables
FROM rental AS r
INNER JOIN inventory as i
	USING (inventory_id)
INNER JOIN film as f
	USING (film_id)
--group by title
GROUP BY f.title
--order by alias of inventory_id count, descending
ORDER BY rental_count DESC;

-----------------------------------------------------------------------------
--4.	Show how much each customer spent on movies (for all time) . Order them from least to most.
--select customer Id and create a new column with the sum of payments 
SELECT customer_id, SUM(amount) AS total_payment 
--from payment table
FROM payment
--group by unique customer id
GROUP BY customer_id
--order by payment amount, ascending
ORDER BY total_payment;

-----------------------------------------------------------------------------
--5.	Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.
--select and alias the first and last name of the actor, count the number of times actor id appears
SELECT first_name AS first, last_name AS last, COUNT(actor_id) AS film_count
--join and alias film_actor and actor tables
FROM film_actor AS f
	INNER JOIN actor AS a
	USING (actor_id)
--group by last and first name
GROUP BY last_name, first_name
--order by  film count, descending
ORDER BY film_count DESC;

-----------------------------------------------------------------------------
--6.	Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to understand how this works http://postgresguide.com/performance/explain.html 
--#4 EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT customer_id, SUM(amount) AS total_payment 
FROM payment
GROUP BY customer_id
ORDER BY total_payment;
--OUTPUT EXPLAIN ANALYZE #4
"Sort  (cost=362.06..363.56 rows=599 width=34) (actual time=16.936..16.990 rows=599 loops=1)"
"  Sort Key: (sum(amount))"
"  Sort Method: quicksort  Memory: 53kB"
"  ->  HashAggregate  (cost=326.94..334.43 rows=599 width=34) (actual time=15.883..16.451 rows=599 loops=1)"
"        Group Key: customer_id"
"        Batches: 1  Memory Usage: 297kB"
"        ->  Seq Scan on payment  (cost=0.00..253.96 rows=14596 width=8) (actual time=0.030..2.504 rows=14596 loops=1)"
"Planning Time: 0.221 ms"
"Execution Time: 17.195 ms"


-----------------------------------------------------------------------------
--7.	What is the average rental rate per genre?
--select the average rental_rate and category name, alias as genre
SELECT AVG(rental_rate) AS avg_rate, name as genre
--join film, film_category, and category_id
FROM film as f
	INNER JOIN film_category as fc
		USING (film_id)
	INNER JOIN category as c
		USING (category_id)
--group by genre
GROUP BY genre
--order by average rental rate, descending
ORDER BY avg_rate;

-----------------------------------------------------------------------------
--8.	How many films were returned late? Early? On time?

--1720 films were returned on the due date
--count all rows
SELECT COUNT(*)
--from film joined to inventory and rental
FROM film as f
	INNER JOIN inventory as i
		USING (film_id)
	INNER JOIN rental as r
		USING (inventory_id)
--select where rental duration = actual return length
--use extract to pull day from two dates
WHERE rental_duration = EXTRACT(DAY FROM return_date-rental_date);

--same code, but rental duration is greater than actual rental time. 7738 movies were returned early.
SELECT COUNT(*)
FROM film as f
	INNER JOIN inventory as i
		USING (film_id)
	INNER JOIN rental as r
		USING (inventory_id)
WHERE rental_duration > EXTRACT(DAY FROM return_date-rental_date);

--same code, but rental duration is less than than actual rental time. 6403 movies were returned late.
SELECT COUNT(*)
FROM film as f
	INNER JOIN inventory as i
		USING (film_id)
	INNER JOIN rental as r
		USING (inventory_id)
WHERE rental_duration < EXTRACT(DAY FROM return_date-rental_date);

-----------------------------------------------------------------------------
--9.	What categories are the most rented and what are their total sales?
--select name of category, count number of rentals as inventory_id in rental table, sum amount in payment table as total_sales
SELECT c.name AS category, 
    COUNT(r.inventory_id) AS rental_count, 
    SUM(amount) AS total_sales
--join payment to rental using rental_id in order to access rental amounts and payment amounts
FROM payment as p
	INNER JOIN rental as r
		USING (rental_id)
--join rental to inventory using inventory_id in order to acces film_id column
	INNER JOIN inventory as i
		USING (inventory_id)
--join inventory to film_category using film_id in order to acces category_id column
	INNER JOIN film_category as f
		USING (film_id)
--join film_category to category using category id in order to access category name column
	INNER JOIN category as c
		USING (category_id)
--group by category
GROUP BY category
--sort by rental_count descending for most number of rentals per category
ORDER BY rental_count DESC;

-----------------------------------------------------------------------------
--10.	Create a view for 8 and a view for 9. Be sure to name them appropriately. 


-----------------------------------------------------------------------------
--Bonus: Write a query that shows how many films were rented each month. Group them by category and month. 
SELECT 
	name AS category, 
	EXTRACT (MONTH FROM rental_date) AS month, 
	COUNT(rental_id) AS total_rentals
FROM rental
	INNER JOIN inventory
		USING (inventory_id)
	INNER JOIN film_category
		USING (film_id)
	INNER JOIN category
		USING (category_id)
GROUP BY name, month
ORDER BY month;
