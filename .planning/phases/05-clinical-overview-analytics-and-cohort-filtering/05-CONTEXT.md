# Phase 05: Clinical Overview Analytics & Cohort Filtering — Context

**Gathered:** 2026-10-21  
**Status:** Ready for planning  

## Phase Boundary

Phase 5 delivers actionable herd epidemiology filtering and clinical overview clarity as specified in REQ-20:
- Interactive Date Range filter (`7d`, `30d`, `90d`, `All`) and Species Cohort filter (`All Bovines`, `Indigenous Cattle`, `Murrah Buffaloes`) on the website.
- Dynamic reactive updates to the 4-quarter udder inflammation heatmap, Somatic Cell Count (SCC) tiers, and KPI summary cards.
- De-cluttering the clumsy "Observations & Symptoms" workspace by elevating the patient's individual anatomical signs, milk appearance, and vitals to the top, while structuring the herd analytics below with clear dropdown controls.
- Epidemiological report export functionality (CSV/PDF summary) for veterinary records.
- Guardrail: Do not touch Android app building or Capacitor mobile workflows without an explicit prompt from the user.

## Implementation Decisions

### 1. Workspace Layout Reorganization
- **Decision locked:** Re-order and de-clutter `#paneClinicalObservations` so the current patient's clinical signs, fore-milk appearance (strip-cup flakes/curds), anatomical quarter inflammation, vital measurements, and farmer notes are displayed immediately at the top in clean, uncluttered cards.
- **Preference:** Move the herd-level epidemiology (4-quarter heatmap, SCC distribution, withholding holds, pathogen surveillance) below the patient observations, separated by a distinct section header with filter dropdowns.

### 2. Website Dropdown Controls
- **Decision locked:** Add two primary reactive dropdown selectors in the website's Clinical Overview header:
  1. `Date Range Filter`: `7 Days` (Last week), `30 Days` (Last month), `90 Days` (Quarterly), `All Time`.
  2. `Species Cohort Filter`: `All Bovines`, `Indigenous Cattle (Gir/Sahiwal/Kankrej)`, `Murrah Buffaloes (Bubalus bubalis)`.
- **Preference:** Selection changes must immediately update the active heatmap percentage distributions, herd mastitis incidence rate KPI, quarters at risk, and active cases count without full page reloads.

### 3. Epidemiological Report Generation (REQ-20)
- **Decision locked:** Provide an export trigger button/action for downloading or printing an epidemiological summary report covering SCC tiers, quarter vulnerability breakdown, and active antibiotic milk withholding schedules.

### 4. Build Scope Guardrail
- **Decision locked:** Do not execute Capacitor build commands (`cap:sync`, `cap:add:android`, etc.) or modify Android project files during Phase 5 unless explicitly prompted by the user. Keep changes strictly inside the web application (`index.html`, `app.js`, `styles.css`).

## Claude's Discretion

- Visual styling of the filter dropdowns to match existing BoviCare design system tokens (`--forest`, `--border`, `--ink`, `--surface`, border radius 10px-12px).
- Internal calculation logic in `app.js` for filtering herd records and recalculating quarter percentage distributions for cattle vs. buffalo cohorts.
- Localization strings in English, Marathi, and Hindi for the new dropdown options.

## Code Context

- [index.html](file:///Users/aryanmokal/Projects/bovicare/index.html#L531-L992): Contains `#paneClinicalObservations` currently housing KPIs, heatmap, SCC meter, withholding feed, and patient observation cards.
- [app.js](file:///Users/aryanmokal/Projects/bovicare/app.js#L4040-L4120): Handles `openClinicalWorkspace()`, `renderClinicalObservations()`, and populating observation vitals and chips.
- [styles.css](file:///Users/aryanmokal/Projects/bovicare/styles.css): Provides design classes for `.clinical-kpi-card`, `.quarter-heatmap-grid`, `.clinical-section-card`, and form selects.

## Deferred Ideas

- Capacitor Android native packaging and camera hardware tests (deferred to Phase 7).
- Push notification service workers for milk withholding countdowns (deferred to Phase 6).

---

_Phase: 05-clinical-overview-analytics-and-cohort-filtering_  
_Context gathered: 2026-10-21_
