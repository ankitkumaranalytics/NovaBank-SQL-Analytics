-- 1. Top 10 customers by total transaction amount
SELECT
    customer_id,
    COUNT(*) AS total_transactions,
    ROUND(SUM(transaction_amount_inr), 2) AS total_amount,
    ROUND(AVG(transaction_amount_inr), 2) AS average_amount,
    ROUND(MAX(transaction_amount_inr), 2) AS largest_transaction
FROM public.bank_transactions_clean
WHERE customer_id IS NOT NULL
  AND transaction_amount_inr IS NOT NULL
GROUP BY customer_id
ORDER BY total_amount DESC
LIMIT 10;


-- 2. Rank customers by total transaction amount
WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS total_transactions,
        SUM(transaction_amount_inr) AS total_amount
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_transactions,
    ROUND(total_amount, 2) AS total_amount,
    RANK() OVER (ORDER BY total_amount DESC) AS customer_rank
FROM customer_summary
ORDER BY customer_rank
LIMIT 20;


-- 3. Find each customer's largest transaction
WITH ranked_transactions AS (
    SELECT
        transaction_id,
        customer_id,
        transaction_date,
        transaction_amount_inr,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY transaction_amount_inr DESC NULLS LAST,
                     transaction_date DESC NULLS LAST,
                     transaction_id
        ) AS row_num
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
)
SELECT
    transaction_id,
    customer_id,
    transaction_date,
    transaction_amount_inr
FROM ranked_transactions
WHERE row_num = 1
ORDER BY transaction_amount_inr DESC NULLS LAST
LIMIT 20;


-- 4. Running transaction total for each customer
SELECT
    customer_id,
    transaction_date,
    transaction_amount_inr,
    SUM(transaction_amount_inr) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date NULLS LAST, transaction_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM public.bank_transactions_clean
WHERE customer_id IS NOT NULL
ORDER BY customer_id, transaction_date NULLS LAST, transaction_id
LIMIT 100;
