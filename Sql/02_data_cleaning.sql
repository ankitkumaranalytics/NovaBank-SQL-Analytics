DROP TABLE IF EXISTS public.bank_transactions_clean;

CREATE TABLE public.bank_transactions_clean AS
SELECT
    transaction_id,
    customer_id,

    CASE
        WHEN TRIM(customer_dob) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$'
        THEN TO_DATE(TRIM(customer_dob), 'FXDD/MM/YY')
        ELSE NULL
    END AS customer_dob,

    NULLIF(TRIM(cust_gender), '') AS cust_gender,
    NULLIF(TRIM(cust_location), '') AS cust_location,
    cust_account_balance,

    CASE
        WHEN TRIM(transaction_date) ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$'
        THEN TO_DATE(TRIM(transaction_date), 'FXDD/MM/YY')
        ELSE NULL
    END AS transaction_date,

    transaction_time,
    transaction_amount_inr

FROM public.bank_transactions;
