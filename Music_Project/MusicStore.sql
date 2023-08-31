use MusicStores

-- 1. Who is the senior most employee based on job title?

select e.first_name+' '+e.last_name as  Senior_Employee , e.title from employee e
where e.employee_id = 1
order by levels desc 



--2. Which countries have the most Invoices?

select count(*) , i.billing_country from invoice i
group by i.billing_country 
order by i.billing_country desc



--3. What are top 3 values of total invoice?

select top 3 i.total as top_Values from invoice i
order by i.total desc



--4. Which city has the best customers? We would like to throw a promotional Music 
    --Festival in the city we made the most money. Write a query that returns one city that 
    --has the highest sum of invoice totals. Return both the city name & sum of all invoice totals


select top 1 c.city , sum(i.total) Highest_Invoice from customer c join invoice i 
on c.customer_id = i.customer_id
group by c.city
order by Highest_Invoice desc


--5. Who is the best customer? The customer who has spent the most money will be 
      --declared the best customer. Write a query that returns the person who has spent the most money

select top 1 c.first_name+' '+ c.last_name as Full_Name , sum(i.total) Spent_Most_Mony from customer c join invoice i
on c.customer_id = i.customer_id
group by c.first_name , c.last_name
order by Spent_Most_Mony desc



--6. Write query to return the email, first name, last name, & Genre of all Rock Music 
		--listeners. Return your list ordered alphabetically by email starting with A

select distinct c.first_name , c.last_name , c.email from  customer c join invoice i
on c.customer_id = i.customer_id join invoice_line il on il.invoice_id = i.invoice_id
where il.track_id in 
(select t.track_id from track t join genre g on t.genre_id = g.genre_id
 where g.name like 'Rock') order by c.email



--7. Let's invite the artists who have written the most rock music in our dataset. Write a 
	--query that returns the Artist name and total track count of the top 10 rock bands

select top 10 a.artist_id , a.name , count(a.artist_id) number_of_songs from artist a 
join album al on a.artist_id = al.artist_id
join track t on t.album_id = al.album_id 
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by a.artist_id, a.name
order by number_of_songs desc




--8. Return all the track names that have a song length longer than the average song length. 
  --Return the Name and Milliseconds for each track. Order by the song length with the 
  --longest songs listed first

select t.name , t.milliseconds from track t 
where t.milliseconds > (select AVG(t.milliseconds) as average_song_length from track t)
order by t.milliseconds desc




--9. Find how much amount spent by each customer on artists? 
      --Write a query to return customer name, artist name and total spent

select c.first_name , c.last_name , ar.name artist_name, sum(il.unit_price*il.quantity) amount_Spent from customer c
join invoice i on c.customer_id = i.customer_id 
join invoice_line il on i.invoice_id = il.invoice_id 
join track t on t.track_id = il.track_id 
join album a on a.album_id = t.album_id 
join artist ar on ar.artist_id = a.artist_id
group by c.first_name , c.last_name , ar.name 
order by amount_Spent desc




--10. We want to find out the most popular music Genre for each country. We determine the 
		--most popular genre as the genre with the highest amount of purchases. Write a query 
		--that returns each country along with the top Genre. For countries where the maximum 
		--number of purchases is shared return all Genres

with popular_genre AS (
select COUNT(il.quantity) as purchases, c.country , g.genre_id , g.name , ROW_NUMBER() OVER
			(PARTITION BY c.country ORDER BY COUNT(il.quantity) desc) as row_num from genre g 
			join track t on t.genre_id = g.genre_id
			join invoice_line il on il.track_id = t.track_id
			join invoice i on i.invoice_id = il.invoice_id
			join customer c on c.customer_id = i.customer_id 
			group by  c.country , g.genre_id , g.name
)
select p.genre_id , p.name Gener_Name , p.country , p.purchases from popular_genre  p
where row_num <= 1 ;




--11. Write a query that determines the customer that has spent the most on music for each 
		--country. Write a query that returns the country along with the top customer and how
		--much they spent. For countries where the top amount spent is shared, provide all 
		--customers who spent this amount

with cte as(
select c.first_name , c.last_name , c.country , sum(i.total) as total_spent
        ,ROW_NUMBER()over(partition by c.country order by sum(i.total) desc) as Row_num
		from customer c join invoice i on i.customer_id = c.customer_id
		group by c.first_name , c.last_name , c.country
)
select c.first_name , c.last_name , c.country , c.total_spent from cte c
where Row_num <= 1