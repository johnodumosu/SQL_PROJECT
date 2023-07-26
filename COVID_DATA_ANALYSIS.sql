SELECT *
  FROM PortfolioProject..CovidDeaths

SELECT * FROM
	PortfolioProject..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath  
FROM PortfolioProject..CovidDeaths
 where location like '%Nigeria%' 
 ORDER BY 1,2

-- Total cases vs populations
-- Show what percentage of Nigeria population that's got COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected 
FROM PortfolioProject..CovidDeaths
 where location like '%Nigeria%' 
 ORDER BY 1,2

-- Country with the highest infection rate compared to the populations
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected 
FROM PortfolioProject..CovidDeaths
 --where location like '%Nigeria%' 
 GROUP BY location, population
 ORDER BY PercentagePopulationInfected DESC 

-- Country with the highest death count	per population
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
 --where location like '%Nigeria%' 
 where continent is not null
 GROUP BY location
 ORDER BY TotalDeathCount DESC 

-- Continent with the highest death count	per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
 --where location like '%Nigeria%' 
 where continent is not null
 GROUP BY continent
 ORDER BY TotalDeathCount DESC 


-- Continent with the highest death count	per population
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
 --where location like '%Nigeria%' 
 where continent is null
 GROUP BY location
 ORDER BY TotalDeathCount DESC 

-- Global Numbers 
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1,2

-- Global Numbers 
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
from PortfolioProject..CovidDeaths
where continent is not null
--GROUP BY date
ORDER BY 1,2


-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as IncreasingPeopleVaccinated
FROM 
PortfolioProject..CovidVaccinations vac JOIN PortfolioProject..CovidDeaths dea ON
vac.date = dea.date and vac.location = dea.location
where dea.continent is not null
order by 2,3


-- Because of the error below we'll use either of CTE or Temp table
-- CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, IncreasingPeopleVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as IncreasingPeopleVaccinated
-- (IncreasingPeopleVaccinated/population)*100  -- Invalid column name 'IncreasingPeopleVaccinated'
FROM 
PortfolioProject..CovidVaccinations vac JOIN PortfolioProject..CovidDeaths dea ON
vac.date = dea.date and vac.location = dea.location
where dea.continent is not null
--order by 2,3
)
select *, (IncreasingPeopleVaccinated/population)*100 from PopVsVac 





-- use of Temp table

DROP TABLE IF EXISTS #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
Continent nvarchar(255), 
Location varchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
IncreasingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as IncreasingPeopleVaccinated
-- (IncreasingPeopleVaccinated/population)*100  -- Invalid column name 'IncreasingPeopleVaccinated'
FROM 
PortfolioProject..CovidVaccinations vac JOIN PortfolioProject..CovidDeaths dea ON
vac.date = dea.date and vac.location = dea.location
where dea.continent is not null
--order by 2,3

select *, (IncreasingPeopleVaccinated/population)*100 from #percentPopulationVaccinated



-- Creating view to store data for later visualizations 
Create View percentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as IncreasingPeopleVaccinated
-- (IncreasingPeopleVaccinated/population)*100  -- Invalid column name 'IncreasingPeopleVaccinated'
FROM 
PortfolioProject..CovidVaccinations vac JOIN PortfolioProject..CovidDeaths dea ON
vac.date = dea.date and vac.location = dea.location
where dea.continent is not null
--order by 2,3