Select *
From [Portfolio Project]..CovidDeaths
order by 3,4

Select *
From [Portfolio Project]..CovidVaccinations
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1,2

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2

Select location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc

Select location, max(cast(total_deaths as int)) as TotaldeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotaldeathCount desc

Select continent, max(cast(total_deaths as int)/population) as TotaldeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
--where location like '%states%'
group by continent
order by TotaldeathCount desc

Select location, max(cast(total_deaths as int)) as TotaldeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotaldeathCount desc

Select continent, max(cast(total_deaths as int)) as TotaldeathCount
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent 
order by TotaldeathCount desc


Select date ,SUM(new_cases),SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
order by 1,2


Select SUM(new_cases),SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select * 
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select * 
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3