-- =========================================
-- 4. OPTIONAL: DATE STANDARDIZATION
-- =========================================

UPDATE transactions
SET date = date(date);-- Remove duplicates
DELETE FROM transactions
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM transactions
    GROUP BY transaction_id, date, store_id, product_id, units, unit_price, total_amount
);-- =========================================



-- =========================================
-- 1. CLEAN PRODUCTS TABLE
-- =========================================

UPDATE products
SET
    product_name = TRIM(product_name),
    category = LOWER(TRIM(category)),
    unit_cost = CASE
        WHEN unit_cost IS NULL OR TRIM(unit_cost) = '' THEN NULL
        ELSE CAST(unit_cost AS REAL)
    END;


-- Remove duplicates (keep first occurrence)
DELETE FROM products
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM products
    GROUP BY product_id, product_name, category, unit_cost
);


-- =========================================
-- 2. CLEAN STORES TABLE
-- =========================================

UPDATE stores
SET
    store_name = TRIM(store_name),
    region = LOWER(TRIM(region));


-- Remove duplicates
DELETE FROM stores
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM stores
    GROUP BY store_id, store_name, region
);


-- =========================================
-- 3. CLEAN TRANSACTIONS TABLE
-- =========================================

-- Trim text fields (if any exist)
UPDATE transactions
SET
    date = TRIM(date);


-- Standardize missing values
UPDATE transactions
SET units = NULL
WHERE TRIM(units) = '' OR units IS NULL;

UPDATE transactions
SET unit_price = NULL
WHERE TRIM(unit_price) = '' OR unit_price IS NULL;

UPDATE transactions
SET total_amount = NULL
WHERE TRIM(total_amount) = '' OR total_amount IS NULL;


-- Convert data types safely
UPDATE transactions
SET
    units = CAST(units AS INTEGER),
    unit_price = CAST(unit_price AS REAL),
    total_amount = CAST(total_amount AS REAL);


-- Fix total_amount consistency
UPDATE transactions
SET total_amount = units * unit_price
WHERE units IS NOT NULL AND unit_price IS NOT NULL;


-- Remove orphan records (invalid foreign keys)
DELETE FROM transactions
WHERE product_id NOT IN (SELECT product_id FROM products)
   OR store_id NOT IN (SELECT store_id FROM stores);


-- Remove duplicates
DELETE FROM transactions
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM transactions
    GROUP BY transaction_id, date, store_id, product_id, units, unit_price, total_amount
);


-- =========================================
-- 4. OPTIONAL: DATE STANDARDIZATION
-- =========================================

-- Try to normalize SQLite date format
UPDATE transactions
SET date = date(date);