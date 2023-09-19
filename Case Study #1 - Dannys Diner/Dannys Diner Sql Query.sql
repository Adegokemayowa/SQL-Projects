/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
	SELECT s.customer_id, SUM(m.price) AS amount_spent
	FROM dannys_diner.sales AS s
	JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
	GROUP BY customer_id
	ORDER BY customer_id;
-- 2. How many days has each customer visited the restaurant?
SELECT 
      customer_id,
      COUNT(DISTINCT order_date) AS num_of_days
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH RANK AS 
    (SELECT s.customer_id,
	        s.order_date,
	        m.product_name,
	        RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS date_rank
	 FROM dannys_diner.sales AS s
	 JOIN dannys_diner.menu AS m
	 ON s.product_id =  m.product_id
	) 
SELECT customer_id, product_name
FROM RANK
WHERE date_rank = 1
ORDER BY customer_id;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	    m.product_name,
	    COUNT( m.product_id) AS num_of_times
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu  AS m
ON s.product_id = m.product_id
GROUP BY m.product_name	
ORDER BY num_of_times DESC
LIMIT 1;



-- 5. Which item was the most popular for each customer?
WITH CTE AS(
SELECT
        s.customer_id,
	    m.product_name,
	    RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT( s.product_id)  DESC) AS rank
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu  AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
	)
SELECT customer_id, product_name
FROM CTE
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE AS (
    SELECT s.customer_id,
	       m.product_name,
	       RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS date_rank
	FROM dannys_diner.sales as s
	JOIN dannys_diner.menu as m
	ON s.product_id = m.product_id
	JOIN dannys_diner.members as me
	ON s.customer_id = me.customer_id
	WHERE s.order_date >= me.join_date
)
 SELECT customer_id, product_name
 FROM CTE
 WHERE date_rank = 1;
-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS (
    SELECT s.customer_id,
	       m.product_name,
	       RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ) AS date_rank
	FROM dannys_diner.sales as s
	JOIN dannys_diner.menu as m
	ON s.product_id = m.product_id
	JOIN dannys_diner.members as me
	ON s.customer_id = me.customer_id
	WHERE s.order_date < me.join_date
)
 SELECT customer_id, product_name
 FROM CTE
 WHERE date_rank = 1;
-- 8. What is the total items and amount spent for each member before they became a member?
WITH CTE AS (
    SELECT s.customer_id,
	       m.product_id,
	       m.price
	FROM dannys_diner.sales as s
	JOIN dannys_diner.menu as m
	ON s.product_id = m.product_id
	JOIN dannys_diner.members as me
	ON s.customer_id = me.customer_id
	WHERE s.order_date < me.join_date
)
 SELECT customer_id, 
        COUNT(product_id) AS total_items,
		SUM(price) AS amount_spent
 FROM CTE
 GROUP BY customer_id
 ORDER BY customer_id;
/*9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
how many points would each customer have?*/
SELECT 
      s.customer_id,
      SUM(CASE WHEN product_name = 'sushi' THEN price * 20
	  ELSE price * 10 END) AS total_points
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu
USING(product_id)           
GROUP BY s.customer_id
ORDER BY s.customer_id;

/*-- 10. In the first week after a customer joins the program 
(including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?*/
SELECT s.customer_id,
       SUM(CASE WHEN (s.order_date BETWEEN me.join_date AND me.join_date + 6)
		   OR m.product_name = 'sushi' THEN m.price * 20
		   ELSE m.price * 10 END
		  ) AS total_points
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id
JOIN dannys_diner.members AS me
ON s.customer_id = me.customer_id
WHERE s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;  
-- Example Query:
SELECT 
    product_id,
    product_name,
    price
FROM dannys_diner.menu
ORDER BY price DESC
LIMIT 5;