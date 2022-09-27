# B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date) AS registration_week, COUNT(runner_id) AS number_of_runner
FROM runners
GROUP BY  registration_week;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT c.runner_id, ROUND(AVG(c.pickup_minutes), 2) AS avg_pickup_minutes
FROM
(SELECT a.runner_id, a.pickup_time, b.order_time, 
TIMESTAMPDIFF(MINUTE, b.order_time, a.pickup_time) AS pickup_minutes
FROM runner_orders_temp a
JOIN customer_orders_temp b
ON a.order_id = b.order_id
WHERE a.cancellation IS NULL
)c
GROUP BY c.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? 
-- STILL ON PROCESS
SELECT a.order_id, b.pizza_id, a.pickup_time, b.order_time, 
TIMESTAMPDIFF(MINUTE, b.order_time, a.pickup_time) AS pickup_minutes
FROM runner_orders_temp a
JOIN customer_orders_temp b
ON a.order_id = b.order_id
WHERE a.cancellation IS NULL;

-- 4. What was the average distance travelled for each customer?
SELECT b.customer_id, ROUND(AVG(a.distance), 2) AS avg_distance
FROM runner_orders_temp a
JOIN customer_orders_temp b
ON a.order_id = b.order_id
GROUP BY b.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT (MAX(duration) - MIN(duration)) AS diff_delivery_times
FROM runner_orders_temp;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
 SELECT a.runner_id, b.customer_id, a.distance, a.duration, 
 ROUND((a.duration/60), 2) AS duration_hour,
 ROUND(a.distance/ROUND((a.duration/60), 2), 2) AS speed
 FROM runner_orders_temp a
 JOIN customer_orders_temp b
 ON a.order_id = b.order_id
 ORDER BY a.runner_id;
 
 -- 7. What is the successful delivery percentage for each runner?
 SELECT runner_id,
 COUNT(pickup_time) AS delivery_orders,
 COUNT(*) AS total_orders,
 ROUND(COUNT(pickup_time)/COUNT(*)*100) AS perc_of_succesful_delivery
 FROM runner_orders_temp
 GROUP BY runner_id;