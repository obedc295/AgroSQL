-- =============================================
-- SCRIPT DE BASE DE DATOS - SISTEMA AGROPECUARIO
-- Fecha: 12/11/2025
-- Descripción: Creación del esquema y tablas iniciales
-- =============================================

-- Crear esquema principal
CREATE SCHEMA agro;

-- =============================================
-- TABLAS BASE DEL SISTEMA
-- =============================================

-- Tabla de categorías de productos
CREATE TABLE agro.categories(
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(100) NOT NULL
);

-- Tabla de productos agrícolas
CREATE TABLE agro.products(
    id INT PRIMARY KEY IDENTITY(1,1),
    category_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(100) NULL,
    unit_of_measure NVARCHAR(50) NOT NULL
);

-- Tabla de clientes del sistema
CREATE TABLE agro.customers(
    id INT PRIMARY KEY IDENTITY(1,1),
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    person_id NVARCHAR(100) UNIQUE NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL
);

-- Tabla de órdenes de compra
CREATE TABLE agro.orders(
    id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT GETDATE(),
    total_amount DECIMAL(10, 2) NOT NULL,
    status NVARCHAR(50) NOT NULL DEFAULT 'Pending'
);

-- =============================================
-- VERSION INICIAL DE ORDER_DETAILS (CON ERROR DE DISEÑO)
-- NOTA: Esta tabla fue eliminada posteriormente por diseño incorrecto
-- =============================================
CREATE TABLE agro.order_details(
      order_id INT NOT NULL,
    product_id INT NOT NULL,  -- DISEÑO INCORRECTO: Debe usar product_lot_id
    quantity DECIMAL(10, 2) NOT NULL,
    historical_sale_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL
);

-- =============================================
-- CONSTRAINTS INICIALES
-- =============================================

-- Relación: Órdenes -> Clientes
ALTER TABLE agro.orders
ADD CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_id)
REFERENCES agro.customers(id);

-- Relación: Productos -> Categorías
ALTER TABLE agro.products
ADD CONSTRAINT FK_products_categories FOREIGN KEY (category_id)
REFERENCES agro.categories(id);

-- Constraints iniciales para order_details (versión incorrecta)
ALTER TABLE agro.order_details
ADD CONSTRAINT FK_orderDetails_order FOREIGN KEY (order_id)
REFERENCES agro.orders(id);

ALTER TABLE agro.order_details
ADD CONSTRAINT FK_orderDetails_product FOREIGN KEY(product_id)
REFERENCES agro.products(id);

ALTER TABLE agro.order_details
ADD CONSTRAINT PK_orderDetails PRIMARY KEY (order_id, product_id);

-- =============================================
-- MEJORA: RENOMBRAR CONSTRAINTS PARA MEJOR LEGIBILIDAD
-- =============================================
EXEC sp_rename 'agro.FK_Orders_Customer', 'FK_Order_Customer', 'OBJECT';
EXEC sp_rename 'agro.FK_products_categories', 'FK_Product_Category', 'OBJECT';
EXEC sp_rename 'agro.FK_orderDetails_order', 'FK_OrderDetail_Order', 'OBJECT';
EXEC sp_rename 'agro.FK_orderDetails_product', 'FK_OrderDetail_Product', 'OBJECT';
EXEC sp_rename 'agro.PK_orderDetails', 'PK_OrderDetail', 'OBJECT';

-- =============================================
-- MIGRACION: CORRECCION DEL MODELO DE DATOS
-- Fecha: 13/11/2025
-- Razon: Implementar gestión de inventario por lotes
-- =============================================

-- MEJORA 1: Agregar campos faltantes a customers
ALTER TABLE agro.customers
ADD phone NVARCHAR(20) NULL,
    address NVARCHAR(255) NULL;

-- MEJORA 2: Crear tabla de lotes de productos
-- JUSTIFICACION: Permitir control de inventario por lotes con precios de compra
CREATE TABLE agro.product_lots(
    id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_price DECIMAL(10, 2) NOT NULL,
    initial_quantity DECIMAL(10, 2) NOT NULL,
    current_stock DECIMAL(10, 2) NOT NULL
);

-- =============================================
-- MIGRACION CRITICA: ELIMINAR VERSION INCORRECTA DE ORDER_DETAILS
-- JUSTIFICACION: La tabla original relacionaba directamente con products,
-- pero el modelo correcto debe usar product_lots para trazabilidad
-- =============================================

-- Paso 1: Eliminar constraints de la versión antigua
ALTER TABLE agro.order_details
DROP CONSTRAINT FK_OrderDetail_Product, PK_OrderDetail;

-- Paso 2: Eliminar tabla con diseño incorrecto
DROP TABLE agro.order_details;

-- Paso 3: Crear nueva versión corregida de order_details
CREATE TABLE agro.order_details(
    order_id INT NOT NULL,
    product_lot_id INT NOT NULL,  -- CORREGIDO: Ahora relaciona con lotes
    quantity DECIMAL(10, 2) NOT NULL,
    historical_sale_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL
);

-- =============================================
-- CONSTRAINTS FINALES DEL MODELO CORREGIDO
-- =============================================

-- Relación: Lotes de productos -> Productos
ALTER TABLE agro.product_lots
ADD CONSTRAINT FK_ProductLot_Product FOREIGN KEY (product_id)
REFERENCES agro.products(id);

-- Relación: Detalles de orden -> Órdenes
ALTER TABLE agro.order_details
ADD CONSTRAINT FK_OrderDetail_Order FOREIGN KEY (order_id)
REFERENCES agro.orders(id);

-- Relación: Detalles de orden -> Lotes de productos
ALTER TABLE agro.order_details
ADD CONSTRAINT FK_OrderDetail_ProductLot FOREIGN KEY (product_lot_id)
REFERENCES agro.product_lots(id);

-- Clave primaria compuesta para detalles de orden
ALTER TABLE agro.order_details
ADD CONSTRAINT PK_OrderDetail PRIMARY KEY (order_id, product_lot_id);