# Danny-s-Diner-case-study
Solution to the [Danny's Diner](https://8weeksqlchallenge.com/case-study-1/) case study challenge using SQL. The goal is to analyze customer spending behavior at a fictional restaurant using three tables: `sales`, `menu`, and `members`.
## Introduction:

![image](https://user-images.githubusercontent.com/92555446/187380541-3e69f5d8-dd41-408e-9945-46e7994f684e.png)

**Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.**

**Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.**

## Problem Statement:

**Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.**

**What is the total amount each customer spent at the restaurant?**

- **How many days has each customer visited the restaurant?**
- **What was the first item from the menu purchased by each customer?**
- **What is the most purchased item on the menu and how many times was it purchased by all customers?**
- **Which item was the most popular for each customer?**
- **Which item was purchased first by the customer after they became a member?**
- **Which item was purchased just before the customer became a member?**
- **What is the total items and amount spent for each member before they became a member?**
- **If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
- **In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A     and B have at the end of January?**

## 📂 Dataset Overview

- **`sales`**: records of customer purchases with product and order date
- **`menu`**: item details and prices
- **`members`**: loyalty program sign-up dates


![image](https://user-images.githubusercontent.com/92555446/187381281-053700c7-de51-4576-b06b-09c679a226ac.png)

## 🧠 Case Study Questions and Solutions

## 1. What is the total amount each customer spent at the restaurant?

**SQL Query:**
```sql
SELECT 
    s.customer_id,
    SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

**Sample Output:**
| customer_id   |   total_spent |
|:--------------|--------------:|
| A             |            76 |
| B             |            74 |
| C             |            36 |


## 2. How many days has each customer visited the restaurant?

**SQL Query:**
```sql
SELECT 
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;
```

**Sample Output:**
| customer_id   |   visit_days |
|:--------------|-------------:|
| A             |            4 |
| B             |            6 |
| C             |            2 |


## 3. What was the first item from the menu purchased by each customer?

**SQL Query:**
```sql
SELECT 
    customer_id,
    product_name
FROM (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
) ranked
WHERE rnk = 1;
```

**Sample Output:**
| customer_id   | product_name   |
|:--------------|:---------------|
| A             | curry          |
| B             | sushi          |
| C             | ramen          |


## 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

**SQL Query:**
```sql
SELECT 
    m.product_name,
    COUNT(*) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;
```

**Sample Output:**
| product_name   |   purchase_count |
|:---------------|-----------------:|
| ramen          |                8 |


## 5. Which item was the most popular for each customer?

**SQL Query:**
```sql
SELECT customer_id, product_name, purchase_count
FROM (
    SELECT 
        s.customer_id,
        m.product_name,
        COUNT(*) AS purchase_count,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rnk
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
) ranked
WHERE rnk = 1;
```

**Sample Output:**
| customer_id   | product_name   |   purchase_count |
|:--------------|:---------------|-----------------:|
| A             | ramen          |                3 |
| B             | sushi          |                2 |
| C             | ramen          |                2 |


## 6. Which item was purchased first by the customer after they became a member?

**SQL Query:**
```sql
SELECT customer_id, order_date, product_name
FROM (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
    FROM sales s
    JOIN members mem ON s.customer_id = mem.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date
) ranked
WHERE rnk = 1;
```

**Sample Output:**
| customer_id   | order_date   | product_name   |
|:--------------|:-------------|:---------------|
| A             | 2021-01-07   | curry          |
| B             | 2021-01-11   | sushi          |


## 7. Which item was purchased just before the customer became a member?

**SQL Query:**
```sql
SELECT customer_id, order_date, product_name
FROM (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
    FROM sales s
    JOIN members mem ON s.customer_id = mem.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
) ranked
WHERE rnk = 1;
```

**Sample Output:**
| customer_id   | order_date   | product_name   |
|:--------------|:-------------|:---------------|
| A             | 2021-01-01   | ramen          |
| B             | 2021-01-04   | sushi          |


## 8. What is the total items and amount spent for each member before they became a member?

**SQL Query:**
```sql
SELECT 
    s.customer_id,
    COUNT(*) AS total_items,
    SUM(m.price) AS total_spent
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;
```

**Sample Output:**
| customer_id   |   total_items |   total_spent |
|:--------------|--------------:|--------------:|
| A             |             2 |            25 |
| B             |             1 |            20 |


## 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?

**SQL Query:**
```sql
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

**Sample Output:**
| customer_id   |   total_points |
|:--------------|---------------:|
| A             |            860 |
| B             |            940 |
| C             |            360 |


## 10. In the first week after a customer joins the program (including their join date), what is the total number of points they earned?

**SQL Query:**
```sql
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS points_earned
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date BETWEEN mem.join_date AND DATE(mem.join_date, '+6 days')
GROUP BY s.customer_id;
```

**Sample Output:**
| customer_id   |   points_earned |
|:--------------|----------------:|
| A             |             250 |
| B             |             400 |


## 🎁 Bonus Questions
:red_square: **The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing 
to join the underlying tables using SQL.**
- customer_id
- order_date
- product_name
- price
- member (Y/N indicating if the customer was a member at the time of order)

**SQL Query:**
```sql
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date >= mem.join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id;
```

**Sample Output:**
| customer_id   | order_date   | product_name   |   price | member   |
|:--------------|:-------------|:---------------|--------:|:---------|
| A             | 2021-01-01   | sushi          |      10 | N        |
| A             | 2021-01-01   | curry          |      15 | N        |
| A             | 2021-01-07   | curry          |      15 | Y        |
| B             | 2021-01-11   | sushi          |      10 | Y        |
| C             | 2021-01-01   | ramen          |      12 | N        |


## Bonus 2: Rank All The Things

**SQL Query:**
```sql
WITH cte AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        m.price,
        CASE
            WHEN s.order_date >= mem.join_date THEN 'Y'
            ELSE 'N'
        END AS member
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    LEFT JOIN members mem ON s.customer_id = mem.customer_id
)
SELECT
    *,
    CASE
        WHEN member = 'N' THEN NULL
        ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
    END AS rank
FROM cte;
```

**Sample Output:**
| customer_id   | order_date   | product_name   |   price | member   |   rank |
|:--------------|:-------------|:---------------|--------:|:---------|-------:|
| A             | 2021-01-01   | sushi          |      10 | N        |    nan |
| A             | 2021-01-07   | curry          |      15 | Y        |      1 |
| A             | 2021-01-10   | ramen          |      12 | Y        |      2 |
| B             | 2021-01-04   | sushi          |      10 | N        |    nan |
| B             | 2021-01-11   | sushi          |      10 | Y        |      1 |

## Tool Used:

- SQL Scripting

- SQL Server Database

## Conclusion
Through the Danny’s Diner SQL case study, we explored essential SQL concepts including:

- Data filtering and aggregation
- Date comparisons and logic
- JOIN operations and CASE statements
- Window functions such as RANK() and ROW_NUMBER()

These 10 core questions and 2 bonus challenges provided valuable hands-on experience in deriving customer insights, calculating loyalty metrics, and structuring readable, modular SQL queries. This case study is an excellent foundation for real-world analytics work in customer behavior, sales performance, and loyalty program analysis.
