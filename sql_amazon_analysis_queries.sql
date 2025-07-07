--   Analysis 1 Q1

--   To simplify its financial reports, Amazon India needs to standardize payment values. Round
--   the average payment values to integer (no decimal) for each payment type and display the
--   results sorted in ascending order.

-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Selecting payment type and rounding the average payment value for each type
SELECT 
    payment_type, 
    ROUND(AVG(payment_value)) AS rounded_avg_payment
FROM 
    amazon_brazil.payments
-- Grouping by payment type
GROUP BY 
    payment_type
-- Ordering results in ascending order by rounded average payment
ORDER BY 
    rounded_avg_payment ASC;








--    Analysis 1 Q2

--    To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type.
--    Calculate the percentage of total orders for each payment type, rounded to one decimal place,
--    and display them in descending order.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Calculating the percentage of total orders for each payment type
SELECT  
    p.payment_type,  
    ROUND(COUNT(p.order_id) * 100.0 / SUM(COUNT(p.order_id)) OVER (), 1) AS percentage_orders  
FROM  
    amazon_brazil.payments p  
GROUP BY  
    p.payment_type  
ORDER BY  
    percentage_orders DESC;










--   Analysis 1 Q3

--   Amazon India seeks to create targeted promotions for products within specific price ranges.
--   Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name.
--   Display these products, sorted by price in descending order.



-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Select distinct product_id and price for products in categories containing 'Smart' and priced between 100 and 500 BRL
SELECT DISTINCT 
     oi.product_id, 
     oi.price
FROM 
     amazon_brazil.order_items oi
-- Join with product table to filter based on product category names
JOIN 
     amazon_brazil.product p
 ON
      oi.product_id = p.product_id
-- Filter for products with price between 100 and 500 BRL and in categories containing 'Smart'
WHERE 
     oi.price BETWEEN 100 AND 500 
     AND p.product_category_name ILIKE '%Smart%'
-- Sort results by price in descending order
ORDER BY 
    oi.price DESC;










--   Analysis 1 Q4

--   To identify seasonal sales patterns, Amazon India needs to focus on the most successful months.
--   Determine the top 3 months with the highest total sales value, rounded to the nearest integer.



-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Extracting month and year to calculate total sales per month and rounding the total sales, 
SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month, 
    ROUND(SUM(oi.price), 0) AS total_sales 
FROM 
    amazon_brazil.orders o
JOIN 
    amazon_brazil.order_items oi 
ON 
    o.order_id = oi.order_id
-- Grouping by year and month to aggregate sales
GROUP BY 
    month
-- Sorting in descending order to get the highest sales
ORDER BY 
    total_sales DESC
-- Limiting results to top 3 months
LIMIT 3;










--   Analysis 1 Q5

--   Amazon India is interested in product categories with significant price variations.
--   Find categories where the difference between the maximum and minimum product prices is greater than 500 BRL.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Selecting the name of the product category and calculating the price difference
SELECT
      p.product_category_name, 
      MAX(oi.price) - MIN(oi.price) AS price_difference 
FROM 
    amazon_brazil.product p 
-- Joining the product tables with order_items table on product_id
JOIN
    amazon_brazil.order_items oi 
ON
    p.product_id = oi.product_id 
-- Grouping results by product category name 
GROUP BY 
    p.product_category_name
-- Filter to include only categories with a price difference greater than 500 BRL
HAVING  
    MAX(oi.price) - MIN(oi.price) > 500 
-- Order the results by price difference in descending order
ORDER BY 
    price_difference DESC;











--   Analysis 1 Q6

--   To enhance the customer experience, Amazon India wants to find which payment types have the most
--   consistent transaction amounts. Identify the payment types with the least variance in transaction amounts,
--   sorting by the smallest standard deviation first.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Finding payment types with the least variance in transaction amounts
-- Calculating the standard deviation of payment amounts
SELECT 
    payment_type, 
    ROUND(STDDEV(payment_value),2) AS std_deviation  
FROM 
    amazon_brazil.payments
-- Exclude any undefined payment types from the results
WHERE 
    payment_type != 'not_defined'
-- Grouping by payment type to calculate std deviation for each type
GROUP BY 
    payment_type
-- Sorting by the smallest standard deviation to find the most consistent payment types
ORDER BY 
    std_deviation ASC;










--    Analysis 1 Q7

--    Amazon India wants to identify products that may have incomplete names in order to fix it from their end.
--    Retrieve the list of products where the product category name is missing or contains only a single character.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Selecting product ID and category name for products with missing or incomplete category names
SELECT 
    product_id, 
    product_category_name
FROM 
    amazon_brazil.product
-- Filtering for missing category names or those with a single character
WHERE 
    product_category_name IS NULL OR 
    LENGTH(product_category_name) = 1;











--   Analysis 2 Q1

--   Amazon India wants to understand which payment types are most popular across different order value segments
--   (e.g., low, medium, high). Segment order values into three ranges: orders less than 200 BRL, between 200 and
--   1000 BRL, and over 1000 BRL. Calculate the count of each payment type within these ranges and display the
--   results in descending order of count.

-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Segmenting orders by value and counting payment types for each segment
SELECT 
    CASE 
        WHEN p.payment_value < 200 THEN 'Low'            
        WHEN p.payment_value BETWEEN 200 AND 1000 THEN 'Medium' 
         ELSE 'High'
	END AS
    order_value_segment,                  
    p.payment_type,                                      
    COUNT(o.order_id) AS count                             
FROM 
    amazon_brazil.orders o
-- Joining the orders table with the payments table                                
JOIN 
    amazon_brazil.payments p
ON 
    o.order_id = p.order_id   
-- Grouping by order value segment and payment type
GROUP BY 
    order_value_segment, p.payment_type
-- Sorting results by count in descending order                  
ORDER BY 
    count DESC;











--   Analysis 2 Q2

--   Amazon India wants to analyse the price range and average price for each product category.
--   Calculate the minimum, maximum, and average price for each category, and list them in descending
--   order by the average price.



-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Getting minimum, maximum, and average price for each product category name
SELECT 
    p.product_category_name, 
    MIN(oi.price) AS min_price,    
    MAX(oi.price) AS max_price,    
    ROUND(AVG(oi.price),2) AS avg_price      
FROM 
    amazon_brazil.order_items oi    
-- Joining the order items table with the product table to get category names
JOIN 
    amazon_brazil.product p         
ON 
    oi.product_id = p.product_id 
-- Grouping results by product category
GROUP BY 
    p.product_category_name         
-- Order results by average price in descending order
ORDER BY 
    avg_price DESC; 

-- Getting minimum, maximum, and average price for each product category name
SELECT 
    p.product_category_name, 
    MIN(oi.price) AS min_price,    
    MAX(oi.price) AS max_price,    
    ROUND(AVG(oi.price),2) AS avg_price      
FROM 
    amazon_brazil.order_items oi    
-- Joining the order items table with the product table to get category names
JOIN 
    amazon_brazil.product p         
ON 
    oi.product_id = p.product_id 
-- Grouping results by product category
GROUP BY 
    p.product_category_name         
-- Order results by average price in descending order
ORDER BY 
    avg_price DESC;











--   Analysis 2 Q3

--   Amazon India wants to identify the customers who have placed multiple orders over time.
--   Find all customers with more than one order, and display their customer unique IDs along 
--   with the total number of orders they have placed.



-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Getting customer unique IDs and counting total orders for each customer
SELECT 
    c.customer_unique_id,                    
    COUNT(o.order_id) AS total_orders          
FROM 
    amazon_brazil.customers c                 
-- Joining the customers table with the orders table
JOIN 
    amazon_brazil.orders o
ON
    c.customer_id = o.customer_id  
-- Grouping by customer unique ID
GROUP BY 
    c.customer_unique_id                      
-- Filtering for customers with more than one order
HAVING 
    COUNT(o.order_id) > 1                     
-- Sorting results by total orders in descending order
ORDER BY 
    total_orders DESC;











--   Analysis 2 Q4

--   Amazon India wants to categorize customers into different types
--   ('New – order qty. = 1';  'Returning' –order qty. 2 to 4;  'Loyal' – order qty. >4)
--   based on their purchase history. Use a temporary table to define these categories
--   and join it with the customer's table to update and display the customer types.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Create a temporary table to categorize customers based on their order quantity
WITH customer_order_count AS (
    SELECT 
        c.customer_id,                    
        COUNT(o.order_id) AS total_orders
    FROM 
        amazon_brazil.customers c                 
    -- Joining the customers table with the orders table
    JOIN 
        amazon_brazil.orders o 
    ON
     c.customer_id = o.customer_id  
    -- Grouping by customer_id to get total orders per customer
    GROUP BY 
        c.customer_id
)

-- Select from the temporary table and categorize customers as New, Returning, or Loyal
SELECT 
    c.customer_id,
    CASE
        WHEN coc.total_orders = 1 THEN 'New'            
        WHEN coc.total_orders BETWEEN 2 AND 4 THEN 'Returning'  
        ELSE 'Loyal'
    END AS customer_type
FROM 
    customer_order_count coc
-- Joining the customer_order_count with the customers table
JOIN 
    amazon_brazil.customers c
ON
coc.customer_id = c.customer_id;











--   Analysis 2 Q5

--   Amazon India wants to know which product categories generate the most revenue.
--   Use joins between the tables to calculate the total revenue for each product category.
--   Display the top 5 categories.

-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Calculating total revenue using SUM for each product category
SELECT 
    p.product_category_name,                                            
    SUM(oi.price) AS total_revenue                                     
FROM 
    amazon_brazil.order_items oi
JOIN                                -- Joining the order_items table with the product table to get category names
    amazon_brazil.product p
ON
    oi.product_id = p.product_id
--Grouping by product category and then setting them in descending order by limiting the top 5 results
GROUP BY 
    p.product_category_name
ORDER BY 
    total_revenue DESC                                                      
LIMIT 5;










--   Analysis 3 Q1

--   The marketing team wants to compare the total sales between different seasons.
--   Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter)
--   based on order purchase dates, and display the results. Spring is in the months of March,
--   April and May. Summer is from June to August and Autumn is between September and November
--   and the rest months are Winter.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Calculating total sales for each season based on order dates
-- Defining the season based on the month extracted from order_purchase_timestamp
SELECT 
    CASE 
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring' 
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
        ELSE 'Winter'
    END AS season,
-- Summing up prices for each season to calculate total sales
    SUM(oi.price) AS total_sales
FROM 
    amazon_brazil.orders o
-- Joining the orders table with the order_items table to get order and sales data
JOIN 
    amazon_brazil.order_items oi
ON
     o.order_id = oi.order_id
GROUP BY 
    season                                         -- Grouping results by season
ORDER BY 
    total_sales DESC;                      -- Sorting results by total sales in descending order











--   Analysis 3 Q2

--   The inventory team is interested in identifying products that have sales volumes above the overall average.
--   Write a query that uses a subquery to filter products with a total quantity sold above the average quantity.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- CTE to calculate the total quantity sold for each product
WITH product_totals AS (
    SELECT 
        p.product_id,                                                                   
        COUNT(DISTINCT oi.order_id) AS total_quantity_sold -- Calculate total quantity sold for each product
    FROM 
        amazon_brazil.product p
    -- Joining product table with order_items table to get sales data
    JOIN 
        amazon_brazil.order_items oi
    ON 
        p.product_id = oi.product_id
    -- Grouping by product_id to calculate the total quantity sold for each product
    GROUP BY 
        p.product_id 
),


-- CTE to calculate the average total quantity sold across all products
avg_quantity AS (
    SELECT 
        AVG(total_quantity_sold) AS avg_quantity_sold  -- Calculate overall average total quantity sold
    FROM 
        product_totals 
)


-- Main query to filter products with total quantity sold above the average
SELECT 
    product_id,                                                               -- Selecting product_id
    total_quantity_sold                                                   -- Displaying the total quantity sold for each product
FROM 
    product_totals
-- Filtering products whose total quantity sold is greater than the overall average
WHERE 
    total_quantity_sold > (SELECT avg_quantity_sold FROM avg_quantity)
-- Sorting results by the total quantity sold in descending order
ORDER BY 
    total_quantity_sold DESC;










--   Analysis 3 Q3

--   To understand seasonal sales patterns, the finance team is analysing the monthly revenue trends
--   over the past year (year 2018). Run a query to calculate total revenue generated each month and
--   identify periods of peak and low sales. Export the data to Excel and create a graph to visually
--    represent revenue changes across the months.


-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;


-- Query to analyze monthly revenue trends for the year 2018
SELECT 
    TO_CHAR(o.order_purchase_timestamp, 'Mon') AS month,  -- Extracts the 3-letter month abbreviation (Jan, Feb)
    SUM(oi.price) AS total_revenue  -- Calculates total revenue by summing item prices
FROM 
    amazon_brazil.orders o 
JOIN 
    amazon_brazil.order_items oi 
ON 
    o.order_id = oi.order_id
-- Filters only orders from the year 2018
WHERE 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018  
-- Groups data by both month number (for ordering) and month name 
GROUP BY 
    EXTRACT(MONTH FROM o.order_purchase_timestamp),  -- Ensures correct chronological ordering
    TO_CHAR(o.order_purchase_timestamp, 'Mon')       --  Keeps the month name for readability
-- Orders the results by month number to display data from January to December
ORDER BY 
    EXTRACT(MONTH FROM o.order_purchase_timestamp);











--   Analysis 3 Q4

--   A loyalty program is being designed for Amazon India. Create a segmentation based on purchase frequency:
--   ‘Occasional’ for customers with 1-2 orders, ‘Regular’ for 3-5 orders, and ‘Loyal’ for more than 5 orders.
--   Use a CTE to classify customers and their count and generate a chart in Excel to show the proportion of each segment.


--Setting the search path
SET search_path TO amazon_brazil;

--Using CTE calculate the number of orders for each customer
WITH customer_order_count AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
), 

--2nd CTE to categorise customers based on their order_count
customer_segments AS (
    SELECT 
        customer_id,
        CASE 
            WHEN order_count BETWEEN 1 AND 2 THEN 'Occasional'
            WHEN order_count BETWEEN 3 AND 5 THEN 'Regular'
            WHEN order_count > 5 THEN 'Loyal'
        END AS customer_type
    FROM customer_order_count
)


--Using the customer_segments CTE to group customers by their respective customer_type
SELECT 
    customer_type,
    COUNT(customer_id) AS count
FROM customer_segments
GROUP BY customer_type
ORDER BY count DESC;











--   Analysis 3 Q5

--   Amazon wants to identify high-value customers to target for an exclusive rewards program.
--   You are required to rank customers based on their average order value (avg_order_value)
--   to find the top 20 customers.


SET search_path TO amazon_brazil;

-- Using CTE to calculate the average order value for each customer
WITH customer_order_value AS (
  SELECT customer_id,
         AVG(price) AS avg_order_value
  FROM Orders o
  JOIN Order_Items oi ON o.order_id = oi.order_id
  GROUP BY customer_id
)

--Using the RANK() function to assign a ranking to each customer based on their average order value
SELECT customer_id,
       avg_order_value,
       RANK() OVER (ORDER BY avg_order_value DESC) AS customer_rank
FROM customer_order_value
ORDER BY avg_order_value DESC
LIMIT 20;










--   Analysis 3 Q6

--   Amazon wants to analyze sales growth trends for its key products over their lifecycle.
--   Calculate monthly cumulative sales for each product from the date of its first sale.
--   Use a recursive CTE to compute the cumulative sales (total_sales) for each product month by month.


-- Setting the search path
SET search_path TO amazon_brazil;

-- Creating a CTE for monthly sales for each product
WITH Monthly_Sales AS (
    SELECT 
        ol.product_id,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS sale_month, 
        SUM(ol.price) AS monthly_sales
    FROM 
        orders o
    JOIN 
        order_items ol
    ON
    o.order_id = ol.order_id
    GROUP BY 
    ol.product_id, sale_month),
-- Calculating the cumulative monthly sales using a window function
Cumulative_Sales AS (
    SELECT
        product_id,
        sale_month,
        SUM(monthly_sales) OVER (PARTITION BY product_id ORDER BY sale_month) AS total_sales
    FROM 
        Monthly_Sales)

-- Final output of cumulative sales month by month for each product
SELECT
    product_id,
    sale_month,
    total_sales
FROM 
    Cumulative_Sales
ORDER BY 
    product_id, sale_month;










--   Analysis 3 Q7

--   To understand how different payment methods affect monthly sales growth, Amazon wants to compute
--   the total sales for each payment method and calculate the month-over-month growth rate for the
--   past year (year 2018). Write query to first calculate total monthly sales for each payment method,
--   then compute the percentage change from the previous month.



-- Setting the search path to the specified schema
SET search_path TO amazon_brazil;

-- Creating a CTE to calculate monthly sales per payment method for the year 2018
WITH Monthly_Sales AS (
    SELECT 
        payment_type,
        DATE_TRUNC('month', order_purchase_timestamp) :: DATE AS sale_month,
        SUM(payment_value) AS monthly_total
    FROM 
        orders o
    JOIN 
        payments p
    ON
    o.order_id = p.order_id
    WHERE 
        EXTRACT(YEAR FROM order_purchase_timestamp) = 2018
    GROUP BY 
       payment_type, sale_month
),
-- Calculating the month-over-month percentage change
Monthly_Change AS (
    SELECT 
        payment_type,
        sale_month,
        monthly_total,
        LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month) AS previous_month_total,
       Round(
        CASE 
            WHEN LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month) > 0 
            THEN ((monthly_total - LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month))
       / LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month)) * 100
            ELSE NULL
        END, 2 ) AS monthly_change
    FROM 
        Monthly_Sales)
-- Final output of total sales and month-over-month change for each payment method
SELECT 
    payment_type,
    sale_month,
    monthly_total,
    monthly_change
FROM 
    Monthly_Change
ORDER BY 
    payment_type, sale_month;

