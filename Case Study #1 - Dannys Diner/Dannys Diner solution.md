# Case Study 1: Danny's Diner

## Solution

***

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT s.customer_id, SUM(m.price) AS amount_spent
	FROM dannys_diner.sales AS s
	JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
	GROUP BY customer_id
	ORDER BY customer_id;
````

#### Answer:
| Customer_id | Amount_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A, B and C spent $76, $74 and $36 respectivly.

***

### 2. How many days has each customer visited the restaurant?

````sql
SELECT 
      customer_id,
      COUNT(DISTINCT order_date) AS num_of_days
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id;
````

#### Answer:
| Customer_id | num_of_days |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A, B and C visited 4, 6 and 2 times respectivly.

***

### 3. What was the first item from the menu purchased by each customer?

````sql
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
````

#### Answer:
| Customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A's first orders were curry and sushi.
- Customer B's first order is curry.
- Customer C's first order is ramen.

***

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT
	    m.product_name,
	    COUNT( m.product_id) AS num_of_times
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu  AS m
ON s.product_id = m.product_id
GROUP BY m.product_name	
ORDER BY num_of_times DESC
LIMIT 1;
````



#### Answer:
| Product_name  | Num_of_times | 
| ----------- | ----------- |
| ramen       | 8|


- Most purchased item on the menu is ramen which is 8 times.

***

### 5. Which item was the most popular for each customer?

````sql
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
````

#### Answer:
| Customer_id | Product_name |
| ----------- | ---------- |
| A           | ramen        |
| B           | sushi        |
| B           | curry        |
| B           | ramen        |
| C           | ramen        |

- Customer A and C's favourite item is ramen while customer B savours all items on the menu. 

***

### 6. Which item was purchased first by the customer after they became a member?

````sql
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
````


#### Answer:
| customer_id |  product_name |
| ----------- | ----------  |
| A           |  curry        |
| B           |  sushi        |

After becoming a member 
- Customer A's first order was curry.
- Customer B's first order was sushi.

***

### 7. Which item was purchased just before the customer became a member?

````sql
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
````

#### Answer:
| customer_id |product_name |
| ----------- | ----------  |
| A           |  sushi      |
| A           |  curry      |
| B           |   sushi     |

Before becoming a member 
- Customer A’s last orders were sushi and curry.
- Customer B’s last order was sushi.

***

### 8. What is the total items and amount spent for each member before they became a member?

````sql
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

````


#### Answer:
| customer_id |total_items | amount_spent |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 3 |  40       |

Before becoming a member
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

````sql
SELECT 
      s.customer_id,
      SUM(CASE WHEN product_name = 'sushi' THEN price * 20
	  ELSE price * 10 END) AS total_points
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu
USING(product_id)           
GROUP BY s.customer_id
ORDER BY s.customer_id;
````


#### Answer:
| customer_id | total_points | 
| ----------- | -------|
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for customer A, B and C are 860, 940 and 360 respectivly.

***

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

````sql
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
````

#### Answer:
| Customer_id | total_points | 
| ----------- | ---------- |
| A           | 1370 |
| B           | 820 |

- Total points for Customer A and B are 1,370 and 820 respectivly.

***
