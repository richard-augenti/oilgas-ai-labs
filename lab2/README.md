# Lab 2 — The ROP Model That Can't Help You Drill

**Maps to:** Modules 4.1 and 4.2 — *Drilling Optimization and Intelligent Well Construction* and
*Predictive Drilling Optimization* (deck slides 61–101, roughly 50–83% of the deck).

**Format:** Jupyter notebook, run in SageMaker. Learners run cells and interpret; they do not write
code.

**Duration:** ~28 minutes.

## The lab in one line

A vendor's ROP model scores **R² 0.873**. Tested the way it would actually be used — predicting
ahead of the bit — it scores **R² −7.094**. And **weight on bit**, the main lever a driller pulls,
accounts for **2.3%** of it.

## Why this works

Every number below came from executing the notebook.

| | |
|---|---:|
| Random split (sees rock either side of each test point) | **R² 0.873** |
| Depth split (trained on upper hole, predicts ahead of bit) | **R² −7.094** |
| Average ROP, upper section | 44.2 ft/hr |
| Average ROP, lower section | 12.6 ft/hr |
| Levers a driller controls (WOB, RPM, flow) | **17.6%** of the model |
| Consequences of the hole (pump pressure, torque, hookload) | **82.4%** |
| Weight on bit alone | **2.3%** |

Two separate failures, and they are independent:

**It does not generalise.** Nothing about the model changes between 0.873 and −7.094 — only how it
was tested. A negative R² means the predictions are further from the truth than guessing the average
would have been. The rock changed at 5,400 ft and the model had never seen it.

**It does not inform a decision.** Even where it is accurate, it keys on pump pressure — which
reflects where you are in the hole, not a choice anyone makes. A driller cannot act on it.

## Files

| File | Purpose |
|---|---|
| `rop_lab.ipynb` | The lab. 32 cells, executed end-to-end and verified. |
| `data/forge_58-32_drilling.csv` | 7,311 samples, 13 channels, 1.3 MB |
| `data/ATTRIBUTION.md` | Citation, licence, and the deliberately retained data defects |

## Data

**Utah FORGE well 58-32**, Milford, Utah — real Pason EDR data released by the US Department of
Energy under **CC BY 4.0**, no registration. 85 ft to 7,536 ft.

> **Say this out loud:** it is a **geothermal** well. The rig, the EDR, the channel set and the
> drilling physics are identical to an oil and gas well; the formation and objective are not. It is
> at least **US data**, unlike Lab 1.

The file ships **uncleaned on purpose** — a dead wellhead-pressure channel, 43 impossible ROP spikes,
198 off-bottom samples. Finding those is Step 1.

## Timing

| Min | Segment |
|---:|---|
| 3 | Set up: you are evaluating a vendor ROP model before it goes on a rig |
| 5 | Step 1 — the data and its three defects |
| 4 | Step 2 — train, see R² 0.873, **commit to a yes/no before proceeding** |
| 6 | Step 3 — depth split, R² −7.094, why it collapses |
| 6 | Step 4 — feature importance, the levers-vs-consequences split |
| 2 | Step 5 — group decision |
| 2 | Debrief |
| **28** | |

## Facilitation

Four marked **⏸ Discuss** stops. The one that matters is Step 4.

**Make them commit before Step 3.** Ask for hands on "would you put this on a rig?" while R² 0.873
is on screen. The lab works because they have publicly backed a position before it is undercut.

**Expect pushback on the depth split** — someone will argue it is unfair. Let them. The answer is
that it is exactly the job: on a rig you have the hole above and you are asking about the hole below.
If a group argues the model should be retrained continuously as it drills, that is a genuinely good
answer — ask what happens the moment it enters a formation nobody has drilled.

**Step 4 is where drillers come alive.** Anyone who has sat in a doghouse knows pump pressure is not
something you dial in to drill faster. Let them say it.

## Debrief — intended learning points

1. **How you split your data can matter more than which model you pick.** 0.873 and −7.094 are the
   same model. A vendor will show you the first number.
2. **Predicting ahead of the bit is the only test that counts** for a drilling advisory, and it is
   the hardest one. Interpolating within drilled hole is not the job.
3. **Accurate is not the same as actionable.** 82.4% of this model rests on variables nobody sets.
   It can predict ROP and still answer no question a driller has.
4. **Feature importance is not causation.** WOB scores 2.3%, yet dropping the consequence variables
   costs only ~0.14 of R². The model did not *need* WOB because pump pressure already encoded depth.
   Importances are unstable when inputs are correlated — they tell you what the model used, not what
   drives the rock.
5. **Dirty data is the normal condition.** A dead channel, impossible rates, and off-bottom rows all
   sit in a real DOE-published EDR file. No model flags them for you.
6. **Where the engineer is mandatory.** Choosing the depth split, recognising the dead channel, and
   knowing which variables are levers are all domain judgements. The model makes none of them.

## Design notes

So these are not "corrected" later by mistake:

- **The 70/30 depth split is the whole design.** It reproduces how a drilling model is actually
  deployed. Replacing it with a random split destroys the lab.
- **Data defects are retained deliberately.** Shipping a cleaned file would remove Step 1 and hide
  that real EDR data arrives like this.
- **The optional cell teaches the subtler point** — levers-only still reaches R² 0.731, which looks
  like it contradicts the 2.3% importance. It does not; it demonstrates that importance is not
  causation. Do not "fix" this apparent inconsistency.
- **Every number in this file came from executing the notebook.** If the data or parameters change,
  re-run and update.

## Relationship to Lab 1

Deliberately the same shape: a model that looks good, a test that reveals it is not, and a decision.
Lab 1 is classification and the failure is *where* it is wrong. Lab 2 is regression and the failure
is *when you ask it something new*. Run both and learners see that the pattern is not a quirk of one
model.
