-- 1. Overall banking transaction KPIs
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(transaction_amount_inr), 2)
        AS total_transaction_value,
    ROUND(AVG(transaction_amount_inr), 2)
        AS average_transaction_value,
    ROUND(MAX(transaction_amount_inr), 2)
        AS highest_transaction_value,
    ROUND(MIN(transaction_amount_inr), 2)
        AS lowest_transaction_value,
    COUNT(*) FILTER (
        WHERE transaction_amount_inr >= 10000
    ) AS transactions_at_least_10000,
    COUNT(*) FILTER (
        WHERE transaction_date IS NULL
    ) AS transactions_missing_date
FROM public.bank_transactions_clean;


-- 2. Monthly KPI trends
SELECT
    DATE_TRUNC('month', transaction_date)::DATE
        AS transaction_month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_amount_inr), 2)
        AS total_transaction_value,
    ROUND(AVG(transaction_amount_inr), 2)
        AS average_transaction_value
FROM public.bank_transactions_clean
WHERE transaction_date IS NOT NULL
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY transaction_month;


-- 3. Transaction amount by category
SELECT
    CASE
        WHEN transaction_amount_inr < 1000 THEN 'Small'
        WHEN transaction_amount_inr < 10000 THEN 'Medium'
        WHEN transaction_amount_inr < 50000 THEN 'Large'
        ELSE 'Very Large'
    END AS transaction_category,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_amount_inr), 2)
        AS total_transaction_value
FROM public.bank_transactions_clean
WHERE transaction_amount_inr IS NOT NULL
GROUP BY 1
ORDER BY total_transaction_value DESC;
