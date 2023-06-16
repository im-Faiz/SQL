--                                                        SQL PROJECT
--                                                       ( PHASE 1 )

-- -------------------------------( 1. Who is the senior most employee based on job title? )------------------------------------------------------------

-- senior most on basis of age
SELECT distinct a.first_name, a.title ,  2023 - right(left(a.birthdate,10),4) as  Age
FROM employee a , employee b
Order by  Age desc;

-- senior most on basis of work experiance
SELECT distinct a.first_name, a.title ,  2023 - right(left(a.hire_date,10),4) as  Experiance
FROM employee a , employee b
Order by  experiance desc;

-- senior most on basis of reporting(reporting done on superior person. person how had max no of people reporting)
SELECT first_name,title,reports_to
FROM employee
ORDER BY reports_to desc;

--  using window function
SELECT A.first_name,title,max(reports_to ) over (partition by title ) as no_reporting 
FROM employee A
ORDER BY reports_to desc;

-- -------------------------------------( 2. Which countries have the most Invoices? )-----------------------------------------------------------------
select * from invoice;

-- on basis of number of invoice
SELECT billing_country,count(total) as count
FROM invoice
GROUP BY billing_country
ORDER BY count desc;

-- invoice on basis of sum of invoice value
SELECT billing_country,round(sum(total),1) as count
FROM invoice
GROUP BY billing_country
ORDER BY count desc;

-- same solution using JOINS  
SELECT A.country, count(B.total) as invoice
FROM customer A join invoice B  on A.customer_id=B.customer_id
GROUP BY country
ORDER BY invoice desc;

-- ----------------------------------( 3. What are top 3 values of total invoice? )-------------------------------------------------------------------  

SELECT A.country, count(B.total) as invoice
FROM customer A join invoice B  on A.customer_id=B.customer_id
GROUP BY country
ORDER BY invoice desc
LIMIT 3;

-- -------( 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.)-------------
-- ----- (Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.)------------- 
SELECT * FROM customer;

SELECT A.city, sum(B.total)
FROM customer A join invoice B on A.customer_id=B.invoice_id
GROUP BY city;

-- checking without sum 
SELECT A.city, B.total
FROM customer A join invoice B on A.customer_id=B.invoice_id
GROUP BY city,total;

-- CITY SUM on basis of unit_price
SELECT A.city,round(sum(C.unit_price),1) as unit_price,round(sum(B.total),1) as total_price
FROM customer A join invoice B on A.customer_id = B.customer_id
join invoice_line C on B.invoice_id = C.invoice_id
GROUP BY city,unit_price;

-- -------------(5. Who is the best customer? The customer who has spent the most money will be declared the best customer.)-------------------------
--  ---------------------------(Write a query that returns the person who has spent the most money)--------------------------------------------------- 

SELECT A.first_name as person, round(sum(B.total),1) as money
FROM customer A join invoice B on A.customer_id = B.customer_id
GROUP BY person
Order BY money desc;

--                                                        (PHASE 2)

-- PHASE 2
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 
select * from customer;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
select * from track;
select * from genre;

SELECT distinct A.email,A.first_name,A.last_name, E.name 
FROM Customer A 
join invoice B on A.customer_id=B.customer_id
join invoice_line C on B.invoice_id=C.invoice_id
join track D on C.track_id=D.track_id
join genre E on D.genre_id=E.genre_id
WHERE E.name = "rock" and a.email like "a%";

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands 

-- ----------------( Let's invite the artists who have written the most rock music in our dataset.  ) ------------------------------------------------
-- -----------( Write a query that returns the Artist name and total track count of the top 10 rock bands  ) ------------------------------------------

SELECT A.name,count(D.name) as total_tracks 
FROM artist A join album B on A.artist_id = B.artist_id
			  join track C on B.album_id = C.album_id
              join genre D on C.genre_id = D.genre_id
WHERE D.name= "rock"
GROUP BY A.name
ORDER BY total_tracks desc
LIMIT 10;

-- 3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

-- Subquery
SELECT * FROM track;
select avg(milliseconds)
from track;

SELECT name as tracks ,milliseconds as ms
FROM track
WHERE milliseconds > (select avg(milliseconds) from track) 
Group by name,ms
ORDER BY ms desc;

-- -----------------------------------------------------( PHASE 3 )-----------------------------------------------------------------------------------
-- PHASE 3
-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 
SELECT * from customer;

-- 
SELECT A.first_name as customer,H.name as artist ,round(sum(c.total),1) as total_spent
fROM customer A join invoice B on A.customer_id = B.customer_id
                join invoice C on B.customer_id = C.customer_id
                join invoice_line D on C.invoice_id = D.invoice_id
                join track E on D.track_id = E.track_id
                join album F on E.album_id = F.album_id
                join artist H on F.artist_id = H.artist_id
GROUP BY A.first_name,H.name;

-- 2. We want to find out the most popular music Genre for each country.
--  We determine the most popular genre as the genre with the highest amount of purchases.
 -- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres

SELECT A.country,I.name as genre ,round(sum(B.total),1) as total_spent
fROM customer A join invoice B on A.customer_id = B.customer_id
                join invoice C on B.customer_id = C.customer_id
                join invoice_line D on C.invoice_id = D.invoice_id
                join track E on D.track_id = E.track_id
                join album F on E.album_id = F.album_id
                join artist H on F.artist_id = H.artist_id
                join genre I on I.genre_id = E.genre_id 
GROUP BY A.country,I.name
ORDER BY total_spent DESC;

-- 3. Write a query that determines the customer that has spent the most on music for each country.
--  Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount


SELECT A.first_name,A.country,A.city,D.name,B.total
FROM customer A join invoice B on A.customer_id = B.customer_id
				join invoice_line C on B.invoice_id = C.invoice_id
                join track D on C.track_id = D.track_id
GROUP BY A.first_name,A.country,A.city,B.total,D.name 
ORDER BY B.total desc;
