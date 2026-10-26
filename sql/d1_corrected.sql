-- Business Question: Which regions have completed-order revenue exceeding 80,000?
SELECT
    c.region,
    SUM(o.amount) AS sales
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.region
HAVING SUM(o.amount) > 80000
ORDER BY sales DESC;
