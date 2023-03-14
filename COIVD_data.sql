
Select * 
From Portfolio_Project..Covid_Deaths
order by 3,4

--Select * 
--From Portfolio_Project..Covid_Vaccinationss$
--order by 3,4

--Select Data that we are going to be used

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of death if you have COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
Where location = 'India'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what % of Population have COVID

Select location, date, population, total_cases, (total_deaths/population)*100 as PercentagePopulationInfected
From Portfolio_Project..Covid_Deaths
Where location = 'India'
order by 1,2

-- Countries with Highest Infection Rate compared to populatin

Select location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 as PercentagePopulationInfected
From Portfolio_Project..Covid_Deaths
group by location, population
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count per population

Select location, MAX(total_deaths) as Total_Death_count
From Portfolio_Project..Covid_Deaths
Where continent is not null
group by location
order by Total_Death_count desc

-- Continent with Highest Death Count per population

Select continent, MAX(total_deaths) as Total_Death_count
From Portfolio_Project..Covid_Deaths
Where continent is not null
group by continent
order by Total_Death_count desc

-- GlOBAL NUMBERS WITH DATE

Select date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
Where continent is not null
group by date
order by 1,2

-- GlOBAL NUMBERS WITHOUT DATE

Select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
Where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated -- USE CONVERT or CAST function for vac.new_vaccinations
From	Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
order by 2,3


-- Use CTE

With Pop_vs_Vac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated -- USE CONVERT or CAST function for vac.new_vaccinations
From	Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From Pop_vs_Vac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated -- USE CONVERT or CAST function for vac.new_vaccinations
From	Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated -- USE CONVERT or CAST function for vac.new_vaccinations
From	Portfolio_Project..Covid_Deaths d
Join Portfolio_Project..Covid_Vaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated