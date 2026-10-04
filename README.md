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
| Tooling | Excel, Sheets, or Power BI only — no Petrel, OpendTect, Kingdom, or Python |
| Duration | A decision-oriented exercise completable in 30–45 minutes |
| Honesty | No fabricated values, wells, or scenarios |

## Labs

| Lab | Topic | Status |
|---|---|---|
| [lab1](./lab1) | Drilling performance & data quality | Dataset researched and verified — **pending final confirmation** |
| [lab2](./lab2) | — | Not yet designed |
| [lab3](./lab3) | — | Not yet designed |
| [lab4](./lab4) | — | Not yet designed |

## Datasets

Datasets are **not vendored into this repository**. Each lab's README gives the verified direct
download link, the source organization, the license, and the exact file to retrieve. This keeps the
repo small and keeps attribution attached to the data rather than buried in a commit.

## Repository conventions

- Secrets (`.env`, credential CSVs, Terraform state) are gitignored and must never be committed.
- Each lab folder is self-contained: dataset pointer, instructor notes, and learner worksheet.
