# Walmart Data Analysis: End-to-End Project Using PostGreSQL + Python

## Project Overview

![Project Pipeline](https://github.com/najirh/Walmart_SQL_Python/blob/main/walmart_project-piplelines.png)
This end-to-end data analysis project focuses on uncovering key business insights from Walmart sales data. It leverages PostgreSQL for data querying, Python for preprocessing and analysis, and structured problem-solving techniques to address critical business questions.

Designed for aspiring and experienced data analysts, this project enhances SQL querying, data manipulation, and ETL (Extract, Transform, Load) skills—making it a strong addition to any data analytics portfolio.

## 🔍 Business Problems & Objectives

## Customer Behaviour

### Q1: Determine the average, minimum, and maximum rating of each category for each city.

Objective: Analyze customer feedback on product categories across different cities.

Business Impact: Helps identify cities where certain product categories are underperforming in customer satisfaction.

Query Approach:
```
sql
      SELECT
            city, 
            category,
            MAX(rating) AS max_rating,
            MIN(rating) AS min_rating,
            ROUND(AVG(rating)::numeric,1) AS avg_rating
      FROM walmart
      GROUP BY 1, 2;

```

### Q2: Identify the highest-rated categories in each branch.

Objective: Find the most preferred product categories per branch based on customer ratings.

Business Impact: Helps in improving inventory and promotional strategies for top-rated categories.

Query Approach:
```
sql

WITH CTE1 AS (SELECT
	  branch,
	  category,
	  AVG(rating) AS avg_rating,
	  RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart
GROUP BY 1, 2)

SELECT *
FROM CTE1
WHERE rank = 1;
```

### Q3: What are the most preferred payment methods for each branch, and how do they correlate with purchase amounts?

Objective: Identify customer payment preferences and analyze their relationship with purchase amounts.

Business Impact: Helps in offering better payment-related promotions or discounts.

Query Approach:
```
sql

WITH rank_payment_method 
AS (
	  SELECT 
		branch,
		payment_method,
		COUNT(*) AS no_of_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1, 2
	)
SELECT * 
FROM rank_payment_method
WHERE rank = 1
```

### Q4: Which branches have the highest customer engagement based on average rating?

Objective: Identify branches with the highest customer satisfaction based on ratings.

Business Impact: Helps in understanding what factors contribute to high engagement and replicating them across other branches.

Query Approach:
```
sql

      SELECT branch,
             city,
             ROUND(AVG(rating)::numeric, 2) AS avg_rating
      FROM walmart
      GROUP BY 1, 2
      ORDER BY avg_rating DESC;
```

## 2. Operational Efficiency & Inventory Management

### Q5: Identify the busiest day for each branch based on the number of transactions.

Objective: Determine which days see the most sales for better workforce planning.

Business Impact: Helps in scheduling staff and stocking up inventory for peak days.

Query Approach:
```
sql
      SELECT * 
      FROM (
      	  SELECT branch, 
             		 TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
      			  COUNT(*) AS no_of_transactions,
      			  RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
            FROM walmart
      	  GROUP BY 1, 2
          )
      WHERE rank = 1
```

### Q6: What is the revenue trend across different time periods (morning, afternoon, evening)?

Objective: Identify how sales vary throughout the day.

Business Impact: Helps optimize staffing, promotional timing, and store operations.

Query Approach:
```
sql
      SELECT branch, 
             CASE 
                 WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
                 WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
                 ELSE 'Evening'
             END AS time_of_day,
             ROUND(SUM(total)::numeric, 2) AS total_revenue
      FROM walmart
      GROUP BY 1, 2
      ORDER BY 1, 3 DESC;

```

## 3. Sales & Revenue Insights

### Q7: Calculate the total profit for each category. List the category and total_profit, ordered from highest to the lowest profit.

Objective: Determine the most profitable product categories.

Business Impact: Helps in product pricing and inventory optimization.

Query Approach:
```
sql
      SELECT category,
	   ROUND(SUM(total)::numeric, 2) AS total_revenue,
	   ROUND(SUM(total * profit_margin)::numeric, 2) AS total_profit
FROM walmart
GROUP BY 1
ORDER BY total_profit DESC;
```

### Q8: Which city has the most frequent high-value purchases (where total > $500 per invoice)?

Objective: Identify the city with the highest number of high-value purchases.

Business Impact: Helps in targeted marketing and premium customer strategies.

Query Approach:
```
sql
      WITH High_Value_Purchases AS (
    SELECT city, 
           category, 
           COUNT(*) AS high_value_count
    FROM walmart
    WHERE total > 500
    GROUP BY city, category
)
SELECT city, 
       category, 
       high_value_count
FROM High_Value_Purchases
WHERE high_value_count = (
    SELECT MAX(high_value_count) 
    FROM High_Value_Purchases
);

```

## 4. Marketing & Promotions
### Q9: Which product category generates the highest total profit in each city?

Objective: Identify the most profitable product category per city.

Business Impact: Helps in targeted stock planning for different cities.

Query Approach:
```
sql
      WITH Category_Profit AS (
    SELECT city, 
           category, 
           ROUND(SUM(unit_price * quantity * profit_margin)::NUMERIC, 2) AS total_profit,
           RANK() OVER(PARTITION BY city ORDER BY SUM(unit_price * quantity * profit_margin) DESC) AS rnk
    FROM walmart
    GROUP BY city, category
)
SELECT city, category, total_profit
FROM Category_Profit
WHERE rnk = 1;
```


### Q10: How is Walmart's revenue growing month-over-month? Find the Monthly Revenue Growth Rate

Objective: Calculate the monthly revenue growth rate.

Business Impact: Helps in understanding the financial trajectory and seasonal trends.

Query Approach:
```
sql

WITH Monthly_Revenue AS (
    SELECT TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'YYYY-MM') AS month, 
           ROUND(SUM(total)::NUMERIC,2) AS revenue
    FROM walmart
    GROUP BY month
),
Revenue_Growth AS (
    SELECT month, 
           revenue, 
           LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
           ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0))::NUMERIC, 2) AS growth_rate
    FROM Monthly_Revenue
)
SELECT * 
FROM Revenue_Growth;
```
























