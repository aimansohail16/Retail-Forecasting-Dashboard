-- Exploring the data of each datasets

-- train
select * 
from retail_forecasting.train
limit 5;
-- test
select *
from retail_forecasting.test
limit 5;
-- stores
select *
from retail_forecasting.stores
limit 5;
-- oil
select *
from retail_forecasting.oil
limit 5;
-- holiday_events
select *
from retail_forecasting.holidays_events
limit 5;
-- transactions
select *
from retail_forecasting.transactions
limit 5;
-- Check Table Structure(Column Name, Datatype)
-- train
describe retail_forecasting.train;
-- test
describe retail_forecasting.test;
-- stores
describe retail_forecasting.stores;
-- oil
describe retail_forecasting.oil;
-- holiday_events
describe retail_forecasting.holidays_events;
-- transactions
describe retail_forecasting.transactions;
-- Change date datatype in different datasets as they are appeared as text
-- test
update retail_forecasting.test
set date = date_format(str_to_date(date, '%d/%m/%Y'), '%Y-%m-%d');

alter table retail_forecasting.test
modify column date DATE;

describe retail_forecasting.test;
-- holidays_events
update retail_forecasting.holidays_events
set date = date_format(str_to_date(date, '%d/%m/%Y'), '%Y-%m-%d');

alter table retail_forecasting.holidays_events
modify column date DATE;

describe retail_forecasting.holidays_events;
-- transactions

update retail_forecasting.transactions
set date = date_format(str_to_date(date, '%d/%m/%Y'), '%Y-%m-%d');

alter table retail_forecasting.transactions
modify column date DATE;

describe retail_forecasting.transactions;

-- oil
update retail_forecasting.oil
set date = date_format(str_to_date(date, '%d/%m/%Y'), '%Y-%m-%d');

alter table retail_forecasting.oil
modify column date DATE;

describe retail_forecasting.oil;
-- Clean the data in each databases

-- check null columns
-- train
select *
from retail_forecasting.train
where id is null 
	or date is null 
    or store_nbr is null 
    or family is null
    or sales is null
    or onpromotion is null; -- 1st method
    
select 
	count(*) as total_rows,
    sum(
		case
			when id is null then 1 else 0 end) as missing_id,
	sum(
		case
			when date is null then 1 else 0 end) as missing_date,
	sum(
		case
			when store_nbr is null then 1 else 0 end) as missing_store,
	sum(
		case
			when family is null then 1 else 0 end) as missing_family,
	sum(
		case
			when sales is null then 1 else 0 end) as missing_sales,
	sum(
		case
			when onpromotion is null then 1 else 0 end) as missing_promotion
from retail_forecasting.train; -- 2nd method
-- for other datasets we've already check nulls or missing values in excel
-- Check duplicates in each datasets
-- train
select date, store_nbr, family, count(*) as duplicate_count
from retail_forecasting.train
group by date, store_nbr, family
having count(*) > 1;
-- test
select date, store_nbr, family, count(*) as duplicate_count
from retail_forecasting.test
group by date, store_nbr, family
having count(*) > 1;
-- stores
select *, count(*) as duplicate_count
from retail_forecasting.stores
group by store_nbr, city, state, type, cluster
having count(*) > 1;
-- oil
select *, count(*) as duplicate_count
from retail_forecasting.oil
group by date, dcoilwtico 
having count(*) > 1;
-- holidays_events
select *, count(*) as duplicate_count
from retail_forecasting.holidays_events
group by date, type, locale, locale_name, description, transferred
having count(*) > 1;
-- transactions
select *, count(*) as duplicate_count
from retail_forecasting.transactions
group by date, store_nbr, transactions
having count(*) > 1;

-- Join the tables
-- As train table is the main table lets check the common columns in other tables to join them with train table
-- In train table, the columns we have id, date, store_nbr, family, sales, onpromotion
-- In oil table, the columns we have date, dcoilwtico
-- In stores table, the column we have store_nbr, city, state, type, cluster
-- In holidays_events table, the column we have date, type, locale, locale_name, description, transferred
-- In transactions table, the column we have date, store_nbr, transactions

-- join table train and oil, the common colum it has is date
select t.date, t.sales, o.dcoilwtico as oil_prices
from retail_forecasting.train as t
left join retail_forecasting.oil as o
	on t.date = o.date
limit 15;

-- join table train and store, the common column they have is store_nbr
select t.date, t.store_nbr, t.sales, s.city, s.state
from retail_forecasting.train as t
join retail_forecasting.stores as s -- join by default means inner join
	on t.store_nbr = s.store_nbr;
    
-- join table train and holidays_events, the common column it has is date
select t.date, t.sales, t.store_nbr,t.family, h.description as holiday_events
from retail_forecasting.train as t
left join retail_forecasting.holidays_events as h
	on t.date = h.date;
    
-- join table train and transactions, the common column it has are date and store_nbr
select t.date, t.store_nbr, t.sales, tr.transactions
from retail_forecasting.train as t
left join retail_forecasting.transactions as tr
	on t.store_nbr = tr.store_nbr and t.date = tr.date;
    
-- Aggregate the data means summarize

-- Total sales per year, month, or week
-- Yearly
select 
	store_nbr,
    year(date) as sales_year,
    sum(sales) as total_sales
from retail_forecasting.train
group by store_nbr, sales_year
order by store_nbr, sales_year;
-- Monthly
select 
	store_nbr,
    date_format(date,'%Y-%m') as sales_month,
    sum(sales) as total_sales
from retail_forecasting.train
group by store_nbr, sales_month
order by store_nbr, sales_month;
-- Weekly
select 
	store_nbr,
    week(date) as week_number,
    sum(sales) as total_sales
from retail_forecasting.train
group by store_nbr, week_number
order by store_nbr, week_number;
-- Max sales in each store
select 
	store_nbr,
    max(sales) as max_sales
from retail_forecasting.train
group by store_nbr
order by store_nbr;
-- Min sales in each store
select 
    store_nbr,
    min(sales) as min_sales
from retail_forecasting.train
group by store_nbr
order by store_nbr;
-- Average sales in each store
select 
	store_nbr,
    avg(sales) as average_sales
from retail_forecasting.train
group by store_nbr
order by store_nbr;

-- Filter and compare

-- Filter the sales on holidays
select t.date, t.sales,t.store_nbr,t.family, h.description as holiday_event
from retail_forecasting.train as t
join retail_forecasting.holidays_events as h
	on t.date = h.date;
-- compare the avg sales in holidays vs in normal days
-- In Normal Days
select 
	avg(sales) as average_sales
from retail_forecasting.train
where date not in ( select date from retail_forecasting.holidays_events); -- output = 352.1592
-- In Holidays
select
	avg(t.sales) as average_holiday_sales
from retail_forecasting.train as t
inner join retail_forecasting.holidays_events as h
	on t.date = h.date; -- output = 393.98645
-- compare the total sales in holidays vs in normal days
-- In Normal Days
select 
	sum(sales) as total_sales
from retail_forecasting.train
where date not in ( select date from retail_forecasting.holidays_events); 
-- output = 898648177
-- In Holidays
select
	sum(t.sales) as total_holiday_sales
from retail_forecasting.train as t
inner join retail_forecasting.holidays_events as h
	on t.date = h.date; -- output = 197926373

-- also we can check how many days in each type
-- Normal Days
select 
	count(distinct date) as total_days
from retail_forecasting.train
where date not in ( select date from retail_forecasting.holidays_events); 
-- output = 1432
-- In Holidays
select
	count(distinct t.date) as total_holidays
from retail_forecasting.train as t
inner join retail_forecasting.holidays_events as h
	on t.date = h.date; -- output = 252

-- Now we create the temporary table for forecasting

create view clean_forecasting_data as 
select 
	t.date, t.store_nbr, t.family, t.sales, t.onpromotion,
    tr.transactions, o.dcoilwtico as oil_prices,
    h.description as holiday_event,
    s.city, s.state
from retail_forecasting.train as t
left join retail_forecasting.holidays_events as h 
	on t.date = h.date
left join retail_forecasting.oil as o
	on t.date = o.date
left join retail_forecasting.transactions as tr
	on t.date = tr.date and t.store_nbr = tr.store_nbr
join retail_forecasting.stores as s
	on t.store_nbr = s.store_nbr;



