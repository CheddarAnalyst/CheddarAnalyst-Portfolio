Select *
From [Portfolio project]..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From [Portfolio project]..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases,new_cases,total_deaths,population
From [Portfolio project]..CovidDeaths$
order by 1,2

--Looking at total cases vs Total Deaths
--Likelihood of dying with covid in Kenya
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
Where location like '%Kenya%'
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population has covid
Select Location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
Where location like '%Kenya%'
order by 1,2

--What countries have the highest infection rate compared to Population
Select Location,population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
Group by Location, population
order by PercentPopulationInfected desc

--BREAKING DOWN BY CONTINENT

--showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeatchCount
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
Where continent is not null
Group by continent
order by TotalDeatchCount desc


--Showing Countries with Highest Death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeatchCount
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
Where continent is not null
Group by Location
order by TotalDeatchCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
where continent is not null
Group by date 
order by 1,2

--If we remove the date 
Select SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
where continent is not null
--Group by date 
order by 1,2

--JOINING THE TABLES
--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100  
From [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE
With PopvsVac  (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100  
From [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100  
From [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100  
From [Portfolio project]..CovidDeaths$ dea
Join [Portfolio project]..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View GlobalNumbers as
Select date, SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
where continent is not null
Group by date 
--order by 1,2

Create View HighestDeathCountPopulation as 
Select Location, MAX(cast(total_deaths as int)) as TotalDeatchCount
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
Where continent is not null
Group by Location
--order by TotalDeatchCount desc


Create View ContinentsHighestDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeatchCount
From [Portfolio project]..CovidDeaths$
--Where location like '%Kenya%'
Where continent is not null
Group by continent
--order by TotalDeatchCount desc

Create View LikelihoodOfDyingWithCovidInKenya as
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths$
Where location like '%Kenya%'
--order by 1,2