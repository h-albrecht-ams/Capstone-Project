import pandas as pd

# ─────────────────────────────────────────────
# 1. REGION MAPPING
#    Based on UN M49 world regions, adapted for
#    Eurostat country codes used in aviation data
# ─────────────────────────────────────────────

region_map = {
    # Europe (EU)
    "AT": "Europe (EU)", "BE": "Europe (EU)", "BG": "Europe (EU)",
    "CY": "Europe (EU)", "CZ": "Europe (EU)", "DE": "Europe (EU)",
    "DK": "Europe (EU)", "EE": "Europe (EU)", "EL": "Europe (EU)",  # EL = Greece
    "ES": "Europe (EU)", "FI": "Europe (EU)", "FR": "Europe (EU)",
    "HR": "Europe (EU)", "HU": "Europe (EU)", "IE": "Europe (EU)",
    "IT": "Europe (EU)", "LT": "Europe (EU)", "LU": "Europe (EU)",
    "LV": "Europe (EU)", "MT": "Europe (EU)", "NL": "Europe (EU)",
    "PL": "Europe (EU)", "PT": "Europe (EU)", "RO": "Europe (EU)",
    "SE": "Europe (EU)", "SI": "Europe (EU)",

    # Europe (non-EU)
    "AL": "Europe (non-EU)", "AM": "Europe (non-EU)", "BA": "Europe (non-EU)",
    "BY": "Europe (non-EU)", "CH": "Europe (non-EU)", "IS": "Europe (non-EU)",
    "MD": "Europe (non-EU)", "MK": "Europe (non-EU)", "NO": "Europe (non-EU)",
    "RS": "Europe (non-EU)", "RU": "Europe (non-EU)", "TR": "Europe (non-EU)",
    "UA": "Europe (non-EU)", "UK": "Europe (non-EU)",

    # Middle East
    "AE": "Middle East", "BH": "Middle East", "IL": "Middle East",
    "IR": "Middle East", "JO": "Middle East", "KW": "Middle East",
    "LB": "Middle East", "OM": "Middle East", "QA": "Middle East",
    "SA": "Middle East",

    # Africa
    "DZ": "Africa", "EG": "Africa", "ET": "Africa", "GH": "Africa",
    "KE": "Africa", "MA": "Africa", "MU": "Africa", "NA": "Africa",
    "NG": "Africa", "TN": "Africa", "TZ": "Africa", "ZA": "Africa",

    # Asia Pacific
    "AU": "Asia Pacific", "CN": "Asia Pacific", "HK": "Asia Pacific",
    "IN": "Asia Pacific", "JP": "Asia Pacific", "KR": "Asia Pacific",
    "KZ": "Asia Pacific", "LK": "Asia Pacific", "MN": "Asia Pacific",
    "MV": "Asia Pacific", "MY": "Asia Pacific", "PH": "Asia Pacific",
    "SG": "Asia Pacific", "TH": "Asia Pacific", "TW": "Asia Pacific",
    "VN": "Asia Pacific",

    # North America
    "CA": "North America", "US": "North America",

    # Latin America & Caribbean
    "AR": "Latin America", "BR": "Latin America", "CL": "Latin America",
    "CO": "Latin America", "CR": "Latin America", "CU": "Latin America",
    "DO": "Latin America", "MX": "Latin America", "PA": "Latin America",
    "VE": "Latin America",

    # Africa (already covered above — just double checking none missed)
    "AF": "Asia Pacific",  # AF = Afghanistan (ICAO code, not Africa)
}

# ─────────────────────────────────────────────
# 2. LOAD & FILTER
# ─────────────────────────────────────────────

print("Loading file...")
df = pd.read_csv("estat_avia_par_de.tsv", sep="\t")
col = df.columns[0]

# Keep only: monthly frequency (M), passengers carried total (PAS_CRD), Frankfurt (DE_EDDF)
mask = (
    df[col].str.startswith("M,PAS,PAS_CRD,") &
    df[col].str.contains("DE_EDDF")
)
fra = df[mask].copy()
print(f"Rows after filtering for FRA monthly PAS_CRD: {len(fra)}")

# ─────────────────────────────────────────────
# 3. SELECT MONTHLY COLUMNS 2017-2024
#    (exclude quarterly Q columns)
# ─────────────────────────────────────────────

month_cols = [
    c for c in df.columns
    if "-" in c.strip()
    and "Q" not in c.strip()
    and c.strip()[:4] in [str(y) for y in range(2017, 2025)]
]
print(f"Monthly columns selected: {len(month_cols)} (2017-01 to 2024-12)")

fra = fra[[col] + month_cols].copy()

# ─────────────────────────────────────────────
# 4. PARSE ROUTE IDENTIFIER
# ─────────────────────────────────────────────

fra["route"] = fra[col].str.split(",").str[3]

# Extract partner airport: remove DE_EDDF_ prefix or _DE_EDDF suffix
fra["partner_airport"] = fra["route"].apply(
    lambda x: x.replace("DE_EDDF_", "") if x.startswith("DE_EDDF_")
    else x.replace("_DE_EDDF", "")
)

# Extract 2-letter partner country code
fra["partner_country"] = fra["partner_airport"].str[:2]

# ─────────────────────────────────────────────
# 5. ADD REGION
# ─────────────────────────────────────────────

fra["region"] = fra["partner_country"].map(region_map).fillna("Other / Unknown")

# Flag domestic routes (partner country = DE)
fra["is_domestic"] = fra["partner_country"] == "DE"

# ─────────────────────────────────────────────
# 6. CLEAN NUMERIC VALUES
#    Eurostat uses ':' for missing and 'b' for breaks
# ─────────────────────────────────────────────

for c in month_cols:
    fra[c] = (
        fra[c].astype(str)
        .str.replace(" b", "", regex=False)
        .str.replace(" p", "", regex=False)
        .str.strip()
        .replace(":", None)
    )
    fra[c] = pd.to_numeric(fra[c], errors="coerce")

# ─────────────────────────────────────────────
# 7. RESHAPE TO LONG FORMAT (better for Tableau)
# ─────────────────────────────────────────────

fra_long = fra.melt(
    id_vars=["route", "partner_airport", "partner_country", "region", "is_domestic"],
    value_vars=month_cols,
    var_name="year_month",
    value_name="passengers"
)

# Split year_month into separate year and month columns
fra_long["year_month"] = fra_long["year_month"].str.strip()
fra_long["year"] = fra_long["year_month"].str[:4].astype(int)
fra_long["month"] = fra_long["year_month"].str[5:].astype(int)

# Drop rows with no passenger data
fra_long = fra_long.dropna(subset=["passengers"])
fra_long["passengers"] = fra_long["passengers"].astype(int)

# Reorder columns nicely
fra_long = fra_long[[
    "year_month", "year", "month",
    "route", "partner_airport", "partner_country", "region", "is_domestic",
    "passengers"
]]

fra_long = fra_long.sort_values(["year_month", "route"]).reset_index(drop=True)

# ─────────────────────────────────────────────
# 8. SUMMARY & SAVE
# ─────────────────────────────────────────────

print(f"\nFinal dataset shape: {fra_long.shape}")
print(f"Date range: {fra_long['year_month'].min()} to {fra_long['year_month'].max()}")
print(f"Unique routes: {fra_long['route'].nunique()}")
print(f"Unique countries: {fra_long['partner_country'].nunique()}")
print(f"\nRegion breakdown:")
print(fra_long.groupby("region")["passengers"].sum().sort_values(ascending=False).to_string())

print(f"\nPassengers by year (all routes):")
print(fra_long.groupby("year")["passengers"].sum().to_string())

fra_long.to_csv("fra_monthly_with_regions.csv", index=False)
print("\nSaved as: fra_monthly_with_regions.csv")
