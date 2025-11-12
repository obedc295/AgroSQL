create schema agro;

create table agro.categories(
    id INT PRIMARY KEY IDENTITY(1,1)
    , name NVARCHAR(100) NOT NULL UNIQUE
    , description NVARCHAR(100) NOT NULL
)

create table agro.products(
    id INT PRIMARY KEY IDENTITY(1,1)
    , category_id INT NOT NULL
    , name NVARCHAR(100) NOT NULL
    , description NVARCHAR(100) NULL
    , unit_of_measure NVARCHAR(50) NOT NULL

)

create table agro.orders(
    id INT PRIMARY KEY IDENTITY(1,1)
    , customer_id INT NOT NULL
    , order_date DATETIME NOT NULL DEFAULT GETDATE()
    , total_amount DECIMAL(10, 2) NOT NULL
    , status NVARCHAR(50) NOT NULL DEFAULT 'Pending'
)

create table agro.customers(
    id INT PRIMARY KEY IDENTITY(1,1)
    , first_name NVARCHAR(100) NOT NULL
    , last_name NVARCHAR(100) NOT NULL
    , person_id NVARCHAR(100) UNIQUE NOT NULL
    , email NVARCHAR(100) UNIQUE NOT NULL
)


create table agro.order_details(
      order_id INT NOT NULL
    , product_id INT NOT NULL
    , quantity DECIMAL(10, 2) NOT NULL
    , historical_sale_price DECIMAL(10, 2) NOT NULL
    , subtotal DECIMAL(10, 2) NOT NULL
    
)


ALTER TABLE agro.orders
add CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_id)
REFERENCES agro.customers(id)

ALTER TABLE agro.products
add CONSTRAINT FK_products_categories FOREIGN KEY (category_id)
REFERENCES agro.categories(id)

ALTER TABLE agro.order_details
add CONSTRAINT FK_orderDetails_order FOREIGN KEY (order_id)
REFERENCES agro.orders(id)

ALTER TABLE agro.order_details
add CONSTRAINT FK_orderDetails_product FOREIGN KEY(product_id)
REFERENCES agro.products(id)

ALTER TABLE agro.order_details
add CONSTRAINT PK_orderDetails PRIMARY KEY (order_id, product_id)