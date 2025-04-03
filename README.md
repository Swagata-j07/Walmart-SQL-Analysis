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
