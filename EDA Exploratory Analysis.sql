-- Exploring what we need from the data
select *
from layoffs_final;

select  max(total_laid_off), max(percentage_laid_off)
from layoffs_final;

select  *
from layoffs_final
where percentage_laid_off = 1
order by total_laid_off desc;

select company, sum(total_laid_off)
from layoffs_final
group by company 
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_final;

select industry, sum(total_laid_off)
from layoffs_final
group by industry 
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_final
group by country
order by 2 desc;

select `date`, sum(total_laid_off)
from layoffs_final
group by `date`
order by 1 desc;

select year(`date`), sum(total_laid_off)
from layoffs_final
group by year(`date`)
order by 1 desc;

select substring(`date`, 1, 7) as `Month` , sum(total_laid_off)
from layoffs_final
where substring(`date`, 1, 7)  is not null
group by substring(`date`, 1, 7) 
order by 1 asc;
