/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
select *
from portfolioproject1..CovidDeaths$
where continent is not null
order by 3,4

select * 
from portfolioproject1..CovidVaccinations$
order by 3,4

--select the data that we are going to use
select location,date,total_cases,new_cases,total_deaths, population
from portfolioproject1..CovidDeaths$
where continent is not null
order by 1,2

--Total cases vs Total deaths
--Shows likelihood of dying if you contract covid in  your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from portfolioproject1..CovidDeaths$
where location like '%india%'
and continent is not null
order by 1,2

--Total cases vs Population
--Shows what percentage of population got covid

select location,date,total_cases,population,(total_cases/population)*100 as casesPercentage
from portfolioproject1..CovidDeaths$
--where location like '%india%'
order by 1,2

--Country with highest infection rate compared to population

select location,population,max(total_cases) as highestInfectionCount,max(total_cases/population)*100 as percetPopulationInfected
from portfolioproject1..CovidDeaths$
group by location,population
--where location like '%india%'
order by percetPopulationInfected desc


--Countries with highest death count per population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject1..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject1..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject1..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
--,(RollingPeoplevaccinated/population)*100 
from portfolioproject1..CovidDeaths$ dea
join portfolioproject1..CovidVaccinations$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 3,4


--Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(continet,location,date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
from portfolioproject1..CovidDeaths$ dea
join portfolioproject1..CovidVaccinations$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 1,2
)
select *,(RollingPeoplevaccinated/population)*100 as VaccinatedperOverPop
from PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercetPopulationVaccinated
create table #PercetPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)

insert into #PercetPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
--(RollingPeoplevaccinated/population)*100
from portfolioproject1..CovidDeaths$ dea
join portfolioproject1..CovidVaccinations$ vac
     on dea.location=vac.location
	 and dea.date=vac.date
--where dea.continent is not null
--order by 1,2

select * ,(RollingPeoplevaccinated/population)*100
from #PercetPopulationVaccinated





--creating view to store data for later visualizations

create view PercetPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
--(RollingPeoplevaccinated/population)*100
from portfolioproject1..CovidDeaths$ dea
join portfolioproject1..CovidVaccinations$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null

