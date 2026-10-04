# Lab 1 — Drilling performance & data quality

**Status:** dataset researched and verified; selection **not yet confirmed**. No worksheet written yet.

Learning objective: learners decide what an AI drilling-advisory system *should* have recommended on
a real well — and where it would have been wrong. The lesson is judgment about data and decisions,
not model training.

## Selected dataset (recommended, pending confirmation)

**Utah FORGE — Well 58-32 Processed Pason Log**

| | |
|---|---|
| Landing page | https://gdr.openei.org/submissions/1113 |
| Direct file | `https://gdr.openei.org/files/1113/Well_58-32_processed_pason_log.csv` |
| Source | Idaho National Laboratory / Geothermal Data Repository (US DOE); contributors EGI, Univ. of Utah |
| License | **CC BY 4.0** — page metadata states `"isAccessibleForFree": true`. No login or registration. |
| DOI | https://doi.org/10.15121/1495411 |
| Size | 1.24 MB · **7,310 data rows × 27 columns** · depth 85–7,536 ft |

Verified by download on 2026-10-04. Expected header:

```
Depth(ft), Depth(m), ROP(1 ft), ROP(1 m), weight on bit (k-lbs), weight on bit (kg),
Temp Out( degF), Temp Out( degC), Temp In(degF), Temp In(degC), Pit Total (bbls),
Pit Total (m3), Pump Press (psi), Pump Press (KPa), Hookload (k-lbs), Hookload (kg),
Surface Torque (psi), Surface Torque (KPa), Rotary Speed (rpm), Flow In (gal/min),
Flow In(liters/min), Flow Out %, WH Pressure (psi), WH Pressure (KPa),
H2S Floor, H2S Cellar, H2S Pits
```

**Do not download `Well 58-32 Raw Pason Log.csv`** — it is 603 MB at 1 Hz and will not open in Excel.

### Known caveats — state these to learners

- **This is a geothermal well, not an oil & gas well.** The rig, the Pason EDR, the channels, and the
  drilling physics transfer directly; the formation and the objective do not. Say so in one sentence
  rather than letting someone notice.
- **Depth-indexed, not time-stamped.** There is no timestamp column. Frame this as depth-based
  drilling performance, not a real-time time-series exercise.
- **No event labels.** Nobody can check their answer — which is precisely the position most
  operators are in when evaluating a predictive drilling product. This is the debrief hook.

### Verified data defects (these drive the lab, don't fix them silently)

| Column | Finding |
|---|---|
| `WH Pressure (psi)` | Range −1,231.8 to 17.4, mean −35.8. **Unusable.** Keep as bait or delete. |
| `Flow Out %` | Range 0.69–111.21; **5,831 of 7,310 rows below 90%**. Baseline is ~80%, not 100%. |
| `weight on bit (k-lbs)` | 198 zero rows (off-bottom) — must filter before ROP correlation |
| `Rotary Speed (rpm)` | 380 zero rows |
| `ROP(1 ft)` | Max 2,977.91 ft/hr; 43 rows above 500 — implausible spikes |
| `Depth(ft)` | **Not strictly monotonic** — reaming intervals re-cover depth. Pre-sort or scope to a clean window. |

## Lab concept (~40 min)

1. **Trust the data before the model (~8 min)** — learners find the three defects themselves: the dead
   `WH Pressure` channel, off-bottom rows where WOB/RPM are zero, and implausible ROP spikes.
2. **Which parameters actually drive ROP? (~10 min)** — scatter ROP against WOB, torque, RPM, and pump
   pressure on filtered on-bottom rows; eyeball which relationships are real.
3. **The returns-deficit judgment call (~12 min)** — flag rows where `Flow Out %` is low and
   `Pit Total` is falling. Learners discover the ~80% baseline means a naive threshold alarm fires
   thousands of times, and must set a rule they'd actually put on a rig floor.
4. **Decision and defence (~10 min)** — each group commits to one written recommendation plus the one
   piece of evidence that would change their mind.

**Deliberately out of scope:** model training, Python, accuracy metrics.

## Instructor pre-work

- Pre-sort by depth (the column is not monotonic as shipped)
- Delete the duplicate SI columns so learners aren't choosing between unit systems
- Decide whether to leave `WH Pressure` in as deliberate bait

## Alternatives evaluated

| Dataset | Verdict |
|---|---|
| [Petrobras 3W v1.1.1](https://github.com/petrobras/3W/tree/v1.1.1/dataset) | CC BY 4.0, real offshore oil wells, **has event labels**, 10,750 rows. Best fallback if oil-well provenance matters more than drilling relevance — but it is production/well-integrity, not drilling. Pin tag `v1.1.1`; v2.0.0 is Parquet. |
| [Utah FORGE Well 16A(78)-32](https://gdr.openei.org/submissions/1283) | CC BY 4.0, 36 channels incl. real `Time`, `RigEventCode`, downhole torque. **113 MB** — Power BI only, needs instructor pre-trim. |
| [FORCE 2020 well logs](https://zenodo.org/records/4351156) | NLOD 2.0 + CC BY 4.0. Well-log/lithofacies option. `train.zip` is ~1.17M rows — **exceeds Excel's row limit**; CSVs are semicolon-delimited. |
| Equinor Volve | Equinor Open Data Licence but **now requires a Databricks account**; real-time drilling is WITSML. Schedule risk. |
| Kansas / Panoma `facies_vectors.csv` | ❌ **Rejected.** Repo states the dataset "is not openly licensed... treat it as proprietary." Fails the license constraint despite being widely recommended. |
| North Dakota DMR production | ❌ **Rejected.** Site states "no link to an excel document is available" — PDF only. |
