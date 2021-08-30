/*
Covid 19 Data Exploration 
Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * From PortfolioProject..CovidDeaths
order by 3,4

Select * From PortfolioProject..CovidVaccinations
order by 3,4

--Select data that is to be used

Select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--looking at total cases vs population

Select location, date, population, total_cases,  (total_cases/population)*100 as covidPercentage  from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--looking at countries with highest infection rate

Select location, population, max(total_cases),  max((total_cases/population))*100 as covidPercentage  from PortfolioProject..CovidDeaths
group by location, population
order by covidPercentage desc

--showing countries with highest death count 

Select location, max(cast(total_deaths as int))as deathcount from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by deathcount desc

--Lets break things by continent
--continent with highest death count

Select continent, max(cast(total_deaths as int))as deathcount from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by deathcount desc

--global numbers

Select  date, sum(new_cases)as total_cases, sum(cast(new_deaths as int))as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage  from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinations

drop table if exists #percentvaccinated
create table #percentvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
insert into #percentvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over ( partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null

select *,(PeopleVaccinated/population)*100 from #percentvaccinated

--creating views to store data for visualizations

create view percentVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) over ( partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
