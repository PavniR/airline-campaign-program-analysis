------ACTIVITY BEHAVIOURAL ANALYSIS------

select loyalty_card,
round(avg(total_flights),2) as avg_flights,
round(avg(total_distance),2) as avg_distance,
round(avg(active_months),2) as avg_active_months,
round(avg(points_accumulated),2) as avg_points_accumulated,
round(avg(points_redeemed),2) as avg_points_redeemed,
round(avg(redeemed_value),2) as avg_redeemed_value
from final_customer_data
group by loyalty_card;

----CAMPAIGN ANALYSIS-----------
select campaign_period,
round(avg(total_flights),2) as avg_flights,
round(avg(total_distance),2) as avg_distance,
round(avg(active_months),2) as avg_active_months,
round(avg(points_accumulated),2) as avg_points_accumulated,
round(avg(points_redeemed),2) as avg_points_redeemed,
round(avg(redeemed_value),2) as avg_redeemed_value,
round(avg(avg_flights_per_active_month),2) as avg_flights_perActiveMonth,
round(avg(avg_distance_per_active_month),2) as avg_distance_perActiveMonth
from final_customer_data
group by campaign_period;

---------CHURN vs BEHAVIOUR ANALYSIS---------
select is_cancelled,
round(avg(total_flights),2) as avg_flights,
round(avg(total_distance),2) as avg_distance,
round(avg(active_months),2) as avg_active_months,
round(avg(points_accumulated),2) as avg_points_accumulated,
round(avg(points_redeemed),2) as avg_points_redeemed,
round(avg(redeemed_value),2) as avg_redeemed_value,
round(avg(avg_flights_per_active_month),2) as avg_flights_perActiveMonth,
round(avg(avg_distance_per_active_month),2) as avg_distance_perActiveMonth
from final_customer_data
group by is_cancelled;

--did campaign brough customers who churn more or less?
select campaign_period,
round(avg(is_cancelled)*100,2) as cancellation_rate
from final_customer_data
group by campaign_period;
/*
"Post-Campaign"	0.76
"Pre-Campaign"	13.92
"Campaign"	11.84
*/

--monthly enrollment trend:
select date_trunc('month', enrollment_date)::date as month,
count(*) as new_members
from final_customer_data
group by month
order by month;

--monthly cancellation trend:
select date_trunc('month', cancellation_date)::date as month,
count(*) as cancellations
from final_customer_data
where cancellation_date is not null
group by month
order by month;

--monthly-net growth: 
with enrollments as (
select date_trunc('month', enrollment_date)::date as month,
count(*) as new_members
from final_customer_data
group by month
),
cancellations as (
select date_trunc('month', cancellation_date)::date as month,
count(*) as cancellations
from final_customer_data
where cancellation_date is not null
group by month
)
select
coalesce(e.month, c.month) as month,
coalesce(e.new_members, 0) as new_members,
coalesce(c.cancellations, 0) as cancellations,
coalesce(e.new_members, 0) - coalesce(c.cancellations, 0) as net_growth
from enrollments e
full outer join cancellations c
on e.month = c.month
order by month;

--active customers by month:
select make_date(year, month, 1) as the_month,
count(distinct loyalty_number) as active_customers,
sum(total_flights) as total_flights
from flight_activity_cleaned
group by the_month
order by the_month;

--cancellation rate by province:
select province,
count(*) as total_customers,
sum(is_cancelled) as cancelled_customers,
round((sum(is_cancelled)::numeric / count(*)) * 100, 2) as cancellation_rate
from final_customer_data
group by province
order by cancellation_rate desc, total_customers desc;

--cancellation-rate by clv bucket:
select clv_buckets,
count(*) as total_customers,
sum(is_cancelled) as cancelled_customers,
round((sum(is_cancelled)::numeric / count(*)) * 100, 2) as cancellation_rate
from final_customer_data
group by clv_buckets
order by cancellation_rate desc;

--cancellation-rate by salary-bucket:
select salary_buckets,
count(*) as total_customers,
sum(is_cancelled) as cancelled_customers,
round((sum(is_cancelled)::numeric / count(*)) * 100, 2) as cancellation_rate
from final_customer_data
group by salary_buckets
order by cancellation_rate desc;

--inactive customers by loyalty card:
select loyalty_card, count(*) as total_customers,
sum(case when total_flights = 0 then 1 else 0 end) as inactive_customers,
round((sum(case when total_flights = 0 then 1 else 0 end)::numeric / count(*)) * 100, 2) as inactive_rate
from final_customer_data
group by loyalty_card
order by inactive_rate desc;

--inactive customers by campaign period:
select campaign_period, count(*) as total_customers,
sum(case when total_flights = 0 then 1 else 0 end) as inactive_customers,
round((sum(case when total_flights = 0 then 1 else 0 end)::numeric / count(*)) * 100, 2) as inactive_rate
from final_customer_data
group by campaign_period
order by inactive_rate desc;

--high-flight, low-points redemption:
with thresholds as (
select percentile_cont(0.75) within group (order by total_flights) as p75_flights
from final_customer_data
)
select loyalty_number, loyalty_card, campaign_period, clv, total_flights, points_redeemed, redeemed_value
from final_customer_data, thresholds
where total_flights >= thresholds.p75_flights
and coalesce(points_redeemed, 0) = 0
order by total_flights desc;
--668

--dormant, low activity customers:
select loyalty_number, loyalty_card, campaign_period, clv, salary, province,city
from final_customer_data
where total_flights = 0
and active_months = 0
and is_cancelled = 0
order by clv desc;
--619

--promo but low-engagement customers:
select loyalty_number, loyalty_card, clv, total_flights, active_months, avg_flights_per_active_month, avg_distance_per_active_month
from final_customer_data
where enrollment_type = '2018 Promotion'
and active_months <= 3
order by avg_flights_per_active_month asc, clv desc;
--118