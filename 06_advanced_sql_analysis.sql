

-- ============================================================
-- 1. Previous Transaction Comparison Using LAG
-- ============================================================

WITH transaction_history AS (
    SELECT
        customer_id,
        transaction_id,
        transaction_date,
        transaction_amount_inr,
        LAG(transaction_amount_inr) OVER (
            PARTITION BY customer_id
            ORDER BY transaction_date, transaction_id
        ) AS previous_transaction_amount
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
)
SELECT
    customer_id,
    transaction_id,
    transaction_date,
    transaction_amount_inr,
    previous_transaction_amount,
    ROUND(
        transaction_amount_inr - previous_transaction_amount,
        2
    ) AS amount_difference
FROM transaction_history
ORDER BY customer_id, transaction_date, transaction_id
LIMIT 100;


-- ============================================================
-- 2. Customer Running Total
-- ============================================================

SELECT
    customer_id,
    transaction_date,
    transaction_id,
    transaction_amount_inr,
    SUM(transaction_amount_inr) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM public.bank_transactions_clean
WHERE customer_id IS NOT NULL
  AND transaction_date IS NOT NULL
  AND transaction_amount_inr IS NOT NULL
ORDER BY customer_id, transaction_date, transaction_id
LIMIT 100;


-- ============================================================
-- 3. Three-Transaction Moving Average
-- ============================================================

SELECT
    customer_id,
    transaction_date,
    transaction_id,
    transaction_amount_inr,
    ROUND(
        AVG(transaction_amount_inr) OVER (
            PARTITION BY customer_id
            ORDER BY transaction_date, transaction_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_avg_3_transactions
FROM public.bank_transactions_clean
WHERE customer_id IS NOT NULL
  AND transaction_amount_inr IS NOT NULL
ORDER BY customer_id, transaction_date, transaction_id
LIMIT 100;


-- ============================================================
-- 4. Next Transaction Comparison Using LEAD
-- ============================================================

SELECT
    customer_id,
    transaction_date,
    transaction_id,
    transaction_amount_inr,
    LEAD(transaction_amount_inr) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date, transaction_id
    ) AS next_transaction_amount
FROM public.bank_transactions_clean
WHERE customer_id IS NOT NULL
  AND transaction_date IS NOT NULL
ORDER BY customer_id, transaction_date, transaction_id
LIMIT 100;


-- ============================================================
-- 5. Rank Customers by Total Spending
-- ============================================================

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(transaction_amount_inr) AS total_spending
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    ROUND(total_spending, 2) AS total_spending,
    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS spending_rank
FROM customer_spending
ORDER BY spending_rank
LIMIT 100;


-- ============================================================
-- 6. Compare ROW_NUMBER, RANK and DENSE_RANK
-- ============================================================

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(transaction_amount_inr) AS total_spending
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    ROUND(total_spending, 2) AS total_spending,
    ROW_NUMBER() OVER (
        ORDER BY total_spending DESC
    ) AS row_number_rank,
    RANK() OVER (
        ORDER BY total_spending DESC
    ) AS rank_value,
    DENSE_RANK() OVER (
        ORDER BY total_spending DESC
    ) AS dense_rank_value
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 100;


-- ============================================================
-- 7. Top Three Transactions per Customer
-- ============================================================

WITH ranked_transactions AS (
    SELECT
        customer_id,
        transaction_id,
        transaction_date,
        transaction_amount_inr,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY transaction_amount_inr DESC,
                     transaction_date,
                     transaction_id
        ) AS transaction_rank
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
)
SELECT
    customer_id,
    transaction_id,
    transaction_date,
    transaction_amount_inr,
    transaction_rank
FROM ranked_transactions
WHERE transaction_rank <= 3
ORDER BY customer_id, transaction_rank
LIMIT 300;


-- ============================================================
-- 8. Transactions Above Each Customer's Average
-- Optimized with a grouped CTE
-- ============================================================

WITH customer_averages AS (
    SELECT
        customer_id,
        AVG(transaction_amount_inr) AS average_amount
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
)
SELECT
    t.customer_id,
    t.transaction_id,
    t.transaction_date,
    t.transaction_amount_inr,
    ROUND(a.average_amount, 2) AS customer_average
FROM public.bank_transactions_clean AS t
JOIN customer_averages AS a
    ON a.customer_id = t.customer_id
WHERE t.transaction_amount_inr > a.average_amount
ORDER BY t.transaction_amount_inr DESC
LIMIT 100;


-- ============================================================
-- 9. Monthly Transaction Performance
-- ============================================================

SELECT
    DATE_TRUNC('month', transaction_date)::DATE AS month,
    COUNT(*) AS transaction_count,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(transaction_amount_inr), 2) AS total_amount,
    ROUND(AVG(transaction_amount_inr), 2) AS average_amount
FROM public.bank_transactions_clean
WHERE transaction_date IS NOT NULL
  AND transaction_amount_inr IS NOT NULL
GROUP BY DATE_TRUNC('month', transaction_date)::DATE
ORDER BY month;


-- ============================================================
-- 10. Month-over-Month Growth
-- ============================================================

WITH monthly_summary AS (
    SELECT
        DATE_TRUNC('month', transaction_date)::DATE AS month,
        SUM(transaction_amount_inr) AS monthly_amount
    FROM public.bank_transactions_clean
    WHERE transaction_date IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY DATE_TRUNC('month', transaction_date)::DATE
),
monthly_comparison AS (
    SELECT
        month,
        monthly_amount,
        LAG(monthly_amount) OVER (
            ORDER BY month
        ) AS previous_month_amount
    FROM monthly_summary
)
SELECT
    month,
    ROUND(monthly_amount, 2) AS monthly_amount,
    ROUND(previous_month_amount, 2) AS previous_month_amount,
    ROUND(
        100.0 * (monthly_amount - previous_month_amount)
        / NULLIF(previous_month_amount, 0),
        2
    ) AS growth_percentage
FROM monthly_comparison
ORDER BY month;


-- ============================================================
-- 11. Rolling Three-Month Average
-- Uses the three latest available monthly rows
-- ============================================================

WITH monthly_summary AS (
    SELECT
        DATE_TRUNC('month', transaction_date)::DATE AS month,
        SUM(transaction_amount_inr) AS monthly_amount
    FROM public.bank_transactions_clean
    WHERE transaction_date IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY DATE_TRUNC('month', transaction_date)::DATE
)
SELECT
    month,
    ROUND(monthly_amount, 2) AS monthly_amount,
    ROUND(
        AVG(monthly_amount) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_3_month_average
FROM monthly_summary
ORDER BY month;


-- ============================================================
-- 12. Transaction Amount Segmentation
-- ============================================================

SELECT
    CASE
        WHEN transaction_amount_inr < 1000 THEN 'Small'
        WHEN transaction_amount_inr < 10000 THEN 'Medium'
        WHEN transaction_amount_inr < 50000 THEN 'Large'
        ELSE 'Very Large'
    END AS transaction_category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(transaction_amount_inr), 2) AS total_amount,
    ROUND(AVG(transaction_amount_inr), 2) AS average_amount
FROM public.bank_transactions_clean
WHERE transaction_amount_inr IS NOT NULL
GROUP BY 1
ORDER BY
    MIN(
        CASE
            WHEN transaction_amount_inr < 1000 THEN 1
            WHEN transaction_amount_inr < 10000 THEN 2
            WHEN transaction_amount_inr < 50000 THEN 3
            ELSE 4
        END
    );


-- ============================================================
-- 13. IQR-Based Transaction Outlier Detection
-- ============================================================

WITH quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (
            ORDER BY transaction_amount_inr
        ) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (
            ORDER BY transaction_amount_inr
        ) AS q3
    FROM public.bank_transactions_clean
    WHERE transaction_amount_inr IS NOT NULL
),
bounds AS (
    SELECT
        q1,
        q3,
        q3 - q1 AS iqr,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM quartiles
)
SELECT
    t.transaction_id,
    t.customer_id,
    t.transaction_date,
    t.transaction_amount_inr,
    ROUND(b.lower_bound::NUMERIC, 2) AS lower_bound,
    ROUND(b.upper_bound::NUMERIC, 2) AS upper_bound
FROM public.bank_transactions_clean AS t
CROSS JOIN bounds AS b
WHERE t.transaction_amount_inr < b.lower_bound
   OR t.transaction_amount_inr > b.upper_bound
ORDER BY t.transaction_amount_inr DESC
LIMIT 100;


-- ============================================================
-- 14. Customer-Level Anomaly Detection
-- Transactions above three times customer average
-- ============================================================

WITH customer_averages AS (
    SELECT
        customer_id,
        AVG(transaction_amount_inr) AS average_amount
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
)
SELECT
    t.customer_id,
    t.transaction_id,
    t.transaction_date,
    t.transaction_amount_inr,
    ROUND(a.average_amount, 2) AS customer_average,
    ROUND((3 * a.average_amount)::NUMERIC, 2) AS anomaly_threshold
FROM public.bank_transactions_clean AS t
JOIN customer_averages AS a
    ON a.customer_id = t.customer_id
WHERE t.transaction_amount_inr > 3 * a.average_amount
ORDER BY t.transaction_amount_inr DESC
LIMIT 100;


-- ============================================================
-- 15. Monthly Customer Retention
-- Customers active in consecutive available months
-- ============================================================

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', transaction_date)::DATE AS month
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
),
monthly_retention AS (
    SELECT
        current_month.month,
        COUNT(*) AS active_customers,
        COUNT(previous_month.customer_id) AS retained_customers
    FROM customer_months AS current_month
    LEFT JOIN customer_months AS previous_month
        ON previous_month.customer_id = current_month.customer_id
       AND previous_month.month =
           (current_month.month - INTERVAL '1 month')::DATE
    GROUP BY current_month.month
)
SELECT
    month,
    active_customers,
    retained_customers,
    ROUND(
        100.0 * retained_customers
        / NULLIF(active_customers, 0),
        2
    ) AS retention_percentage
FROM monthly_retention
ORDER BY month;


-- ============================================================
-- 16. Customer Cohort Analysis
-- Cohort is the month of the first recorded transaction
-- ============================================================

WITH customer_first_month AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(transaction_date))::DATE AS cohort_month
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', transaction_date)::DATE AS activity_month
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
)
SELECT
    f.cohort_month,
    a.activity_month,
    (
        EXTRACT(YEAR FROM AGE(a.activity_month, f.cohort_month)) * 12
        + EXTRACT(MONTH FROM AGE(a.activity_month, f.cohort_month))
    )::INTEGER AS cohort_age_months,
    COUNT(DISTINCT a.customer_id) AS active_customers
FROM customer_first_month AS f
JOIN customer_activity AS a
    ON a.customer_id = f.customer_id
GROUP BY f.cohort_month, a.activity_month
ORDER BY f.cohort_month, a.activity_month;


-- ============================================================
-- 17. Customer Spending Distribution
-- ============================================================

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(transaction_amount_inr) AS total_spending
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_spending >= 100000 THEN 'Platinum'
        WHEN total_spending >= 50000 THEN 'Gold'
        WHEN total_spending >= 10000 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spending), 2) AS segment_total_spending,
    ROUND(AVG(total_spending), 2) AS average_customer_spending
FROM customer_spending
GROUP BY 1
ORDER BY
    MIN(
        CASE
            WHEN total_spending >= 100000 THEN 1
            WHEN total_spending >= 50000 THEN 2
            WHEN total_spending >= 10000 THEN 3
            ELSE 4
        END
    );


-- ============================================================
-- 18. Final Advanced Analysis Summary
-- ============================================================

SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT transaction_date) AS active_transaction_dates,
    ROUND(SUM(transaction_amount_inr), 2) AS total_transaction_amount,
    ROUND(AVG(transaction_amount_inr), 2) AS average_transaction_amount,
    MAX(transaction_amount_inr) AS largest_transaction
FROM public.bank_transactions_clean
WHERE transaction_amount_inr IS NOT NULL;
