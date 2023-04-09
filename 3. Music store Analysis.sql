
                                                 --- Music Store Data Analysis ---

select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;


-- SET 1 -- 

-- 1. Who is the senior most employee based on job title ?

select top 1 first_name,last_name,title,levels 
from employee
order by levels desc;


-- 2. Which countries have the most invoices ?

select count(*) as most_invoice ,billing_country from invoice
group by billing_country
order by most_invoice desc;


-- 3. What are the top 3 values of total invoice ?
select top 3 total
from invoice
order by total desc;


/* 4. Which city has the best customers ? We would like to throw a 
promotional music festival in the city we made the most money. Write
a query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals */

select billing_city,sum(total) as invoice_totals 
from invoice
group by billing_city 
order by invoice_totals desc;


/* 5. Who is the best customer? The customer who has the spent the most
money will be declared the best customer. Write a query that returns the 
person who has spent the most money */
select top 1 c.first_name,c.last_name,sum(i.total) as spent_money 
from customer as c
inner join invoice as i
on c.customer_id = i.customer_id
group by c.first_name,c.last_name
order by spent_money desc;



--- SET 2 ---

/* 6. Write a query to return the email, firstname, lastname,
& Genre of all Rock Music listeners. Return your list ordered
alphabetically by email starting with A */

select distinct c.email,c.first_name,c.last_name 
from customer as c
inner join invoice as i
on c.customer_id = i.customer_id
inner join invoice_line as li
on i.invoice_id = li.invoice_id
where track_id in (
select track_id from track as t
inner join genre as g
on t.genre_id = g.genre_id
where g.name like 'Rock'
)
order by c.email;



/* 7. Let's Invite the artist who have written the most
rock music in our dataset. Write a query that returns the 
artist name and total track count of the top 10 rock bands */

select top 10 a.artist_id,a.name,count(a.artist_id) as no_of_songs
from track t
inner join album as al
on t.album_id = al.album_id
inner join artist as a
on a.artist_id = al.artist_id
inner join genre as g
on t.genre_id = g.genre_id
where g.name like 'Rock'
group by a.artist_id ,a.name
order by no_of_songs desc;


/* 8. Return all the track names that have a song length longer than
the avg song length. 
Return the name and miliseconds for each track. Order by the song length
with the longest song listed first */

select * from track;

select name,milliseconds from 
track 
where milliseconds > (
select avg(milliseconds) as avg_song_len
from track
)
order by milliseconds desc;



--- SET 3 ---

/* 9. Find how much amount spent by each customer on artist?
write a query to return customer name, artist name and total spent */

select * from customer;
select * from artist;
select * from invoice;
select * from invoice_line;


-- fetching the sales value & artist name

with best_selling_artist as (

select a.artist_id, a.name,sum(il.unit_price*il.quantity) as total_sale
from invoice_line as il
inner join track as t
on t.track_id = il.track_id
inner join album as al
on al.album_id = t.album_id
inner join artist as a
on a.artist_id = a.artist_id
group by a.artist_id,a.name
--order by total_sale desc

)

-- fetching customer details 

select c.customer_id,c.first_name,c.last_name, bsa.name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice as i
inner join customer as c
on c.customer_id = i.customer_id
inner join invoice_line as il 
on il.invoice_id = i.invoice_id
inner join track as t
on t.track_id = il.track_id
inner join album as al
on al.album_id = t.album_id
inner join best_selling_artist as bsa
on bsa.artist_id = al.artist_id
group by c.customer_id,c.first_name,c.last_name, bsa.name
order by amount_spent desc;



/* 10. Find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest 
amount of purchase. 
Write a query that returns each country along with the top genre.
for countries were the maximum no. of purchase is shared return all Genre*/

with popular_genre as (

select COUNT(il.quantity) as purchases,c.country,g.name,g.genre_id,
ROW_NUMBER() over(partition by c.country order by COUNT(il.quantity) desc ) as row_num
from invoice_line as il
inner join  invoice as i
on il.invoice_id = i.invoice_id
inner join customer as c
on i.customer_id = c.customer_id
inner join track as t
on t.track_id = il.track_id
inner join genre as g
on g.genre_id = t.genre_id
group by c.country,g.name,g.genre_id
-- order by c.country asc, purchases desc

)
select * from popular_genre where row_num <=1

