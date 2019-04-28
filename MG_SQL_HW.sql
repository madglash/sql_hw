use sakila;

#1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name, ' ', last_name) AS Actor_Name FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor where first_name = 'JOE';

#2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name LIKE "%GEN%";

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where last_name LIKE "%LI%" order by last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT  country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so
#so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

#Checking
select * from actor;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as 'Number of Actors with Last Name' 
FROM actor 
group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, count(last_name) as 'Number of Actors with Last Name' FROM actor 
group by last_name
having count(last_name) >= 2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.alter

select * from actor where first_name = "Groucho";

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id= 172;

#Checking
select * from actor WHERE actor_id= 172;

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES = 0;

UPDATE actor
SET first_name = "GROUCHO"
where first_name = "HARPO";

#Checking
select * from actor where first_name = "Groucho";

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address 
ON staff.address_id = address.address_id; 

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT s.staff_id, s.first_name, s.last_name, sum(p.amount) as "Total Payments in August 2005" FROM staff s
JOIN payment p
ON s.staff_id = p.staff_id
where p.payment_date between '2005-08-01' and '2005-08-31 23:59:59'
GROUP BY staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select f.title, count(fa.actor_id) as "Number of Actors per Film" from film f
inner join film_actor fa
on f.film_id = fa.film_id
GROUP BY f.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select  f.title, count(i.inventory_id) as "Number in Inventory" from film f 
join inventory i
on f.film_id = i.film_id
where f.title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:

SELECT c.first_name, c.last_name, sum(p.amount) as "Total Payments per Customer" FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY last_name;


#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
#starting with the letters K and Q whose language is English.

select title from film where title in (
	select f.title from film f
	join language l
	on l.language_id = f.language_id
	where l.name = "English")
and title like 'K%' or title like 'Q%';


#7b. Use subqueries to display all actors who appear in the film Alone Trip.

select a.first_name, a.last_name from actor a
join film_actor fa
on a.actor_id = fa.actor_id
where film_id = (
	select film_id from film where title = "Alone Trip");


#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

select cust.customer_id, cust.first_name, cust.last_name, cust.email, coun.country from customer cust 
join address a
on cust.address_id = a.address_id
join city cit
on a.city_id = cit.city_id
join country coun
on cit.country_id = coun.country_id
where country = "Canada";

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.

select title, description from film f
join film_category fc
on f.film_id = fc.film_id
where category_id in (select category_id from category where name = "Family");

#7e. Display the most frequently rented movies in descending order.

select f.title, count(f.film_id) as "Rental Frequency" from rental r
join inventory i
on r.inventory_id = i.inventory_id
join film f
on i.film_id = f.film_id
group by f.film_id
order by count(f.film_id) desc;

#7f. Write a query to display how much business, in dollars, each store brought in.

select store, total_sales from sales_by_store;

#7g. Write a query to display for each store its store ID, city, and country.

select s.store_id, cit.city, coun.country from store s
join address a
on s.address_id = a.address_id
join city cit
on a.city_id = cit.city_id
join country coun
on cit.country_id = coun.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select cat.name as "Genre", sum(p.amount) as "Gross Revenue" from film f
join film_category fc
on f.film_id = fc.film_id
join category cat
on fc.category_id = cat.category_id
join inventory i
on i.film_id = f.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on r.rental_id = p.rental_id
group by cat.name
order by sum(p.amount) desc limit 5;


#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_5_genres_by_revenue as 
	select cat.name as "Genre", sum(p.amount) as "Gross Revenue" from film f
	join film_category fc
	on f.film_id = fc.film_id
	join category cat
	on fc.category_id = cat.category_id
	join inventory i
	on i.film_id = f.film_id
	join rental r
	on r.inventory_id = i.inventory_id
	join payment p
	on r.rental_id = p.rental_id
	group by cat.name
	order by sum(p.amount) desc limit 5;

#8b. How would you display the view that you created in 8a?

select * from top_5_genres_by_revenue;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_5_genres_by_revenue;
