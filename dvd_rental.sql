/* Finding the top film category for the countries(United states, United kingdom, India, Saudi arabia, China)
 1st slide */
SELECT co.country, ca.name, COUNT(*) AS category_rent_count
FROM category ca
JOIN film_category fc
	ON ca.category_id = fc.category_id
JOIN film f
	ON fc.film_id = f.film_id
JOIN inventory i
	ON f.film_id = i.film_id
JOIN rental r
	ON i.inventory_id = r.inventory_id
JOIN customer c
	ON r.customer_id = c.customer_id
JOIN address a
	ON c.address_id = a.address_id
JOIN city ci
	ON a.city_id = ci.city_id
JOIN country co
	ON ci.country_id = co.country_id
WHERE co.country IN ('United States', 'United Kingdom', 'Saudi Arabia', 'India', 'China')
GROUP BY ca.name, ca.category_id, co.country_id, co.country
HAVING COUNT(*) = (
	SELECT MAX(category_rent_count)
	FROM(
		SELECT co.country, ca.name, COUNT(*) AS category_rent_count
		FROM category ca
		JOIN film_category fc
			ON ca.category_id = fc.category_id
		JOIN film f
			ON fc.film_id = f.film_id
		JOIN inventory i
			ON f.film_id = i.film_id
		JOIN rental r
			ON i.inventory_id = r.inventory_id
		JOIN customer c
			ON r.customer_id = c.customer_id
		JOIN address a
			ON c.address_id = a.address_id
		JOIN city ci
			ON a.city_id = ci.city_id
		JOIN country outer_co
			ON ci.country_id = co.country_id
		WHERE co.country_id = outer_co.country_id
		GROUP BY 1, 2, ca.category_id
	) sub
	
)
ORDER BY 3 DESC;


/* Finding the top 10 customers with most money spent. 2nd slide */
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.email, SUM(p.amount) AS total_amount
FROM customer c
JOIN payment p
	ON c.customer_id = p.customer_id
GROUP BY 1, 2 ,3
ORDER BY total_amount DESC
LIMIT 10;


/* Finding the 10 most rented categories globally. 3rd slide */
WITH rented_category AS (
	SELECT ca.name AS category, COUNT(*) AS rental_count,
	ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rank
	FROM rental r
	JOIN inventory i
		ON r.inventory_id = i.inventory_id
	JOIN film f
		ON i.film_id = f.film_id
	JOIN film_category fc
		ON f.film_id = fc.film_id
	JOIN category ca
		ON fc.category_id = ca.category_id
	GROUP BY ca.name
)
SELECT category, rental_count
FROM rented_category
WHERE rank <= 10;

/* Finding the total rental counts for each store throughout the months for each year available in the dataset
 4th slide */
SELECT DATE_PART('month', r.rental_date) AS rental_month, DATE_PART('year', r.rental_date) AS rental_year, 
s.store_id, COUNT(*) AS count_rentals
FROM store s
JOIN staff sta
	ON s.store_id = sta.store_id
JOIN rental r
	ON sta.staff_id = r.staff_id
GROUP BY 1, 2, 3
ORDER BY count_rentals DESC;