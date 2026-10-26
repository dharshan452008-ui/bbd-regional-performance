-- Business Question: How many orders and what total amount belong to each status?
SELECT
    status,
    COUNT(*) AS number_of_orders,
    SUM(amount) AS total_amount
FROM orders
GROUP BY status
ORDER BY number_of_orders DESC;
