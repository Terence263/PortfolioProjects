Select *
From PortfolioProfject..['covid-death$']
where continent is not null
order by 3,4

--Select *
--From PortfolioProfject..['covid-vaccines$']
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProfject..['covid-death$']
where continent is not null
order by 1,2


-- Chance of death if you contract covid in Zimbabwe
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From PortfolioProfject..['covid-death$']
Where location like '%Zimb%'
where continent is not null
order by 1,2


-- Cases vs the population
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From PortfolioProfject..['covid-death$']
--Where location like '%Zimb%'
where continent is not null
order by 1,2


--Highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionRate
From PortfolioProfject..['covid-death$']
--Where location like '%Zimb%'
where continent is not null
Group by location, population
order by InfectionRate desc



--Total death by continent
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProfject..['covid-death$']
--Where location like '%Zimb%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- Highest death rate per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProfject..['covid-death$']
--Where location like '%Zimb%'
where continent is not null
Group by location, population
order by TotalDeathCount desc

-- Continents with highest death count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProfject..['covid-death$']
--Where location like '%Zimb%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Stats
Select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathRatePercent
From PortfolioProfject..['covid-death$']
--Where location like '%Zimb%'
where continent is not null
Group by date
order by 1,2


Select  sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathRatePercent
From PortfolioProfject..['covid-death$']
--Where location like '%Zimb%'
where continent is not null
--Group by date
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
,sum(convert(int, new_vaccinations)) Over (Partition By dea.location order by dea.location
,dea.date) as TotalVaccinated
--(TotalVaccinated/population)
from PortfolioProfject..['covid-death$'] dea
Join PortfolioProfject..['covid-vaccines$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
,sum(convert(bigint, new_vaccinations)) Over (Partition By dea.location order by dea.location
,dea.date) as TotalVaccinated
--(TotalVaccinated/population)
from PortfolioProfject..['covid-death$'] dea
Join PortfolioProfject..['covid-vaccines$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (TotalVaccinated/Population)*100 as  PercentPopVacc
From PopvsVac



--temp table
Drop Table if exists #PercentPopVacc
Create table #PercentPopVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
TotalVaccinated numeric
)
insert into #PercentPopVacc
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
,sum(convert(bigint, new_vaccinations)) Over (Partition By dea.location order by dea.location
,dea.date) as TotalVaccinated
--(TotalVaccinated/population)
from PortfolioProfject..['covid-death$'] dea
Join PortfolioProfject..['covid-vaccines$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (TotalVaccinated/Population)*100 as  PercentPopVacc
From #PercentPopVacc


-- Create View to store data for visualisations
Create View PercentPopVacc as
Select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations
,sum(convert(bigint, new_vaccinations)) Over (Partition By dea.location order by dea.location
,dea.date) as TotalVaccinated
--(TotalVaccinated/population)
from PortfolioProfject..['covid-death$'] dea
Join PortfolioProfject..['covid-vaccines$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

