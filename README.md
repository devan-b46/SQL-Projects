# Music_Store_Data-SQL_Analysis


## Schema Diagram:

<img src=schema_diagram.png title="Schema Diagram" height=500 />


---


#### Question Set 1. Basic
1. Who is the senior most employee based on the job title?
   
```sql
select TOP 1 first_name,last_name,max(levels) 
from employee
group by first_name,last_name
ORDER BY max(levels) DESC
```


2. Which countries have the most invoices?
```sql
SELECT TOP 1 billing_country,COUNT(billing_country) total_count_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_count_invoices DESC
```

3. What are the top 3 values of total invoice?
```sql
select top 3 total from invoice
order by total desc
```

4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
```sql
SELECT TOP 1 billing_city,SUM(TOTAL) total_sum FROM invoice
GROUP BY billing_city
ORDER BY total_sum DESC
```

6. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
```sql
SELECT TOP 1 customer_id, SUM(TOTAL) total_invoice
FROM invoice
GROUP BY customer_id
ORDER BY total_invoice DESC
```




#### Question Set 2: Medium

1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
```sql
select distinct email,first_name,last_name from customer c
inner join invoice i on c.customer_id=i.customer_id
inner join invoice_line il on i.invoice_id = il.invoice_id
where track_id in (
	select track_id from track t
	inner join genre g on t.genre_id=g.genre_id
	where g.name like 'rock%'
)
order by email
```

-- Doing above, using the CTE

```sql
with abc as(
	select track_id from track t
	inner join genre g on t.genre_id = g.genre_id
	where g.name LIKE 'rock%'
)

select distinct email, first_name,last_name from customer c
inner join invoice i on c.customer_id= i.customer_id
inner join invoice_line il on i.invoice_id=il.invoice_id
where il.track_id IN (select track_id from abc)
order by email
```


-- Another Try
```sql
WITH RockTracks AS (
  SELECT track_id
  FROM track t
  INNER JOIN genre g ON t.genre_id = g.genre_id
  WHERE g.name LIKE 'rock%'
)
SELECT DISTINCT email, first_name, last_name
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN (SELECT track_id FROM RockTracks)
ORDER BY email;
```


2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

```sql
select top 10 ar.name artist_name,count(g.name) no_of_Rock_tracks
from track t
inner join genre g on t.genre_id = g.genre_id
inner join album ab on t.album_id=ab.album_id
inner join artist ar on ab.artist_id=ar.artist_id
where g.name like 'rock%'
group by ar.name
order by no_of_Rock_tracks desc
```

3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

```sql
select name,milliseconds from track
where milliseconds > (select avg(milliseconds) avg_value from track)
order by milliseconds desc
```

```sql
-- Using CTE
with avglength as (
select avg(milliseconds) avg_value from track)

select name,milliseconds from track
where milliseconds > (select avg_value from avglength)
order by milliseconds desc
```





#### Question Set 3: Advanced

1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

```sql
Select * from
(
	select first_name+' '+last_name customer_name,ar.name artist_name,sum(i.total) total_spent,
		DENSE_RANK() Over (PARTITION BY first_name,last_name
		ORDER BY sum(i.total) DESC) RANKS
	from customer c
	inner join invoice i on c.customer_id = i.customer_id 
	inner join invoice_line il on i.invoice_id=il.invoice_id
	inner join track t on il.track_id=t.track_id
	inner join album ab on ab.album_id=t.album_id
	inner join artist ar on ar.artist_id=ab.artist_id
	group by first_name,last_name,ar.name
) as X
where ranks = 1
```

2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.

```sql
with ranking_genre as (
select billing_country,g.name,sum(total) total_spent,
	DENSE_RANK() Over (partition by billing_country order by sum(total) desc) ranks
from invoice i
inner join invoice_line il on i.invoice_id=il.invoice_id
inner join track t on t.track_id = il.track_id
inner join genre g on g.genre_id = t.genre_id
group by billing_country,g.name
)

select * from ranking_genre
where ranks = 1
```


3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

```sql
select * from 
(
select c.first_name+' '+c.last_name customer_name,i.customer_id,billing_country,sum(total) total_spent,
	DENSE_RANK() OVER (PARTITION BY billing_country ORDER BY SUM(TOTAL) DESC) RANKS
from invoice i
inner join customer c on c.customer_id=i.customer_id
group by billing_country,c.first_name+' '+c.last_name,i.customer_id
) as x
where ranks = 1
```
