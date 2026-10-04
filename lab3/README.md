# Lab 3 — Does AI Beat the Decline Curve?

**Maps to:** Module 3.3 — *Reservoir Characterization and Forecasting* (deck slides 41–60), and
specifically **slide 55**, which claims *"AI often outperforms traditional decline curve methods."*

**Format:** Jupyter notebook, run in SageMaker. Learners run cells and interpret.

**Duration:** ~28 minutes.

## The lab in one line

The lab tests a claim your own deck makes — and on 682 real Bakken wells, **the 1945 equation wins**.

## Why this works

Every number below came from executing the notebook. Both methods get each well's first 18 months
and must predict months 19–30.

| Forecasting a single well forward | Median error |
|---|---:|
| **Arps decline curve (1945)** | **35.0%** |
| Random forest | 47.7% |
| | |
| Decline curve better on | **67% of wells** |

Then the optional cell flips it. Predicting peak rate for a well with **no production history**,
where a decline curve has nothing to fit:

| Predicting across wells | Median error |
|---|---:|
| Guess the average | 90.4% |
| **Random forest (operator, field, pool, county)** | **40.7%** |

**That contrast is the lab.** Not "AI is overhyped" — a sharper and more useful conclusion:

> ML wins **across wells**, where it interpolates between analogues.
> Decline curves win **forward in time**, because they encode physics and tree models
> cannot predict outside their training range.

A random forest asked about month 25 having seen only months 0–17 returns the closest thing it knows
— a flat line at roughly the last value it saw. The notebook plots exactly that, and it is the
moment the lesson lands.

## Files

| File | Purpose |
|---|---|
| `forecasting_lab.ipynb` | The lab. 23 cells, executed end-to-end and verified. |
| `data/nd_bakken_production.csv` | 27,022 well-months, 768 wells, 3.5 MB |
| `data/ATTRIBUTION.md` | Source, access terms, and how the subset was built |

## Data

**North Dakota Bakken** — every producing well reported to the state, Jan 2021 – Dec 2024, filtered
to 768 wells whose first production falls inside the window so their full early life is visible.
Real operators, real wells; learners can look any API number up on the NDIC site.

> ⚠️ **Licensing is weaker here than Labs 1 and 2.** NDIC publishes no explicit open-data licence.
> These are public records, freely downloadable with no registration, and are committed on that
> basis for classroom use. See `data/ATTRIBUTION.md` before republishing more widely.

The strongest thing about this dataset: **it is unambiguously US data**, which neither of the other
labs can claim.

## Timing

| Min | Segment |
|---:|---|
| 3 | Set up: the deck claims AI beats decline curves — you are going to test it |
| 5 | Step 1 — production histories, and why we forecast rate per producing day |
| 4 | Step 2 — the contest setup, **groups predict the winner before seeing it** |
| 5 | The result: 35.0% vs 47.7% |
| 6 | Step 3 — plot one well, see the random forest flatline |
| 3 | Step 4 — group decision |
| 2 | Optional cell + debrief |
| **28** | |

## Facilitation

**Make them predict before the reveal.** Step 2 ends with an explicit "which do you think won?"
Most rooms will back AI — the deck told them to. That is what makes the result land.

**Do not let it become "AI is useless."** That is the failure mode of this lab. The optional cell
exists to prevent it and is not really optional — if time is short, cut Step 1 rather than the
peak-rate comparison. Learners should leave knowing *which question suits which tool*, not that
machine learning does not work.

**Expect someone to object that the ML model was handicapped** — one feature, one well, no tuning.
That is a good objection and the honest answer is yes: this is deliberately the worst case for a
tree model, and it is also exactly what "AI production forecasting" often means in a vendor pitch.
A model trained across many wells would do better, which is the optional cell.

**If a group asks about neural networks** — an LSTM or similar can extrapolate better than a tree,
but the structural point holds: it still has no physics, and with 18 points on one well it has
nothing like enough data.

## Debrief — intended learning points

1. **Tree-based models cannot extrapolate.** They predict by averaging training examples, so they
   can never output a value outside the training range. For anything that keeps declining, that is
   disqualifying.
2. **A 3-parameter physical equation beat a machine-learning model**, on real data, by a wide
   margin — because it encodes how reservoirs actually behave.
3. **Interpolation and extrapolation are different problems.** ML is strong at the first and weak
   at the second. Most of the value in upstream ML is interpolation across analogues.
4. **The deck's claim is incomplete, not wrong.** Slide 55 is true for cross-well prediction and
   false for single-well extrapolation. Teaching the distinction is more useful than teaching
   either slogan.
5. **Forecast the right quantity.** Monthly volume mixes decline with downtime; rate per producing
   day separates them. Choosing that is a reservoir engineer's judgement, not a modelling step.
6. **Where the engineer is mandatory.** Choosing the method, fitting from peak rather than first
   production, and knowing which question is being asked — none of these are decisions a model
   makes.

## Design notes

So these are not "corrected" later by mistake:

- **The decline fit starts at peak rate, not month 0.** Unconventional wells ramp up before they
  decline; fitting Arps from first production gives nonsense. This mirrors standard practice.
- **MAPE, not R².** These are forecasts at different scales across 682 wells; percentage error is
  the comparable measure and is what a reserves discussion would use.
- **18 months fit / 12 months forecast** is deliberate — enough history for a stable Arps fit, long
  enough forward to expose the flatline.
- **The optional cell is load-bearing.** Without it the lab teaches a wrong lesson. Treat it as part
  of the lab.
- **Every number in this file came from executing the notebook.** If the data or parameters change,
  re-run and update.

## Relationship to Labs 1 and 2

Labs 1 and 2 are both "a model looks good and is not." Lab 3 is deliberately different in shape: a
**head-to-head method comparison** that tests a claim from the deck itself, and ends with machine
learning winning the question it is actually suited to. Run after Labs 1 and 2, it stops the course
reading as uniformly sceptical about AI.
