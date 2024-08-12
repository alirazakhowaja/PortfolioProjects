SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE total_deaths <> 0 AND location LIKE 'Pakistan' AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Population
SELECT location, date, total_cases, Population , (total_cases/Population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like 'Pakistan' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/Population)*100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location,Population
ORDER BY PercentPopulationInfected DESC

-- Countires with highest death count per population
SELECT location, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent
-- Showing the continents with highest death count per population
SELECT continent, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_deaths) <> 0
ORDER BY 1,2


-- Looking at total vaccination vs total population
-- Use of CTE
WITH PopVsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations,
SUM(CovidVaccination.new_vaccinations) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated 
FROM CovidDeaths
JOIN CovidVaccination 
ON CovidDeaths.location = CovidVaccination.location
AND CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent is NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated FROM PopVsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC,
)

INSERT INTO #PercentPopulationVaccinated
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations,
SUM(CovidVaccination.new_vaccinations) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated 
FROM CovidDeaths
JOIN CovidVaccination 
ON CovidDeaths.location = CovidVaccination.location
AND CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent is NOT NULL
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated FROM #PercentPopulationVaccinated


-- Creating Views to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations,
SUM(CovidVaccination.new_vaccinations) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) AS RollingPeopleVaccinated 
FROM CovidDeaths
JOIN CovidVaccination 
ON CovidDeaths.location = CovidVaccination.location
AND CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent is NOT NULL
-- ORDER BY 2,3


CREATE VIEW PercentPopulationInfected AS
SELECT location, Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/Population)*100) AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location,Population
-- ORDER BY PercentPopulationInfected DESC

CREATE VIEW TotalDeathCount AS
SELECT location, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
-- ORDER BY TotalDeathCount DESC

CREATE VIEW ContinetTotalDeathCount AS
SELECT continent, MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
-- ORDER BY TotalDeathCount DESC

CREATE VIEW ContinentDeathPercent AS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_deaths) <> 0
-- ORDER BY 1,2
