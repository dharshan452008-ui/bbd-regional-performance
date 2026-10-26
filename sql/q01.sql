-- Business Question: What are the details of pending orders?
SELECT
    order_id,
    customer_id,
    item,
    amount
FROM orders
WHERE status = 'pending'
ORDER BY order_id ASC;
