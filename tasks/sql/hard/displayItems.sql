
-- =====================================================
-- FORK, COMMIT, MERGE
-- Issue #8522: Hard SQL Exercises
-- Multi-table SQL: SELLER, STOCKS and PRODUCT
-- Database: SQLite
-- =====================================================

PRAGMA foreign_keys = ON;


-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

CREATE TABLE SELLER (
    S_id INTEGER PRIMARY KEY,
    Name TEXT NOT NULL,
    Bank_acc_no TEXT NOT NULL,
    Email TEXT NOT NULL,
    Phone TEXT NOT NULL
);


CREATE TABLE PRODUCT (
    Prod_id INTEGER PRIMARY KEY,
    Prod_name TEXT NOT NULL,
    Description TEXT,
    Price REAL NOT NULL CHECK (Price >= 0),
    Expiry_date TEXT
);


CREATE TABLE STOCKS (
    S_id INTEGER NOT NULL,
    Prod_id INTEGER NOT NULL,
    S_Date TEXT NOT NULL,

    PRIMARY KEY (S_id, Prod_id, S_Date),

    FOREIGN KEY (S_id)
        REFERENCES SELLER(S_id),

    FOREIGN KEY (Prod_id)
        REFERENCES PRODUCT(Prod_id)
);


-- =====================================================
-- 2. INSERT SAMPLE DATA
-- =====================================================

-- Insert values into SELLER

INSERT INTO SELLER
    (S_id, Name, Bank_acc_no, Email, Phone)
VALUES
    (1, 'John Doe', '1234567890',
     'johndoe@email.com', '555-123-4567'),

    (2, 'Jane Smith', '9876543210',
     'janesmith@email.com', '555-987-6543');


-- Insert values into PRODUCT

INSERT INTO PRODUCT
    (Prod_id, Prod_name, Description, Price, Expiry_date)
VALUES
    (101, 'Product A', 'Description for Product A',
     25.99, '2023-12-31'),

    (102, 'Product B', 'Description for Product B',
     19.99, '2023-11-30'),

    (103, 'Product C', 'Description for Product C',
     39.99, '2023-10-15');


-- Insert values into STOCKS

INSERT INTO STOCKS
    (S_id, Prod_id, S_Date)
VALUES
    (1, 101, '2023-01-15'),

    (1, 102, '2023-02-20'),

    (2, 103, '2023-03-10');


-- =====================================================
-- 3. SQL EXERCISES
-- =====================================================


-- -----------------------------------------------------
-- (a)
-- Display sellers and their bank account numbers
-- who stocked at least 24 different products
-- priced higher than 1000 rupees in the last year.
-- -----------------------------------------------------

SELECT
    s.Name,
    s.Bank_acc_no

FROM SELLER s

INNER JOIN STOCKS st
    ON s.S_id = st.S_id

INNER JOIN PRODUCT p
    ON st.Prod_id = p.Prod_id

WHERE p.Price > 1000

AND date(st.S_Date) >= date('now', '-1 year')
AND date(st.S_Date) <= date('now')

GROUP BY
    s.S_id,
    s.Name,
    s.Bank_acc_no

HAVING COUNT(DISTINCT p.Prod_id) >= 24;


-- -----------------------------------------------------
-- (b)
-- Use nested query to display sellers' names
-- and email addresses who have expired products.
-- -----------------------------------------------------

SELECT
    Name,
    Email

FROM SELLER

WHERE S_id IN (

    SELECT S_id

    FROM STOCKS

    WHERE Prod_id IN (

        SELECT Prod_id

        FROM PRODUCT

        WHERE date(Expiry_date) < date('now')

    )

);


-- -----------------------------------------------------
-- (c)
-- Display products that are in stock by at least
-- one seller and products that are not in stock
-- by any seller.
-- -----------------------------------------------------

SELECT
    p.Prod_name,

    CASE
        WHEN EXISTS (

            SELECT 1

            FROM STOCKS st

            WHERE st.Prod_id = p.Prod_id

        )

        THEN 'In Stock'

        ELSE 'Not In Stock'

    END AS Stock_Status

FROM PRODUCT p

ORDER BY p.Prod_name;


-- -----------------------------------------------------
-- (d)
-- Display seller names and product names
-- stocked between March 23, 2020 and June 30, 2020.
-- -----------------------------------------------------

SELECT
    s.Name AS Seller_Name,
    p.Prod_name AS Product_Name

FROM SELLER s

INNER JOIN STOCKS st
    ON s.S_id = st.S_id

INNER JOIN PRODUCT p
    ON st.Prod_id = p.Prod_id

WHERE date(st.S_Date)
BETWEEN '2020-03-23' AND '2020-06-30'

ORDER BY
    s.Name,
    p.Prod_name;


-- -----------------------------------------------------
-- (e)
-- Display sellers who have stocked the maximum
-- and minimum number of different products.
-- -----------------------------------------------------

WITH Seller_Product_Count AS (

    SELECT
        s.S_id,
        s.Name,

        COUNT(DISTINCT st.Prod_id) AS Total_Products

    FROM SELLER s

    LEFT JOIN STOCKS st
        ON s.S_id = st.S_id

    GROUP BY
        s.S_id,
        s.Name

)

SELECT
    Name,
    Total_Products

FROM Seller_Product_Count

WHERE Total_Products = (
    SELECT MAX(Total_Products)
    FROM Seller_Product_Count
)

OR Total_Products = (
    SELECT MIN(Total_Products)
    FROM Seller_Product_Count
)

ORDER BY Total_Products DESC, Name;
