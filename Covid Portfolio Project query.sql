
Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'af%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases, 
(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like 'af%'
order by 1,2

-- Lookking at Total Cases vs Population
-- Showing what Percentage of population got Covid

select location, population, max(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
WHERE LOCATION LIKE 'Af%'
group by location, population


--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Looking for Country with highest death count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null 
group by location
order by TotalDeathCount desc

--- LETS BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null 
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBER

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int))as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'afganistan'
where continent is not null 
group by date
order by 1,2

--Join Table 

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location  = vac.location
and dea.date = vac.date

-- Looking at Total Puplation vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVacinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- use CTE 

with PopvsVac (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVacinated
--,  (RollingPeopleVacinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVacinated/Population)*100 
from PopvsVac

-- TEMP  TABLE 


DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
poulation numeric,
new_vaccinations numeric,
RollingPeopleVacinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVacinated
--,  (RollingPeopleVacinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

select *, (RollingPeopleVacinated/poulation)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization


create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVacinated
--,  (RollingPeopleVacinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated