-- Import the table covid_deaths

CREATE TABLE covid_deaths(
ontinent varchar(250),
location varchar(250),
date date,
population bigint,
total_cases bigint,
new_cases bigint,
total_deaths bigint,
new_deaths bigint
);

-- Import the table covid_vaccinations
CREATE TABLE covid_vaccinations(
continent varchar(250),
location varchar(250),
date date,
total_vaccinations bigint,
new_vaccinations bigint);


-- Alter some columns type from bigint to numeric for better showing calculation results.
ALTER TABLE covid_deaths
ALTER COLUMN total_deaths TYPE NUMERIC,
ALTER COLUMN total_cases TYPE NUMERIC,
ALTER COLUMN new_deaths TYPE NUMERIC,
ALTER COLUMN new_cases TYPE NUMERIC;

ALTER TABLE covid_vaccinations
ALTER COLUMN total_vaccinations TYPE NUMERIC,
ALTER COLUMN new_vaccinations TYPE NUMERIC;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying in countries in the world in the order of the highest to lowest death percentage.

SELECT location,MAX(total_cases) AS Cases_total, MAX(total_deaths) AS Death_total, (MAX(total_deaths)/MAX(total_cases)) AS DeathPercentange
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY DeathPercentange DESC;

-- Shows likelihood of you getting infected in your country in the order of the highest to lowest infection percentage.
SELECT location, population, MAX(total_cases) AS Cases_total, (MAX(total_cases)/population)*100 AS InfectionPercentage
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY InfectionPercentage DESC;

-- Showing contintents with the highest total death per population.
SELECT continent, MAX(total_deaths) AS Deaths_total, (MAX(total_deaths)/population)*100 AS DeathPerPopulation
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent,population
ORDER BY DeathPerPopulation DESC;

-- Global total death per population
SELECT EXTRACT(Year FROM(date)) AS Year, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,SUM(new_deaths)/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY Year
ORDER BY Year ASC;

-- Let's explore the vaccination data
-- Looking at the progress of vaccinated population by country

WITH population_vaccinated AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS aggre_vaccinations
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
    ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
   AND vac.new_vaccinations IS NOT NULL)
SELECT *, (aggre_vaccinations/population)*100 AS vac_progress
FROM population_vaccinated;

-- Using Temp Table of the pervious query
DROP TABLE IF EXISTS population_vaccinated2;
CREATE TEMPORARY TABLE population_vaccinated2 (
continent VARCHAR(250),
location VARCHAR(250),
date DATE,
population BIGINT,
new_vaccinations NUMERIC,
aggre_vaccinations NUMERIC
);
INSERT INTO population_vaccinated2
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS aggre_vaccinations
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
    ON dea.location=vac.location
    AND dea.date=vac.date;

SELECT *, (aggre_vaccinations/population)*100 AS vac_progress
FROM population_vaccinated2
WHERE continent IS NOT NULL
   AND new_vaccinations IS NOT NULL;

-- Creating view to store the data we created
CREATE VIEW population_vaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS aggre_vaccinations
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
    ON dea.location=vac.location
    AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
   AND vac.new_vaccinations IS NOT NULL


   

