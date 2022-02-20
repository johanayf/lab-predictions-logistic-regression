##In order to optimize our inventory, we would like to know which films will be rented next month and we are asked to create a model to predict it.
##Create a query or queries to extract the information you think may be relevant for building the prediction model. It should include some film features and some rental features.

use sakila;

##The data I neeed are: Film Title, rental date, category_id 

##I will only choose the data from 2005 May to August. As that is the only consistent data.  
select distinct year(rental_date), month(rental_date)
from rental;

select distinct store_id from store;

create or replace view rental_logistic_regression as (

with CTE as (with CTE_Rental as (
with recursive cte_rental_may as (select inventory_id, count(rental_date) as number_of_rental_may from rental
where rental_date between '2005-05-01 00:00:00' AND '2005-05-31 23:59:59'
group by inventory_id),
cte_rental_june as (select inventory_id, count(rental_date) as number_of_rental_june from rental
where rental_date between '2005-06-01 00:00:00' AND '2005-06-30 23:59:59'
group by inventory_id),
cte_rental_july as (select inventory_id, count(rental_date) as number_of_rental_july from rental
where rental_date between '2005-07-01 00:00:00' AND '2005-07-31 23:59:59'
group by inventory_id),
cte_rental_august as (select inventory_id, count(rental_date) as number_of_rental_august from rental
where rental_date between '2005-08-01 00:00:00' AND '2005-08-31 23:59:59'
group by inventory_id)

select i.inventory_id, c1.number_of_rental_may, c2.number_of_rental_june, c3.number_of_rental_july, c4.number_of_rental_august, 
if(i.store_id = 1, 1, 0) as store_1,
if(i.store_id = 2, 1, 0) as store_2
from inventory as i
left join cte_rental_may as c1 on i.inventory_id = c1.inventory_id
left join cte_rental_june as c2 on i.inventory_id = c2.inventory_id
left join cte_rental_july as c3 on i.inventory_id = c3.inventory_id
left join cte_rental_august as c4 on i.inventory_id = c4.inventory_id)

select  i.film_id, if(sum(c.store_1)>0, 1, 0) as store1,
if(sum(c.store_2)>0, 1, 0) as store2,
sum(c.number_of_rental_may) as number_of_rental_may,
sum(c.number_of_rental_june) as number_of_rental_june,
sum(c.number_of_rental_july) as number_of_rental_july,
sum(c.number_of_rental_august) as number_of_rental_august
from inventory as i 
left join cte_rental as c on c.inventory_id = i.inventory_id
group by i.film_id)

select fc.category_id, f.film_id, c.store1, c.store2, c.number_of_rental_may,
c.number_of_rental_june, c.number_of_rental_july, c.number_of_rental_august
from film as f 
left join cte as c on f.film_id = c.film_id
left join film_category as fc on fc.film_id = f.film_id);

select * from rental_logistic_regression ;

