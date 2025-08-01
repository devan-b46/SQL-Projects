CREATE DATABASE MusicStore

USE MusicStore



-- Question Set 1. Basic
-- 1. Who is the senior most employee based on the job title?
SELECT TOP 1 first_name,last_name,max(levels) 
FROM employee
GROUP BY first_name,last_name
ORDER BY MAX(levels) DESC


-- 2. Which countries have the most invoices?
SELECT TOP 1 billing_country,COUNT(billing_country) total_count_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_count_invoices DESC


-- 3. What are the top 3 values of total invoice?
SELECT TOP 3 total FROM invoice
ORDER BY total DESC


-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
SELECT TOP 1 billing_city,SUM(TOTAL) total_sum FROM invoice
GROUP BY billing_city
ORDER BY total_sum DESC


-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
SELECT TOP 1 customer_id, SUM(TOTAL) total_invoice
FROM invoice
GROUP BY customer_id
ORDER BY total_invoice DESC





-- Question Set 2: Medium

-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT email,first_name,last_name FROM customer c
INNER JOIN invoice i on c.customer_id=i.customer_id
INNER JOIN invoice_line il on i.invoice_id = il.invoice_id
WHERE track_id in (
	SELECT track_id FROM track t
	INNER JOIN genre g ON t.genre_id=g.genre_id
	WHERE g.name like 'rock%'
)
ORDER BY email


-- Doing above, using the CTE

WITH abc AS(
	SELECT track_id FROM track t
	INNER JOIN genre g on t.genre_id = g.genre_id
	WHERE g.name LIKE 'rock%'
)

SELECT DISTINCT email, first_name,last_name FROM customer c
INNER JOIN invoice i ON c.customer_id= i.customer_id
INNER JOIN invoice_line il ON i.invoice_id=il.invoice_id
WHERE il.track_id IN (SELECT track_id FROM abc)
ORDER BY email



-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT TOP 10 ar.name artist_name,COUNT(g.name) no_of_Rock_tracks
FROM track t
INNER JOIN genre g ON t.genre_id = g.genre_id
INNER JOIN album ab ON t.album_id=ab.album_id
INNER JOIN artist ar ON ab.artist_id=ar.artist_id
WHERE g.name like 'rock%'
GROUP BY ar.name
ORDER BY no_of_Rock_tracks desc

-- 3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT name,milliseconds FROM track
WHERE milliseconds > (SELECT avg(milliseconds) avg_value FROM track)
ORDER BY milliseconds desc



-- Using CTE
WITH avglength AS (
SELECT avg(milliseconds) avg_value FROM track)

SELECT name,milliseconds FROM track
WHERE milliseconds > (SELECT avg_value FROM avglength)
ORDER BY milliseconds desc






-- Question Set 3: Advanced

-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT * FROM
(
	SELECT first_name+' '+last_name customer_name,ar.name artist_name,sum(i.total) total_spent,
		DENSE_RANK() Over (PARTITION BY first_name,last_name
		ORDER BY sum(i.total) DESC) RANKS
	FROM customer c
	INNER JOIN invoice i ON c.customer_id = i.customer_id 
	INNER JOIN invoice_line il ON i.invoice_id=il.invoice_id
	INNER JOIN track t ON il.track_id=t.track_id
	INNER JOIN album ab ON ab.album_id=t.album_id
	INNER JOIN artist ar ON ar.artist_id=ab.artist_id
	GROUP BY first_name,last_name,ar.name
) AS X
WHERE ranks = 1


-- 2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.


WITH ranking_genre AS (
SELECT billing_country,g.name,sum(total) total_spent,
	DENSE_RANK() OVER (PARTITION BY billing_country ORDER BY sum(total) desc) ranks
FROM invoice i
INNER JOIN invoice_line il on i.invoice_id=il.invoice_id
INNER JOIN track t ON t.track_id = il.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
GROUP BY billing_country,g.name
)

SELECT * FROM ranking_genre
WHERE ranks = 1



-- 3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

SELECT * FROM 
(
SELECT c.first_name+' '+c.last_name customer_name,i.customer_id,billing_country,SUM(total) total_spent,
	DENSE_RANK() OVER (PARTITION BY billing_country ORDER BY SUM(TOTAL) DESC) RANKS
FROM invoice i
INNER JOIN customer c ON c.customer_id=i.customer_id
GROUP BY billing_country,c.first_name+' '+c.last_name,i.customer_id
) AS x
WHERE ranks = 1


