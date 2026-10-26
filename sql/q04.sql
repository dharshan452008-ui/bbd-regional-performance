-- Business Question: Which customers in the North or West regions are aged between 25 and 40 inclusive?
SELECT
    customer_id,
    first_name,
    last_name,
    region,
    age
FROM customers
WHERE region IN ('North', 'West')
  AND age BETWEEN 25 AND 40
ORDER BY age ASC, customer_id ASC;
