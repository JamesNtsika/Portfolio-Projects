--USE PortfolioProject

--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select the Data we are going to be using

--IF OBJECT_ID('Deaths', 'V') IS NOT NULL
--	DROP VIEW Deaths
--GO

--CREATE VIEW Deaths AS
--SELECT 
--	location, 
--	date, 
--	total_cases, 
--	new_cases, 
--	total_deaths, 
--	population,
--	continent
--FROM CovidDeaths
--WHERE continent IS NOT NULL

--Looking at Total Cases vs Total Deaths
-- the likelihood of dying in South Africa if you contract Covid

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases) * 100 AS Death_Percentage
FROM Deaths
WHERE location = 'South Africa'
ORDER BY location, date

--Total Cases vs Population
--What % of the population has been infected

SELECT location, date, population, total_cases, (total_cases / population) * 100 AS Infected_Percentage
FROM CovidDeaths
--WHERE location = 'South Africa'
ORDER BY location, date


-- Highest infection rate by Country compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases / population) * 100) AS Infected_Percentage
FROM CovidDeaths
--WHERE location = 'South Africa'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Infected_Percentage DESC


-- Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location = 'South Africa' 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Base things on Continets

-- Continents with the most deaths


SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location = 'South Africa'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC




--- GLOBAL NUMBERS

SELECT SUM(CAST(new_cases AS INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS Death_Percentage
FROM CovidDeaths
--WHERE location = 'South Afriica' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccinations

-- CTE


WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations ,Rolling_People_Vaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
	, SUM(CAST(dea.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
	FROM CovidDeaths dea
	JOIN CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)

SELECT *, (Rolling_People_Vaccinated / population) *100
FROM Pop_vs_Vac


--TEMP TABLE

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent					NVARCHAR(255),
location					NVARCHAR(255),
date						DATETIME,
population					NUMERIC,
new_vaccinations			NUMERIC,
Rolling_People_Vaccinated	NUMERIC
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (Rolling_People_Vaccinated / population) *100
FROM #Percent_Population_Vaccinated



-- CREATING VIEW TO STORE FOR LATER VISUALIZATIONS

IF OBJECT_ID('Percent_Population_Vaccinated', 'V') IS NOT NULL
	DROP VIEW Percent_Population_Vaccinated
GO
CREATE VIEW Percent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(dea.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM Percent_Population_Vaccinated