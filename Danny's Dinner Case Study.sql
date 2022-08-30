create database Dannys_Dinner

use Dannys_Dinner

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

select * from INFORMATION_SCHEMA.TABLES
select * from sales
select * from menu
select * from members
--Case Study Questions

--Each of the following case study questions can be answered using a single SQL statement:

--1.What is the total amount each customer spent at the restaurant?
select 
	s.customer_id, 
	sum(price) total_price
from 
	sales s 
		join menu m 
			on s.product_id = m.product_id
group by customer_id;

--2.How many days has each customer visited the restaurant?
select 
	s.customer_id, 
	count(distinct order_date) no_of_visit
from 
	sales s
group by customer_id;
--3.What was the first item from the menu purchased by each customer?
select distinct
	customer_id, 
	product_name 
from
	(
		select 
			customer_id, 
			order_date,product_name, 
			rank() over(partition by customer_id order by order_date) rnk 
		from 
			sales s
	join menu m 
		on s.product_id = m.product_id)t1
where rnk = 1;
--4.What is the most purchased item on the menu and how many times was it purchased by all customers?
select 
	top 1 m.product_name, 
	count(s.product_id) most_purchased_item 
from 
	sales s
	join menu m 
		on s.product_id = m.product_id 
group by product_name 
order by most_purchased_item desc;
--5.Which item was the most popular for each customer?
with t1 as (
	select 
		customer_id, 
		product_name, 
		count(s.product_id) no_of_purchase,
		rank() over(partition by customer_id order by count(s.product_id) desc) rnk 
	from sales s 
		join menu m 
			on s.product_id = m.product_id 
	group by customer_id, product_name  )
select 
	t1.customer_id,
	t1.product_name
from t1 
where rnk = 1;
--6.Which item was purchased first by the customer after they became a member?
select 
	t1.customer_id, 
	t1.product_name 
from (
	select 
		s.customer_id, 
		s.order_date,
		m.product_name, 
		rank() over(partition by s.customer_id order by order_date) rnk 
	from 
		sales s 
			join menu m 
				on s.product_id = m.product_id 
			join members ms 
				on s.customer_id = ms.customer_id
	where order_date > join_date ) t1
where rnk = 1;
--7.Which item was purchased just before the customer became a member?
with t1 as (
	select 
		s.customer_id, 
		s.order_date,
		m.product_name,
		rank() over(partition by s.customer_id order by order_date) rnk 
	from 
		sales s 
			join menu m 
				on s.product_id = m.product_id 
			join members ms 
				on s.customer_id = ms.customer_id
	where order_date < join_date)
select 
	t1.customer_id, 
	t1.product_name 
from 
	t1 
where rnk = 1;

--8.What is the total items and amount spent for each member before they became a member?
select 
	s.customer_id, 
	count(s.product_id) total_items,
	sum(price) total_price
from 
	sales s
		join menu m on s.product_id = m.product_id
		join members ms on s.customer_id = ms.customer_id
where order_date < join_date
group by s.customer_id;
--9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select distinct
	s.customer_id,
	sum(case 
			when m.product_name = 'sushi' 
				then m.price * 20 
			else m.price * 10 end
		) as total_points
from sales s
	join menu m 
		on s.product_id = m.product_id
group by s.customer_id;
--10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--   not just sushi - how many points do customer A and B have at the end of January?
with t1 as (
	select 
		s.customer_id, 
		s.order_date,
		m.join_date,
		dateadd(day, 6, join_date) first_week_last_date,
		eomonth('2021-01-31') first_month_last_date,
		me.product_name,
		me.price
	from 
		sales s 
			join members m 
				on s.customer_id = m.customer_id
			join menu me
				on s.product_id = me.product_id
				)
select 
	t1.customer_id, 
	sum(case 
			when product_name= 'sushi' then price * 20 
			when order_date between join_date and first_week_last_date then price * 20 
			else price * 10  end
		 )as total_points
from 
	t1
where order_date <= first_month_last_date
group by customer_id;


