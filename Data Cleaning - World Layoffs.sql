-- 1. Remove Duplicates 
-- 2. Standardize the data 
-- 3. Null values or Blank values 
-- 4. Remove the column which are not necessary 

CREATE TABLE layoffs_staging 
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging 
SELECT *
FROM layoffs;



WITH duplicate_cte AS 
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage,
    country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)

SELECT *
FROM duplicate_cte; 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT	
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage,
country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data 

SELECT DISTINCT (company), TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company), location = TRIM(location);

SELECT DISTINCT (industry)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry = 'Crypto Currency';

SELECT *
FROM layoffs_staging2;

SELECT DISTINCT (country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United %';

SELECT  `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT *
FROM layoffs_staging2;

DESC layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Null Values or Blank Values 

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT  t1.company, t1.location, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
    AND t1.location = t2.location 
WHERE (t1.industry IS NULL or t1.industry = '')
	AND t2.industry IS NOT NULL;
    
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';



UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
    AND t1.location = t2.location 
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND t2.industry is not null;

SELECT *
FROM layoffs_staging2
WHERE company = "Bally's Interactive";

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL 
		AND percentage_laid_off IS NULL;
        
SELECT *
FROM layoffs_staging2;


-- Removing Columns We Don't Need

ALTER TABLE  layoffs_staging2
DROP COLUMN row_num;


















