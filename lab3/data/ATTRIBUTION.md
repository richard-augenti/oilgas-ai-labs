# Data attribution

`nd_bakken_production.csv` is derived from the **North Dakota Monthly Production Report**, published
by the North Dakota Department of Mineral Resources, Oil and Gas Division.

## Source

- Agency: North Dakota Department of Mineral Resources, Oil and Gas Division (NDIC)
- Landing page: https://www.dmr.nd.gov/oilgas/mprindex.asp
- Files used: `https://www.dmr.nd.gov/oilgas/mpr/YYYY_MM.xlsx`, Jan 2021 – Dec 2024 (48 monthly files)
- Downloaded **2026-10-04**

## Access terms — read this before redistributing further

⚠️ **Weaker provenance than the other labs.** Unlike Lab 1 (CC BY 4.0 + NLOD 2.0) and Lab 2
(CC BY 4.0), the NDIC does **not** publish an explicit open-data licence for these files.

What is true:

- Operators are **required by state law** to report production, and the resulting reports are
  **public records** published by a state agency.
- The monthly `.xlsx` files download with **no registration, no login, and no fee**.
- NDIC publishes a general disclaimer that data is provided "as is" with no warranty.

What is **not** established: an explicit grant of redistribution rights. Public-record status
usually implies free reuse, and this subset is committed here on that basis for classroom use. If
this material is ever published more widely or commercially, confirm terms with NDIC first.

Note also that the `mprindex.asp` page states Excel files are not linked because amendments make
past spreadsheets diverge from the PDFs — **the files are still served at the URL pattern above**,
but treat them as a point-in-time snapshot, not the authoritative current record.

## What was changed

1. Downloaded 48 monthly files (Jan 2021 – Dec 2024) and concatenated them. 958,266 well-months
   across 22,186 wells.
2. Dropped rows with `Days = 0` (no production reported that month).
3. Kept only wells whose **first appearance** falls between Jun 2021 and Dec 2021, with at least 30
   months of records and still producing in Jun 2024 — so each well's full early life is visible
   inside the window. This is the key filter: it avoids wells that were already years into decline
   when the window opened.
4. Added `MONTHS_ON_PROD`, counted from each well's first reported production.
5. Added `OIL_BOPD` = `OIL_BBL / DAYS_PRODUCED`, which removes downtime from the decline signal.
6. Truncated at 36 months on production.

**No values were altered or smoothed.** Result: **27,022 well-months from 768 wells.**

## Fields

| Column | Meaning |
|---|---|
| `API` | API well number, the unique identifier |
| `WELL_NAME`, `OPERATOR`, `FIELD`, `COUNTY`, `POOL` | Well header |
| `REPORT_DATE` | Production month |
| `MONTHS_ON_PROD` | Months since first production (0 = first month) |
| `OIL_BBL`, `GAS_MCF`, `WATER_BBL` | Reported monthly volumes |
| `DAYS_PRODUCED` | Days the well produced that month |
| `OIL_BOPD` | `OIL_BBL / DAYS_PRODUCED` — the rate the lab forecasts |

## Note for instructors

This is **real US data** — North Dakota Bakken, named operators, real wells. Learners can look any
`API` up on the NDIC site. That makes it the most directly relatable dataset of the three labs.

These are genuine unconventional wells with the steep early decline that implies. The decline rates
learners see are real, not illustrative.
