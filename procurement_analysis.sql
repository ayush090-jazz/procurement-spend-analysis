create database procurement_analysis;
use procurement_analysis;

create table staging_spend (
invoice_date varchar(20),
vendor_name varchar(255),
category varchar(100),
department varchar(100),
amount decimal(12,2),
po_number varchar(50)
);

SELECT * FROM staging_spend LIMIT 5;
SELECT COUNT(*) FROM staging_spend;
UPDATE staging_spend
SET invoice_date = STR_TO_DATE(invoice_date, '%d-%m-%Y');
alter table staging_spend
modify invoice_date date;
SELECT MIN(invoice_date), MAX(invoice_date) FROM staging_spend;

SELECT 
    SUM(invoice_date IS NULL) AS missing_dates,
    SUM(vendor_name IS NULL) AS missing_vendors,
    SUM(category IS NULL) AS missing_categories,
    SUM(amount IS NULL) AS missing_amounts
FROM staging_spend;

UPDATE staging_spend
SET vendor_name = UPPER(TRIM(vendor_name));
UPDATE staging_spend
SET vendor_name = 'ABC LTD'
WHERE vendor_name IN ('ABC LIMITED', 'A.B.C LTD');
UPDATE staging_spend
SET vendor_name = 'XYZ TRADERS'
WHERE vendor_name IN ('XYZ TRADERS PVT', 'XYZ TRADERS LTD');
UPDATE staging_spend
SET vendor_name = 'TATA PVT LTD'
WHERE vendor_name IN ('TATA PVT LTD', 'TATA LIMITED');
UPDATE staging_spend
SET vendor_name = 'METRO CORPORATION'
WHERE vendor_name IN ('METRO CORP', 'METRO CORPORATION');
select*from staging_spend;

SELECT vendor_name, COUNT(*) AS txn_count
FROM staging_spend
GROUP BY vendor_name
ORDER BY txn_count DESC;

SELECT category, SUM(amount) AS total_spend
FROM staging_spend
GROUP BY category
ORDER BY total_spend DESC;

CREATE TABLE consolidated_spend AS
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    vendor_name,
    category,
    department,
    SUM(amount) AS total_spend
FROM staging_spend
GROUP BY month, vendor_name, category, department;

SELECT *
FROM (
    SELECT 
        vendor_name,
        category,
        total_spend,
        AVG(total_spend) OVER (PARTITION BY category) AS avg_category_spend
    FROM consolidated_spend
) AS t
WHERE total_spend > 1.2 * avg_category_spend;

SELECT 
    category,
    MIN(total_spend) AS min_spend,
    MAX(total_spend) AS max_spend,
    AVG(total_spend) AS avg_spend,
    COUNT(*) AS vendors_count
FROM consolidated_spend
GROUP BY category;













