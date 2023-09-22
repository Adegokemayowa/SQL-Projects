# 🍕 Case Study #2 - Pizza Runner

## 🧼 Data Cleaning & Transformation

### 🔨 Table: customer_orders

Looking at the `customer_orders` table , we can see that there are
- In the `exclusions` column, there are missing/ blank spaces ' ' and text "null"  values. 
- In the `extras` column, there are missing/ blank spaces ' ' and text "null"  values.



Our course of action to clean the table:
- Remove blank spaces text "null" and  in `exlusions` and `extras` columns and set it to be null.

```sql
UPDATE pizza_runner.customer_orders
SET exclusions = 
CASE 
     WHEN exclusions LIKE 'null' OR exclusions = ''
	 THEN NULL
	 ELSE exclusions
	 END,
extras = 
CASE 
     WHEN extras LIKE 'null' OR extras = ''
	 THEN NULL
	 ELSE extras
	 END;
```
***
### 🔨 Table: runner_orders

Our course of action to clean the table:
- In `pickup_time` column, remove the text "null" and set them to be null values.
- In `distance` column, remove "km" and the text "null" and set them to be null values..
- In `duration` column, remove "minutes", "minute", "mins" and the text "null" and set them to be null values.
- In `cancellation` column, reomve the text "null" and set them to be null values.  
	
```sql
UPDATE pizza_runner.runner_orders
SET pickup_time = 
CASE
	  WHEN pickup_time LIKE 'null' THEN NULL
	  ELSE pickup_time
	  END,
distance = 
CASE 
      WHEN distance LIKE 'null' THEN NULL
	  WHEN distance LIKE '%km' THEN TRIM ('km' FROM distance)
	  ELSE distance 
	  END,
duration = 
CASE 
      WHEN duration LIKE 'null' THEN NULL
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END,
cancellation = 
CASE 
      WHEN cancellation LIKE 'null' OR
	  cancellation LIKE '' THEN NULL
	  ELSE cancellation
	  END;
```
***
Then, we alter the `distance` , `duration` and `pickup_time` columns to the correct data type.
```sql	  
ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN distance TYPE FLOAT
USING distance::double precision,
ALTER COLUMN duration TYPE FLOAT
USING duration::double precision,
ALTER COLUMN pickup_time TYPE TIMESTAMP
USING pickup_time::timestamp without time zone;
```	  
***