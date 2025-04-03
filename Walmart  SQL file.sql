SELECT * FROM walmart;

-- DROP TABLE walmart;

DROP TABLE walmart;


---- Business Problems


--- #Q1 Determine the average, minimum and maximum rating of category for each city. List the city, avg_rating, min_rating and max_rating.


SELECT city, 
	   category,
	   MAX(rating) AS max_rating,
	   MIN(rating) AS min_rating,
	   ROUND(AVG(rating)::numeric,1) AS avg_rating
FROM walmart
GROUP BY 1, 2;


--- #Q2 Identify the highest-rated categories in each branch, displaying the branch, category and average rating.


SELECT *
FROM 
( SELECT
	  branch,
	  category,
	  AVG(rating) AS avg_rating,
	  RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart
GROUP BY 1, 2
)
WHERE rank = 1


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



--- #Q3 Identify the busiest day for each branch based on the number of transactions.



SELECT * 
FROM (
	  SELECT branch, 
       		 TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
			  COUNT(*) AS no_of_transactions,
			  RANK() OVER(PARTITION BY branch ORDER BY   COUNT(*) DESC) AS rank
      FROM walmart
	  GROUP BY 1, 2
    )
WHERE rank = 1



--- #Q4 What are the most preferred payment methods for each branch, and how do they correlate with purchase amounts?


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



--- #Q5 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
--- List the category and total_profit, ordered from highest to the lowest profit.



SELECT category,
	   ROUND(SUM(total)::numeric, 2) AS total_revenue,
	   ROUND(SUM(total * profit_margin)::numeric, 2) AS total_profit
FROM walmart
GROUP BY 1
ORDER BY total_profit DESC;



--- #Q6 What is the revenue trend across different time periods (morning, afternoon, evening)?
--- Find out each of the shift and number of invoices



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



--- #Q7: Which branches have the highest customer engagement based on average rating?


SELECT branch,
 	   city,
	   ROUND(AVG(rating)::numeric, 2) AS avg_rating
FROM walmart
GROUP BY 1, 2
ORDER BY avg_rating DESC;



--- #Q8: Which city has the most frequent high-value purchases (where total > $500 per invoice)?
--- Which category contributes the most to these high-value purchases in that city?



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



--- #Q9: Which product category generates the highest total profit in each city?


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



--- Find the Monthly Revenue Growth Rate
--- #Q10: How is Walmart's revenue growing month-over-month?

-- Formula: (Current Month Revenue - Previous Month Revenue) / Previous Month Revenue)


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

























