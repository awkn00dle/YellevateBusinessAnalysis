-------------- Step1: Create new database and name it Group Project 1.
-------------- Step2: Create Table and name it yellevate_invoices.
CREATE TABLE IF NOT EXISTS yellevate_invoices (
	country varchar,
	customer_id varchar,
	invoice_number numeric,
	invoice_date date,
	due_date date,
	invoice_amount_usd numeric,
	disputed numeric,
	dispute_lost numeric,
	settled_date date,
	days_to_settle integer,
	days_late integer
);
-------------- Step 3: Import CSV file (make sure to select UTF-8 and Header is Toggled On).
-------------- Step 4: Check imported dataset
select * from yellevate_invoices

-------------- Step 5: Create backup table and add columns in preparation for data analysis.
CREATE TABLE yellevate_invoices_backup AS
SELECT *,
CASE
    WHEN disputed=0 AND dispute_lost=0 THEN 'no disputes'
    WHEN disputed=1 AND dispute_lost=0 THEN 'won disputes'
    WHEN disputed=1 AND dispute_lost=1 THEN 'lost disputes'
    END AS disputes,
CASE 
    WHEN disputed=0 AND dispute_lost=0 THEN 'gained revenue'
    WHEN disputed=1 AND dispute_lost=0 THEN 'gained revenue'
    WHEN disputed=1 AND dispute_lost=1 THEN 'lost revenue'
    END AS revenue
FROM yellevate_invoices;

-------------- Step 6: Check new table
select * from yellevate_invoices_backup

-------------- Step 7: Conduct the initial data analysis.
----------------- task 1: Find average # of days invoices were processed (rounded to whole number).
----------------- task 2: Find average # of days disputes were settled (rounded to whole number).
----------------- task 3: Find % of lost disputes of company (2 decimal places).
----------------- task 4: Find % of revenue loss of company (2 decimal places).
select 
    round(avg (days_to_settle),0) as avg_processing_time,     ---task 1
    round(avg (case when disputed = 1 then days_to_settle else NULL end),0) as avg_disputed_processing_time,    ---task 2
    round(sum(dispute_lost) / sum(disputed)*100,2) as pct_lost_disputed,     ---task 3
    round(sum (case when dispute_lost = 1 then invoice_amount_usd else 0 end)/sum (invoice_amount_usd)*100,2) as pct_losses    ---task 4
from yellevate_invoices_backup;

----------------- task 5: Find country reaching the highest loss from lost disputes.
select country,
	sum(case when disputes='lost disputes' then invoice_amount_usd else 0 end) as losses_usd
from yellevate_invoices_backup
group by country
order by losses_usd desc

-------------- Step 8: Save SQL file and Export data as a CSV file
select * from yellevate_invoices_backup