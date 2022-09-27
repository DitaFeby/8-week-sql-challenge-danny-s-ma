-- JOIN ALL THE THINGS
-- MAKE IT AS TEMPORARY TABLE BECAUSE WE WILL USE IT FOR THE NEXT STEP
DROP TABLE IF EXISTS join_all;
CREATE TEMPORARY TABLE join_all
SELECT 
	a.customer_id,
    a.order_date,
    b.product_name,
    b.price,
    CASE WHEN a.order_date < c.join_date THEN 'N'
    WHEN a.order_date >= c.join_date THEN 'Y'
    ELSE 'N' END AS members
FROM sales a
LEFT JOIN menu b
ON a.product_id = b.product_id
LEFT JOIN members c
ON a.customer_id = c.customer_id;

-- RANK ALL THE THINGS
SELECT 
	*,
	CASE WHEN members = 'N' THEN NULL 
	ELSE
	RANK () OVER(PARTITION BY customer_id, members ORDER BY order_date) END AS ranking
FROM join_all;







