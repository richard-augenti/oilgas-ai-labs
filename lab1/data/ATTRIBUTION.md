# Data attribution

`well_logs_lab.csv` is a subset of the **FORCE 2020 Well Log and Lithofacies Dataset for Machine
Learning Competition**.

## Required citation

> Lithofacies data was provided by the FORCE Machine Learning competition with well logs and
> seismic 2020.

Bormann, P., Aursand, P., Dilib, F., Manral, S., Dischington, P. (2020). *FORCE 2020 Well Well Log
and Lithofacies Dataset for Machine Learning Competition.* Zenodo.
https://doi.org/10.5281/zenodo.4351155

## Licence

- **Well log data** — Norwegian Licence for Open Government Data (NLOD) 2.0
- **Lithofacies labels** — Creative Commons Attribution 4.0 International (CC BY 4.0)

Both permit redistribution with attribution, which is why this subset is committed here rather than
downloaded during the session.

## Source

- Original dataset: https://doi.org/10.5281/zenodo.4351155
- Competition repository: https://github.com/bolgebrygg/Force-2020-Machine-Learning-competition
- Provenance: Norwegian Continental Shelf, released by the Norwegian government via FORCE

## What was changed to make this subset

Derived from `lithology_competition/data/train.zip` → `train.csv` on **2026-10-04**.

1. Selected 7 of the 98 training wells, all from quadrant 25 so the test well has genuine
   geological analogues — six for training, `25/8-5 S` held back as a blind test.
2. Dropped rows missing any of GR, RHOB, NPHI, RDEP, DTC.
3. Kept `WELL`, `DEPTH_MD`, the seven curves above plus PEF and CALI, the lithology label and its
   confidence code. Added a `SPLIT` column.
4. Mapped the numeric `FORCE_2020_LITHOFACIES_LITHOLOGY` codes to names (65000 → Shale,
   30000 → Sandstone, and so on).
5. Rounded values to 4 decimal places.

**No values were altered, synthesised, or rebalanced.** 41,596 rows — 34,141 train, 7,455 test.

## Note for instructors

These are **North Sea** wells, not US. Say so. The lithologies and the lesson transfer; the
stratigraphy is not Permian or Gulf Coast. The nearest US equivalent with core-derived facies
labels is the Kansas/Panoma Council Grove dataset, which its own repository states is **not openly
licensed** — which is why it is not used here.
