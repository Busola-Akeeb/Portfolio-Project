SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Select Data that we are going to be using

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at total cases VS total deaths

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Death Percentage in Nigeria
--This shows the likelihood of dying if you contract covid in Nigeria. It is worth noting that the death percentage in Nigeria and a lot of African
-- countries was very low.

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS Death_Percentage
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2;

--Looking at Total Cases VS the population in Nigeria
--Shows what percentage of Nigerians contracted Covid

SELECT location, date, population, total_cases, (total_cases/population)* 100 AS Infection_Rate
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2;

--Looking at total cases per Continent
-- Shows the total amount of covid cases each continent recorded and shows that South America recorded the highest number of covid cases

SELECT continent, SUM(total_cases) AS Cases_Per_Continent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 1 DESC;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))* 100 AS Infection_Rate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infection_Rate DESC;

-- Looking at Countries with the highest death count per population
-- This shows that the United States recorded the highest number of deaths

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;


-- Looking at continent with the highest death count per population
-- This shows that North America had the highest death count while oceania recorded the lowest death count.

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)* 100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)* 100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- JOINING BOTH TABLES
SELECT *
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
ORDER BY 1, 2;

--Looking at Total Population VS vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;


-- USING A CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL
)
SELECT *, (Rolling_People_Vaccinated/population)* 100
FROM PopVsVac;


-- USING A TEMP TABLE

DROP TABLE IF EXISTS #Percentage_Population_Vaccinated
CREATE TABLE #Percentage_Population_Vaccinated (
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
Rolling_People_Vaccinated NUMERIC
);

INSERT INTO #Percentage_Population_Vaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
     ON cd.location = cv.location
     AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL

SELECT *, (Rolling_People_Vaccinated/population)* 100
FROM #Percentage_Population_Vaccinated;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW Percentage_Population_Vaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date 
WHERE cd.continent IS NOT NULL;


