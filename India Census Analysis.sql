--                                                     ( Data of 2011 )
SELECT * FROM district_clean;
SELECT * FROM state_clean;
/**
                                     ( Analysis on Census Record of India )

1) Total number of population in india
2) Average % Growth of states
3) Average Literacy rate of each state
4) Calculate number of male and female from population
5) Calculate number of literate and illiterate people of each state
6) Query List of district from specific state having highest number of literacy rate

About Data :
District : name
state : name
Area_km2 : Area
Population: population

Growth :
sex_ratio :
Literacy : 

**/

-- For practice try to create random table so that concep might be clear

-- Check the number of rows imported as code
SELECT count(*)
FROM state_clean;

SELECT count(*)
FROM district_clean;

-- Query all records of madhya pradesh.
SELECT * 
FROM state_clean 
WHERE state = 'madhya pradesh';

-- What is the population of india 
SELECT sum(population) 
FROM district_clean;


-- what is the avg % growth of each state ?
SELECT state, round(avg(growth),2)*100 as a    -- To get in %
FROM state_clean
GROUP BY state
ORDER BY a desc  ;

-- check the literacy rate of each states
SELECT distinct state, round(avg(literacy)) as lit
FROM state_clean
Group by district,state,Literacy
Having lit > 95
Order by Lit desc
limit 3;

-- list the name of districts of madhya pradesh those literacy is grater than average litracy of country;

SELECT avg(Literacy)
FROM state_clean;    -- Inner Query

SELECT *
FROM state_clean
WHERE Literacy > (SELECT avg(Literacy) FROM state_clean) and state = "madhya pradesh"
ORDER BY Literacy desc;

-- Query list of each District of country how has highest literacy
SELECT *, row_number() over (partition by state order by Literacy desc) as Wnd 
FROM state_clean; -- considered it as Inner Query because WHERE clause is not working with window function

SELECT *
FROM (SELECT *, row_number() over (partition by state order by Literacy desc) as Wnd FROM state_clean ) as T
WHERE wnd = 1; -- we put inner query with From because this query return whole table with window so we considered it as new table


--  Phase 2
select * from district_clean;
select * from state_clean;

-- Calculated number of men and female
SELECT * 
FROM state_clean a join district_clean b on a.District=b.District;
/**
	we have = female/male = sex ration ----------- eq (1)
			  male + female = Population -----------eq (2)

FROM eq (2)
male + female = population
female = popultion - male
population - male = sex ratio * male ------ from eq (1) (send male right hand side with sex ratio)               

population = (sex ration * male + male) 
population = male ( sex ration + 1)

we want no of male

population/(sex ration + 1) = male ------------ ( give us male number )

male = population/(sex ration + 1)

number of female from 2nd eq
male + female = population
female = population - male
female = population - population / (sex ratio + 1) ------- [value of male]
female = population( 1-1 / sex ration + 1)
female = population * sex ration / sex ration + 1

Answer Equation is : male  = population / (sex_ratio +1)
					female = population - population / ( sex_ratio + 1)

**/

SELECT state, district ,round(population / (sex_ratio + 1) , 0) as male ,round( population * sex_ratio / sex_ratio + 1, 0) as female 
from (SELECT a.district, a.state ,a.sex_ratio /1000 sex_ratio , b.Population   -- 1000 because to convert sex ratio in decimal than apply formula
      FROM state_clean a join district_clean b on a.District=b.District) as t;


-- Total number of male and female using group by + sub query + join
SELECT c.state, sum(c.male), sum(c.female) 
FROM ( SELECT state, district ,round(population / (sex_ratio + 1) , 0) as male ,round( population * sex_ratio / sex_ratio + 1, 0) as female 
       from (SELECT a.district, a.state ,a.sex_ratio /1000  as sex_ratio , b.Population FROM state_clean a join district_clean b on a.District=b.District) as t ) as c
GROUP BY state;

--  Total number of literate and illiterate people state and districts
SELECT state,district,sum(x.literate_people) as l1,sum(x.illiterate ) as l2
FROM (SELECT District,state, round(literacy_ratio * population, 0)as literate_people, round(-literacy_ratio+literacy_ratio*Population,0) as illiterate
FROM (SELECT a.district, a.state ,a.literacy /100 as literacy_ratio , b.Population 
	  FROM state_clean a join district_clean b on a.District=b.District) as t) as x
GROUP BY state,District
ORDER BY l1 desc;

-- top 3 district from each state with highest litracy rate
SELECT * 
FROM (SELECT State ,district,literacy, dense_rank() over (partition by state order by Literacy desc) as rnk  
FROM state_clean) as a 
WHERE rnk <= 3 ;  -- Due to order of execution where clause is not filtering rnk column so we convert whole query to new table as inner query and use subquery 


-- query rank madhya pradesh literacy rate of each district
SELECT State ,district,literacy, dense_rank() over (partition by state order by Literacy desc) as rnk  
FROM state_clean
WHERE state = 'madhya pradesh';