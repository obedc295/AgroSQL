-- =============================================
-- SCRIPT DDL - SISTEMA AGROPECUARIO
-- Tablas: Categories, Products, Product_Lots
-- =============================================

---Crear schema principal
CREATE SCHEMA agro;

-- Crear tabla de categorías de productos
CREATE TABLE agro.categories(
    id INT PRIMARY KEY IDENTITY(1,1),           -- ID único autoincremental
    name NVARCHAR(100) NOT NULL UNIQUE,         -- Nombre único de categoría
    description NVARCHAR(255) NOT NULL          -- Descripción de la categoría
);

-- Crear tabla de productos agrícolas
CREATE TABLE agro.products(
    id INT PRIMARY KEY IDENTITY(1,1),           -- ID único autoincremental
    category_id INT NOT NULL,                   -- FK a la categoría del producto
    name NVARCHAR(100) NOT NULL,                -- Nombre del producto
    description NVARCHAR(255) NULL,             -- Descripción opcional del producto
    unit_of_measure NVARCHAR(50) NOT NULL       -- Unidad de medida (ej: Saco 50 kg, 1 Litro)
);

-- Crear tabla de lotes de productos para control de inventario
CREATE TABLE agro.product_lots(
    id INT PRIMARY KEY IDENTITY(1,1),           -- ID único autoincremental
    product_id INT NOT NULL,                    -- FK al producto
    purchase_date DATE NOT NULL,                -- Fecha de compra del lote
    purchase_price DECIMAL(10,2) NOT NULL,      -- Precio de compra por unidad
    initial_quantity DECIMAL(10,2) NOT NULL,    -- Cantidad inicial del lote
    current_stock DECIMAL(10,2) NOT NULL        -- Stock actual disponible
);

-- =============================================
-- CONSTRAINTS DE INTEGRIDAD REFERENCIAL
-- =============================================

-- Relación: Productos -> Categorías
-- Garantiza que cada producto pertenezca a una categoría válida
ALTER TABLE agro.products 
ADD CONSTRAINT FK_Product_Category FOREIGN KEY (category_id) 
REFERENCES agro.categories(id);

-- Relación: Lotes -> Productos  
-- Garantiza que cada lote esté asociado a un producto válido
ALTER TABLE agro.product_lots 
ADD CONSTRAINT FK_ProductLot_Product FOREIGN KEY (product_id) 
REFERENCES agro.products(id);

-- Restricción única: No puede haber productos con mismo nombre en misma categoría
-- Ej: No puede haber "Urea 46%" dos veces en "Fertilizantes"
ALTER TABLE agro.products 
ADD CONSTRAINT UQ_Product_Category_Name UNIQUE (category_id, name);

-- Agregar timestamp exacto
ALTER TABLE agro.product_lots 
ADD created_datetime DATETIME2 NOT NULL DEFAULT GETDATE();
