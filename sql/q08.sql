-- Business Question: What is the customer profile by region in terms of count and age distribution?
SELECT
    region,
    COUNT(*) AS number_of_customers,
    AVG(age) AS average_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age
FROM customers
GROUP BY region
ORDER BY region ASC;
