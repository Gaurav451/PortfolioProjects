select * from projects..CovidDeaths

select location, date, total_cases, population, (total_cases/population)*100 as Death_per
from projects..CovidDeaths
where location = 'India' and continent is not null
order by 1,2

-- Insights of above query
-- 1.) 1st case was discovered on 30 January 2020
-- 2.) From 4th of february to 1st March 2020, cases were stable(constant)
-- 3.) Cases started ascending pretty heavily from 14th March 2020
-- 4.) The death percentage in around 2020 was keeping itself pretty close to its predecessor record
-- 5.) 2021 brought Death percentage in range of 0.7
-- 6.) 2021 proved to be the most fatal in cases of deaths for India, as the Death percentage kept on spiking sharply



-- Country with highest rate of infection compared to population

Select Location, population, max(total_cases) as Highest_Infect, max((total_cases/population))*100 as PercentPopulationInfect
from projects..CovidDeaths
where continent is not null
group by Location, population
order by 4 desc


-- Highest Death Count Per Population

Select Location, max(cast(Total_deaths as INT)) as total_count
from projects..CovidDeaths
where continent is not null
group by Location
order by 2 desc



-- Same thing, but now, by the continent

Select continent, max(cast(Total_deaths as INT)) as total_count
from projects..CovidDeaths
where continent is not null
group by continent
order by 2 desc

 -- Showing Death percentage, new cases and total_deaths date wise

 select date, sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , 
        sum(cast(total_deaths as int))/ nullif(total_cases , 0) * 100 as Death_percent
 from projects..CovidDeaths
 where continent is not null
 group by date, total_cases
 order by 1,2


-- Refreshing our memories for CovidVaccinations Table

select * 
from projects..CovidVaccination


-- Using Join to join both tables

select * 
from projects..CovidDeaths dea
join projects..CovidVaccination vac 
     on dea.location = vac.location and dea.date = vac.date


-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from projects..CovidDeaths dea
join projects..CovidVaccination vac 
     on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Insights from above data
-- 1.) Afghanistan only did vaccinations on very few days, first of which was 27 of January 2021
-- 2.) Very few countries actually took very early measures for vaccinations on covid


-- New vaccinations per country


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
      , sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as new_vac
from projects..CovidDeaths dea
join projects..CovidVaccination vac 
     on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--As we can't use the new column(new_vac) directly, we will create a 'CTE'

with pvsvac(continent, location, date, population, new_vaccinations, new_vac) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
      , sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as new_vac
from projects..CovidDeaths dea
join projects..CovidVaccination vac 
     on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (new_vac/population)*100 as New_vac_perc
from pvsvac
order by 2,3


-- Another method of doing the same work above, is we can create a Temp Table

-- Temp Table

DROP table if exists #PercentPopVac
CREATE table #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
new_vac numeric
)

INSERT INTO #PercentPopVac

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
      , sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as new_vac
from projects..CovidDeaths dea
join projects..CovidVaccination vac 
     on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (new_vac/population)*100 as New_vac_perc
from #PercentPopVac
order by 2,3


-- For better understanding and storage of data for visualisation, we are going to use view

create view PercentPopVac as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
      , sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as new_vac
from projects..CovidDeaths dea
join projects..CovidVaccination vac 
     on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


create view new_vac_per_country as

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
      , sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as new_vac
 from projects..CovidDeaths dea
      join projects..CovidVaccination vac 
           on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 create view totalpopvsvac as
 (
    select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    from projects..CovidDeaths dea
    join projects..CovidVaccination vac 
         on dea.location = vac.location and dea.date = vac.date
    where dea.continent is not null
    order by 2,3
 )  
