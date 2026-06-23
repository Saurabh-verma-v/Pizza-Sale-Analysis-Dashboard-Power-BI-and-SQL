
-- 1. Retrieve the total number of orders placed.

select count(order_id) as total_order_placed 
from orders;

-- 2. Calculate the total revenue generated from pizza sales.


select sum(pizzas.price*order_details.quantity) as total_revenue
from  pizzas join order_details
on pizzas.pizza_id=order_details.order_id;

-- 3. Identify the highest-priced pizza.

select pizza_types.name,max(pizzas.price) as highest_price
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.name
order by highest_price desc
limit 1;

-- 4. Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_id) as most_order
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size
order by most_order desc;

-- 5. List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name,sum(order_details.quantity) as order_count
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id 
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name
order by order_count desc
limit 5;


-- Intermediate:


-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,sum(order_details.quantity)
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category;

-- 7.  Determine the distribution of orders by hour of the day.

select hour(order_time),count(order_id) as order_count
from orders
group by hour(order_time);

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

select pizza_types.category,count(order_details.order_id) as order_dist
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category
order by order_dist desc;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(quantity)
FROM
    (SELECT 
        order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quantity;
    
    
-- 10. Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;

-- Advanced:


-- 11. Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,sum(pizzas.price * order_details.quantity) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category
order by revenue desc;


-- Analyze the cumulative revenue generated over time.


select order_date,
sum(revenue) over (order by order_date)	as running_total
from
(select orders.order_date
,round(sum(order_details.quantity * pizzas.price),2) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,revenue,rnk
from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rnk
from
(select pizza_types.category,pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join	order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as t) as a
where rnk <=3;