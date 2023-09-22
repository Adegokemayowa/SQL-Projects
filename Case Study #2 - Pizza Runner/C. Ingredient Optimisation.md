# 🍕 Case Study #2 Pizza Runner

## Solution - C. Ingredient Optimisation

### 1.What are the standard ingredients for each pizza?

````sql
SELECT
  pizza_name,
  STRING_AGG(topping_name, ', ') AS toppings
FROM
  pizza_runner.pizza_toppings AS t,
  pizza_runner.pizza_recipes AS r
  JOIN pizza_runner.pizza_names AS n 
  ON r.pizza_id = n.pizza_id
WHERE
  t.topping_id IN (
    SELECT
      UNNEST(STRING_TO_ARRAY(r.toppings, ',') :: int [])
  )
GROUP BY pizza_name;
````
| pizza_name | toppings |
|---|---|
| Meatlovers |Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami|
|Vegetarian|Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce|

***
### 2.What was the most commonly added extra?

````sql
WITH extras_cte AS(
SELECT
	order_id,
	UNNEST(STRING_TO_ARRAY(extras, ','):: int[]) AS topping_id
	FROM pizza_runner.customer_orders
	WHERE extras IS NOT NULL
)

SELECT 
    topping_name,
	COUNT(topping_name) AS num_of_pizzas,
	RANK() OVER(ORDER BY COUNT(topping_name) DESC) AS rank
FROM 
    pizza_runner.pizza_toppings AS t
	JOIN extras_cte AS et
    USING(topping_id) 	
GROUP BY topping_name
ORDER BY rank
LIMIT 1;
````
| topping_name | number_of_pizzas | rank |
| ---------------- | ---------------- | --- |
| Bacon            | 4                |  1  |

_The most poplular topping added as an extra is bacon. It was added as extra to 4 pizzas_
***
### 3.What was the most common exclusion?

````sql
WITH exclusions_cte AS(
SELECT
	order_id,
	UNNEST(STRING_TO_ARRAY(exclusions, ','):: int[]) AS topping_id
	FROM pizza_runner.customer_orders
	WHERE exclusions IS NOT NULL
)

SELECT 
    topping_name,
	COUNT(topping_name) AS num_of_pizzas,
	RANK() OVER(ORDER BY COUNT(topping_name) DESC) AS rank
FROM 
    pizza_runner.pizza_toppings AS t
	JOIN exclusions_cte AS ex
    USING(topping_id) 	
GROUP BY topping_name
ORDER BY rank
LIMIT 1;
````
| topping_name | number_of_pizzas | rank |
| ---------------- | ---------------- | --- |
| Cheese            | 4                |  1  |

_The most common exclusion is cheese. It was excluded from 4 pizzas_
***
### 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
* Meat Lovers 
* Meat Lovers - Exclude Beef
* Meat Lovers - Extra Bacon
* Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
SELECT
  order_id,
  CONCAT(
    pizza_name,
    ' ',
    CASE
      WHEN COUNT(exclusions) > 0 THEN '- Exclude '
      ELSE ''
    END,
    STRING_AGG(exclusions, ', '),
    CASE
      WHEN COUNT(extras) > 0 THEN ' - Extra '
      ELSE ''
    END,
    STRING_AGG(extras, ', ')
  ) AS pizza_name_exclusions_and_extras
FROM
  (
    WITH rank_added AS (
      SELECT *,
        ROW_NUMBER() OVER () AS rank
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      rank,
      ra.order_id,
      pizza_name,
      CASE
        WHEN exclusions IS NOT NULL
        AND topping_id IN (
          SELECT
            UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int [])
        ) THEN topping_name
      END AS exclusions,
      CASE
        WHEN extras IS NOT NULL
        AND topping_id IN (
          SELECT
            UNNEST(string_to_array(extras, ',') :: int [])
        ) THEN topping_name
      END AS extras
    FROM
      pizza_runner.pizza_toppings AS t,
      rank_added as ra
      JOIN pizza_runner.pizza_names AS n 
	  ON ra.pizza_id = n.pizza_id
    GROUP BY
      rank,
      ra.order_id,
      pizza_name,
      exclusions,
      extras,
      topping_id,
      topping_name
  ) AS toppings_as_names
GROUP BY pizza_name, rank, order_id
ORDER BY rank;
``` 
 | order_id | pizza_name_exclusions_and_extras |
|---|---|
|1| Meatlovers  |
|2| Meatlovers  |
|3| Meatlovers  |
|3| Vegetarian  |
|4| Meatlovers - Exclude Cheese |
|4| Meatlovers - Exclude Cheese |
|4| Vegetarian - Exclude Cheese |
|5| Meatlovers  - Extra Bacon |
|6| Vegetarian  |
|7| Vegetarian  - Extra Bacon |
|8| Meatlovers  |
|9| Meatlovers - Exclude Cheese - Extra Bacon, Chicken |
|10| Meatlovers  |
|10| Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese|

 ***
### 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

```sql
SELECT
  order_id,
  CONCAT(
    pizza_name,
    ': ',
    STRING_AGG(
      topping_name,
      ', '
      ORDER BY
        topping_name
    )
  ) AS all_ingredients
FROM
  (
    SELECT
      rank,
      order_id,
      pizza_name,
      CONCAT(
        CASE
          WHEN (SUM(toppings_count) + SUM(extra_count)) > 1 
		  THEN (SUM(toppings_count) + SUM(extra_count)) || 'x'
        END,
        topping_name
      ) AS topping_name
    FROM
      (
        WITH rank_added AS (
          SELECT
            *,
            ROW_NUMBER() OVER () AS rank
          FROM
            pizza_runner.customer_orders
        )
        SELECT
          rank,
          ra.order_id,
          pizza_name,
          topping_name,
          CASE
            WHEN exclusions IS NOT NULL 
            AND t.topping_id IN (
              SELECT
                UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int [])
            ) THEN 0
            ELSE CASE
              WHEN t.topping_id IN (
                SELECT
                  UNNEST(STRING_TO_ARRAY(r.toppings, ',') :: int [])
              ) THEN COUNT(topping_name)
              ELSE 0
            END
          END AS toppings_count,
          CASE
            WHEN extras IS NOT NULL
            AND t.topping_id IN (
              SELECT
                unnest(string_to_array(extras, ',') :: int [])
            ) THEN count(topping_name)
            ELSE 0
          END AS extra_count
        FROM
          rank_added AS ra,
          pizza_runner.pizza_toppings AS t,
          pizza_runner.pizza_recipes AS r
          JOIN pizza_runner.pizza_names AS n ON r.pizza_id = n.pizza_id
        WHERE
          ra.pizza_id = n.pizza_id
        GROUP BY
          pizza_name,
          rank,
          ra.order_id,
          topping_name,
          toppings,
          exclusions,
          extras,
          t.topping_id
      ) tt
    WHERE
      toppings_count > 0
      OR extra_count > 0
    GROUP BY
      pizza_name,
      rank,
      order_id,
      topping_name
  ) cc
GROUP BY
  pizza_name, rank,order_id
ORDER BY rank;
```
| order_id | all_ingredients                                                                     |
| -------- | ----------------------------------------------------------------------------------- |
| 1        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                      |
| 5        | Meatlovers: 2xBacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 7        | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes       |
| 8        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 9        | Meatlovers: 2xBacon, 2xChicken, BBQ Sauce, Beef, Mushrooms, Pepperoni, Salami       |
| 10       | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 10       | Meatlovers: 2xBacon, 2xCheese, Beef, Chicken, Pepperoni, Salami                     |
***
### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
SELECT
  topping_name,
  (SUM(topping_count) + SUM(extras_count)) AS total_ingredients
FROM
  (
    WITH rank_added AS (
      SELECT
        *,
        ROW_NUMBER() OVER () AS rank
      FROM
        pizza_runner.customer_orders
    )
    SELECT
      rank,
      topping_name,
      CASE
        WHEN extras IS NOT NULL
        AND topping_id IN (
          SELECT
            unnest(string_to_array(extras, ',') :: int [])
        ) THEN count(topping_name)
        ELSE 0 END AS extras_count,
      CASE
        WHEN exclusions IS NOT NULL
        AND topping_id IN (
          SELECT
            UNNEST(STRING_TO_ARRAY(exclusions, ',') :: int [])
        ) THEN NULL
        ELSE CASE
          WHEN topping_id IN (
            SELECT
              UNNEST(STRING_TO_ARRAY(toppings, ',') :: int [])
          ) THEN COUNT(topping_name)
        END
      END AS topping_count
    FROM
      pizza_runner.pizza_toppings AS t,
      pizza_runner.pizza_recipes AS r,
      rank_added AS ra,
      pizza_runner.runner_orders AS ro
    WHERE
      ro.order_id = ra.order_id
      and ra.pizza_id = r.pizza_id
      and pickup_time IS NOT NULL
      AND distance IS NOT NULL
      AND duration IS NOT NULL
    GROUP BY
      topping_name,
      exclusions,
      extras,
      toppings,
      topping_id,
      rank
  ) AS topping_count
GROUP BY topping_name
ORDER BY total_ingredients DESC;
```
| topping_name | total_ingredients |
|---|---|
| Bacon | 12 |
| Mushrooms | 11 |
| Cheese | 10 |
| Pepperoni | 9 |
| Salami | 9 |
| Chicken | 9 |
| Beef | 9 |
| BBQ Sauce | 8 |
| Tomatoes"| 3 |
| Onions | 3 |
| Peppers | 3 |
| Tomato Sauce | 3 |

***