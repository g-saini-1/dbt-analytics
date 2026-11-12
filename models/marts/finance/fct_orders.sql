with orders as  (
    select * from {{ ref ('stg_jaffle_shop__orders' )}}
),

payments_orig as (
    select * from {{ ref ('stg_stripe__payment') }}
),

payments as (
    select
        payment_id,
        order_id,
        payment_method,
        status as payment_status,
        amount as payment_amount,
        created_at
        -- _batched_at
    from payments_orig
),

order_payments as (
    select
        order_id,
        sum (case when payment_status = 'success' then payment_amount end) as amount

    from payments
    group by 1
),

 final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        coalesce (order_payments.amount, 0) as amount

    from orders
    left join order_payments using (order_id)
)

select * from final