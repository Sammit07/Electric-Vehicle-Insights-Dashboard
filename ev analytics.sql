/* 
Electric Vehicle Analytics — SQL Companion

This script provides quick exploration and BI-ready aggregations for the `electric_vehicle_analytics` table. It includes data peeks and row counts, distinct make/model tallies, core averages, filters for long-range & healthy batteries, highest/lowest energy-consumption lists, per-type summaries, KPI rollups by make, cost-per-km by region, type mix by region, an efficiency leaderboard, YoY and cumulative CO₂-saved analyses, plus helpful indexes for faster slicing in dashboards. Written for MySQL 8+ (window functions used) and easy to adapt to other SQL dialects.
*/


-- Peek rows
SELECT * FROM electric_vehicle_analytics LIMIT 20;

-- Row count
SELECT COUNT(*) AS vehicle_count FROM electric_vehicle_analytics;

-- Distinct makes & models
SELECT COUNT(DISTINCT Make) AS make_count,
       COUNT(DISTINCT Model) AS model_count
FROM electric_vehicle_analytics;

-- Basic averages
SELECT AVG(Range_km) AS avg_range_km,
       AVG(Battery_Capacity_kWh) AS avg_battery_kWh,
       AVG(Energy_Consumption_kWh_per_100km) AS avg_kWh_per_100km
FROM electric_vehicle_analytics;

-- Filter: long-range & healthy batteries
SELECT vehicle_id, Make, Model, year, range_km, battery_health_pct
FROM electric_vehicle_analytics
WHERE range_km >= 400 AND battery_health_pct >= 90
ORDER BY range_km DESC
LIMIT 50;

-- Highest energy consumption
SELECT *
FROM electric_vehicle_analytics
ORDER BY energy_consumption_kwh_per_100km DESC
LIMIT 20;

-- Lowest energy consumption
SELECT *
FROM electric_vehicle_analytics
ORDER BY energy_consumption_kwh_per_100km ASC
LIMIT 20;

-- Per-type range summary
SELECT vehicle_type,
       COUNT(*) AS n,
       MIN(energy_consumption_kwh_per_100km) AS min_cons,
       AVG(energy_consumption_kwh_per_100km) AS avg_cons,
       MAX(energy_consumption_kwh_per_100km) AS max_cons
FROM electric_vehicle_analytics
GROUP BY vehicle_type
ORDER BY avg_cons;

-- KPI by Make
SELECT Make,
       COUNT(*) AS vehicles,
       AVG(Range_km) AS avg_range_km,
       AVG(Battery_Capacity_kWh) AS avg_batt_kWh,
       AVG(Resale_Value_USD) AS avg_resale_usd
FROM electric_vehicle_analytics
GROUP BY Make
ORDER BY vehicles DESC;

-- Cost per km by Region
SELECT Region,
       AVG((Energy_Consumption_kWh_per_100km/100.0) * Electricity_Cost_USD_per_kWh) AS avg_cost_per_km_usd
FROM electric_vehicle_analytics
GROUP BY Region
ORDER BY avg_cost_per_km_usd;

-- Vehicle type mix per Region (pivot-like)
SELECT Region,
       SUM(CASE WHEN Vehicle_Type='SUV' THEN 1 ELSE 0 END) AS suv,
       SUM(CASE WHEN Vehicle_Type='Sedan' THEN 1 ELSE 0 END) AS sedan,
       SUM(CASE WHEN Vehicle_Type='Hatchback' THEN 1 ELSE 0 END) AS hatchback,
       SUM(CASE WHEN Vehicle_Type='Truck' THEN 1 ELSE 0 END) AS truck,
       COUNT(*) AS total
FROM electric_vehicle_analytics
GROUP BY Region
ORDER BY Region;

-- Model efficiency leaderboard (km per kWh)
SELECT Make, Model,
       AVG(Range_km / NULLIF(Battery_Capacity_kWh,0)) AS range_per_kWh_km,
       COUNT(*) AS samples
FROM electric_vehicle_analytics
GROUP BY Make, Model
HAVING COUNT(*) >= 5
ORDER BY range_per_kWh_km DESC
LIMIT 25;

-- Add a BI-friendly date on the fly (Jan 1 of each Year)
SELECT *,
       STR_TO_DATE(CONCAT(Year,'-01-01'), '%Y-%m-%d') AS AsOfDate
FROM electric_vehicle_analytics
LIMIT 10;

-- YoY change in average range by Make
SELECT Make, Year, avg_range_km,
       avg_range_km - LAG(avg_range_km) OVER (PARTITION BY Make ORDER BY Year) AS yoy_change_km
FROM (
  SELECT Make, Year, AVG(Range_km) AS avg_range_km
  FROM electric_vehicle_analytics
  GROUP BY Make, Year
) t
ORDER BY Make, Year;

-- Top 5 (per Region) models by average range
WITH model_avg AS (
  SELECT Region, Make, Model, AVG(Range_km) AS avg_range_km
  FROM electric_vehicle_analytics
  GROUP BY Region, Make, Model
)
SELECT *
FROM (
  SELECT Region, Make, Model, avg_range_km,
         RANK() OVER (PARTITION BY Region ORDER BY avg_range_km DESC) AS rnk
  FROM model_avg
) x
WHERE rnk <= 5
ORDER BY Region, rnk;

-- Cumulative CO2 saved by Region across years
WITH yearly AS (
  SELECT Region, Year, SUM(CO2_Saved_tons) AS total_co2_tons
  FROM electric_vehicle_analytics
  GROUP BY Region, Year
)
SELECT Region, Year, total_co2_tons,
       SUM(total_co2_tons) OVER (PARTITION BY Region ORDER BY Year
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_co2_tons
FROM yearly
ORDER BY Region, Year;


-- Quartiles of resale value within each Make
SELECT Vehicle_ID, Make, Model, Resale_Value_USD,
       NTILE(4) OVER (PARTITION BY Make ORDER BY Resale_Value_USD) AS resale_quartile
FROM electric_vehicle_analytics;

-- Helpful indexes for common filters/joins
CREATE INDEX idx_eva_make_model ON electric_vehicle_analytics (Make, Model);
CREATE INDEX idx_eva_region ON electric_vehicle_analytics (Region);
CREATE INDEX idx_eva_year ON electric_vehicle_analytics (Year);
