
-- ============================================================
-- 1. Customer RFM Metrics
-- Recency: Days since last recorded transaction
-- Frequency: Number of recorded transactions
-- Monetary: Total transaction amount
-- ============================================================

WITH customer_rfm AS (
    SELECT
        customer_id,
        MAX(transaction_date) AS last_transaction_date,
        COUNT(*) AS frequency,
        SUM(transaction_amount_inr) AS monetary_value
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
)
SELECT
    customer_id,
    last_transaction_date,
    CURRENT_DATE - last_transaction_date AS recency_days,
    frequency,
    ROUND(monetary_value, 2) AS monetary_value
FROM customer_rfm
ORDER BY monetary_value DESC
LIMIT 100;


-- ============================================================
-- 2. RFM Scores
-- Score customers from 1 to 5
-- Higher recency score = more recent activity
-- ============================================================

WITH customer_rfm AS (
    SELECT
        customer_id,
        MAX(transaction_date) AS last_transaction_date,
        COUNT(*) AS frequency,
        SUM(transaction_amount_inr) AS monetary_value
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
),
scored_customers AS (
    SELECT
        customer_id,
        last_transaction_date,
        CURRENT_DATE - last_transaction_date AS recency_days,
        frequency,
        monetary_value,

        NTILE(5) OVER (
            ORDER BY last_transaction_date ASC
        ) AS recency_bucket,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS monetary_score

    FROM customer_rfm
)
SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) AS monetary_value,
    6 - recency_bucket AS recency_score,
    frequency_score,
    monetary_score,
    (6 - recency_bucket)
        + frequency_score
        + monetary_score AS rfm_total_score
FROM scored_customers
ORDER BY rfm_total_score DESC, monetary_value DESC
LIMIT 100;


-- ============================================================
-- 3. Customer Segment Classification
-- Illustrative business rules, not universal thresholds
-- ============================================================

WITH customer_rfm AS (
    SELECT
        customer_id,
        MAX(transaction_date) AS last_transaction_date,
        COUNT(*) AS frequency,
        SUM(transaction_amount_inr) AS monetary_value
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
),
scored_customers AS (
    SELECT
        customer_id,
        CURRENT_DATE - last_transaction_date AS recency_days,
        frequency,
        monetary_value,
        NTILE(5) OVER (
            ORDER BY last_transaction_date ASC
        ) AS recency_bucket,
        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS monetary_score
    FROM customer_rfm
),
rfm_scores AS (
    SELECT
        *,
        6 - recency_bucket AS recency_score
    FROM scored_customers
)
SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) AS monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score >= 4
         AND frequency_score >= 4
         AND monetary_score >= 4
            THEN 'Best Customers'

        WHEN recency_score >= 3
         AND frequency_score >= 3
            THEN 'Loyal Customers'

        WHEN recency_score >= 4
         AND frequency_score <= 2
            THEN 'Recent Customers'

        WHEN recency_score <= 2
         AND frequency_score >= 3
            THEN 'At Risk'

        ELSE 'Needs Attention'
    END AS customer_segment
FROM rfm_scores
ORDER BY recency_score DESC, monetary_score DESC
LIMIT 100;


-- ============================================================
-- 4. RFM Segment Summary
-- ============================================================

WITH customer_rfm AS (
    SELECT
        customer_id,
        MAX(transaction_date) AS last_transaction_date,
        COUNT(*) AS frequency,
        SUM(transaction_amount_inr) AS monetary_value
    FROM public.bank_transactions_clean
    WHERE customer_id IS NOT NULL
      AND transaction_date IS NOT NULL
      AND transaction_amount_inr IS NOT NULL
    GROUP BY customer_id
),
scored_customers AS (
    SELECT
        customer_id,
        CURRENT_DATE - last_transaction_date AS recency_days,
        frequency,
        monetary_value,
        6 - NTILE(5) OVER (
            ORDER BY last_transaction_date ASC
        ) AS recency_score,
        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS monetary_score
    FROM customer_rfm
),
segmented_customers AS (
    SELECT
        *,
        CASE
            WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
                THEN 'Best Customers'
            WHEN recency_score >= 3
             AND frequency_score >= 3
                THEN 'Loyal Customers'
            WHEN recency_score >= 4
             AND frequency_score <= 2
                THEN 'Recent Customers'
            WHEN recency_score <= 2
             AND frequency_score >= 3
                THEN 'At Risk'
            ELSE 'Needs Attention'
        END AS customer_segment
    FROM scored_customers
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary_value), 2) AS average_customer_value,
    ROUND(SUM(monetary_value), 2) AS total_segment_value,
    ROUND(AVG(recency_days), 2) AS average_recency_days,
    ROUND(AVG(frequency), 2) AS average_transaction_frequency
FROM segmented_customers
GROUP BY customer_segment
ORDER BY customer_count DESC;


-- ============================================================
-- 5. RFM Analysis Data Quality Summary
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_ids,
    COUNT(*) FILTER (
        WHERE transaction_date IS NULL
    ) AS missing_transaction_dates,
    COUNT(*) FILTER (
        WHERE transaction_amount_inr IS NULL
    ) AS missing_transaction_amounts
FROM public.bank_transactions_clean;
