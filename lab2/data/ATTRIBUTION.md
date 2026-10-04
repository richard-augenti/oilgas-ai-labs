# Data attribution

`forge_58-32_drilling.csv` is the processed Pason EDR log from **Utah FORGE well 58-32**.

## Citation

Podgorney, Robert K.; McLennan, John; Moore, Joseph (2018). *Utah FORGE: Drilling Data for Student
Competition.* Geothermal Data Repository, Idaho National Laboratory.
https://doi.org/10.15121/1495411

## Licence

**Creative Commons Attribution 4.0 International (CC BY 4.0).** The Geothermal Data Repository
record states `"isAccessibleForFree": true`; no login or registration is required.

Redistribution with attribution is permitted, which is why this file is committed here rather than
downloaded during the session.

## Source

- Landing page: https://gdr.openei.org/submissions/1113
- Direct file: https://gdr.openei.org/files/1113/Well_58-32_processed_pason_log.csv
- Funded by the US Department of Energy; contributors Energy & Geoscience Institute, University of Utah

## The well

Well 58-32 (previously MU-ESW1), drilled near Milford, Utah during Phase 2B of the FORGE project to
confirm the site met geothermal reservoir requirements. Vertical, 85 ft to 7,536 ft, through
sediments into crystalline granite.

## What was changed

Downloaded **2026-10-04**. The source file is already downscaled by its publishers to ~0.3 m (1 ft)
intervals from 1 Hz raw data.

1. Renamed columns to explicit names with units (`ROP(1 ft)` → `ROP_FTHR`, and so on).
2. Kept the imperial columns and dropped the duplicate SI versions.
3. Sorted by depth and rounded to 3 decimal places.

**No values were altered, filtered, or cleaned.** 7,311 rows retained — including the known data
defects, which the lab asks learners to find:

| Column | Defect |
|---|---|
| `WH_PRESSURE_PSI` | Ranges −1,231.8 to 17.4 psi. A sensor offset, not a measurement. Unusable. |
| `ROP_FTHR` | 43 samples above 500 ft/hr, max 2,978 — recording artifacts. |
| `WOB_KLBS` | 198 zero samples — bit off bottom. |
| `RPM` | 380 zero samples. |
| `DEPTH_FT` | Not strictly monotonic; reaming intervals re-cover depth. |

Cleaning these before handing the file over would remove the first exercise.

## Note for instructors

This is a **geothermal** well, not oil and gas. Say so. The rig, the Pason EDR, the channel set and
the drilling physics are identical to an oil and gas well; the formation and the objective are not.

It is, however, **US data** — Milford, Utah — released by the Department of Energy.
