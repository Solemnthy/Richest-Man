-- data cleaning

-- 1. check for missing values
select 
    count(*) as total_rows,
    sum(case when name is null then 1 else 0 end) as null_name,
    sum(case when country is null then 1 else 0 end) as null_country,
    sum(case when industry is null then 1 else 0 end) as null_industry,
    sum(case when `net worth (in billions)` is null then 1 else 0 end) as null_net_worth,
    sum(case when company is null then 1 else 0 end) as null_company
from top_1000_wealthiest_people;

-- 2. check for duplicate records
with duplicate_finder as (
    select 
        name,
        country,
        industry,
        `net worth (in billions)`,
        company,
        row_number() over (partition by name, country, industry, `net worth (in billions)`, company order by name) as row_num
    from top_1000_wealthiest_people
)
select 
    name,
    country,
    industry,
    `net worth (in billions)`,
    company,
    row_num
from duplicate_finder
where row_num > 1;

-- 3. validate data types
select 
    count(*) as invalid_net_worth_count
from top_1000_wealthiest_people
where not (`net worth (in billions)` regexp '^[0-9]+(\\.[0-9]+)?$');

-- data exploration

-- 1. summary statistics
select 
    avg(`net worth (in billions)`) as avg_net_worth,
    min(`net worth (in billions)`) as min_net_worth,
    max(`net worth (in billions)`) as max_net_worth,
    count(distinct name) as total_individuals
from top_1000_wealthiest_people;

-- 2. distribution by country
select 
    country,
    count(*) as number_of_individuals,
    avg(`net worth (in billions)`) as avg_net_worth,
    sum(`net worth (in billions)`) as total_net_worth
from top_1000_wealthiest_people
group by country
order by total_net_worth desc;

-- 3. wealth distribution by country
select 
    country,
    count(*) as number_of_individuals,
    avg(`net worth (in billions)`) as average_net_worth,
    max(`net worth (in billions)`) as max_net_worth
from top_1000_wealthiest_people
group by country
order by average_net_worth desc;

-- 4. distribution by industry
select 
    industry,
    count(*) as number_of_individuals,
    avg(`net worth (in billions)`) as avg_net_worth,
    sum(`net worth (in billions)`) as total_net_worth
from top_1000_wealthiest_people
group by industry
order by total_net_worth desc;

-- 5. industry-wise net worth and number of individuals
select 
    industry,
    count(*) as number_of_individuals,
    avg(`net worth (in billions)`) as average_net_worth,
    max(`net worth (in billions)`) as max_net_worth
from top_1000_wealthiest_people
group by industry
order by average_net_worth desc;

-- 6. wealth trends by company
select 
    company,
    count(*) as number_of_individuals,
    avg(`net worth (in billions)`) as avg_net_worth,
    sum(`net worth (in billions)`) as total_net_worth
from top_1000_wealthiest_people
group by company
order by total_net_worth desc;

-- 7. total net worth of people by company
select 
    company,
    sum(`net worth (in billions)`) as total_net_worth
from top_1000_wealthiest_people
group by company
order by total_net_worth desc;

-- 8. top wealthiest individuals
select 
    name,
    country,
    industry,
    `net worth (in billions)` as net_worth,
    company
from top_1000_wealthiest_people
order by `net worth (in billions)` desc
limit 20;

-- 9. wealthiest individuals in each industry
with ranked_individuals as (
    select 
        name,
        industry,
        `net worth (in billions)` as net_worth,
        row_number() over (partition by industry order by `net worth (in billions)` desc) as rank
    from top_1000_wealthiest_people
)
select 
    name,
    industry,
    net_worth
from ranked_individuals
where rank <= 5
order by industry, net_worth desc;

-- 10. track changes in net worth over time (requires historical data)
select 
    year,
    name,
    `net worth (in billions)` as net_worth
from historical_wealth_data
where name in (select name from top_1000_wealthiest_people)
order by year, net_worth desc;

-- 11. highlight notable individuals with exceptional wealth
select 
    name,
    country,
    industry,
    `net worth (in billions)` as net_worth,
    company
from top_1000_wealthiest_people
where `net worth (in billions)` > 150 
order by `net worth (in billions)` desc;
