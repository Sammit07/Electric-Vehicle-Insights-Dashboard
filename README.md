# EV Analytics Dashboard (Power BI + SQL + Jupyter)

An end-to-end electric-vehicle (EV) analytics project. It combines a **Power BI** dashboard for interactive insights, a **Jupyter notebook** for quick exploratory analysis, and **SQL** scripts for repeatable queries. The goal is to understand fleet **size**, **driving range**, **energy use/efficiency**, **geography**, and **CO₂ savings**—and make those insights explorable for anyone.

> **Data source:** Kaggle — *Electric Vehicle Analytics Dataset*  
> https://www.kaggle.com/datasets/khushikyad001/electric-vehicle-analytics-dataset

<img width="492" height="282" alt="EV Analytics" src="https://github.com/user-attachments/assets/f01f96d5-c1ae-40a7-976d-2a1a8aa8d8fe" />

---

## 🧩 Problem statement

**How can we quickly explore an EV fleet to answer:**
- How many vehicles do we have and where are they?  
- What is the **average range** and **energy consumption** (kWh/100 km)?  
- Which **vehicle types** and **makes** dominate the fleet?  
- How much **CO₂ has been avoided** compared to ICE vehicles?

**Project goals**
1. Clear KPIs (Vehicles, Avg Range, Avg Energy, Total CO₂ Saved).  
2. Intuitive slicing by **Region**, **Vehicle Type**, **Make**, and **Year**.  
3. Reproducible pipeline: **SQL + Notebook + PBIX**.

---

## 🗃️ Data (high level)

Common fields include:
- Identifiers & descriptors: `Vehicle_ID`, `Make`, `Model`, `Vehicle_Type`, `Region`, `Year`
- Performance & usage: `Range_km`, `Battery_Capacity_kWh`, `Energy_Consumption_kWh_per_100km`
- Charging: `Charging_Power_kW`, `Charging_Time_hr`
- Environment: `CO2_Saved_tons`
- (Optional costs if present) `Monthly_Charging_Cost_USD`, `Maintenance_Cost_USD`, etc.

> In Power BI, numeric columns are typed as **Whole/Decimal/Currency**; text fields as **Text**. `Region` is set to **Data category: Continent** for maps.

---

## 🔍 SQL code overview (`sql/ev analytics.sql`)

Written for **MySQL 8+** (window functions), but easy to adapt.

**Included sections**
- **Peeks & counts** — row counts, distinct `Make`/`Model`, basic stats.  
- **Core KPIs** — average range & energy consumption; long-range and high-health filters.  
- **Extremes** — highest/lowest energy consumption lists.  
- **Summaries** — per-`Vehicle_Type` and per-`Make` rollups (count, avg range/battery).  
- **Regional metrics** — example cost-per-km by region (consumption × electricity price).  
- **Mix by region** — distribution of types across regions.  
- **Leaderboards & trends** — efficiency leaderboard (km/kWh), YoY changes, cumulative **CO₂ saved** by region.  
- **Indexes** — on `Make/Model`, `Region`, `Year` to speed up slicing.

**How to use**
1. Load the CSV into your DB (or connect BI directly to CSV).  
2. Open the SQL file in MySQL Workbench/DBeaver/phpMyAdmin and run sections you need.

---

## 📒 Notebook overview (`notebooks/EV Analytics.ipynb`)

A lightweight, reproducible EDA that supports the dashboard:

- **Load & type fixes** for numeric/text columns  
- **Basic profiling** (shape, missing values, descriptive stats)  
- **Quick visuals** (histograms/boxplots for range & consumption; bars by Region/Type/Make)  
- **Helper features** (optional):  
  - Efficiency (km/kWh) = `100 / Energy_Consumption_kWh_per_100km`  
- **Notes for BI** (anything discovered that informs visuals/slicers)

> Minimal dependencies: `pandas`, `numpy`, `matplotlib`.

---

## 📊 Power BI dashboard (what you’ll see)

**KPIs (cards)**
- **Vehicles** — *distinct count* of `Vehicle_ID`  
- **Avg Range (km)** — average `Range_km`  
- **Avg Energy (kWh/100km)** — average `Energy_Consumption_KWh_per_100km`  
- **Total CO₂ Saved (tons)** — sum of `CO2_Saved_tons`  
  - *Interpretation:* total emissions avoided vs. comparable ICE cars, per dataset assumptions.

**Visuals**
- **Vehicles by Type** — clustered column (distinct Vehicle_ID)  
- **Make share** — donut chart (share of distinct Vehicle_ID by `Make`)  
- **Vehicles by Region** — map using `Region` (data category = Continent)

**Slicers (left)**
- `Region`, `Vehicle_Type`, `Make`, `Year` (Between)

**Why this layout?**  
Executives get KPIs up top; analysts drill by Type/Make/Region below; slicers keep interaction simple.

---

## ▶️ Getting started

### 1) Data
- Download from Kaggle (link above).  
- Optional: add a **small sample** to `data/` for demos. Keep big raw files out of Git.

### 2) Power BI
1. Open `powerbi/EV_Analytics.pbix`.  
2. **Home → Transform data → Data source settings → Change Source…** to point to your CSV.  
3. **Refresh** and interact with slicers.

### 3) Notebook
```bash
# create env (optional)
python -m venv .venv
# activate and install
pip install pandas numpy matplotlib
# open the notebook in Jupyter or VS Code
```

### 4) SQL
- Open `sql/ev analytics.sql` in your client and run the sections you need.
