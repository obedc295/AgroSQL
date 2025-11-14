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

---ESTA TABLA SE ELIMINA PARA ARREGLAR EL MODELO DE DATOS
create table agro.order_details(
      order_id INT NOT NULL
    , product_id INT NOT NULL  ---El nuevo cambio usa product_lot_id
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

EXEC sp_rename 'agro.FK_Orders_Customer', 'FK_Order_Customer', 'OBJECT';
EXEC sp_rename 'agro.FK_products_categories', 'FK_Product_Category', 'OBJECT';
EXEC sp_rename 'agro.FK_orderDetails_order', 'FK_OrderDetail_Order', 'OBJECT';
EXEC sp_rename 'agro.FK_orderDetails_product', 'FK_OrderDetail_Product', 'OBJECT';
EXEC sp_rename 'agro.PK_orderDetails', 'PK_OrderDetail', 'OBJECT';


-- Agregar campos faltantes a customers
ALTER TABLE agro.customers
ADD phone NVARCHAR(20) NULL,
    address NVARCHAR(255) NULL;

-- Crear tabla product_lots
CREATE TABLE agro.product_lots(
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_price DECIMAL(10, 2) NOT NULL,
    initial_quantity DECIMAL(10, 2) NOT NULL,
    current_stock DECIMAL(10, 2) NOT NULL
);

-- Modificar order_details para usar product_lot_id en lugar de product_id
-- Primero eliminar constraints y tabla existente
ALTER TABLE agro.order_details
DROP CONSTRAINT FK_OrderDetail_Product, PK_OrderDetail;

DROP TABLE agro.order_details;

-- Crear nueva tabla order_details con product_lot_id
CREATE TABLE agro.order_details(
    order_id INT NOT NULL,
    product_lot_id INT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    historical_sale_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL
);

-- Agregar constraints para las nuevas relaciones
ALTER TABLE agro.product_lots
ADD CONSTRAINT FK_ProductLot_Product FOREIGN KEY (product_id)
REFERENCES agro.products(id);

ALTER TABLE agro.order_details
ADD CONSTRAINT FK_OrderDetail_Order FOREIGN KEY (order_id)
REFERENCES agro.orders(id);

ALTER TABLE agro.order_details
ADD CONSTRAINT FK_OrderDetail_ProductLot FOREIGN KEY (product_lot_id)
REFERENCES agro.product_lots(id);

ALTER TABLE agro.order_details
ADD CONSTRAINT PK_OrderDetail PRIMARY KEY (order_id, product_lot_id);