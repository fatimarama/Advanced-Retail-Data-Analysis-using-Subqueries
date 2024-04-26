use assignment_2; -- using the dataset from the previous assignment, because Ma'am Maham mentioned you can use either
set sql_safe_updates = 0;

-- [Question 1A]
-- Make sure you have extracted street names from the previous assignment
-- USING A JOIN, select order ids and the street name and city name for each order id. 

select o.order_id, c.street, c.city
from orders o
left join customers c
	on c.customer_id=o.customer_id;

-- [Question 1B]
-- Find out the total number of orders per street per city. Your results should show street, city and total_orders
-- results should be ordered by street in ascending order and cities in descending order

select count(o.order_id) as total_orders, c.street, c.city 
from orders o
left join customers c
	on c.customer_id=o.customer_id
group by c.street, c.city
order by c.street, c.city desc;
    
-- [Question 2A]
-- USING A JOIN, select first names, last names and addresses of customers who have never placed an order.
-- Only these three columns should show in your results

select c.first_name, c.last_name, c.address
from customers c
left join orders o 
	on c.customer_id=o.customer_id
where o.order_id is null;

-- [Question 2B]
-- USING A SUBQUERY IN WHERE (NOT correlated), select first_names, last_names and addresses of customers who have never placed an order.

select first_name, last_name, address
from customers
where customer_id not in (
							select distinct customer_id
                            from orders);

-- [Question 2C]
-- What do you observe in the results?

-- All customers have placed orders at least once. There are no customers who have not placed an order. 

-- [Question 3A]
-- Write a simple group by query to find out item types and their average price
-- Pin this result in your workbench so you have it for comparison for the next question

select item_type, round(avg(item_price),2) as average_price
from items
group by item_type;

-- [Question 3B]
-- USING A CORRELATED SUBQUERY IN WHERE:
-- select item id, item name, item type and item price for all those items that have a price higher than the average price FOR THAT ITEM TYPE (NOT average of the whole column)
-- order your result by item type;

select i.item_id, i.item_name, i.item_type, i.item_price
from items i
where i.item_price > (
						select avg(it.item_price)
                        from items it
                        where i.item_type=it.item_type
                        group by it.item_type)
order by i.item_type;

-- [Question 3C]
-- Compare your results in part B to the averages you found in part A for each item type. 
-- Is your query in B returning all the items priced higher than the average of that item category?

-- Yes, query in B returning all the items priced higher than the average of that item category

-- [Question 4] 
-- USING A SUBQUERY IN WHERE (NOT correlated), find out customer ids and the order date and item id of their most recent order
-- order your result by customer_id

select customer_id, order_date, item_id
from orders
where (customer_id, order_date) in (
										select customer_id, max(order_date)
										from orders 
										group by customer_id)
order by customer_id;
										
-- [Question 5A]
-- USE A JOIN to select the following:
-- last name, address, phone number, order id, order date, item name, item type, and item price. 

select c.last_name, c.address, c.phone_number, o.order_id, o.order_date, i.item_name, i.item_type, i.item_price
from customers c
join orders o 
	on c.customer_id=o.customer_id
join items i
	on o.item_id=i.item_id;

-- [Question 5B]
-- Now return the same table as above but also return the total number of orders by that customer next to each row (call this total_orders)
-- USE A CORRELATED SUBQUERY IN THE SELECT CLAUSE FOR THIS

select c.last_name, c.address, c.phone_number, o.order_id, o.order_date, i.item_name, i.item_type, i.item_price, 
					(
						select count(od.customer_id)
						from orders od
						where c.customer_id=od.customer_id
					) as total_orders
from customers c
join orders o 
	on c.customer_id=o.customer_id
join items i
	on o.item_id=i.item_id
order by c.customer_id;

-- NOTE FOR QUESTION 6: 
-- Please remember that when you group by a certain column for e.g. id, you can only add id and aggregate columns like sum(), count() avg() etc to the select clause
-- You cannot add non-aggregated columns like name, type etc to the select clause UNLESS they are also in the group by clause
-- However, you CAN add non-aggregated columns like name, type etc to the select clause without them being in the group by clause IF you group by a primary key column.
-- To solve the question, you can either set a primary key or add all the requested columns to the group by clause along with the column you need to group by. 

-- [Questions 6] 
-- USING A JOIN, find out the item name, item type, amount in stock and total_orders for the 5 top most sold items.
-- Since there are more than 5 top most sold items, show your top 5 based on item name ascending alphabetical order (your results should not show more than 5 rows)
-- DON'T use any subqueries here

-- setting a primary key in items table
alter table items
add primary key (item_id); 

select i.item_name, i.item_type, i.amount_in_stock, count(o.item_id) as total_orders
from items i
join orders o
	on i.item_id=o.item_id
group by i.item_id
order by total_orders desc, i.item_name
limit 5;



