# Lab 4 — Would You Let It Close the Loop?

**Maps to:** Module 4.3 — *Intelligent and Autonomous Drilling Systems* (deck slides 102–121), and
specifically **slide 118** (DDSS as AI copilots), **119** (generative AI), and **109–110**
(closed-loop optimization).

**Format:** Jupyter notebook, run in SageMaker. **Calls a live LLM** — Claude on Amazon Bedrock,
authenticated by the instance's IAM role. No API key.

**Duration:** ~28 minutes.

## The lab in one line

Learners run an AI drilling copilot on three real intervals, watch it confidently misdiagnose the
one with no problem, then decide how much authority it should have.

## The setup

Three intervals from Utah FORGE well 58-32:

| | **A** | **B — the decoy** | **C** |
|---|---:|---:|---:|
| Depth (ft) | 6780–6840 | 175–225 | 3000–3060 |
| ROP (ft/hr) | 9.0 | 201.0 | 37.2 |
| **WOB (klbs)** | 26.4 | **0.0** | 28.4 |
| **Flow out (%)** | **68.0** | **97.0** | 95.7 |
| **Pit change (bbl)** | **−29.6** | **−42.1** | +8.3 |

**Interval B is the lab.** It has the *largest* pit drop and *no problem*: returns are at 97%, so
nothing is being lost, and WOB = 0 means the bit is off bottom — the pit is falling because mud is
going into the hole.

A pit-volume threshold alarm flags it. So does the AI.

## What actually happens

Verified by executing the notebook.

**1. The threshold alarm fires on both A and B** — loudest on B, the one that is fine.

**2. The copilot contradicts itself on B.** A representative response:

> "Severe loss of circulation (pit loss: −42.1 bbl, **flow return 97% of input**)"

It reports 97% returns and calls it severe loss circulation in the same sentence. It then recommends
applying weight on bit — with the string off bottom.

**3. Asked three times on identical data, it gave three different diagnoses:**

| Run | Diagnosis |
|---|---|
| 1 | "Severe Loss Circulation Event" |
| 2 | "Bit sliding/rotating freely **in a cavern**" |
| 3 | "Bit off-bottom, high ROP indicates **soft formation**" |

**4. Given the missing context, it gets it right:**

> "**BIT OFF BOTTOM – CIRCULATING.** The pit is dropping 42.1 bbl, which is expected when
> circulating off-bottom without adding fluid."

That last contrast is the payload. The engineering knowledge that made the answer correct came from
**the person writing the prompt**, not from the model. Someone had to already know that WOB = 0 means
off bottom in order to tell it so.

> ⚠️ **LLM output varies by design.** Every group will get different wording, and the notebook is
> built around that rather than against it — Step 4 asks the same question three times precisely to
> expose it. Do not expect the quotes above verbatim.

## Files

| File | Purpose |
|---|---|
| `autonomy_lab.ipynb` | The lab. 25 cells, executed end-to-end and verified on a live instance. |
| `data/forge_58-32_drilling.csv` | Same file as Lab 2, duplicated so the lab is self-contained |
| `data/ATTRIBUTION.md` | Citation, licence, and the three intervals |

## Prerequisites

**This lab needs Bedrock access**, which Lab 1–3 do not. The instance execution role must permit
`bedrock:InvokeModel` on the Haiku inference profile. That is already provisioned in `infra/`, and
every instance logs a `BEDROCK SMOKE TEST: PASS` line at boot — check CloudWatch before class.

Running on a machine without that permission fails at Step 3 with `AccessDeniedException`.

## Timing

| Min | Segment |
|---:|---|
| 3 | Set up: you are evaluating a copilot that will eventually close the loop |
| 5 | Step 1 — the three intervals, **learners diagnose before any AI** |
| 4 | Step 2 — the threshold alarm flags the wrong one |
| 6 | Step 3 — the copilot on A and B |
| 5 | Step 4 — three runs, three answers |
| 3 | Step 5 — the autonomy-level decision |
| 2 | Optional cell + debrief |
| **28** | |

## Facilitation

**Make them diagnose B before the AI does.** Step 1 ends with "look at WOB in interval B." A room
with drillers in it will get this immediately, and that is the point — the expertise exists in the
room and the model lacks it.

**Do not pre-explain interval B.** The lab works because learners watch a fluent, well-formatted
answer be wrong about something they just worked out themselves.

**Step 4 is the autonomy argument.** It is not a jab at the model — non-determinism is inherent. Ask
directly: *a closed-loop system acts without asking. What does it mean that it answers differently
each time?*

**Someone will say "set temperature to 0."** Good. The answer: that makes it repeatable, not
correct. It would then give the same wrong answer every time. Repeatability and correctness are
different properties, and automation needs both.

**The optional cell is load-bearing.** Without it the lab reads as "LLMs are useless for drilling,"
which is both wrong and unhelpful. With it, learners see the real shape: useful tool, correctness
still resting on an engineer.

## Debrief — intended learning points

1. **Threshold alarms and language models fail the same way here** — both flagged the interval with
   the biggest number rather than the one with the problem. Neither knew what WOB = 0 means.
2. **Fluency is not competence.** The wrong answer was better formatted than the right one. You
   could not tell from the prose which was which unless you already knew.
3. **Non-determinism is disqualifying for closed-loop control.** Three diagnoses on one dataset.
4. **The context that fixed it came from a human.** This is the honest state of drilling copilots:
   fast at drafting and summarising, dependent on an engineer for correctness.
5. **Authority levels are the useful frame** — advisory, human-in-the-loop, human-on-the-loop, closed
   loop. The question is never "does AI work" but "how much authority has it earned."
6. **Where the engineer is mandatory.** Recognising off-bottom, knowing losses need *both* reduced
   returns and falling pit volume, and knowing that losses and influx are opposite problems.

## Design notes

So these are not "corrected" later by mistake:

- **Interval B must stay the one with the largest pit drop.** That is what makes the threshold alarm
  and the copilot both fail. Do not "fix" the data.
- **Temperature is 1.0 deliberately**, so Step 4 reliably shows variation. Setting it to 0 removes
  the lab's third beat.
- **The notebook asserts nothing about what the model will say.** All claims about responses live in
  this README, measured from real runs. Learners evaluate the output they get against the data,
  which is a better exercise anyway.
- **The optional cell is part of the lab**, not a bonus. Cut Step 2 before cutting it.

## Relationship to Labs 1–3

The only lab that uses generative AI rather than a predictive model, and the only one where learners
interact with a system rather than evaluate a static result. It closes the course on the governance
question the other three build toward: **not whether the model is good, but how much authority it
should have.**
