# Walmart Data Analysis: End-to-End Project Using PostGreSQL + Python

## Project Overview

![Project Pipeline](https://github.com/najirh/Walmart_SQL_Python/blob/main/walmart_project-piplelines.png)
This end-to-end data analysis project focuses on uncovering key business insights from Walmart sales data. It leverages PostgreSQL for data querying, Python for preprocessing and analysis, and structured problem-solving techniques to address critical business questions.

Designed for aspiring and experienced data analysts, this project enhances SQL querying, data manipulation, and ETL (Extract, Transform, Load) skills—making it a strong addition to any data analytics portfolio.

## 🔍 Business Problems & Objectives

## 1. Customer Behaviour

### Q1: Determine the average, minimum, and maximum rating of each category for each city.

Objective: Analyze customer feedback on product categories across different cities.

Business Impact: Helps identify cities where certain product categories are underperforming in customer satisfaction.

Query Approach:
```sql
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
```sql

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
```sql

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
```sql

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
```sql
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
```sql
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
```sql
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
```sql
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
```sql
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
```sql

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
           ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) /
           NULLIF(LAG(revenue) OVER (ORDER BY month), 0))::NUMERIC, 2) AS growth_rate
    FROM Monthly_Revenue
)
SELECT * 
FROM Revenue_Growth;
```

## ⚙️ Project Workflow

### 1. Set Up the Environment

Tools Used: Visual Studio Code (VS Code), Python, SQL (MySQL and PostgreSQL)

Goal: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

### 2. Set Up Kaggle API
   - **API Setup**: Obtain your Kaggle API token from [Kaggle](https://www.kaggle.com/) by navigating to your profile settings and downloading the JSON file.
   - **Configure Kaggle**: 
      - Place the downloaded `kaggle.json` file in your local `.kaggle` folder.
      - Use the command `kaggle datasets download -d <dataset-path>` to pull datasets directly into your project.


### 3. Download Walmart Sales Data

- **Data Source**: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)
   - **Storage**: Save the data in the `data/` folder for easy reference and access.

### 4. Install Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:
     ```bash
     pip install pandas numpy sqlalchemy mysql-connector-python psycopg2
     ```
   - **Loading Data**: Read the data into a Pandas DataFrame for initial analysis and transformations.

### 5. Explore the Data
   - **Goal**: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
   - **Analysis**: Use functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and remove duplicate entries to avoid skewed results.
   - **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.
   - **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`).
   - **Currency Formatting**: Use `.replace()` to handle and format currency values for analysis.
   - **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
   - **Create New Columns**: Calculate the `Total Amount` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

### 8. Load Data into MySQL and PostgreSQL
   - **Set Up Connections**: Connect to MySQL and PostgreSQL using `sqlalchemy` and load the cleaned data into each database.
   - **Table Creation**: Set up tables in both MySQL and PostgreSQL using Python SQLAlchemy to automate table creation and data insertion.
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.

### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - **Business Problem-Solving**: Write and execute complex SQL queries to answer critical business questions, such as:
     - Revenue trends across branches and categories.
     - Identifying best-selling product categories.
     - Sales performance by time, city, and payment method.
     - Analyzing peak sales periods and customer buying patterns.
     - Profit margin analysis by branch and category.
   - **Documentation**: Keep clear notes of each query's objective, approach, and results.

### 10. Project Publishing and Documentation
   - **Documentation**: Maintain well-structured documentation of the entire process in Markdown or a Jupyter Notebook.
   - **Project Publishing**: Publish the completed project on GitHub or any other version control platform, including:
     - The `README.md` file (this document).
     - Jupyter Notebooks (if applicable).
     - SQL query scripts.
     - Data files (if possible) or steps to access them.




## Requirements

- **Python 3.8+**
- **SQL Databases**: MySQL, PostgreSQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `psycopg2`
- **Kaggle API Key** (for data downloading)

## Getting Started

1. Clone the repository:
   ```bash
   git clone (https://github.com/Swagata-j07/Walmart-SQL-Analysis)
   ```
2. Install Python libraries:
   ```bash
   pip install -r requirements.txt
   ```
3. Set up your Kaggle API, download the data, and follow the steps to load and analyze.



## Project Structure

```plaintext
|-- data/                     # Raw data and transformed data
|-- sql_queries/              # SQL scripts for analysis and queries
|-- notebooks/                # Jupyter notebooks for Python analysis
|-- README.md                 # Project documentation
|-- requirements.txt          # List of required Python libraries
|-- main.py                   # Main script for loading, cleaning, and processing data
```


## Results and Insights

This section will include your analysis findings:
- **Sales Insights**: Key categories, branches with highest sales, and preferred payment methods.
- **Profitability**: Insights into the most profitable product categories and locations.
- **Customer Behavior**: Trends in ratings, payment preferences, and peak shopping hours.

## Future Enhancements

Possible extensions to this project:
- Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
- Additional data sources to enhance analysis depth.
- Automation of the data pipeline for real-time data ingestion and analysis.


## Acknowledgments

- **Data Source**: Kaggle’s Walmart Sales Dataset
- **Inspiration**: Walmart’s business case studies on sales and supply chain optimization.













