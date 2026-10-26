-- Business Question: What is the completed order and revenue breakdown by region and order month?
-- Join type choice: An INNER JOIN between customers and orders is chosen because the analysis reports strictly on realized completed orders with valid customer regional attributes.
-- Distinct count necessity: COUNT(DISTINCT c.customer_id) is necessary because repeat customers place multiple orders within the same month; a simple COUNT would measure transactions rather than unique participating customers.
SELECT
    c.region,
    o.order_month,
    COUNT(o.order_id) AS number_of_orders,
    COUNT(DISTINCT c.customer_id) AS number_of_customers,
    SUM(o.amount) AS total_revenue,
    AVG(o.amount) AS average_revenue
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.region, o.order_month
ORDER BY c.region ASC, o.order_month ASC;
