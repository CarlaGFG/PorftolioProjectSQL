--Loking at Total Cases vs Total Deaths
-- Shows the probability of death if you contract covid in Switzerland

SELECT location, date, total_cases, total_deaths, (total_cases/total_deaths)*0.1 As DeathPrtcentage
FROM CovidDeaths
Where location = 'Switzerland'
and total_deaths > 0
Order by 1,2

--Looking at Total Cases vs Population 
-- Shows the percentage of infected population 

SELECT location, date, population, total_cases, (total_cases/population)*100 As PertcentPopulationInfected
FROM CovidDeaths
Where location = 'Switzerland'
Order by 1,2

-- Countries with Highest Infectation Rate compared to Population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As PertcentPopulationInfected
FROM CovidDeaths
Where total_cases > 0
And population > 0
Group by location, population
Order by PertcentPopulationInfected desc

-- Countries with Highest Death Count

SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM CovidDeaths
Where DATALENGTH(continent) > 0 
Group by location 
Order by TotalDeathCount desc

-- Global Numbers 

Select date, Sum (new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/ sum(new_cases)*100 as DeathPercentage
From CovidDeaths
Where DATALENGTH(continent) > 0  and total_deaths > 0 and new_cases >0
Group by date
Order by 1,2

-- Total Populations vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over( Partition by dea.Location order by dea.location, dea.Date) as RunningAmount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where DATALENGTH(dea.continent) > 0
Order by 2,3


-- CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RunningAmount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over( Partition by dea.Location order by dea.location, dea.Date) as RunningAmount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where DATALENGTH(dea.continent) > 0 
)
Select *,(RunningAmount/Population)*100
From PopVsVac
Where Population > 0

-- Temp Table 

Create Table #PercentPopulationVaccinated
(
Continent varchar (50),
Location varchar (50),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RunningAmount numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over( Partition by dea.Location order by dea.location, dea.Date) as RunningAmount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where DATALENGTH(dea.continent) > 0 

Select *,(RunningAmount/Population)*100
From #PercentPopulationVaccinated
Where Population > 0

 --DROP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar (50),
Location varchar (50),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RunningAmount numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over( Partition by dea.Location order by dea.location, dea.Date) as RunningAmount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where DATALENGTH(dea.continent) > 0 

Select *,(RunningAmount/Population)*100
From #PercentPopulationVaccinated
Where Population > 0


-- Creating view to store data for later visualization

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over( Partition by dea.Location order by dea.location, dea.Date) as RunningAmount
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where DATALENGTH(dea.continent) > 0 


