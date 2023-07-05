
select *
from PortfolioProject..CovidDeaths$
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
order by 3,4

--an overview of columns to be used

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Total cases and total deaths in India and an estimate of death percentage

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where location like 'India'
order by 1,2 desc

--Percentage of Indian population infected due to Covid-19

select location, date, total_cases,population, (total_cases/population)*100 as percentagepopulationinfected
from PortfolioProject..CovidDeaths$
where location like 'India'
order by 1,2 desc


--  highest infection rate of each country during the Covid pandemic

select location,population,MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as percentagepopulationinfected
from PortfolioProject..CovidDeaths$
group by location, population
order by percentagepopulationinfected desc

-- Total Death count of all the countries

select location, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

-- Continent wise death count

select location, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by totaldeathcount desc

--Continents with highest death count 

select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

--Worlwide death percentage

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
--where location like 'In%'
where continent is not null
order by 1,2

--Finding vaccination details for each country

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--use CTE

with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--use table 
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date

select *,(RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated

--creating view for later visualizations in tableau

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated

--filtering total death count to not include some values 

select location, sum(cast(new_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is null
and location not in('World', 'European Union', 'International')
group by location
order by totaldeathcount desc

select location,population,date,MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as percentagepopulationinfected
from PortfolioProject..CovidDeaths$
group by location, population,date
order by percentagepopulationinfected desc















