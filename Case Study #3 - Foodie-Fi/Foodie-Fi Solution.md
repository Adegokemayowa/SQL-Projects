# 🥑 Case Study #3: Foodie-Fi


## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***

## Business Task
Danny and his friends launched a new startup Foodie-Fi and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world.

This case study focuses on using subscription style digital data to answer important business questions on customer journey, payments, and business performances.



**Table 1: `plans`**

There are 5 customer plans.

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their Foodie-Fi service — they will have a Churn plan record with a null price, but their plan will continue until the end of the billing period.

**Table 2: `subscriptions`**

Customer subscriptions show the **exact date** where their specific `plan_id` starts.

If customers downgrade from a pro plan or cancel their subscription — the higher plan will remain in place until the period is over — the `start_date` in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan — the higher plan will take effect straightaway.

When customers churn, they will keep their access until the end of their current billing period, but the start_date will be technically the day they decided to cancel their service.

***

## Question and Solution

## 🎞️ A. Customer Journey

Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about each customer’s onboarding journey.


**Answer:**

```sql
-- For Customer 1
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 1   
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer:**

|customer_id|	plan_id| plan_name	 |start_date|
|-----------|--------|-------------|----------|
|1	        |0	     |trial	       |2020-08-01|
|1	        |1	     |basic monthly|2020-08-08|
- This customer initiated their journey by starting the free trial on 1 Aug 2020. After the trial period ended, on 8 Aug 2020, they subscribed to the basic monthly plan.
```sql
-- For Customer 2
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 2  
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer:**
|customer_id| plan_id| plan_name|start_date|
|-----------|--------|----------|----------|
|2	        |0	     |trial	    |2020-09-20|
|2	        |3	     |pro annual|2020-09-27|

- This customer started thier journey journey with the free trial on the 20th of September 2020 and moved on to the pro annual plan after the trial period ended on 27th of Septomber 2020
```sql
-- For Customer 11
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 11  
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer:**

|customer_id|	plan_id| plan_name	 |start_date|
|-----------|--------|-------------|----------|
|11	        |0	     |trial	       |2020-11-19|
|11	        |4	     |churn        |2020-11-26|

- This customer started with the trial plan on the 19th of November 2020 and churned right after the trial plan ended on the 26th of November 2020
```sql
-- For Customer 13
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 13  
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer:**
|customer_id|	plan_id| plan_name	 |start_date|
|-----------|--------|-------------|----------|
|13	        |0	     |trial	       |2020-12-15|
|13	        |1	     |baic monthly |2020-12-22|
|13	        |2	     |pro monthly  |2021-03-29|

- The onboarding journey for this customer began with a free trial on 15 Dec 2020. Following the trial period, on 22 Dec 2020, they subscribed to the basic monthly plan. After three months, on 29 Mar 2021, they upgraded to the pro monthly plan.
```sql
-- For Customer 15
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 15  
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer:** 
|customer_id|	plan_id| plan_name	 |start_date|
|-----------|--------|-------------|----------|
|15	        |0	     |trial	       |2020-03-17|
|15	        |2	     |pro monthly  |2020-03-24|
|15	        |4	     |churn        |2021-04-29|

- Initially, this customer commenced their onboarding journey with a free trial on 17 Mar 2020. Once the trial ended, on 24 Mar 2020, they upgraded to the pro monthly plan. However, the following month, on 29 Apr 2020, the customer decided to terminate their subscription and subsequently churned until the paid subscription ends. 

```sql
-- For Customer 16
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 16  
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer**
|customer_id|	plan_id| plan_name	 |start_date|
|-----------|--------|-------------|----------|
|16	        |0	     |trial	       |2020-05-31|
|16	        |1	     |basic monthly|2020-06-07|
|16	        |3	     |pro annual   |2021-10-21|

-  Initially, this customer commenced their onboarding journey with a free trial on 31 May 2020. Once the trial ended, on 7 June  2020, they upgraded to the basic monthly plan. On 21 October 2021, the customer decided to upgrade their subscription to the pro annual plan. 
```sql
-- For Customer 18
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 18 
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer:**
|customer_id|	plan_id| plan_name	 |start_date|
|-----------|--------|-------------|----------|
|18	        |0	     |trial	       |2020-05-31|
|18	        |1	     |pro monthly  |2020-06-07|

- This customer started their journey with the trial plan on 31 May 2020 and upgraded to the pro monthly plan after the trial plan ended on 7 June 2020 
```sql
-- For Customer 19
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans 
  USING (plan_id)
WHERE customer_id = 19  
GROUP BY customer_id,plan_id,plan_name,start_date
ORDER BY customer_id;
```
**Answer:**
|customer_id|	plan_id| plan_name	 |start_date|
|-----------|--------|-------------|----------|
|19	        |0	     |trial	       |2020-06-22|
|19	        |1	     |pro monthly  |2020-06-29|
|19	        |3	     |pro annual   |2021-08-21|

- This customer started theor onboarding journey with the trial plan on 22 June 2020 and upgraded to the pro monthly plan right after on 29 June 2020. About a little over a year after the customer changed plans to the pro annual plan on 21 August 2021 
***















## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

To determine the count of unique customers for Foodie-Fi, I utilize the `COUNT()` function wrapped around `DISTINCT`.

```sql
SELECT 
	COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions;
```

**Answer:**
|count|
|-----|
|1000 |


- Foodie-Fi has 1,000 unique customers.
***
### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

In other words, the question is asking for the monthly count of users on the trial plan subscription.
- To start, extract the numerical value of month from `start_date` column using the `EXTRACT` function, specifying the 'month' part of a date. 
- Filter the results to retrieve only users with trial plan subscriptions (`plan_id = 0). 

```sql
SELECT 
	EXTRACT(MONTH FROM start_date) AS month,
	COUNT(*)
FROM foodie_fi.subscriptions
WHERE plan_id = 0
GROUP BY month
ORDER BY month;
```

**Answer:**
|month|count|
|-----|-----|
|1    |	88  |
|2    |	68  |
|3    |	94  |
|4    |	81  |
|5    |	88  |
|6    |	79  |
|7    |	89  |
|8    |	88  |
|9    |	87  | 
|10   |	79  |
|11   |	75  | 
|12   |	84  |


- Among all the months, March has the highest number of trial plans, while February has the lowest number of trial plans.
***
### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

To put it simply, we have to determine the count of plans with start dates on or after 1 January 2021 grouped by plan names. 
1. Filter plans based on their start dates by including only the plans occurring on or after January 1, 2021.
2. Calculate the number of customers as the number of events. 
3. Group results based on the plan names. 

````sql
SELECT
	plan_name,
	COUNT(*) AS num_of_events
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
	USING(plan_id)
WHERE start_date > '2020-12-31'
GROUP BY plan_name;	
````

**Answer:**

| plan_name     | num_of_events |
| ------------- | ------------- |
| basic monthly | 8             |
| pro monthly   | 60            |
| pro annual    | 63            |
| churn         | 71            |
***
### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

Let's analyze the question:
- First, we need to determine
  - The number of customers who have churned, meaning those who have discontinued their subscription using a CTE
  - The total number of customers, including both active and churned ones.

- To calculate the churn rate, we divide the number of churned customers by the total number of customers. The result should be rounded to one decimal place.


```sql
WITH churn_cte AS 
(SELECT
	COUNT(DISTINCT customer_id) AS churned_customers
FROM foodie_fi.subscriptions
WHERE plan_id = 4)
SELECT 
	churned_customers,
	ROUND(100 * churned_customers :: NUMERIC / COUNT(DISTINCT customer_id),1) AS pct_churned
FROM
	churn_cte, foodie_fi.subscriptions
GROUP BY churned_customers;
```

**Answer:**
|churned_customers|	pct_churned|
|-----------------|-------------|
|307              |	30.7        | 


- Out of the total customer base of Foodie-Fi, 307 customers have churned. This represents approximately 30.7% of the overall customer count.
***
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

Within a CTE called `ranked_cte`, determine which customers churned immediately after the trial plan by utilizing `ROW_NUMBER()` function to assign rankings to each customer's plans. We will be using the `LEAD()` window function

In the outer query:
- Apply 2 conditions in the WHERE clause:
  - Filter `plan_id = 0`. 
  - Filter  `next_plan = 4`.
- Count the number of customers who have churned immediately after their trial period  
- Calculate the churn percentage by dividing the `churned_customers` count by the total count of distinct customer IDs in the `subscriptions` table. Round percentage to a whole number.


```sql
WITH next_plan_cte AS (
	SELECT *,
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id 
							  ORDER BY start_date) AS next_plan
	 FROM foodie_fi.subscriptions	 
)
SELECT
	COUNT(*) AS churn_after_trial,
	ROUND(100 * COUNT(*) :: NUMERIC/ 
		  (SELECT
		  COUNT(DISTINCT customer_id)
		  FROM foodie_fi.subscriptions) ,0) AS pct_churned
FROM next_plan_cte
WHERE plan_id = 0
AND next_plan = 4;
```

**Answer:**
|churn_after_trial|	pct_churned|
|  -------------  | ---------  |
|92               |	9          |


- A total of 92 customers churned immediately after the initial free trial period, representing approximately 9% of the entire customer base.
***
### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
WITH next_plan_cte AS (
	SELECT *,
		LEAD(plan_name, 1) OVER(PARTITION BY customer_id 
							  ORDER BY start_date) AS next_plan
	 FROM foodie_fi.subscriptions
	 JOIN foodie_fi.plans
	 USING (plan_id )
)
SELECT 
	next_plan,
	COUNT (*) AS count,
	ROUND(100 * COUNT(*) :: NUMERIC/ 
		  (SELECT
		  COUNT(DISTINCT customer_id)
		  FROM foodie_fi.subscriptions) ,1) AS pct
FROM next_plan_cte
WHERE plan_id = 0
	AND next_plan IS NOT NULL
GROUP BY next_plan;
```

**Answer:**


| next_plan     | count | pct    |
| -------       | ------| ------ |
| pro annual    | 37    | 3.7    |
| churn         | 92    | 9.2    |
| pro monthly   | 325   | 32.5   |
| basic monthly | 546   | 54.62  |

- More than 80% of Foodie-Fi's customers are on paid plans with a majority opting for baic and pro monthly plans
- There is potential for improvement in customer acquisition for pro annual plan as only a small percentage of customers are choosing this higher-priced plan.
***
### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

In the cte called `next_date_cte`, we begin by filtering the results to include only the plans with start dates on or before '2020-12-31'. To identify the next start date for each plan, we utilize the `LEAD()` window function.

In the outer query,  we filter the results where the `next_date` is NULL. This step helps us identify the most recent plan that each customer subscribed to as of '2020-12-31'. 

Lastly, we perform calculations to determine the total count of customers and the percentage of customers associated with each trial plan. 

```sql
WITH next_date_cte AS (
	SELECT *,
		LEAD(start_date) OVER(PARTITION BY customer_id 
							  ORDER BY start_date) AS next_date
	 FROM foodie_fi.subscriptions
	 JOIN foodie_fi.plans
	 USING (plan_id)
	 WHERE start_date <= '2020-12-31'
)
SELECT
	plan_id,
	plan_name,
	COUNT (*) AS customer_count,
	ROUND(100 * COUNT(*) :: NUMERIC/ 
		  (SELECT
		  COUNT(DISTINCT customer_id)
		  FROM foodie_fi.subscriptions) ,1) AS pct
FROM next_date_cte
WHERE next_date IS NULL
GROUP BY plan_id,plan_name;
```

**Answer:**
|plan_id |    plan_name  |	customer_count|	pct |
|--------| ------------- | ---------      | --- |
|0       |	trial        |	19            |	1.9 |
|1       |	basic monthly|	224	          | 22.4|
|2       |	pro monthly  |	326	          | 32.6|
|3       |	pro annual   |	195	          | 19.5|
|4       |	churn	       |  236	          | 23.6|
***

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT
	COUNT (DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions
WHERE plan_id = 3
	AND EXTRACT(YEAR FROM start_date) = '2020';
```

**Answer:**
|customer_count|
|--------------|
|195           |


- 195 customers have upgraded to an annual plan in 2020.
***
### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?

This question is straightforward and the query provided is self-explanatory. 

````sql
-- trial_plan CTE: Filter results to include only the customers subscribed to the trial plan.
  WITH trial_plan AS(
	SELECT 
		customer_id,
		start_date AS trial_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 0
), 
-- annual_plan CTE: Filter results to only include the customers subscribed to the pro annual plan.
 annual_plan AS(
	SELECT 
		customer_id,
		start_date AS annual_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 3
)
-- Find the average of the differences between the start date of a trial plan and a pro annual plan.
SELECT 
	ROUND(AVG (a.annual_date -  t.trial_date)::NUMERIC,0) avg_days_to_upgrade
FROM trial_plan AS t
JOIN annual_plan AS a
	ON t.customer_id = a.customer_id;
````

**Answer:**
|avg_days_to_upgrade|
|-------------------|
|195                |


- On average, customers take approximately 105 days from the day they join Foodie-Fi to upgrade to an annual plan.
***
### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)



```sql
-- trial_plan CTE: Filter results to include only the customers subscribed to the trial plan.
WITH trial_plan AS(
	SELECT 
		customer_id,
		start_date AS trial_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 0
),
-- annual_plan CTE: Filter results to only include the customers subscribed to the pro annual plan.
annual_plan AS(
	SELECT 
		customer_id,
		start_date AS annual_date
	FROM foodie_fi.subscriptions
	WHERE plan_id = 3
),
-- bins CTE: Put customers in 30-day buckets based on the average number of days taken to upgrade to a pro annual plan.
bins AS(
	SELECT 
	WIDTH_BUCKET(a.annual_date - t.trial_date, 0, 365, 12) AS avg_days_to_upgrade
	FROM trial_plan AS t
	JOIN annual_plan AS a
		ON t.customer_id = a.customer_id
)
SELECT 
	((avg_days_to_upgrade - 1 ) * 30 || ' - ' || avg_days_to_upgrade * 30 || ' days') AS bucket,
	COUNT(*) AS num_of_customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;
```

**Answer:**

| bucket         | num_of_customers |
| -------------- | ---------------- |
| 0 - 30 days    | 49               |
| 30 - 60 days   | 24               |
| 60 - 90 days   | 35               |
| 90 - 120 days  | 35               |
| 120 - 150 days | 43               |
| 150 - 180 days | 37               |
| 180 - 210 days | 24               |
| 210 - 240 days | 4                |
| 240 - 270 days | 4                |
| 270 - 300 days | 1                |
| 300 - 330 days | 1                |
| 330 - 360 days | 1                |
***
### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH next_plan_cte AS
  (SELECT *,
          LEAD(plan_id, 1) OVER(PARTITION BY customer_id
                                ORDER BY start_date) AS next_plan
   FROM foodie_fi.subscriptions
   WHERE DATE_PART('year', start_date) = 2020)
SELECT COUNT(*) AS churned_customers
FROM next_plan_cte
WHERE plan_id = 2
  AND next_plan = 1;
```

**Answer:**
|churned_customers|
|-----------------|
|0                |

- In 2020, there were no instances where customers downgraded from a pro monthly plan to a basic monthly plan.

***
# 📊 In-depth Analysis of Results

This analysis of Foodie-Fi's subscription data reveals key insights into customer behavior, plan popularity, and churn trends.

Overall Customer Base & Trial Period Performance:
- Foodie-Fi has a solid base of 1,000 unique customers. The monthly distribution of trial plan sign-ups is relatively stable throughout the year, with March seeing the highest number (94) and February the lowest (68). This consistent trial intake is a positive sign for initial customer engagement.

Post-Trial Plan Selection:
- A significant observation is the customer behavior immediately following the free trial. While 92 customers (9% of the total base) churned straight after their trial, a substantial majority convert to paid plans. Specifically:

    - Basic Monthly: 546 customers (54.62%)

    - Pro Monthly: 325 customers (32.5%)

    - Pro Annual: 37 customers (3.7%)

    - Churn: 92 customers (9.2%)

This indicates a strong inclination towards monthly paid plans, particularly the basic monthly option. The relatively low conversion to the Pro Annual plan directly after the trial suggests potential for optimizing the trial-to-annual-plan conversion strategy.

Plan Distribution at Year-End 2020:
- Looking at the customer plan breakdown as of December 31, 2020, we see the following:

	- Basic Monthly: 224 customers (22.4%)

    - Pro Monthly: 326 customers (32.6%)

    - Pro Annual: 195 customers (19.5%)

    - Churn: 236 customers (23.6%)

    - Trial: 19 customers (1.9%)

The churn rate by the end of 2020 was 23.6%, which is a significant portion of the customer base. Interestingly, the Pro Annual plan shows a higher adoption rate by year-end compared to immediate post-trial conversion, suggesting customers might take time to consider the annual commitment.

Annual Plan Upgrades:
- In 2020, 195 customers upgraded to an annual plan. On average, it takes approximately 105 days for a customer to upgrade to an annual plan from their initial join date. Breaking this down into 30-day periods reveals that the highest number of annual plan upgrades occur within the first 0-30 days (49 customers), followed by 120-150 days (43 customers), 60-90 days (35 customers), and 90-120 days (35 customers). This pattern indicates that while some customers commit early, a substantial group deliberates for several months before making the annual commitment.

Lack of Downgrades:
- A notable finding is that no customers downgraded from a Pro Monthly to a Basic Monthly plan in 2020. This is a positive indicator, suggesting satisfaction among Pro Monthly subscribers and potentially effective value proposition for that tier.

Summary of Customer Journeys:
The individual customer journeys demonstrate varied paths:

- Some transition smoothly from trial to basic monthly (Customer 1).

- Others quickly adopt the pro annual plan after trial (Customer 2).

- A segment churns immediately after the trial (Customer 11).

- Some customers upgrade gradually, moving from basic to pro monthly (Customer 13).

- Others upgrade to pro monthly but then churn later (Customer 15).

- There are also customers who start with basic monthly and eventually upgrade to pro annual (Customer 16).

***
# 💡 Recommendations for Foodie-Fi

Based on the analysis, here are some recommendations for Foodie-Fi to optimize customer engagement, reduce churn, and drive plan upgrades:

Enhance Trial-to-Annual Conversion:

- Offer Incentives for Early Annual Upgrade: Since only 3.7% of customers immediately upgrade to the Pro Annual plan after the trial, consider offering a significant discount or bonus features for those who commit to the annual plan during or immediately after the 7-day trial.

- Highlight Long-Term Value: During the trial, emphasize the cost savings and added benefits of the Pro Annual plan compared to monthly options. Use clear visual comparisons on the pricing page.

- Targeted Communication: Implement automated email sequences during the trial to showcase the advantages of the Pro Annual plan, perhaps with testimonials from satisfied annual subscribers.

Churn Prevention Post-Trial:

- Exit Survey for Churners: For the 9% of customers who churn immediately after the trial, implement a mandatory (but quick) exit survey to understand their reasons for leaving. This feedback is invaluable for identifying pain points or unmet expectations.

- Re-engagement Campaign: For customers who churn after the trial, consider a short-term, special offer to entice them back within a few weeks, focusing on addressing common reasons for churn identified in surveys.

Optimize the Basic Monthly to Pro Monthly/Annual Upgrade Path:

- Feature Gaps & Upsell Prompts: Since a large portion of customers opt for the Basic Monthly plan initially, strategically highlight the exclusive features of the Pro Monthly and Pro Annual plans (e.g., unlimited access, offline downloads) at opportune moments within the app. For example, if a basic user tries to download a video, prompt them with an upgrade option.

- Tiered Feature Showcase: Clearly illustrate the value proposition of each tier, showing what features are gained at each upgrade level. A visual comparison chart would be beneficial.