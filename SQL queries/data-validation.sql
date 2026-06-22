--------------DATA VALIDATION-------------
select count(*)
from final_customer_data
--16737

select count(*)
from flight_activity_cleaned
--389065

select count(*)
from loyalty_history_cleaned
--16737

select count(distinct loyalty_number)
from final_customer_data

select count(distinct loyalty_number)
from flight_activity_cleaned

select count(distinct loyalty_number)
from loyalty_history_cleaned
-- all have unique count of 16737: distinct customers

select is_cancelled, count(loyalty_number)
from final_customer_data
group by is_cancelled
--2067 cancelled, 14670 are still customers. 

select campaign_period, count(*)
from final_customer_data
group by campaign_period
/*
pre-campaign enrollments: 13,919
post-campaign: 1847
during campaign: 971
*/

select loyalty_card, count(*)
from final_customer_data
group by loyalty_card
/* 
star- 7637
nova- 5671
aurora- 3429
*/

select enrollment_type, count(*)
from final_customer_data
group by enrollment_type
/*
2018 promotion: 971
standard: 15766
*/

select clv_buckets, count(*)
from final_customer_data
group by clv_buckets
/*
"High"	5578
"Medium" 5578
"Low"	5581
similar distribution since we used quartiles
*/

select salary_buckets, count(*)
from final_customer_data
group by salary_buckets
/*
"Low"    4161
nulls    4258
"High"   4160
"Medium" 4158
*/

select min(enrollment_date), max(enrollment_date),
min(cancellation_date), max(cancellation_date)
from final_customer_data
/*
min enrol: 1/4/12
max enrol: 1/12/18
min cancel: 1/1/13
max cancel: 1/12/18
*/

select min(year), max(year),
min(month), max(month)
from flight_activity_cleaned
/*
jan 2017 to dec 2018
*/

select count(*)
from final_customer_data
where total_flights=0
--1570

select count(*)
from final_customer_data
where active_months=0
--1570

select count(*)
from final_customer_data
where avg_flights_per_active_month=0
--1570

--hence 1570 customers are inactive

select count(*)
from final_customer_data
where points_redeemed>0
--11,487