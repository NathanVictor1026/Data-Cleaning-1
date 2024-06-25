# RECORDS OF LAYOFFS AROUND THE WORLD.

### Table Of Contents.
- [PROJECT OVERVIEW](#project-overview)

- [TOOLS](#tools)

- [DATA PREPARATION AND CLEANING.](#data-preparation-and-cleaning.)

- [EXPLORATORY DATA ANALYSIS.](#exploratory-data-analysis.)

- [RESULTS/FINDINGS.](#results/findings.)

- [LIMITATIONS.](#limitations.)

- [CODE.](#code.)


## PROJECT OVERVIEW
This data set was initially obtained as a raw data set with errors and missing values. Using MySQL Workbench and knowledge of SQL syntax, the data set was cleaned and afterwards analysed to obtain statistics like highest number of layoffs, companies that laid off the most, countries with the most layoffs, and more.

## TOOLS
- MySQL Workbench

## DATA PREPARATION AND CLEANING.
The following tasks were performed in this stage:
1. Loading into a schema in MySQL Workbench
2. Removal of duplicates.
3. Standardisation.
4. Handling missing and null values.
5. Removing rows and columns that may not be important in EDA.

## EXPLORATORY DATA ANALYSIS.
This stage involved exploring the data to answer questions such as;
- What is the span of data collection?
- What are the peak layoff periods?
- Which companies had the most and least layoffs?
- Which countries had the most and least layoffs?
- Which industry had the most and least layoffs?

## RESULTS/FINDINGS.
Some of the findings are as follows:
- United States was the country with the most layoffs.
- Google, the company having the biggest layoff in one go.
- Retail was the most affected industry with the biggest number of layoffs.
And more in the Exploratory Data Analysis.

## LIMITATIONS.
Original size of the company before layoff was not provided so further analysis and filling null percentage laid off was not possible.

## CODE.

```sql
-- we are going to perform data cleaning to the layoffs table. 
-- remove duplicates
-- standardise the data
-- take care of the null values and blanks
-- remove the rows or columns that are irrelevant.
-- it is advisable to leave the table of raw data as it is. So create a copy of the raw data table.

create table layoffs_cleaning like layoffs;
-- insert the information from the layoffs table
insert into layoffs_cleaning
select *
from layoffs;

select *
from layoffs_cleaning;

-- Now, there is no unque identifier like id so that we can spot duplicates. Thus we have to create it.
select *, row_number() over(partition by company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as id -- aliased as id
from layoffs_cleaning;
-- we use back ticks on date because its a keyword in MySQL

-- To display the duplicates, we run the query below, but we aliase it as a common table expression(CTE)
-- to reduce length of the query
with subquery as 
(select *, row_number() over(partition by company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as id -- aliased as id
from layoffs_cleaning
)
select * 
from subquery
where id > 1;

-- test the aunthenticity of the query.
select *
from layoffs_cleaning
where company = 'Wildlife Studios'; -- works perfeclty!

-- Now we just have to delete those duplicates but, According to MySQL syntax, you cannot update a CTE.
-- so create another table, containing the information of the CTE, including the new column 'id'
-- copy the code for the original table
CREATE TABLE `layoffs_final` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `id` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- check whether the table is created.
select *
from layoffs_final; -- created. Now add the information from the CTE created before.

insert into layoffs_final
select*, row_number() over(partition by company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as id -- aliased as id
from layoffs_cleaning;

-- now run the delete and it should work perfectly.
delete
from layoffs_final
where id > 1;

-- check the results.
select *
from layoffs_final
where id > 1; -- the results are good.


--   Standardising the Data.
-- noticing grammatical errors in individual columns starting with company.
select  company, trim(company) -- trim means removing white spaces before and after the words or sentences.
from layoffs_final;
update layoffs_final
set company = trim(company);

-- Now lets check the industry coulmn.
select distinct (industry)
from layoffs_final
order by industry;
 
 -- noticed crypto and cryptocurrency. So we'll change that to 
 -- crypto because the difference will upset the explanatory data analysis
 select industry
from layoffs_final
where industry like 'crypto%';
update layoffs_final
set industry = 'Crypto'
where industry like 'crypto%';

select *
from layoffs_final;

-- Now Lets check for inconsistences in country
select distinct (country)
from layoffs_final
order by country; -- four rows have been spotted ending with '.'

select distinct (country), trim(trailing '.' from country)
from layoffs_final
order by country;

-- update statement is as follows;
update layoffs_final
set country =  trim(trailing '.' from country)
where country like 'United States%'; 

-- previously from importing, the date was set as text, for the ease of time series, 
-- we have to change it to a date format
select `date`,
str_to_date(`date`, '%m/%d/%Y')  -- this function converts string date to actual date format.
from layoffs_final;
 -- Now we update the date column.
 update layoffs_final
set date = str_to_date(`date`, '%m/%d/%Y');

-- check the results
select `date`
from layoffs_final; -- they are okay.

-- Dealing With NULL / Blank values
-- lets start with industry
select * 
from layoffs_final
where industry is null
or industry = '';

-- test one of the results from company if there may be another company, with the same name with industry filled in.
select * 
from layoffs_final
where company = 'Airbnb'; -- just as suspected, found 2 airbnb, one with industry named.

-- its not easy to work with blank values so lets turn all of them into null values.
update layoffs_final
set industry = null
where industry = '';

-- so lets try a self join, to put values with the same company together. those with industry and those without.
select lay1.industry, lay2.industry  -- since these are the columns we are only interested in.
from layoffs_final lay1
join layoffs_final lay2 on
lay1.company = lay2.company
where (lay1.industry is null) and lay2.industry is not null; -- this was done just to verify the results, but i could have achieved the end result without it.

-- Now we update the table.
update layoffs_final lay1
join layoffs_final lay2 on
lay1.company = lay2.company
set lay1.industry = lay2.industry
where (lay1.industry is null) and lay2.industry is not null;

-- more null values in total_laid_off and percentage_laid_off. so those rows cant be trusted.
select *
from layoffs_final
where total_laid_off is null 
and percentage_laid_off is null; -- viewed those specific rows.

delete
from layoffs_final
where total_laid_off is null 
and percentage_laid_off is null; --  deleted them.

-- we have to remove the column that we created as id from the beginning.
alter table layoffs_final
drop column id;

select *
from  layoffs_final;

-- the data is finally clean.
```







