----CUSTOMER UNDERSTANDING: PROFILING AND SEGMENTATION----

select province, count(*) as customers
from final_customer_data
group by province
order by customers desc
/*
11 provinces
min: 66 in prince edward island
max: 5404 in ontario
*/

select city, count(*) as customers
from final_customer_data
group by city
order by customers desc
/*
29 provinces
min: 66 in Charlottetown
max: 3351 in Toronto
*/

select gender, count(*) as customers
from final_customer_data
group by gender
order by customers 
/*
"Male"	 8327
"Female" 8410
*/

select education, count(*) as customers
from final_customer_data
group by education
order by customers 
/*
"Master"	508
"Doctor"	734
"High School or Below"	782
"College"	4,238
"Bachelor"	10,475
*/

select marital_status, count(*) as customers
from final_customer_data
group by marital_status
order by customers 
/*
"Divorced"	2518
"Single"	4484
"Married"	9735
*/

--by loyalty cards: we have done the evaluation earlier

--determining which customers have highest average_clv as per groups...

select loyalty_card, count(*), round(avg(clv),2) as average_clv
from final_customer_data
group by loyalty_card
order by average_clv;
/*
"Star"	7637	6741.76
"Nova"	5671	8045.62
"Aurora"	3429	10672.69
*/

--lower tier customers have higher avg clv
--Loyalty card tier is not behaving like a premium value hierarchy
/* Although Star appears to be the highest loyalty card category based on the data dictionary, 
Aurora customers showed the highest average CLV in the dataset. 
This suggests that loyalty card status may not directly correspond to customer lifetime value*/

select campaign_period, count(*), round(avg(clv),2) as average_clv
from final_customer_data
group by campaign_period
order by average_clv;
/*
"Pre-Campaign"	13919	7978.20
"Post-Campaign"	1847	8039.22
"Campaign"	971	8046.51
*/

/*
clv difference here is very small.
Average CLV remained broadly similar across campaign periods, 
with campaign-acquired customers showing a slightly higher average CLV
*/

select loyalty_card, count(*), round(avg(salary),2) as average_salary
from final_customer_data
group by loyalty_card
order by average_salary;
/*
"Aurora"	3429	78975.54
"Nova"	5671	78994.70
"Star"	7637	79987.49
income alone is not enough to identify high-value loyalty members
*/

--by cancellation rates:
select loyalty_card, count(*) as customers,
round((sum(is_cancelled)::numeric / count(*)) * 100, 2) as cancellation_rate
from final_customer_data
group by loyalty_card
order by cancellation_rate desc;
/*
"Aurora"	3429	13.09
"Nova"	5671	12.64
"Star"	7637	11.80
highest value customers churn less
*/

select campaign_period, count(*) as customers,
round((sum(is_cancelled)::numeric / count(*)) * 100, 2) as cancellation_rate
from final_customer_data
group by campaign_period
order by cancellation_rate desc;
/*
"Pre-Campaign"	13919	13.92
"Campaign"	971	11.84
"Post-Campaign"	1847	0.76
significantly reduced post campaign amongst limited (1847) new_customers enrolled 
although data is limited so they probably had less time to cancel as well
Post-campaign customers show a much lower observed cancellation rate, 
but this should be interpreted cautiously because they had less time in the dataset to cancel.
however reduction in churn compared in pre-campain to during campaign reduced. 
*/

select enrollment_type, count(*) as customers,
round((sum(is_cancelled)::numeric / count(*)) * 100, 2) as cancellation_rate
from final_customer_data
group by enrollment_type
order by cancellation_rate desc;
/*
"Standard"	15766	12.38
"2018 Promotion"	971	11.84
Customers acquired through the 2018 Promotion had a slightly lower 
observed cancellation rate than standard enrollees, suggesting that the 
campaign did not significantly harm retention quality
*/

select round(avg(salary),2) from final_customer_data
--79,429
select round(avg(clv),2) from final_customer_data
--7988