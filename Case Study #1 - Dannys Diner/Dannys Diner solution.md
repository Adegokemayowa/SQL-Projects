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


## Executive Summary

Danny's Diner is a Japanese restaurant offering three menu items: sushi ($10), curry ($15), and ramen ($12). This analysis examines customer behavior, spending patterns, and loyalty program effectiveness during the restaurant's initial months of operation in January 2021.

---

## Key Findings

### Customer Behavior Patterns

**Visit Frequency**
- Customer B is the most engaged patron with 6 visits in January 2021
- Customer A showed strong engagement with 4 visits
- Customer C has minimal engagement with only 2 visits

**Spending Analysis**
- Customer A: Total spend of $76
- Customer B: Total spend of $74  
- Customer C: Total spend of $36
- Average transaction value varies significantly across customers, indicating different ordering behaviors

**Product Preferences**
- **Ramen is the star product** - Most popular item overall
- Customer A and C strongly prefer ramen
- Customer B demonstrates balanced preferences across all menu items (sushi, curry, and ramen)
- This diverse preference pattern makes Customer B particularly valuable

### Loyalty Program Performance

**Member Acquisition**
- Customers A and B both joined the loyalty program
- Interestingly, both customers became members shortly after trying sushi
- Customer C has not joined the program despite multiple visits

**Pre-Membership Behavior**
- Customer A spent $25 on 2 items before membership
- Customer B spent $40 on 3 items before membership
- First member order (Customer A): curry

**Points Performance**
- Customer A earned 860 points (standard calculation)
- Customer B earned 940 points (standard calculation)
- Customer C earned 360 points despite not being a member
- With promotional multipliers, Customer A accumulated 1,370 points and Customer B earned 820 points by end of January

---

## Strategic Insights

### 1. Product Strategy

**Ramen as Core Offering**
Ramen's popularity makes it the restaurant's flagship product. This item drives repeat visits and should be protected at all costs in terms of quality and consistency.

**Menu Balance Concerns**
While ramen dominates, the three-item menu lacks variety. This could limit appeal to diverse customer segments and reduce visit frequency over time.

### 2. Customer Segmentation

**High-Value Loyalists (A & B)**
- Frequent visitors with strong engagement
- Responsive to loyalty programs
- Combined represent significant revenue concentration

**At-Risk Customer (C)**
- Low engagement despite having visited
- Has not converted to membership
- Represents untapped potential or poor product-market fit

### 3. Loyalty Program Effectiveness

**Positive Indicators**
- Both members show high visit frequency
- Points system appears to drive engagement
- Sushi may serve as a "gateway" product to membership

**Areas of Concern**
- Only 2 of 3 customers converted to membership (67% conversion)
- Limited data on whether program drives incremental visits or just rewards existing behavior

---

## Business Recommendations

### Immediate Actions (0-30 Days)

1. **Re-engage Customer C**
   - Offer complimentary sushi to entice membership signup (data suggests sushi drives conversions)
   - Direct outreach to understand barriers to engagement
   - Time-limited membership offer with bonus points

2. **Optimize Loyalty Program Communications**
   - Emphasize the 2x multiplier on sushi to drive higher-margin sales
   - Create urgency around promotional point periods
   - Implement push notifications for points balance and rewards

3. **Protect Product Quality**
   - Ensure ramen quality and consistency (it's driving the business)
   - Monitor customer feedback on all items
   - Consider recipe refinement for less popular items

### Short-Term Initiatives (1-3 Months)

4. **Menu Innovation**
   - Test limited-time offerings to increase variety without operational complexity
   - Consider combo meals pairing popular ramen with other items
   - Introduce seasonal specials to drive repeat visits

5. **Enhanced Loyalty Tiers**
   - Implement milestone rewards (e.g., free item at 1,500 points)
   - Create VIP status for top spenders like Customers A & B
   - Offer exclusive perks: priority seating, special servings, early access to new items

6. **Customer Acquisition Focus**
   - The small customer base (only 3 customers) is a critical business risk
   - Implement referral program: give existing members bonus points for bringing friends
   - Partner with local businesses or food delivery platforms

### Medium-Term Strategy (3-6 Months)

7. **Data Infrastructure**
   - Expand data collection: customer demographics, satisfaction scores, time of visits
   - Implement feedback mechanism after each visit
   - Track customer lifetime value and churn indicators

8. **Revenue Diversification**
   - Consider catering or group dining options
   - Explore beverage menu to increase average ticket size
   - Test takeout/delivery to expand market reach

9. **Competitive Positioning**
   - Research local competitive landscape
   - Identify unique value proposition beyond menu items
   - Consider atmosphere, service quality, or authenticity as differentiators

---

## Conclusions

Danny's Diner shows promising customer loyalty among its small base, with the loyalty program demonstrating early effectiveness. However, the business faces existential challenges due to its extremely limited customer base and menu variety.

**Strengths to Leverage:**
- Strong product-market fit for ramen
- Engaged core customers (A & B)
- Functional loyalty program infrastructure

**Critical Gaps:**
- Customer acquisition is the #1 priority
- Menu needs expansion for sustainability
- Risk management required around customer concentration

**Bottom Line:**
The restaurant has demonstrated it can create loyal customers, but urgent action is needed on customer acquisition and menu development. Without expanding the customer base significantly, long-term viability is questionable regardless of how well the loyalty program performs with existing customers.

The data suggests Danny should shift focus from optimizing existing customer spend to aggressive growth in customer count while maintaining the quality that made Customers A and B loyal in the first place.

---

## Next Steps

1. Conduct customer interviews with A, B, and C to understand drivers and barriers
2. Develop 90-day customer acquisition plan with specific targets
3. Test menu additions with existing customers
4. Implement enhanced analytics and tracking
5. Create monthly review cadence to monitor key metrics
6. Consider strategic alternatives if customer growth doesn't materialize within 3 months


