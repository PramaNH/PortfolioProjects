
select * 
from PortfolioProject..CovidDeaths
where continent is null
order by 3,4


--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--  Total kenak covid dan yang mati

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2
 
-- Percentage deaths because covid

Select Location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


Select Location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Shows what percentage of population got covid in US

SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Countries with the highest infection rate compared to population

SELECT location, population, max(total_cases) as TotalCases, max((total_cases/population))*100 as CovidPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by CovidPercentage desc

-- COUNTRIES with HIGHESHT DEATH PER POPULATION

SELECT Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


-- CONTINENT with HIGHESHT DEATH PER POPULATION

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


Select sum(new_cases) as totalCases, max(total_cases)  -- total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by continent
order by 1,2

-- GLOBAL NUMBERS

Select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
--group by continent
order by 1,2


-- Looking at total POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
	, dea.date) TotalVaccinations
	--, (
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

WITH PopandVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
	, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 VaccinationPercentage 
FROM PopandVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
	, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 VaccinationPercentage 
FROM #PercentPopulationVaccinated


-- CREATING VIEW to store data for later visualizations

CREATE View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location
	, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT DB_NAME() AS CurrentDatabase;

SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.VIEWS;

USE PortfolioProject
SELECT DB_NAME() AS CurrentDatabase;

SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'PercentPopulationVaccinated';

-- RESULT

SELECT * FROM PercentPopulationVaccinated



--select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location) TotalVaccinations
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


--select dea.continent, dea.location, dea.date, dea.population, t.TotalVaccinations
--from PortfolioProject..CovidDeaths dea
--join (SELECT vac.location,
--	SUM(cast(vac.new_vaccinations as int)) as TotalVaccinations
--	from PortfolioProject..CovidVaccinations vac
--	group by vac.location
--)	t on dea.location = t.location
--where dea.continent is not null
--order by t.TotalVaccinations desc