USE energy;

SELECT * FROM energy_indicators;

-- add NULLS
UPDATE energy_indicators
SET energy_supply = NULL
WHERE energy_supply = "...";

UPDATE energy_indicators
SET energy_supply_per_capita = NULL
WHERE energy_supply_per_capita = "...";


-- remove spaces (or commas)
SELECT country, energy_supply, energy_supply * 1 AS calc
FROM energy_indicators;

SELECT country, energy_supply, 
		REPLACE(energy_supply, " ", "") AS e_numeric, 
        REPLACE(energy_supply, " ", "") * 1 AS calc
FROM energy_indicators;

UPDATE energy_indicators
SET energy_supply = REPLACE (energy_supply, " ", "");

-- clean country
ALTER TABLE energy_indicators
ADD COLUMN country_new VARCHAR(100) AFTER country;

SELECT * FROM energy_indicators;

-- find/remove parenthesis
/*SELECT country, INSTR(country, "("),
		CASE WHEN INSTR(country, "(") = 0 THEN country
        ELSE SUBSTR(country,1,INSTR(country, "(")-2)
        END AS country_new
FROM energy_indicators;*/

SELECT country, INSTR(country, "("),
		CASE WHEN INSTR(country, "(") = 0 THEN country
        ELSE SUBSTR(country,1,INSTR(country, "(")-2)
        END AS country_new
FROM energy_indicators;

UPDATE energy_indicators
SET country_new = 	CASE WHEN INSTR(country, "(") = 0 THEN country
					ELSE SUBSTR(country,1,INSTR(country, "(")-2)
					END;

SELECT * FROM energy_indicators;


-- find/remove digits
SELECT 	country, RIGHT(country, 1), LEFT(RIGHT(country, 2),1),
		CASE WHEN LEFT(RIGHT(country, 2),1) REGEXP "[[:digit:]]$" THEN 1 ELSE 0 END
FROM energy_indicators
WHERE country REGEXP "[[:digit:]]$";

UPDATE energy_indicators
SET country_new = CASE
					WHEN LEFT(RIGHT(country_new, 2), 1) REGEXP "[[:digit:]]$"
						THEN LEFT(country_new, length(country_new) - 2)
					WHEN RIGHT(country_new, 1) REGEXP "[[:digit:]]$"
						THEN LEFT(country_new, length(country_new) - 1)
					ELSE country_new
                    END
;

SELECT * FROM energy.energy_indicators;

-- add gdp
USE gdp;

SELECT * FROM gdp;

-- look for unmatched countries
SELECT country_new, country_name
FROM gdp.gdp 
	LEFT JOIN energy.energy_indicators
		ON country_new = country_name
WHERE country_new IS NULL
UNION
SELECT country_new, country_name
FROM gdp.gdp 
	RIGHT JOIN energy.energy_indicators
		ON country_new = country_name
WHERE country_name IS NULL;

-- update country names by hand
UPDATE energy.energy_indicators
SET country_new = CASE country_new
					WHEN "Republic of Korea" THEN "South Korea"
                    WHEN "United States of America" THEN "United States"
                    WHEN "United Kingdom of Great Britain and Northern Ireland" THEN "United Kingdom"
                    WHEN "China, Hong Kong Special Administrative Region" THEN "Hong Kong"
                    ELSE country_new
                    END;
                    
UPDATE gdp.gdp
SET country_name = CASE country_name
					WHEN "Korea, Rep." THEN "South Korea"
                    WHEN "Iran, Islamic Rep." THEN "Iran"
                    WHEN "Hong Kong SAR, China" THEN "Hong Kong"
                    ELSE country_name
                    END;



-- create joined file
SELECT country_name, yr_2015, energy_supply_per_capita
FROM gdp.gdp 
	JOIN energy.energy_indicators
		ON country_new = country_name
;