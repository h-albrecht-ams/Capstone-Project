# Back in the Air — European Aviation Recovery After COVID-19

An analysis of passenger and cargo traffic recovery at four major European hub airports following the COVID-19 pandemic, using official Eurostat data from 2017–2024.

## Overview

This project examines how European aviation recovered after the pandemic by comparing pre-COVID, COVID, and post-COVID traffic at four of the continent's busiest hubs:

- **FRA** — Frankfurt Airport
- **AMS** — Amsterdam Schiphol
- **CDG** — Paris Charles de Gaulle
- **MAD** — Madrid Barajas

The analysis quantifies the scale of the collapse, tests whether recovery is statistically significant, and classifies individual routes by how they fared through the disruption.

## Key Questions

The project tests four hypotheses using Mann-Whitney U tests, comparing traffic distributions across periods to determine whether observed differences in recovery are statistically significant rather than due to chance.

Routes are also classified into four categories:

- **Survivors** — routes active both before and after COVID
- **Lost** — routes that existed before COVID but did not return
- **New** — routes that appeared only after the pandemic
- **COVID-only** — routes that operated exclusively during the COVID period

## Data Source

Data comes from [Eurostat](https://ec.europa.eu/eurostat), the statistical office of the European Union, covering 2017–2024. The analysis uses the **passengers carried** metric at the route (origin–destination) level. This metric was chosen deliberately to avoid double-counting connecting travelers, given the route-level structure of the dataset.

## Pipeline

The analytical work is done entirely in Python/pandas. PostgreSQL serves purely as the serving layer that connects the finished dataset to Tableau for visualization — it is not used for transformation or analysis. This makes the pipeline a classic **ETL** flow, with all Transform work upstream of the load.

```
Eurostat (Excel)  →  pandas  →  cleaning + analysis + hypothesis testing  →  PostgreSQL  →  Tableau
```

**Steps:**

1. **Extract** — Download traffic data from Eurostat as Excel files.
2. **Import** — Load the Excel files into pandas.
3. **Clean** — Handle nulls, correct data types, and standardize airport/route codes in Python.
4. **Analyse** — Run the full analysis in pandas: exploratory analysis, route classification (Survivors / Lost / New / COVID-only), and the four Mann-Whitney U hypothesis tests.
5. **Load** — Write the finished, analysis-ready tables to PostgreSQL via SQLAlchemy.
6. **Connect** — Establish the PostgreSQL → Tableau connection.
7. **Visualise** — Build the dashboards and final visualizations in Tableau.

## Tech Stack

- **Python** (pandas) — extraction, cleaning, analysis, and statistical testing
- **SQLAlchemy** — loading the processed data into PostgreSQL
- **PostgreSQL** — serving layer for visualization
- **Tableau** — dashboards and final visualizations

## Repository Structure

```
.
├── data/            # Raw Eurostat Excel files
├── notebooks/       # pandas cleaning, analysis, and hypothesis testing
├── src/             # Reusable Python scripts / helpers
├── sql/             # Schema / load scripts for PostgreSQL
├── tableau/         # Tableau workbook(s)
└── README.md
```
*(Adjust to match your actual layout.)*

## Getting Started

### Prerequisites

- Python 3.x
- PostgreSQL
- Tableau Desktop

### Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd <repo-name>

# Install dependencies
pip install -r requirements.txt
```

Configure your PostgreSQL connection (e.g. via environment variables or a config file) before running the load step.

## Results

*(Summarize your headline findings here — e.g. how far each hub recovered relative to 2019 baseline, which hypotheses were confirmed, and how many routes fell into each category.)*

## Author

**Natalia Ströher**
Capstone project — Data Analytics

## License

*(Add a license if you intend to share this publicly, e.g. MIT.)*