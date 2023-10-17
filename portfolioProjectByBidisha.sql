Select * from PortfolioProject..CovidDeaths
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%bangladesh%'
order by 1,2

-- locking at total cases vs population
-- shows what % of population got covid
 
select Location, date, population, total_cases, (total_cases/population)*100 as covidpercentage
from PortfolioProject..CovidDeaths
where location like '%bangladesh%'
order by 1,2


-- looking at countries with higest infection rate compared to population

select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by percentagePopulationInfected desc

-- showing countries with highest death count per population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent
 

-- showing continets with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- golbal numbers

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--- looking at toal population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- with CTE

with PopVsVac(continent, location, date, population, newVaccnations, rolllingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolllingpeoplevaccinated
from
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * ,(rolllingpeoplevaccinated/population)* 100
from PopVsVac

-- Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolllingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolllingpeoplevaccinated
from
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (rolllingpeoplevaccinated/population) *100
from #PercentPopulationVaccinated



-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolllingpeoplevaccinated
from
PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
order by 2,3