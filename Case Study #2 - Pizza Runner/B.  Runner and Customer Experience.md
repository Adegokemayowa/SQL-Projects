# 🍕 Case Study #2 Pizza Runner

## Solution - B. Runner and Customer Experience


### 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT 
  DATE_PART('week', registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM pizza_runner.runners
GROUP BY registration_week;
````
| registration_week | runner_signup |
| -------------- | ---------------- |
|  1             | 2                |
|  2             | 1                |
|  3             | 1                |

- On Week 1 of Jan 2021, 2 new runners signed up.
- On Week 2 and 3 of Jan 2021, 1 new runner signed up
***
### 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
SELECT 
    runner_id,
	ROUND(AVG (EXTRACT('Minute' FROM r.pickup_time - c.order_time)),2)AS time_taken_in_min
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r 
USING(order_id)
WHERE r.pickup_time IS NOT NULL
GROUP BY runner_id
ORDER BY runner_id;
````
| runner_id | time_taken_in_min |
|---|---|
|1| 15.33 |
|2| 23.40 |
|3| 10.00 |

- It took runner 1 an average of 15.33 minutes to ariive at pizza runner HQ for pickup
- It took runner 2 an average of 23.4 minutes to ariive at pizza runner HQ for pickup
- It took runner 3 an average of 10 minutes to ariive at pizza runner HQ for pickup
***
### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
WITH prep_time_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.order_id) AS num_of_pizzas,
    AVG(EXTRACT('Minute' FROM r.pickup_time - c.order_time)) AS prep_time_minutes
  FROM pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r
    USING(order_id)
  WHERE r.pickup_time IS NOT NULL
  GROUP BY c.order_id
)

SELECT 
  num_of_pizzas, 
  ROUND(AVG(prep_time_minutes),1) AS avg_prep_time_minutes
FROM prep_time_cte
WHERE prep_time_minutes IS NOT NULL
GROUP BY num_of_pizzas;
````
| num_of_pizzas | avg_prep_time_minutes |
|---|---|
| 3 | 29.0 | 
| 2 | 18.0 | 
| 1 | 12.0 | 

- On average, a single pizza order takes 12 minutes to prepare.
- An order with 3 pizzas takes 29 minutes per pizza.
- It takes 16 minutes to prepare an order with 2 pizzas which is 8 minutes per pizza — making 2 pizzas in a single order the ultimate efficiency rate.
***
### 4.What was the average distance travelled for each customer?

````sql
SELECT 
    c.customer_id,
	ROUND(AVG(r.distance)::numeric,2) AS avg_dist_travelled
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r
 USING(order_id)
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id; 
````
| customer_id | avg_dist_travelled |
|---|---|
|101| 20.00 |
|102| 16.73 |
|103| 23.40 |
|104| 10.00 |
|105| 25.00 |

- Customer 104 had the shortest distance travelled for a delivery with 10km 
- While customer 105 had the longest distance travelled with 25km
***
### 5.What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT 
    MAX(duration) - MIN(duration) AS delivery_time_diff
FROM pizza_runner.runner_orders
WHERE duration IS NOT NULL;
````
| delivery_time_diff | 
|---|
| 30 |

- The difference between longest (40 minutes) and shortest (10 minutes) delivery time for all orders is 30 minutes
***
### 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
SELECT 
  r.runner_id, 
  c.customer_id, 
  c.order_id, 
  COUNT(c.order_id) AS pizza_count, 
  r.distance,
  ROUND((r.distance/r.duration * 60)::numeric, 2) AS avg_speed_in_kmph
FROM pizza_runner.runner_orders AS r
JOIN pizza_runner.customer_orders AS c
  ON r.order_id = c.order_id
WHERE distance IS NOT NULL
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance, r.duration
ORDER BY c.customer_id;
````
| runner_id | customer_id | order_id | pizza_count | distance | avg_speed_in_kmph |
|---|---|---|---|---|---|
|1|101|1| 1 | 20 | 37.50 |
|1|101|2| 1 | 20 | 44.44 |
|1|102|3| 2 | 13.4 | 40.20 |
|2|102|8| 1 | 23.4 | 93.60 |
|2|103|4| 3 | 23.4 | 35.10 |
|1|104|10| 2 | 10 | 60.00 |
|3|104|5| 1 | 10 | 40.00 |
|2|105|7| 1 | 25 | 60.00 |

_(Average speed = Distance in km / Duration in hour)_
- Runner 1’s average speed runs from 37.5km/h to 60km/h.
- Runner 2’s average speed runs from 35.1km/h to 93.6km/h. Danny should investigate Runner 2 as the average speed has a 300% fluctuation rate!
- Runner 3’s average speed is 40km/h
***
### 7.What is the successful delivery percentage for each runner?

````sql
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance IS NULL THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER  BY runner_id;
````
| customer_id | no_change |
|---|---|
|1| 100 | 
|2| 75 | 
|3| 50 | 

- Runner 1 has 100% successful delivery.
- Runner 2 has 75% successful delivery.
- Runner 3 has 50% successful delivery

_(It’s not right to attribute successful delivery to runners as order cancellations are out of the runner’s control.)_
***