# Lab 1 — Can We Trust the Lithology Model?

**Maps to:** Module 3.2, *Geological and Petrophysical Modeling* (deck slides 21–40, specifically
25–30 lithology and facies prediction).

**Format:** Jupyter notebook, run in SageMaker. Learners run cells and interpret; they do not write
code.

**Duration:** ~28 minutes.

## The lab in one line

A vendor's lithology model scores **84.3%** on a blind well and **misses 62% of the sandstone**.
Learners decide whether to sign off on it.

## Why this works

The result is real and it is the whole lesson. Measured on the held-out well `25/8-5 S`:

| | |
|---|---:|
| "Always predict Shale" baseline | **78.7%** |
| Random forest | **84.3%** |
| Improvement over doing nothing | **+5.6 pp** |
| Sandstone **precision** | **0.98** |
| Sandstone **recall** | **0.38** |
| Real sandstone samples missed | **769 of 1,245 (62%)** |
| — called Shale | 513 |
| — called Sandstone/Shale | 256 |
| Tuff (293 samples) | **0.00 — never found** |

84.3% sounds like a working model. It finds barely a third of the reservoir rock, and when it is
wrong it says *shale* — the one error that makes you walk past pay.

The precision/recall split is the teaching moment: **trust it when it says sandstone; do not trust
it when it says there is none.** A single accuracy figure hides both facts.

## Files

| File | Purpose |
|---|---|
| `lithology_lab.ipynb` | The lab. 32 cells, executed end-to-end and verified. |
| `data/well_logs_lab.csv` | 41,596 rows, 7 wells, 3.5 MB |
| `data/ATTRIBUTION.md` | FORCE 2020 citation, licence, and exactly how the subset was built |

## Data

FORCE 2020, Norwegian Continental Shelf. Logs under NLOD 2.0, labels under CC BY 4.0 — both permit
redistribution with attribution, so the subset is committed rather than downloaded live. Six
training wells and one blind test well, all from quadrant 25 so the test well has real geological
analogues.

> **Say this out loud:** these are **North Sea** wells, not US. The lesson transfers; the
> stratigraphy is not Permian or Gulf Coast. The nearest US dataset with core-derived facies labels
> is Kansas/Panoma Council Grove, which its own repository states is **not openly licensed**.

## Timing

| Min | Segment |
|---:|---|
| 3 | Set up: you are reviewing a vendor model before it enters your workflow |
| 5 | Steps 1–2 — what is in the data, what do the logs look like |
| 4 | Step 3 — train, see 84.3%, **commit to a yes/no before proceeding** |
| 4 | Step 4 — compare against the always-Shale baseline |
| 6 | Step 5 — per-class results, the sandstone reveal, where it fails in depth |
| 3 | Step 6 — group decision |
| 3 | Debrief |
| **28** | |

## Facilitation

Four marked **⏸ Discuss** stops. The one that matters is after the classification report.

**Make them commit before Step 4.** Ask for hands on "would you deploy this?" right after the 84.3%
appears. The lab only works if they have publicly backed a position before the baseline comparison
undercuts it.

**Expect the room to split** on precision vs. recall. Explorationists usually say missing pay is
worse. Drilling and completions people sometimes argue false positives cost more. Both are right —
it depends on the decision the model feeds. Do not resolve it; that *is* the point.

**If a group finishes early**, send them to the optional cell. Rebalancing lifts sandstone recall
from 0.38 to 0.42 and barely moves accuracy — the fix is not a hyperparameter.

## Debrief — intended learning points

1. **An accuracy number can be nearly useless.** 84.3% against a 78.7% do-nothing baseline is a
   5.6-point gain, and the model still misses most of the reservoir.
2. **Precision and recall answer different questions**, and which one matters depends on the
   decision downstream — not on the model.
3. **Class imbalance is a geological fact, not a data defect.** Shale dominates because shale
   dominates. The rare classes are often the interesting ones.
4. **Data availability constrains the model before anyone writes code.** PEF — one of the best
   lithology discriminators — is missing from 23.5% of the data. Deck slide 24: *"AI models are
   only as effective as the quality and diversity of input data."*
5. **Generalising to a new well is the real test.** Train and test on the same well and this looks
   excellent. The blind well is where it falls over, and that is the only evaluation that reflects
   how the model would actually be used.
6. **Where the geoscientist is mandatory.** The model cannot tell you it missed the pay. Catching
   that needs someone who knows what the sand should look like — and knows which *evidence* to go
   and get. Deck slide 39: *"combining AI outputs with geological expertise."*

## Design notes

So these are not "corrected" later by mistake:

- **The test well was chosen deliberately.** Quadrant-matched training wells make the model
  credible (it beats the baseline) while still failing instructively. An earlier pairing with
  non-analogue wells scored *below* the baseline — which teaches "ML doesn't work," the wrong
  lesson.
- **Only the five complete curves are used** (GR, RHOB, NPHI, RDEP, DTC). PEF is deliberately left
  in the CSV, and visibly incomplete, to drive the data-quality discussion.
- **Every number above was produced by executing the notebook**, not estimated. If the data or the
  model parameters change, re-run and update this file.
