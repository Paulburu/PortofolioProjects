SELECT *
From PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--From PortofolioProject..TotalVaccinations
--order by 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the Total Cases vs Total Deaths
--Shows likelihood of dying if contracted in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentageContracted
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
Select Location, MAX(total_cases) as HighestInfectionCount, Population, ((MAX(total_cases))/Population)*100 as PercentageContracted
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location,Population
order by PercentageContracted desc 



--Showing countries with heighest death count per population

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc 


--Showing countries with heighest death count per population

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc 


--break things down by continent

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc 


--showing continents with the highest death count
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc 




--global numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths,sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, --(RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea 
Join PortofolioProject..TotalVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use CTE

with PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea 
Join PortofolioProject..TotalVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



--Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea 
Join PortofolioProject..TotalVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea 
Join PortofolioProject..TotalVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
