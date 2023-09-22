# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics
***
### 1. How many pizzas were ordered

````sql
SELECT 
   COUNT(*) AS pizzas_ordered
FROM pizza_runner.customer_orders;
````
| pizzas_ordered |
| ----------- |
| 14          |

- There were 14 pizzas ordered
***

### 2. How many unique customer orders were made?

````sql
SELECT 
   COUNT(DISTINCT order_id) AS unique_order_count
FROM pizza_runner.customer_orders; 
````
| unique_order_count |
| ----------------   |
| 10                 |

- There were 10 unique customer orders 
***

### 3. How many successful orders were delivered by each runner?

````sql
SELECT 
  runner_id, 
  COUNT(order_id) AS successful_orders
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
````
| runner_id  | successful_orders |
| -----------| -----------       |
| 1          |      4            |
| 2          |      3            |
| 3          |      1            |

- Runner 1 had 4 successful deliveries
- Runner 2 had 3 successful deliveries
- Runner 3 had 1 successful delivery

It should be noted that some orders were cancelled which had nothing to fo with the runners

***
### 4.How many of each type of pizza was delivered?

````sql
SELECT 
    p.pizza_name AS pizza_type,
	COUNT(c.pizza_id) AS num_delivered
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.pizza_names AS p
ON c.pizza_id = p.pizza_id
JOIN pizza_runner.runner_orders AS r
ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY pizza_type;
````
| pizza_type  | num_delivered |
| ----------- | -----------   |
| Vegetarian  |      3        |
| Meatlovers  |      9        |

- There are 9 delivered Meatlovers pizzas and 3 Vegetarian pizzas.
***
### 5.How many Vegetarian and Meatlovers were ordered by each customer?

````sql
SELECT 
    c.customer_id AS customer_id,
	p.pizza_name AS pizza_type,
	COUNT(c.pizza_id) AS num_ordered
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.pizza_names AS p
USING (pizza_id)
GROUP BY customer_id,pizza_type
ORDER BY customer_id;
````
|customer_id|pizza_type | num_ordered |
|---|---|---|
|101| Meatlovers | 2 | 
|101| Vegetarian | 1 |
|102| Meatlovers | 2 |
|102| Vegetarian | 1 |
|103| Meatlovers | 3 |
|103| Vegetarian | 1 |
|104| Meatlovers | 3 |
|105| Vegetarian | 1 |

- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 1 Vegetarian pizzas.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 3 Meatlovers pizza.
- Customer 105 ordered 1 Vegetarian pizza.
***
### 6.What was the maximum number of pizzas delivered in a single order?

````sql
WITH pizza_count_cte AS(
SELECT 
	c.order_id,
	COUNT(c.pizza_id) AS pizza_count
	FROM pizza_runner.customer_orders AS c
	JOIN pizza_runner.runner_orders AS r
	USING(order_id)
	WHERE r.cancellation IS NULL
	GROUP BY c.order_id
)
SELECT 
    MAX(pizza_count) AS max_pizzas_delivered
	FROM pizza_count_cte;
	SELECT * FROM pizza_runner.customer_orders;
````

| max_pizzas_delivered |
| ------------------ |
| 3                  |

There were a maximum of 3 pizzas delivered in a single order 
***
### 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT 
	c.customer_id,
	SUM(
		CASE WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1 
		ELSE 0 END
	) AS no_change,
	SUM(
		CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 
		ELSE 0 END
	) AS at_least_1_change
	FROM pizza_runner.customer_orders AS c
	JOIN pizza_runner.runner_orders AS r
	  USING(order_id)
	WHERE r.cancellation IS NULL
	GROUP BY c.customer_id
	ORDER BY c.customer_id;
````    
| customer_id | no_change | at_least_1_change |
|---|---|---|
|101| 2 | 0 |
|102| 3 | 0 |
|103| 0 | 3 |
|104| 1 | 2 |
|105| 0 | 1 |

- Customer 101 and 102 like their pizzas per the original recipe.
- Customer 103, 104 and 105 have their own preference for pizza topping and requested at least 1 change (extra or exclusion topping) on their pizza.
***

### 8.How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT 
    COUNT(r.order_id) pizza_count_w_exclusions_extras
FROM pizza_runner.runner_orders AS r
JOIN pizza_runner.customer_orders AS c
  USING(order_id)
WHERE c.exclusions IS NOT NULL
      AND c.extras IS NOT NULL;
````      
| pizza_count_w_exclusions_extras |
| ------------------ |
| 2                 |

There were two pizzas delivered that had both exclusions and extras
***

### 9.What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT 
    DATE_PART('hour',order_time)AS hour_of_day,
	COUNT(pizza_id) AS pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;
````
| hour_of_day | pizzas_ordered |
|---|---|
| 11 | 1 |
| 13 | 3 |
| 18 | 3 |
| 19 | 1 |
| 21 | 3 |
| 23 | 3 |

- Highest volume of pizza ordered is at 13 (1:00 pm), 18 (6:00 pm), 21 (9:00 pm) and 23 (11:00 pm).
- Lowest volume of pizza ordered is at 11 (11:00 am) and 19 (7:00 pm).
***
### 10.What was the volume of orders for each day of the week?

````sql
SELECT 
 TO_CHAR(order_time,'day') AS order_day,
	COUNT(pizza_id) AS pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY order_day;
````
| order_day | pizzas_ordered |
|---|---|
| wednesday | 5 |
| thursday  | 3 |
| friday    | 1 |
| saturday  | 5 |

- Highest volume of pizza ordered were on Wednesday and Saturday 
- The lowest volume of pizza ordered was on Friday
***

