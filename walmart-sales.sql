-- ------------------------------ DATA PREPARATION ------------------------------
-- A. Data Collection
-- 1. Create database 
create database walmart_walmartsales;
use walmart_walmartsales;

-- 2. Create table
CREATE TABLE IF NOT EXISTS walmartsales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6 , 4 ) NOT NULL,
    total DECIMAL(12 , 4 ) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_percentage FLOAT(11 , 9 ),
    gross_income DECIMAL(12 , 4 ) NOT NULL,
    rating FLOAT(2 , 1 )
);

-- ------------------------------ DATA UNDERSTANDING ------------------------------
-- Check table structure
DESCRIBE walmartsales;

-- ------------------------------ DATA WRAGLING ------------------------------
-- 1. Check missing value
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE
        WHEN invoice_id IS NULL THEN 1
        ELSE 0
    END) AS missing_invoice_id,
    SUM(CASE
        WHEN branch IS NULL THEN 1
        ELSE 0
    END) AS missing_branch,
    SUM(CASE
        WHEN city IS NULL THEN 1
        ELSE 0
    END) AS missing_city,
    SUM(CASE
        WHEN customer_type IS NULL THEN 1
        ELSE 0
    END) AS missing_customer_type,
    SUM(CASE
        WHEN gender IS NULL THEN 1
        ELSE 0
    END) AS missing_gender,
    SUM(CASE
        WHEN product_line IS NULL THEN 1
        ELSE 0
    END) AS missing_product_line,
    SUM(CASE
        WHEN unit_price IS NULL THEN 1
        ELSE 0
    END) AS missing_unit_price,
    SUM(CASE
        WHEN quantity IS NULL THEN 1
        ELSE 0
    END) AS missing_quantity,
    SUM(CASE
        WHEN total IS NULL THEN 1
        ELSE 0
    END) AS missing_total,
    SUM(CASE
        WHEN date IS NULL THEN 1
        ELSE 0
    END) AS missing_date,
    SUM(CASE
        WHEN time IS NULL THEN 1
        ELSE 0
    END) AS missing_time,
    SUM(CASE
        WHEN payment IS NULL THEN 1
        ELSE 0
    END) AS missing_payment,
    SUM(CASE
        WHEN rating IS NULL THEN 1
        ELSE 0
    END) AS missing_rating
FROM walmartsales;

-- 2. Duplicate check (invoice_id)
SELECT 
    invoice_id, COUNT(*)
FROM
    walmartsales
GROUP BY invoice_id
HAVING COUNT(*) > 1;

-- B. DATA TRANSFORMATION
-- Check data consistency
SELECT DISTINCT branch
FROM walmartsales;

SELECT DISTINCT city
FROM walmartsales;

SELECT DISTINCT customer_type
FROM walmartsales;

SELECT DISTINCT gender
FROM walmartsales;

SELECT DISTINCT product_line
FROM walmartsales;

SELECT DISTINCT payment
FROM walmartsales;

-- 2. Outlier Check
-- Identify price outliers
SELECT *
FROM walmartsales
WHERE
    Unit_price < 0
        OR Unit_price > (SELECT 
            AVG(Unit_price) + 3 * STDDEV(Unit_price)
        FROM walmartsales);

-- 3. Data Consistency Validation
-- Check inconsistency between Tax & Total
SELECT *
FROM walmartsales
WHERE
    ABS((Total - cogs) - Tax) > 0.01;-- Rounding tolerance

-- Add column
-- Time of day
SELECT time,
    (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_day
FROM walmartsales;

ALTER TABLE walmartsales ADD COLUMN time_of_day VARCHAR(20);

UPDATE walmartsales 
SET 
    time_of_day = (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END);

-- 2. Day
SELECT date, 
		DAYNAME(date)
FROM walmartsales;

ALTER TABLE walmartsales 
ADD COLUMN day_name VARCHAR(10);

UPDATE walmartsales 
SET day_name = DAYNAME(date);

-- 3. Month
SELECT date, 
		MONTHNAME(date)
FROM walmartsales;

ALTER TABLE walmartsales 
ADD COLUMN month_name VARCHAR(10);

UPDATE walmartsales 
SET month_name = MONTHNAME(date);

-- ------------------------------ DATA CLEANING ------------------------------
-- EXPLORATORY DATA ANALYSIS (EDA) 
# 1. Understand Data Structure
-- Check table schema
desc walmartsales;

# 2. Basic Statistical Analysis
-- a. Numerical Statistics (Price, Quantity, Tax, Total, etc.)
SELECT 
    COUNT(*) AS total_transactions,
    ROUND(MIN(Unit_price),2) AS price_min,
    ROUND(MAX(Unit_price),2) AS price_max,
    ROUND(AVG(Unit_price),2) AS avg_price,
    ROUND(MIN(Quantity),2) AS min_quantity,
    ROUND(MAX(Quantity),2) AS max_quantity,
    ROUND(AVG(Quantity),2) AS avg_quantity,
    ROUND(MIN(Total),2) AS total_min,
    ROUND(MAX(Total),2) AS total_max,
    ROUND(AVG(Total),2) AS avg_total,
    ROUND(MIN(Tax),2) AS tax_min,
    ROUND(MAX(tax),2) AS tax_max,
    ROUND(AVG(tax),2) AS avg_tax,
    ROUND(MIN(rating),2) AS rating_minimun,
    ROUND(MAX(rating),2) AS rating_maximun,
    ROUND(AVG(rating),2) AS avg_rating,
	ROUND(MIN(cogs),2) AS cogs_minimun,
    ROUND(MAX(cogs),2) AS cogs_max,
    ROUND(AVG(cogs),2)avg_cogs,
    ROUND(MIN(gross_income),2) AS gross_income_min,
    ROUND(MAX(gross_income),2) AS gross_income_max,
    ROUND(AVG(gross_income),2) AS avg_gross_income,
    ROUND(MIN(gross_margin_percentage),2) AS GMP_min,
    ROUND(MAX(gross_margin_percentage),2) AS GMP_max,
    ROUND(AVG(gross_margin_percentage),2) AS avg_GMP
FROM walmartsales;

-- b. Gross Income & Gross Margin Analysis
SELECT 
    ROUND(AVG(gross_income),2) AS average_gross_income,
    FORMAT(SUM(gross_income),2) AS total_gross_income,
    ROUND(AVG(gross_margin_percentage),2) AS average_margin
FROM walmartsales;

# 3. Customer Segmentation
-- Customer segmentation by purchase behavior
SELECT 
    customer_type,
    ROUND(AVG(total),2) AS avg_transaction_value,
    ROUND(AVG(quantity),2) AS avg_quantity,
    ROUND(AVG(unit_price),2) AS avg_unit_price,
    COUNT(DISTINCT invoice_id) AS transaction_count
FROM
    walmartsales
GROUP BY customer_type;

# 4. Revenue Distribution
-- a. Revenue by product line
SELECT 
    product_line,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue,
    COUNT(*) AS transactions,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(unit_price),2) AS avg_price
FROM
    walmartsales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- b. Revenue by customer type
SELECT 
    customer_type,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue,
    COUNT(*) AS transactions,
    ROUND(AVG(total),2) AS avg_transaction_value
FROM
    walmartsales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- c. Revenue by branch & city
SELECT 
    branch,
    city,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue,
    COUNT(*) AS transactions
FROM
    walmartsales
GROUP BY branch , city
ORDER BY total_revenue DESC;

# 5. Categorical Analysis
-- a. Branch & City Distribution
SELECT 
    Branch, 
    City, 
    COUNT(*) AS number_transactions,
    CONCAT(ROUND(COUNT(*) * 100.0 / 
    (SELECT COUNT(*) FROM walmartsales), 2)) AS percentage
FROM walmartsales
GROUP BY Branch, City
ORDER BY number_transactions DESC;

-- b. Customer Type & Gender
SELECT 
    customer_type, 
    Gender,
    COUNT(*) AS total_transactions,
    ROUND(AVG(Total),2) AS average_purchase
FROM walmartsales
GROUP BY customer_type, Gender
ORDER BY total_transactions DESC;

-- c. Payment Method
SELECT 
    payment,
    COUNT(*) AS total_transactions,
    ROUND(AVG(Total),2) AS average_payment
FROM walmartsales
GROUP BY Payment
ORDER BY average_payment DESC;

-- d. Customer type & branch
SELECT 
    branch,
    customer_type,
    COUNT(*) AS transactions,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue
FROM
    walmartsales
GROUP BY branch , customer_type
ORDER BY branch , total_revenue DESC;

# 6. Date and Time Analysis
-- a. Daily/Monthly Trend
-- Number of transactions per day
SELECT
	date,
	DAYNAME(date) as day,
	COUNT(*) AS total_transactions
FROM walmartsales
GROUP BY date, day
ORDER BY date ASC;

-- Average sales per hour
SELECT 
    HOUR(time) AS hour,
    ROUND(AVG(Total),2) AS average_sales_per_hour
FROM walmartsales
GROUP BY HOUR(time)
ORDER BY HOUR(time);

-- Hourly sales patterns
SELECT 
    time, FORMAT(ROUND(SUM(total),2),2) AS total_revenue, COUNT(*) AS transactions
FROM
    walmartsales
GROUP BY time
ORDER BY time;

-- b. Date with Highest Sales
SELECT 
    date,
    DAYNAME(date) as day,
    FORMAT(ROUND(SUM(Total), 2), 2) AS total_revenue,
    COUNT(*) AS total_transactions
FROM walmartsales
GROUP BY date
ORDER BY SUM(Total) DESC;

# 7. Product Line Analysis
-- a. Best-Selling Products
SELECT 
    product_line,
    COUNT(*) AS total_transactions,
    SUM(Quantity) AS total_sold,
	FORMAT(ROUND(SUM(Total), 2), 2) AS total_revenue
FROM walmartsales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- b. Correlation between Product Line and Rating
SELECT 
    product_line,
    ROUND(AVG(Rating),2) AS avg_rating
FROM walmartsales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- c. Product performance by gender
SELECT 
    product_line,
    gender,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue,
    COUNT(*) AS transactions
FROM
    walmartsales
GROUP BY product_line , gender
ORDER BY product_line , total_revenue DESC;

# 8. Correlation Analysis & Advanced Insights
-- a. Does Cash Payment Provide a Higher Total?
SELECT 
    payment,
    ROUND(AVG(Total),2) AS avg_total
FROM walmartsales
GROUP BY payment;

-- b. Do Customers Give Higher Ratings at Certain Branches?
SELECT 
    Branch,
    ROUND(AVG(Rating),2) AS avg_rating
FROM walmartsales
GROUP BY Branch
ORDER BY avg_rating DESC;

# 9. Payment Method Analysis
-- Payment method preferences
SELECT 
    payment,
    COUNT(*) AS transactions,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue,
    ROUND(AVG(total),2) AS avg_transaction_value
FROM
    walmartsales
GROUP BY payment
ORDER BY total_revenue DESC;

-- Payment method by customer type
SELECT 
    customer_type,
    payment,
    COUNT(*) AS transactions,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue
FROM
    walmartsales
GROUP BY customer_type , payment
ORDER BY customer_type , total_revenue DESC;

# 10. Ratings Analysis
-- Average ratings by branch
SELECT 
    branch, ROUND(AVG(rating),2) AS avg_rating
FROM
    walmartsales
GROUP BY branch
ORDER BY avg_rating DESC;

-- Average ratings by product_line
SELECT 
    product_line, ROUND(AVG(rating),2) AS avg_rating
FROM
    walmartsales
GROUP BY product_line
ORDER BY avg_rating DESC;

 -- Average ratings by customer_type
SELECT 
    customer_type, ROUND(AVG(rating),2) AS avg_rating
FROM
    walmartsales
GROUP BY customer_type
ORDER BY avg_rating DESC;

# 11. Time Series Analysis
-- Daily sales with 7-time_of_day moving average
SELECT 
    date,
    FORMAT(ROUND(SUM(total), 2), 2) AS daily_sales,
    FORMAT(ROUND(
        AVG(SUM(total)) OVER (
            ORDER BY date 
            ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
        ), 
    2), 2) AS moving_avg_7day
FROM walmartsales
GROUP BY date
ORDER BY date;

# 12. Bivariate Analysis (2 Variables)
-- a. Quantity vs Total Sales Relationship
-- Insight: Do large purchases generate higher revenue?
SELECT 
    Quantity,
    ROUND(AVG(Total),2) AS avg_total,
    FORMAT(SUM(Total),2) AS sum_total,
    COUNT(*) AS transaction_count
FROM walmartsales
GROUP BY Quantity
ORDER BY Quantity;

-- b. Gender vs Payment Method
-- Insight: Do certain genders tend to use certain payments?
SELECT 
    Gender,
    Payment,
    COUNT(*) AS transaction_count,
    CONCAT(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) 
    OVER (PARTITION BY Gender), 2), "%") AS percentage
FROM walmartsales
GROUP BY Gender, Payment
ORDER BY Gender, transaction_count DESC;

-- c. Product Line vs Customer Rating
-- Insight: Which products get the highest/lowest ratings?
SELECT 
    product_line,
    ROUND(AVG(Rating),2) AS avg_rating,
    COUNT(*) AS transaction_count
FROM walmartsales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- d. Time (Hours) vs Average Sales
-- Insight: What time of day is the highest sales?
SELECT 
    HOUR(Time) AS hour_of_day,
    ROUND(AVG(Total),2) AS avg_sale_amount,
    COUNT(*) AS transaction_count
FROM walmartsales
GROUP BY HOUR(Time)
ORDER BY hour_of_day;

# 13. Multivariate Analysis (3+ Variables)
-- a. Branch + Product Line + Total Sales
-- Insight: What products sell best in each branch?
SELECT 
    branch,
    product_line,
    FORMAT(ROUND(SUM(total),2),2) AS total_revenue,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total) * 100.0 / SUM(SUM(Total)) 
    OVER (PARTITION BY Branch), 2) AS sales_percentage
FROM walmartsales
GROUP BY branch, product_line
ORDER BY branch, total_revenue DESC;

-- b. Customer Type + Payment Method + Average Purchase
-- Insight: Do members/non-members have different payment preferences?
SELECT 
    customer_type,
    payment,
    ROUND(AVG(total),2) AS avg_purchase_amount,
    COUNT(*) AS transaction_count
FROM walmartsales
GROUP BY customer_type, payment
ORDER BY customer_type, avg_purchase_amount DESC;

-- c. Day + Gender + Average Rating
-- Insight: Do ratings differ by day and gender?
SELECT 
    date,
    Gender,
    ROUND(AVG(Rating),2) AS avg_rating,
    COUNT(*) AS transaction_count
FROM walmartsales
GROUP BY date, gender
ORDER BY date, avg_rating DESC;

-- d. Multivariate Analysis with Complex Conditions
-- Insight: What combination generates the highest sales for transactions with quantity > 5?
SELECT 
    branch,
    customer_type,
    product_line,
    ROUND(AVG(Total),2) AS avg_sale,
    ROUND(AVG(Rating),2) AS avg_rating,
    COUNT(*) AS transactions
FROM walmartsales
WHERE quantity > 5
GROUP BY branch, customer_type, product_line
HAVING COUNT(*) > 10
ORDER BY avg_sale DESC;

-- 14. Numerical Correlation Analysis
-- Insight: How strong is the relationship between quantity/price and total sales?
-- Correlation between Quantity, Unit Price, and Total
SELECT 
    ROUND(
        (COUNT(*) * SUM(Quantity * Total) - SUM(Quantity) * SUM(Total)) / 
        SQRT(
            (COUNT(*) * SUM(Quantity*Quantity) - SUM(Quantity)*SUM(Quantity)) * 
            (COUNT(*) * SUM(Total*Total) - SUM(Total)*SUM(Total))),2 
    ) AS qty_total_corr,
    
    ROUND(
        (COUNT(*) * SUM(unit_price * Total) - SUM(unit_price) * SUM(Total)) / 
        SQRT(
            (COUNT(*) * SUM(unit_price * unit_price) - SUM(unit_price)*SUM(unit_price)) * 
            (COUNT(*) * SUM(Total*Total) - SUM(Total)*SUM(Total))), 2) AS price_total_corr
FROM walmartsales;
    
    
-- ---------------------- GENERAL QUESTION -----------------------

# 1. How many unique cities does the data have? 
SELECT DISTINCT city
FROM walmartsales;

# 2. In which city is each branch?
SELECT DISTINCT city, branch
FROM walmartsales;

-- --------------------- PRODUCT -----------------------
# 1. How many unique product lines does the data have? 
SELECT DISTINCT product_line
FROM walmartsales;

# 2. What is the most selling product line? 
SELECT 
		product_line, 
		SUM(quantity) AS total_quantity
FROM walmartsales
GROUP BY product_line
ORDER BY total_quantity DESC;

# 3. What is the most common payment method? 
SELECT 
    payment, 
    COUNT(payment) AS total_payment
FROM walmartsales
GROUP BY payment
ORDER BY total_payment DESC;

# 4. What is the total revenue by month? 
SELECT 
    month_name AS month, 
    FORMAT(ROUND(SUM(Total),2),2) AS total_revenue
FROM walmartsales
GROUP BY month_name
ORDER BY ROUND(SUM(Total),2) DESC;

# 5. What month had the largest COGS? 
SELECT 
    month_name AS month, 
    FORMAT(ROUND(SUM(cogs), 2), 2) as cogs
FROM walmartsales
GROUP BY month_name
ORDER BY ROUND(SUM(cogs), 2) DESC;

# 6. What product line had the largest revenue? 
SELECT 
    product_line,
    FORMAT(ROUND(SUM(total), 2), 2) AS total_revenue
FROM walmartsales
GROUP BY product_line
ORDER BY total_revenue DESC;

# 7. What is the city with the largest revenue? 
SELECT 
    branch,
    city,
    FORMAT(ROUND(SUM(total), 2), 2) AS total_revenue
FROM walmartsales
GROUP BY city , branch
ORDER BY total_revenue DESC;

# 8. What product line had the largest VAT?
SELECT 
    product_line, 
    ROUND(sum(tax), 2) AS avg_tax
FROM walmartsales
GROUP BY product_line
ORDER BY avg_tax DESC;

# 9. Retrieve each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
    product_line, 
    ROUND(AVG(quantity), 2) AS average_total
FROM walmartsales
GROUP BY product_line
ORDER BY average_total DESC;

SELECT 
    ROUND(AVG(quantity),2) AS avg_qty
FROM walmartsales;

SELECT 
    product_line,
    CASE
        WHEN AVG(quantity) > 6 THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM walmartsales
GROUP BY product_line;

# 10. Which branch sold more products than average product sold?
SELECT 
    branch, 
    FORMAT(SUM(quantity), 0) AS qty
FROM walmartsales
GROUP BY branch
HAVING SUM(quantity) > 
	(SELECT AVG(quantity)
    FROM walmartsales);

# 11. What is the most common product line by gender?
SELECT 
    gender, 
    product_line,
    COUNT(gender) AS total_cnt
FROM walmartsales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

# 12. What is the average rating of each product line?
SELECT 
    product_line, 
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmartsales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- -------------------- SALES -----------------------
# 1. Number of sales made in each time of the day per weekday
SELECT 
    day_name, 
    time_of_day, 
    COUNT(*) AS total_sales
FROM walmartsales
WHERE
    day_name IN ('Sunday' , 'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday')
GROUP BY day_name, time_of_day
ORDER BY total_sales DESC;

# 2. Which of the customer types brings the most revenue?
SELECT 
    customer_type, 
    FORMAT(SUM(total), 2) AS total_revenue
FROM walmartsales
GROUP BY customer_type
ORDER BY total_revenue DESC;

# 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
    city, 
    FORMAT(ROUND(SUM(tax),2),2) AS total_tax
FROM walmartsales
GROUP BY city
ORDER BY total_tax DESC;

# 4. Which customer type pays the most in VAT?
SELECT 
    customer_type, 
    FORMAT(ROUND(SUM(tax),2), 2) AS total_tax
FROM walmartsales
GROUP BY customer_type
ORDER BY total_tax DESC;


-- --------------------- CUSTOMER -----------------------
# 1. How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM walmartsales;

# 2. How many unique payment methods does the data have?
SELECT DISTINCT payment
FROM walmartsales;

# 3. What is the most common customer type?
SELECT 
    customer_type, 
    COUNT(*) AS count
FROM walmartsales
GROUP BY customer_type
ORDER BY count DESC;

# 4. Which customer type buys the most?
SELECT 
    customer_type, 
    COUNT(*)
FROM walmartsales
GROUP BY customer_type;

# 5. What is the gender of most of the customers?
SELECT 
    gender, 
    COUNT(*) AS count
FROM walmartsales
GROUP BY gender
ORDER BY count DESC;

# 6. What is the gender distribution per branch?
SELECT 
    branch, 
    gender, 
    COUNT(*) AS gender_cnt
FROM walmartsales
WHERE branch IN ('A' , 'B', 'C')
GROUP BY branch , gender
ORDER BY gender_cnt DESC;

# 7. Which time of the day do customers give most ratings?
SELECT 
    time_of_day, 
    FORMAT(ROUND(SUM(rating), 2),2) AS total_rating
FROM walmartsales
GROUP BY time_of_day
ORDER BY total_rating DESC;

# 8. Which time of the day do customers give most ratings per branch?
SELECT 
    branch, 
    time_of_day, 
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmartsales
WHERE branch IN ('A' , 'B', 'C')
GROUP BY branch, time_of_day
ORDER BY avg_rating DESC;

# 9. Which day of the week has the best avg ratings?
SELECT 
    day_name, 
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmartsales
GROUP BY day_name
ORDER BY avg_rating DESC;

# 10. Which day of the week has the best average ratings per branch?
SELECT 
    day_name, 
    branch, 
    ROUND(AVG(rating), 2) AS avg_rating
FROM walmartsales
WHERE branch IN ('A' , 'B', 'C')
GROUP BY branch , day_name
ORDER BY avg_rating DESC;





