CREATE DATABASE ecommerce;
USE ecommerce;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    subtotal DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers (customer_name, email, country) VALUES
('Amit Patel', 'amit@gmail.com', 'India'),
('Sarah Smith', 'sarah@gmail.com', 'USA'),
('Mohammed Ali', 'ali@yahoo.com', 'UAE');

select * from customers;

INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 55000),
('Smartphone', 'Electronics', 20000),
('Shoes', 'Fashion', 3000);

select * from products;

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2024-04-01', 75000),
(2, '2024-04-02', 20000);

select * from orders;

INSERT INTO order_items (order_id, product_id, quantity, subtotal) VALUES
(1, 1, 1, 55000),
(1, 3, 2, 6000),
(2, 2, 1, 20000);

select * from order_items;

-- Get all Indian customers sorted by name
SELECT * FROM customers WHERE country = 'India' ORDER BY customer_name;

-- Total orders and amount spent by each customer
SELECT customer_id, COUNT(order_id) AS total_orders, SUM(total_amount) AS total_spent
FROM orders GROUP BY customer_id;

-- Monthly order summary with total revenue
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM orders GROUP BY order_month ORDER BY order_month;

-- INNER JOIN: Orders with customer names
SELECT o.order_id, c.customer_name, o.order_date, o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- LEFT JOIN: All customers with or without orders
SELECT c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- RIGHT JOIN: All orders with customer names
SELECT o.order_id, c.customer_name
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id;

-- Customers who spent more than average total order amount
SELECT customer_name FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total_amount) > (
        SELECT AVG(total_amount) FROM orders
    )
);

-- Find customers who placed the highest value single order
SELECT customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount = (
        SELECT MAX(total_amount) FROM orders
    )
);

-- Average order amount per customer
SELECT customer_id, AVG(total_amount) AS avg_order_value
FROM orders
GROUP BY customer_id;

-- Total quantity sold per product
SELECT p.product_name, SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id;

SELECT 
    MAX(total_amount) AS highest_order,
    MIN(total_amount) AS lowest_order
FROM orders;

CREATE VIEW customer_summary AS
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

select * from customer_summary;

-- Add index on customer_id in orders table
CREATE INDEX idx_customer_id_orders ON orders(customer_id);
SHOW INDEX FROM orders;

-- Add index on order_id in order_items
CREATE INDEX idx_order_id_items ON order_items(order_id);
SHOW INDEX FROM order_items;


SELECT 
  customer_name,
  total_amount,
  CASE 
    WHEN total_amount >= 1000 THEN 'High Value'
    WHEN total_amount >= 500 THEN 'Medium Value'
    ELSE 'Low Value'
  END AS order_category
FROM orders
JOIN customers ON orders.customer_id = customers.customer_id;

SELECT 
  DATE_FORMAT(order_date, '%M %Y') AS month,
  COUNT(order_id) AS total_orders
FROM orders
GROUP BY month;

SELECT 
  customer_id, order_id, total_amount,
  RANK() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS rank_in_customer
FROM orders;