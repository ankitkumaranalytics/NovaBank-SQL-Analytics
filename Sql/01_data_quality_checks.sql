-- 1. Check total rows and distinct transaction IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS distinct_transaction_ids
FROM public.bank_transactions_clean;

-- 2. Check missing values
SELECT
    COUNT(*) FILTER (
        WHERE transaction_id IS NULL
           OR TRIM(transaction_id) = ''
    ) AS missing_transaction_ids,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
           OR TRIM(customer_id) = ''
    ) AS missing_customer_ids,
    COUNT(*) FILTER (
        WHERE transaction_date IS NULL
    ) AS missing_transaction_dates,
    COUNT(*) FILTER (
        WHERE transaction_amount_inr IS NULL
    ) AS missing_transaction_amounts
FROM public.bank_transactions_clean;

-- 3. Check duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS occurrence_count
FROM public.bank_transactions_clean
WHERE transaction_id IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC
LIMIT 20;

-- 4. Check negative transaction amounts
SELECT COUNT(*) AS negative_transaction_amounts
FROM public.bank_transactions_clean
WHERE transaction_amount_inr < 0;
