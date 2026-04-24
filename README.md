# UK Strawberry Production LCA

[![DOI](https://img.shields.io/badge/DOI-pending-blue)]()
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Life cycle assessment of protected strawberry (*Fragaria × ananassa*) production systems in the United Kingdom, comparing polytunnels, heated glasshouses, and non-heated glasshouses.

## Citation

TBD

## Overview

This repository contains data, methods, and reproducibility materials for a cradle-to-farm-gate life cycle assessment of UK strawberry production. The study compares three protected cultivation systems using primary data from a commercial farm over four production years (2020–2023).

### Key findings

- Polytunnels achieve ~20% lower climate change impact compared to heated glasshouses
- N₂O emissions from soilless coir substrate are substantially lower than IPCC soil defaults
- System rankings remain robust across sensitivity scenarios

## Repository structure

```
uk-strawberry-lca/
├── data/
│   ├── raw/                 # Anonymised production records
│   ├── processed/           # Aggregated LCI parameters
│   └── external/            # Emission factors, IPCC parameters
├── docs/
│   ├── methods_draft_v3.md  # Methods section
│   ├── supplementary/       # Supplementary tables and materials
│   └── figures/             # System boundary diagram
├── simapro/
│   └── [SimaPro export files]
├── scripts/
│   ├── R/                   # Data processing and visualisation
│   └── python/              # LCA pipeline (alternative to SimaPro)
├── results/
│   ├── monte_carlo/         # Monte Carlo simulation outputs
│   └── figures/             # Publication-ready figures
└── references/
    └── strawberry_lca_references_v3.ris
```

## Data

### Production data

Primary data from a UK commercial strawberry enterprise (anonymised):
- 117 production records across 4 years (2020–2023)
- Three systems: polytunnel (n=73), heated glasshouse (n=24), non-heated glasshouse (n=20)
- Inputs: fertilisers, energy, materials, seedlings, irrigation

### Background data

- ecoinvent v3.8 (allocation at point of substitution)
- Environmental Footprint 3.1 characterisation factors
- IPCC 2019 Refinement emission factors (adapted for soilless substrate)

## Methods

Full methods are documented in `docs/strawberry_lca_methods_draft_v3.md`. Key methodological choices:

| Parameter | Value | Justification |
|-----------|-------|---------------|
| Functional unit | 1 kg strawberries | Farm gate |
| EF₁ (direct N₂O) | 0.005 | Soilless substrate, aerobic conditions |
| Frac_LEACH | 0.10 | Semi-closed fertigation |
| Frac_GASF | 0.02 | CAN + drip fertigation |
| Monte Carlo | 1,000 iterations | Per system-year combination |

## Software

- **SimaPro 9.x** — Primary LCA modelling
- **R 4.x** — Data processing, visualisation
- **Python 3.x** — Alternative LCA pipeline (optional)

## License

- **Data**: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Code**: [MIT License](LICENSE)




