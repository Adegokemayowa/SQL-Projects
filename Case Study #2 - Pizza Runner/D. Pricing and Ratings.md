# 🍕 Case Study #2 Pizza Runner

## Solution - D. Pricing and Ratings

### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
WITH profit_cte AS(
SELECT pizza_name,
	CASE WHEN
	pizza_name = 'Meatlovers' THEN COUNT(pizza_name) * 12
	ELSE COUNT(pizza_name) * 10
	END AS profit
FROM pizza_runner.customer_orders AS c 
	 JOIN pizza_runner.pizza_names AS n
	 ON c.pizza_id = n.pizza_id
	 JOIN pizza_runner.runner_orders AS r
	 ON c.order_id = r.order_id
WHERE
	r.duration IS NOT NULL 
GROUP BY n.pizza_name

)
 SELECT SUM(profit) AS total_profit
 FROM profit_cte;
```
| total_profit |
| ------------ |
| 138          |
- The total profit that would have been made is $138
***
### 2. What if there was an additional $1 charge for any pizza extras?

```sql
WITH profit_cte AS(
SELECT pizza_name,
	CASE WHEN
	pizza_name = 'Meatlovers' THEN COUNT(pizza_name) * 12
	ELSE COUNT(pizza_name) * 10
	END AS profit
FROM pizza_runner.customer_orders AS c 
	 JOIN pizza_runner.pizza_names AS n
	 ON c.pizza_id = n.pizza_id
	 JOIN pizza_runner.runner_orders AS r
	 ON c.order_id = r.order_id
WHERE
	r.duration IS NOT NULL 
GROUP BY n.pizza_name

),

extras_cte AS (
SELECT COUNT(topping_id) AS extras
FROM (
SELECT 
	UNNEST(STRING_TO_ARRAY(extras, ',') :: int[]) AS topping_id
	FROM pizza_runner.customer_orders
)
)

SELECT SUM(profit) + extras AS total_profit
FROM profit_cte,
     extras_cte
GROUP BY extras;
```
| total_profit |
| ------------ |
| 144          |

- The total profit made if there was an additional $1 charge for any pizza extras is $144
***
### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
SET
  search_path = pizza_runner;
DROP TABLE IF EXISTS runner_rating;
CREATE TABLE runner_rating (
    "id" SERIAL PRIMARY KEY,
    "order_id" INTEGER,
    "customer_id" INTEGER,
    "runner_id" INTEGER,
    "rating" INTEGER
  );
INSERT INTO
  runner_rating (
    "order_id",
    "customer_id",
    "runner_id",
    "rating"
  )
VALUES
  ('1', '101', '1', '5'),
  ('2', '101', '1', '5'),
  ('3', '102', '1', '4'),
  ('4', '103', '2', '5'),
  ('5', '104', '3', '5'),
  ('7', '105', '2', '4'),
  ('8', '102', '2', '4'),
  ('10', '104', '1', '5');
```
***
### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
* customer_id
* order_id
* runner_id
* rating
* order_time
* pickup_time
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas

```sql
SELECT 
    c.customer_id,
	r.order_id,
	r.runner_id,
	rating,
	order_time,
	pickup_time,
	ROUND(
		(EXTRACT('Minute' FROM r.pickup_time - c.order_time))
		,2) AS time_btw_order_pickup,
	duration,
	ROUND(AVG(r.distance/r.duration * 60)::numeric, 2) AS avg_speed_in_kmph,
	COUNT(r.order_id) AS total_number_of_pizzas 
FROM
   pizza_runner.customer_orders AS c 
   JOIN pizza_runner.runner_orders AS r
   ON c.order_id=r.order_id
   JOIN pizza_runner.runner_rating AS rr
   ON c.order_id = rr.order_id
GROUP BY
 c.customer_id,
	r.order_id,
	r.runner_id,
	rating,
	order_time,
	pickup_time,
	duration
ORDER BY c.customer_id;
```
| customer_id | order_id | runner_id | rating | order_time | pickup_time | time_btw_order_pickup | duration | avg_speed_in_kmph | total_number_of_pizzas |
|---|---|---|---|---|---|---|---|---|---|
|101|1|1|5| 2020-01-01 18:05:02 | 2020-01-01 18:15:34 | 10.00 |32|37.50|1|
|101|2|1|5|2020-01-01 19:00:52|2020-01-01 19:10:54|10.00|27|44.44|1|
|102|3|1|4|2020-01-02 23:51:23|2020-01-03 00:12:37|21.00| 20 |40.20|2|
|102|8|2|4|2020-01-09 23:54:33|2020-01-10 00:15:02|20.00|15|93.60|1|
|103|4|2|5|2020-01-04 13:23:46|2020-01-04 13:53:03|29.00|40|35.10|3|
|104|5|3|5|2020-01-08 21:00:29|2020-01-08 21:10:57|10.00|15|40.00|1|
|104|10|1|5|2020-01-11 18:34:49|2020-01-11 18:50:20|15.00|10|60.00|2|
|105|7|2|4|2020-01-08 21:20:29|2020-01-08 21:30:45|10.00|25|60.00|1|

***
### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql
WITH profit AS (
  SELECT
    pizza_name,
    CASE
      WHEN pizza_name = 'Meatlovers' THEN COUNT(pizza_name) * 12
      ELSE COUNT(pizza_name) * 10
    END AS profit
  FROM
    pizza_runner.customer_orders AS c
    JOIN pizza_runner.pizza_names AS n 
	ON c.pizza_id = n.pizza_id
    JOIN pizza_runner.runner_orders AS r 
	ON c.order_id = r.order_id
  WHERE duration IS NOT NULL
  GROUP BY pizza_name
    
),
expenses AS (
  SELECT
   SUM (distance * 0.3) AS expense
  FROM
    pizza_runner.runner_orders
   WHERE duration IS NOT NULL
    ) 
SELECT
  SUM(profit) - expense AS net_profit
FROM
  profit,
  expenses
GROUP BY
  expense;
```
| net_profit |
| ---------- |
| 94.44      |  
- Pizza runner will have a net profit of $94.44
***