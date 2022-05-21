select * from CovidProject..CovidDeath
WHERE continent is not null
order by 1,2;

-- select data we are going to using
Select Location ,date , total_cases ,new_cases ,total_deaths ,population 
from CovidProject..CovidDeath
order by 1,2;

-- looking at total cases vs total deathes
Select  Location , date, total_cases ,total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeath
where location like '%gypt%' and continent is not null
order by 1,2;

--looking at total cases vs population
-- show percentage of population gets covid
Select Location , date,population ,  total_cases  , (total_cases/population)*100 as TotalCasesPercentage
from CovidProject..CovidDeath
--where location like '%gypt%'
where continent is not null

order by 1,2;


-- looking at countries with highest infection rate compared to population
Select Location , population ,  max(total_cases) as HighestInfectionCount , (max(total_cases)/population)*100 as TotalCasesPercentage
from CovidProject..CovidDeath
--where location like '%gypt%'
where continent is not null
group by Location , population
order by TotalCasesPercentage desc;


-- Showing countries with highst death count per population
Select Location ,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidProject..CovidDeath
--where location like '%gypt%'
where continent is not null
group by Location 
order by TotalDeathCount  desc;


-- Showing contenents with highst death count per population
Select	continent ,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidProject..CovidDeath
--where location like '%gypt%'
where continent  is not null
group by continent 
order by TotalDeathCount  desc;

-- Global numbers 

Select  sum(new_cases) as TotalCases ,sum(cast(new_deaths as int)) as TotalDeath , (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidProject..CovidDeath
--where location like '%gypt%' and 
where continent is not null
--group by date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeath dea
Join CovidProject..CovidVacctination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeath dea
Join CovidProject..CovidVacctination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeath dea
Join CovidProject..CovidVacctination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeath dea
Join CovidProject..CovidVacctination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

