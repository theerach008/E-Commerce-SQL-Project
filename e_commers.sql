-- Step 1: Create Database
CREATE DATABASE IF NOT EXISTS E_Commerce;
USE E_Commerce;


-- Step 2: Create Users Table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email_id VARCHAR(100),
    password VARCHAR(20) UNIQUE,
    role ENUM('users', 'customer', 'seller'),
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Insert Users
INSERT INTO users (name, email_id, password, role) VALUES
('John Doe', 'john@example.com', 'pass123', 'customer'),
('Alice Smith', 'alice@example.com', 'alice456', 'seller'),
('Bob Johnson', 'bob@example.com', 'bob7891', 'customer'),
('Michael Brown', 'michael@example.com', 'mike321!', 'seller'),
('Emily Davis', 'emily@example.com', 'emily987$', 'customer');

-- Step 4: Create Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    seller_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Step 5: Insert Products
INSERT INTO products (name, description, price, stock, seller_id) VALUES
('Laptop', 'High-performance laptop with 16GB RAM', 850.99, 10, 2),
('Smartphone', 'Latest model smartphone with 128GB storage', 599.49, 15, 2);
INSERT INTO products (name, description, price, stock, seller_id) VALUES
('Laptop', 'High-performance laptop with 16GB RAM', 850.99, 10, 2),
('Smartphone', 'Latest model smartphone with 128GB storage', 599.49, 15, 2),
('Tablet', 'Lightweight tablet with 10-inch display', 399.99, 20, 4),
('Smartwatch', 'Fitness smartwatch with heart rate monitor', 199.99, 30, 4),
('Headphones', 'Wireless noise-canceling headphones', 129.99, 25, 2);


-- Step 6: Create Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_id INT,
    product_count INT DEFAULT 1,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),
    status ENUM('pending', 'shipped', 'delivered', 'canceled') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL
);

-- Step 7: Insert Orders
INSERT INTO orders (user_id, product_id, product_count, order_date, total_amount, status) VALUES
(1, 1, 2, NOW(), 1701.98, 'pending'),
(2, 2, 1, NOW(), 599.49, 'shipped'),
(3, 1, 3, NOW(), 2552.97, 'delivered'),
(4, 2, 2, NOW(), 1198.98, 'canceled'),
(5, 1, 1, NOW(), 850.99, 'pending'),
(1, 2, 3, NOW(), 1798.47, 'shipped'),
(2, 1, 2, NOW(), 1701.98, 'delivered'),
(3, 2, 1, NOW(), 599.49, 'pending'),
(4, 1, 5, NOW(), 4254.95, 'shipped'),
(5, 2, 4, NOW(), 2397.96, 'delivered'),
(1, 1, 1, NOW(), 850.99, 'pending'),
(2, 2, 2, NOW(), 1198.98, 'shipped'),
(3, 1, 4, NOW(), 3403.96, 'delivered'),
(4, 2, 1, NOW(), 599.49, 'canceled'),
(5, 1, 3, NOW(), 2552.97, 'pending'),
(1, 2, 2, NOW(), 1198.98, 'shipped'),
(2, 1, 1, NOW(), 850.99, 'delivered'),
(3, 2, 3, NOW(), 1798.47, 'pending'),
(4, 1, 2, NOW(), 1701.98, 'shipped'),
(5, 2, 5, NOW(), 2997.45, 'delivered');

-- Step 8: Check Data
select * from e_commerce.users;
select * from orders;
select * from products;

# Sales Report per User
SELECT t1.user_id, t2.name AS user_name, SUM(t1.total_amount) AS total_spent, COUNT(t1.order_id) AS total_orders 
FROM orders t1 JOIN users t2 ON t1.user_id = t2.user_id 
GROUP BY t1.user_id, t2.name ORDER BY total_spent DESC;

#Top-Selling Products
select t1.product_id,t2.name,count(t1.product_id) ,sum(t1.total_amount) 
from orders t1 join products t2 on t1.product_id = t2.product_id
group by t1.product_id,t2.name;

#Find Canceled Orders
select * from orders where status = 'canceled';

#Orders by Product & User
select t1.user_id,t2.name,t1.product_id,t3.name,sum(t1.product_count) as total_quantity
from orders  t1 join users t2 on t1.user_id = t2.user_id
join products t3 on t1.product_id = t3.product_id
group by t1.user_id,t2.name,t1.product_id,t3.name;

#Find Users Who Bought More Than 5 Items
select user_id,sum(product_count) as total_qu from orders group by user_id having total_qu > 8;

#Find Total Revenue Per Seller
select user_id , sum(total_amount) from orders group by user_id;

select t1.user_id,t2.name,t1.product_id,t3.name,sum(t1.product_count) as sum_product_count 
from orders t1 join users t2 on t1.user_id = t2.user_id
join products t3 on t1.product_id = t3.product_id
group by t1.user_id,t2.name,t1.product_id,t3.name; 

#Stored Procedure Example: Fetch order details for a customer,seller
delimiter //
create procedure users_details ( in users_cat varchar(50) , users_ID int )
begin
	if users_cat ='customer' then
		select * from users where user_id = users_ID ;
	ELSEIF  users_cat = 'seller' then
		select * from users where user_id = users_ID;
	else 
		select 'role you mention was not in table , retry' as message;
	end if;
end//
delimiter ;
use e_commerce;
call users_details ('seller',1);
call users_details ('customer',1);
call users_details ('users',1);

select distinct t1.*,concat(sum(t2.product_count),' ', t3.name,' was salesed by him and the total prices ',sum(t2.total_amount)) as message
from users t1 join orders t2 on t1.user_id = t2.user_id
join products t3 on t2.product_id = t3.product_id 
where t1.user_id = 1  group by t3.name;

delimiter //

DELIMITER //
CREATE TRIGGER reduce_stock_on_order
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- Check if stock is sufficient
    DECLARE current_stock INT;
    
    SELECT stock INTO current_stock FROM products WHERE product_id = NEW.product_id;

    IF current_stock < NEW.product_count THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock available for this product';
    ELSE
        -- Reduce the stock
        UPDATE products 
        SET stock = stock - NEW.product_count
        WHERE product_id = NEW.product_id;
    END IF;
END //
DELIMITER ;

select * from products ;