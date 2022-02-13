SELECT *
	From covid_deaths$
	order by 3,4

--SELECT *
--	From covid_vaccinations$
--order by 3,4

--Select data that we are to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..covid_deaths$
	order by 1,2

--Looking at total case vs total deaths
--Shows the likelihood of dying if you get Covid in you country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
	From PortfolioProject..covid_deaths$
	Where Location like '%states%'
	order by 1,2

-- Looking at the total cases vs. Population
-- Shows what percentage of Population got Covid
SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as Contraction_Percentage
	From PortfolioProject..covid_deaths$
	Where Location like '%states%'
	order by 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/Population)*100) as Contraction_Percentage
	From PortfolioProject..covid_deaths$
	Group by Location, Population
	Order by Contraction_Percentage DESC

--Looking at the countries with the highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as Highest_Death_Count
	From PortfolioProject..covid_deaths$
	Where continent is null
	Group by Location
	Order by Highest_Death_Count DESC

--Looking at the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as Highest_Death_Count
	From PortfolioProject..covid_deaths$
	Where continent is not null
	Group by continent
	Order by Highest_Death_Count DESC

--Global Numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
	*100 as Death_Percentage
	From PortfolioProject..covid_deaths$
	Where continent is not null
	Group by Date
	order by 1,2

SELECT *
	From PortfolioProject..covid_vaccinations$
--Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.Location Order by dea.location, dea.date) as Rolling_Vacs_Count
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Using Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vacs_Count numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.Location Order by dea.location, dea.date) as Rolling_Vacs_Count
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (Rolling_Vacs_Count/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later viz
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.Location Order by dea.location, dea.date) as Rolling_Vacs_Count
From PortfolioProject..covid_deaths$ dea
Join PortfolioProject..covid_vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3