SELECT * FROM customer_orders;
# we can see that there are blank spaces and null values in the exclusions and extras columns.
# This need to be cleaned up before using them in the queries.
DROP TABLE IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id, customer_id, pizza_id,
CASE
	WHEN exclusions = '' THEN NULL
	WHEN exclusions = 'null' THEN NULL
	ELSE exclusions
END AS exclusions,
CASE
	WHEN extras = '' THEN NULL
	WHEN extras = 'null' THEN NULL
	ELSE extras
END AS extras,
order_time
FROM customer_orders;

SELECT * FROM customer_orders_temp;

# A. Pizza Metrics

-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS 'Numbef of pizza ordered'
FROM customer_orders_temp;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS 'Number of unique orders'
FROM customer_orders_temp;


SELECT * FROM runner_orders;
# we can see that there are blank spaces and null values in the cancellation columns.
# This need to be cleaned up before using them in the queries.
DROP TABLE IF EXISTS runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT order_id, runner_id, pickup_time, distance, duration,
CASE
	WHEN cancellation = '' THEN NULL
    WHEN cancellation = 'null' THEN NULL
    ELSE cancellation
END AS cancellation
FROM runner_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS count
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT b.pizza_id, c.pizza_name, COUNT(b.pizza_id) AS 'number of pizza delivered'
FROM runner_orders_temp a
JOIN customer_orders b
ON a.order_id = b.order_id
JOIN pizza_names c
ON b.pizza_id = c.pizza_id
WHERE cancellation IS NULL
GROUP BY b.pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT a.customer_id, b.pizza_name, 
	COUNT(a.pizza_id) AS 'Number of pizza ordered'
FROM customer_orders_temp a
JOIN pizza_names b
ON a.pizza_id = b.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT a.customer_id, a.order_id, COUNT(a.pizza_id) AS 'Number of pizza ordered'
FROM customer_orders_temp a
JOIN runner_orders_temp b
ON a.order_id = b.order_id
WHERE b.cancellation IS NULL
GROUP BY a.customer_id, a.order_id
ORDER BY COUNT(a.pizza_id) DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
       SUM(CASE
               WHEN (exclusions IS NOT NULL
                     OR extras IS NOT NULL) THEN 1
               ELSE 0
           END) AS change_in_pizza,
       SUM(CASE
               WHEN (exclusions IS NULL
                     AND extras IS NULL) THEN 1
               ELSE 0
           END) AS no_change_in_pizza
FROM customer_orders_temp
INNER JOIN runner_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT customer_id, 
SUM(CASE WHEN (exclusions IS NOT NULL 
				AND extras IS NOT NULL) THEN 1 ELSE 0 END
    ) AS 'Count'
FROM customer_orders_temp a
JOIN runner_orders_temp b
ON a.order_id = b.order_id
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY Count DESC;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT hour(order_time) AS 'hour', COUNT(order_id) AS 'volume_of_pizza_ordered'
FROM customer_orders_temp
GROUP BY hour
ORDER BY hour ASC;

-- 10. What was the volume of orders for each day of the week?
SELECT dayname(order_time) AS 'date_name', COUNT(order_id) AS 'volume_of_pizza_ordered'
FROM customer_orders_temp
GROUP BY date_name;
