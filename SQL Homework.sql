/************************************************************************
1a. Display the first and last names of all actors from the table `actor`.
************************************************************************/
select first_name,  last_name
from sakila.actor;

/*******************************************************************
1b. Display the first and last name of each actor in a single column 
in upper case letters. Name the column `Actor Name`.
********************************************************************/
select concat(first_name, " " ,last_name) as 'Actor Name'
from sakila.actor;
/**************************************************************
2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query 
would you use to obtain this information?
**************************************************************/
select actor_id, first_name, last_name
from sakila.actor
where first_name = "Joe";

/**************************************************************
2b. Find all actors whose last name contain the letters `GEN`:
**************************************************************/
select actor_id, first_name, last_name
from sakila.actor
where last_name like "%GEN%";
/**************************************************************
2c. Find all actors whose last names contain the letters `LI`. 
This time, order the rows by last name and first name, in that order:
**************************************************************/
select actor_id, first_name, last_name
from sakila.actor
where last_name like "%LI%"
order by last_name, first_name;
/**************************************************************
2d. Using `IN`, display the `country_id` and `country` columns 
of the following countries: Afghanistan, Bangladesh, and China:
**************************************************************/
select country_id, country
from sakila.country
where country in ('Afghanistan', 'Bangladesh', 'China');
/**************************************************************
3a. You want to keep a description of each actor. 
You don't think you will be performing queries on a description, so create a column in the 
table `actor` named `description` and use the data type `BLOB`
 (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
**************************************************************/
ALTER TABLE sakila.actor
ADD description BLOB;
/**************************************************************
 3b. Very quickly you realize that entering descriptions 
for each actor is too much effort. Delete the `description` column.
**************************************************************/
ALTER TABLE sakila.actor
DROP COLUMN description;
/**************************************************************
 4a. List the last names of actors, as well as how many actors have that last name
**************************************************************/
SELECT last_name, count(last_name)
from sakila.actor;
/**************************************************************
 4b. List last names of actors and the number of actors who have that last name, 
 but only for names that are shared by at least two actors. List the last names of actors, 
 as well as how many actors have that last name
**************************************************************/
SELECT last_name, count(last_name)
from sakila.actor
group by last_name
having count(last_name) > 1
order by last_name;
/**************************************************************
 4c. The actor `HARPO WILLIAMS` was accidentally entered in 
 the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
**************************************************************/
UPDATE sakila.actor
SET first_name = 'HARPO'
where first_name = 'GROUCHO'
and last_name = 'WILLIAMS';
/**************************************************************
 * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns 
 out that `GROUCHO` was the correct name after all! In a single query, 
 if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
**************************************************************/
UPDATE sakila.actor
SET first_name = 'GROUCHO'
where first_name = 'HARPO'
and last_name = 'WILLIAMS';
/**************************************************************
 * 5a. You cannot locate the schema of the `address` table. 
 Which query would you use to re-create it?
*******************************************************/
show create table address;

CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
/**************************************************************
 6a. Use `JOIN` to display the first and last names, as well as the address, 
 of each staff member. Use the tables `staff` and `address`:
*******************************************************/
select ST.first_name, ST.last_name, ad.address
from sakila.staff as ST 
join sakila.address as ad on ST.address_id = ad.address_id;
/**************************************************************
 * 6b. Use `JOIN` to display the total amount rung up by each staff member in 
 August of 2005. Use tables `staff` and `payment`.
*******************************************************/
select concat(st.last_name, ", " ,st.first_name) as 'Staff Member',
sum(py.amount) as 'Total'
from sakila.staff st 
join sakila.payment py on st.staff_id = py.staff_id
where substr(payment_date,1,4) = '2005'
and substr(payment_date,6,2) = '08' 
group by concat(st.last_name, ", " ,st.first_name)
;
/***************************************************************************************
* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. 
Use inner join.
*******************************************************/
select f.title, count(fa.actor_id)
from sakila.film f
inner join sakila.film_actor fa on f.film_id = fa.film_id
group by f.title
order by f.title
;
/**************************************************************
* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
*******************************************************/
Select f.title, count(inv.inventory_id)
from sakila.film f
inner join sakila.inventory inv on f.film_id = inv.film_id
where f.title = "Hunchback Impossible";
/**************************************************************
* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
List the customers alphabetically by last name:
  ![Total amount paid](Images/total_payment.png)
*******************************************************/
select cu.last_name,cu.first_name,sum(pm.amount)
from sakila.payment pm
join sakila.customer cu on pm.customer_id = cu.customer_id
group by cu.last_name,cu.first_name
order by cu.last_name,cu.first_name
;
/**************************************************************
* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
*********************************************************************************/
SELECT film.title
from sakila.film 
where film.title like 'K%' or 
        film.title like 'Q%'
    and
LANGUAGE_ID IN 
    (SELECT LANGUAGE_ID 
    FROM sakila.language
    where LANGUAGE_ID = 1
    )
/**************************************************************
* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
*******************************************************/
select concat(first_name, " " ,last_name) as 'Actor Name'
from sakila.actor a
where a.actor_id in 
	(select actor_id 
    from sakila.film_actor fa
    where film_id in 
		(
        select film_id 
        from sakila.film 
    where film.title = "Alone Trip"));

/**************************************************************
* 7c. You want to run an email marketing campaign in Canada, for which you will need the 
names and email addresses of all Canadian customers. Use joins to retrieve this information.
*******************************************************/
select cu.last_name,cu.first_name, cu.email, ct.country 
from sakila.customer cu
join sakila.address ad on cu.address_id = ad.address_id
join sakila.city cy on cy.city_id = ad.city_id
join sakila.country ct on ct.country_id = cy.country_id
where ct.country = "Canada";

/**************************************************************
* 7d. Sales have been lagging among young families, and you wish to target all family 
movies for a promotion. Identify all movies categorized as _family_ films.
*******************************************************/
select F.title
from sakila.film F
join sakila.film_category FC on F.film_id = FC.film_id
join sakila.category C on FC.category_id = C.category_id
where C.name = "Family"
;
/**************************************************************
* 7e. Display the most frequently rented movies in descending order.
*******************************************************/
select F.title as 'Film Title', count(R.rental_id) AS 'Rentals'
from sakila.film F
join sakila.inventory INV on F.film_id = INV.film_id
join sakila.rental R on R.inventory_id = INV.inventory_id
group by F.title
order by Rentals desc, F.title
;
/**************************************************************
* 7f. Write a query to display how much business, in dollars, each store brought in.
*******************************************************/
select st.store_id as 'Store', sum(py.amount) as 'Amount'
from sakila.store st
join sakila.customer cu on st.store_id = cu.store_id
inner join sakila.payment py on cu.customer_id = py.customer_id
group by st.store_id
order by Amount desc, st.store_id;

/**************************************************************
* 7g. Write a query to display for each store its store ID, city, and country.
*******************************************************/
select st.store_id as 'Store', cy.city, ct.country
from sakila.store st
join sakila.address ad on st.address_id = ad.address_id
join sakila.city cy on cy.city_id = ad.city_id
join sakila.country ct on ct.country_id = cy.country_id;
/**************************************************************
* 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
*******************************************************/
select C.name as 'Genre', sum(py.amount) as 'Amount'
from sakila.film_category FC 
inner join sakila.category C on FC.category_id = C.category_id
inner join sakila.inventory inv on inv.film_id = FC.film_id
inner join sakila.rental RT on RT.inventory_id = inv.inventory_id
inner join sakila.payment py on py.rental_id = RT.rental_id
group by  C.name
order by Amount desc, C.name
limit 5 ;

/**************************************************************
* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top 
five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.
*******************************************************/
CREATE VIEW Top5Genres as 
select C.name as 'Genre', sum(py.amount) as 'Amount'
from sakila.film_category FC 
inner join sakila.category C on FC.category_id = C.category_id
inner join sakila.inventory inv on inv.film_id = FC.film_id
inner join sakila.rental RT on RT.inventory_id = inv.inventory_id
inner join sakila.payment py on py.rental_id = RT.rental_id
group by  C.name
order by Amount desc, C.name
limit 5;
-- Had to Double click Sakila database so it knew to use it
/**************************************************************
* 8b. How would you display the view that you created in 8a?
*******************************************************/
SELECT * from Top5Genres;
/**************************************************************
* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
**************************************************************/
DROP VIEW Top5Genres;
