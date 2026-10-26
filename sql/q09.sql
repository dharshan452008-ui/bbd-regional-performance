-- Business Question: What is the complete order-level fact table with customer and sales rep details?
SELECT
    o.order_id,
    o.order_month,
    c.first_name,
    c.last_name,
    c.region,
    r.rep_name,
    o.item,
    o.quantity,
    o.amount,
    o.status
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN reps AS r ON c.rep_id = r.rep_id
ORDER BY o.order_id ASC;
