{{ config(materialized='table', alias ='order_rpt')}}

with source as (

    select
        order_id,
        customer_id,
        order_date,
        order_timestamp,
        status,
        total_amount,
        payment_method,
        country
    from {{ source('bigquery_source', 'orders') }} --staging.orders

),

cleaned as (

    select
        order_id,
        customer_id,

        -- Dates
        cast(order_date as date) as order_date,
        cast(order_timestamp as timestamp) as order_ts,

        -- Standardize text
        upper(status) as order_status,
        upper(payment_method) as payment_method,
        upper(country) as country_code,

        -- Metrics
        cast(total_amount as numeric) as order_amount,

        -- Flags
        case
            when upper(status) = 'COMPLETED' then true
            else false
        end as is_completed,

        case
            when upper(status) in ('CANCELLED', 'REFUNDED') then true
            else false
        end as is_cancelled_or_refunded

    from source
)

select * from cleaned