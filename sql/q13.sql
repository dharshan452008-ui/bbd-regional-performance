-- Business Question: How did each sales rep perform against their monthly target by month?
SELECT
    r.rep_name,
    o.order_month,
    r.monthly_target,
    SUM(o.amount) AS revenue,
    CASE
        WHEN SUM(o.amount) < r.monthly_target THEN 'Below Target'
        WHEN SUM(o.amount) < 1.1 * r.monthly_target THEN 'On Target'
        ELSE 'Above Target'
    END AS performance_tier
FROM reps AS r
JOIN customers AS c ON r.rep_id = c.rep_id
JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY r.rep_name, o.order_month, r.monthly_target
ORDER BY r.rep_name ASC, o.order_month ASC;
