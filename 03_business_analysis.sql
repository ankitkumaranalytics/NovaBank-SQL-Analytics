-- 1. Monthly transaction performance
SELECT
    DATE_TRUNC('month', transaction_date)::DATE AS transaction_month,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(transaction_amount_inr), 2) AS total_transaction_value,
    ROUND(AVG(transaction_amount_inr), 2) AS average_transaction_value
FROM public.bank_transactions_clean
WHERE transaction_date IS NOT NULL
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY transaction_month;


-- 2. Transaction categories
SELECT
    CASE
        WHEN transaction_amount_inr < 1000 THEN 'Small'
        WHEN transaction_amount_inr < 10000 THEN 'Medium'
        WHEN transaction_amount_inr < 50000 THEN 'Large'
        ELSE 'Very Large'
    END AS transaction_category,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_amount_inr), 2) AS total_amount,
    ROUND(AVG(transaction_amount_inr), 2) AS average_amount
FROM public.bank_transactions_clean
WHERE transaction_amount_inr IS NOT NULL
GROUP BY 1
ORDER BY total_transactions DESC;


-- 3. Gender-wise transaction analysis
SELECT
    COALESCE(cust_gender, 'Unknown') AS gender,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(transaction_amount_inr), 2) AS total_amount
FROM public.bank_transactions_clean
GROUP BY 1
ORDER BY total_amount DESC NULLS LAST;


-- 4. Top 10 locations by transaction amount
SELECT
    COALESCE(cust_location, 'Unknown') AS customer_location,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(transaction_amount_inr), 2) AS total_amount
FROM public.bank_transactions_clean
GROUP BY 1
ORDER BY total_amount DESC NULLS LAST
LIMIT 10;


-- 5. Highest-transaction month
SELECT
    DATE_TRUNC('month', transaction_date)::DATE AS transaction_month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_amount_inr), 2) AS total_transaction_value
FROM public.bank_transactions_clean
WHERE transaction_date IS NOT NULL
GROUP BY 1
ORDER BY total_transaction_value DESC
LIMIT 1;
