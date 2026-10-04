# oilgas-ai-labs

Hands-on learner labs for a two-hour instructor-led training on **AI applications in upstream oil and gas**.

The accompanying lecture deck covers AI-enabled seismic interpretation and prospect evaluation,
geological and petrophysical modeling, reservoir characterization and forecasting, drilling analytics
and real-time operational data, predictive drilling optimization (ROP, torque and drag, lost
circulation, stuck pipe, wellbore stability), and intelligent/autonomous drilling.

These labs exist to make that material hands-on **without requiring specialized oil-and-gas
software**. Every lab is designed to run in Excel, Google Sheets, or Power BI.

## Design constraints

Each lab must satisfy all of the following:

| Constraint | Requirement |
|---|---|
| Data | Real or realistic operational variables — not a narrative case study |
| License | Freely and legally usable for education, with clear stated terms |
| Format | CSV / XLSX / plain downloadable text |
| Tooling | Jupyter on SageMaker, or Excel / Sheets / Power BI. No Petrel, OpendTect, or Kingdom. |
| Code | Learners **run and interpret** code; they are not asked to write it |
| Duration | A decision-oriented exercise completable in ~28 minutes |
| Honesty | No fabricated values, wells, or scenarios. Every reported result is produced by executing the lab. |

## Labs

| Lab | Topic | Status |
|---|---|---|
| [lab1](./lab1) | Lithology prediction from well logs (Module 3.2) | **Built** — notebook + data, verified end-to-end |
| [lab2](./lab2) | ROP prediction & drilling optimization (Modules 4.1–4.2) | **Built** — notebook + data, verified end-to-end |
| [lab3](./lab3) | Production forecasting: decline curves vs ML (Module 3.3) | **Built** — notebook + data, verified end-to-end |
| [lab4](./lab4) | AI drilling copilot & autonomy levels (Module 4.3) | **Built** — notebook + data, verified end-to-end |

## Datasets

Small, openly licensed datasets are **committed alongside the lab** in `labN/data/`, with an
`ATTRIBUTION.md` recording the citation, licence, and exactly how the subset was derived. Shipping
the data removes the single biggest live-delivery risk — a source site being slow or down mid-session.

Anything above ~10 MB, or without redistribution rights, stays a documented download link instead.

## Repository conventions

- Secrets (`.env`, credential CSVs, Terraform state) are gitignored and must never be committed.
- Each lab folder is self-contained: dataset pointer, instructor notes, and learner worksheet.
