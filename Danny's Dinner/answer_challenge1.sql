-- 1.What is the total amount each customer spent at the restaurant?
SELECT c.customer_id, SUM(c.price) AS total_spent FROM
	(SELECT a.customer_id, a.product_id, b.price
	FROM sales a
	JOIN menu b
	ON a.product_id = b.product_id
    ) c
GROUP BY customer_id;

-- 2.How many days has each customer visited the restaurant?
SELECT customer_id, 
COUNT(DISTINCT order_date) AS number_of_visited 
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT c.customer_id, c.product_name FROM
	(SELECT a.customer_id, a.order_date, b.product_name,
    RANK() OVER (PARTITION BY customer_id ORDER BY a.order_date ASC) AS rnk
	FROM sales a
	JOIN menu b
	ON a.product_id = b.product_id
    )c
WHERE rnk = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers??
SELECT a.product_id, b.product_name, 
COUNT(a.product_id) AS count 
FROM sales a
JOIN menu b
ON a.product_id = b.product_id
GROUP BY b.product_name 
ORDER BY count DESC 
LIMIT 1;


-- 5. Which item was the most popular for each customer?
SELECT c.customer_id, c.product_name count FROM
	(SELECT a.customer_id, a.product_id, b.product_name, 
	RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(a.product_id) DESC) AS rnk
	FROM sales a
	JOIN menu b
	ON a.product_id = b.product_id 
	GROUP BY customer_id, product_id
    ) c
WHERE rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT c.customer_id, d.product_name 
FROM
# to get the first date purchased after becaming a member
	(SELECT a.customer_id, MIN(a.order_date), a.product_id
	FROM sales a
	JOIN members b
	ON a.customer_id = b.customer_id
	WHERE a.order_date >= b.join_date
	GROUP BY customer_id
    ) c
JOIN menu d
ON c.product_id = d.product_id;

-- 7. Which item was purchased just before the customer became a member?
SELECT c.customer_id, d.product_name
FROM
	(SELECT a.customer_id, a.product_id, 
    RANK() OVER (PARTITION BY a.customer_id ORDER BY a.order_date DESC) as rnk
    FROM sales a
    JOIN members b
    ON a.customer_id = b.customer_id
    WHERE a.order_date < b.join_date
    ) c
JOIN menu d
ON c.product_id = d.product_id
WHERE rnk = 1
GROUP BY c.customer_id, d.product_name
ORDER BY c.customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT c.customer_id, d.product_name, c.count * d.price as total_spent
FROM
    (SELECT a.customer_id, a.product_id, COUNT(a.product_id) as count
    FROM sales a
    JOIN members b
    ON a.customer_id = b.customer_id
    WHERE a.order_date < b.join_date
    GROUP BY a.customer_id, a.product_id
    ) c
JOIN menu d
ON c.product_id = d.product_id
ORDER BY c.customer_id; 

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT b.customer_id, SUM(a.points) AS total_points
FROM 
	(SELECT *, 
    CASE
		WHEN product_id = 1 THEN price * 20
        ELSE price * 10
        END AS points
	FROM menu m
    ) a
JOIN sales b
ON a.product_id = b.product_id
GROUP BY b.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
WITH dates AS 
(
   SELECT *, 
      DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date, 
      LAST_DAY('2021-01-31') AS last_date
   FROM members 
)
Select S.Customer_id, 
       SUM(
	   Case 
	  When m.product_ID = 1 THEN m.price*20
	  When S.order_date between D.join_date and D.valid_date Then m.price*20
	  Else m.price*10
	  END 
	  ) as Points
From Dates D
join Sales S
On D.customer_id = S.customer_id
Join Menu M
On M.product_id = S.product_id
Where S.order_date < d.last_date
Group by S.customer_id;



