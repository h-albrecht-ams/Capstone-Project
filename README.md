# Back in the Air — European Aviation Recovery After COVID-19

An end-to-end data analytics project exploring how passenger traffic, cargo transport, and flight operations recovered after the COVID-19 pandemic across four major European hub airports using official Eurostat data (2017–2024).

---

## Project Overview

The COVID-19 pandemic caused an unprecedented disruption to global aviation. While passenger traffic collapsed almost overnight, cargo operations proved considerably more resilient and played a critical role in maintaining global supply chains.

This project investigates how both passenger and cargo traffic recovered between 2017 and 2024 at four of Europe's busiest hub airports:

- **AMS** — Amsterdam Schiphol
- **CDG** — Paris Charles de Gaulle
- **FRA** — Frankfurt Airport
- **MAD** — Adolfo Suárez Madrid-Barajas

Using statistical analysis and interactive Tableau dashboards, we compare pre-pandemic, pandemic, and recovery periods to identify long-term changes in aviation demand and network structures.

---

## Research Questions

The project investigates four hypotheses:

### H1 — COVID Impact

Did passenger and cargo traffic decrease by more than 50% during the first pandemic year?

### H2 — Recovery

Did Amsterdam recover more slowly than the other hub airports?

### H3 — Transport Efficiency

Did transport efficiency (passengers or cargo per flight) recover after COVID?

### H4 — Network Changes

Did post-pandemic aviation networks shift toward new destinations and regions, particularly in cargo transport?

---

## Route Classification

To better understand structural changes in the aviation network, routes were classified into four categories:

- **Survivors** — Active before and after COVID
- **Lost** — Active before COVID but discontinued afterwards
- **New** — Introduced after COVID
- **COVID-only** — Operated exclusively during the pandemic

---

## Data Sources

The project uses official aviation datasets published by **Eurostat**, covering the years **2017–2024**.

The analysis combines:

- Passenger traffic
- Cargo traffic
- Flight movements

at the route (origin–destination) level.

---

## Data Pipeline

The project follows a Python-based analytics workflow:

```
Eurostat
      ↓
Python (pandas)
      ↓
Data Cleaning & Statistical Analysis
      ↓
PostgreSQL
      ↓
Tableau Dashboards
```

### Workflow

1. Extract official Eurostat datasets.
2. Clean and prepare the raw data using pandas.
3. Perform exploratory data analysis.
4. Conduct statistical hypothesis testing.
5. Load processed datasets into PostgreSQL.
6. Build interactive Tableau dashboards for visual analysis and presentation.

---

## Technologies

- Python
- pandas
- NumPy
- SciPy
- SQLAlchemy
- PostgreSQL
- Tableau

---

## Tableau Dashboards

The final results are presented through interactive Tableau dashboards including:

- Executive Overview
- Cargo Geography Analysis
- Recovery Analysis
- Cargo per Flight Analysis
- Passenger Traffic per Airport Analysis
- Growth by Region Analysis
- Final Conclusions

---

## Key Findings

Some of the main findings include:

- Passenger traffic experienced a significantly stronger decline than cargo traffic during COVID-19.
- Cargo operations proved considerably more resilient throughout the pandemic.
- Recovery patterns differed substantially across the four hub airports.
- Madrid showed the strongest recovery in several cargo-related indicators.
- Cargo route networks changed after COVID, with evidence of new long-haul connections.
- Passenger recovery followed a different trajectory than cargo recovery, highlighting the importance of analysing both markets separately.

---

## Repository Structure

```
.
├── data/                  # Raw Eurostat datasets
├── notebooks/             # Data cleaning, EDA and statistical analysis
├── src/                   # Reusable Python functions
├── sql/                   # Database scripts
├── tableau/               # Tableau workbooks and dashboards
├── presentation/          # Final presentation
└── README.md
```

---

## Getting Started

### Requirements

- Python 3.x
- PostgreSQL
- Tableau Desktop

### Installation

```bash
git clone <repository-url>
cd <repository>

pip install -r requirements.txt
```

Configure your PostgreSQL connection before loading the processed data into the database.

---

## Authors

**Natalia Ströher**

**Hendrik Albrecht**

Capstone Project – Data Analytics Bootcamp

---

## Acknowledgements

Data provided by **Eurostat**, the statistical office of the European Union.

---

## License

This project was developed as part of a Data Analytics Bootcamp Capstone Project.