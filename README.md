# UK Strawberry Production LCA

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22764954.svg)](https://doi.org/10.5281/zenodo.22764954)

Life cycle assessment of protected strawberry (*Fragaria × ananassa*) production systems in the United Kingdom, comparing polytunnels, heated glasshouses, and non-heated glasshouses.

## Citation

Siqueiros, E. and McAuliffe, G. (submitted). A multi-system Life Cycle Assessment of protected strawberry production. Data and code: https://doi.org/10.5281/zenodo.22764954

## Overview

This repository contains data, methods, and reproducibility materials for a cradle-to-farm-gate life cycle assessment of UK strawberry production. The study compares three protected cultivation systems using primary data from a commercial farm over four production years (2020–2023).

### Key findings

- Polytunnel production had the lowest climate change impact (0.51 kg CO₂-eq per kg of strawberries), against 0.68 for the non-heated glasshouse and 0.99 for the heated glasshouse, about 49% lower than the heated glasshouse
- N₂O emissions from soilless coir substrate are substantially lower than IPCC soil defaults
- The climate change ranking was unchanged across six N₂O emission factor scenarios, including IPCC default values
- The polytunnel had the highest marine eutrophication impact, which depends on assumed drainage losses that were not measured

## Repository structure

```
uk-strawberry-lca/
├── data/
│   ├── raw/                 # Anonymised production records
│   ├── processed/           # Aggregated LCI parameters
│   └── external/            # Emission factors, IPCC parameters
├── docs/
│   ├── supplementary/       # Supplementary tables and materials
│   └── figures/             # System boundary diagram
├── simapro/
│   └── [SimaPro export files]
├── scripts/
│   ├── R/                   # Data processing and visualisation
│   └── python/              # LCA pipeline (alternative to SimaPro)
├── results/
│   ├── monte_carlo/         # Monte Carlo simulation outputs
│   └── figures/             # Figures
└── references/
    └── strawberry_lca_references_v3.ris
```

## Data

### Production data

Primary data from a UK commercial strawberry enterprise (anonymised):
- 113 production records across 4 years (2020–2023)
- Three systems: polytunnel (n=73), heated glasshouse (n=24), non-heated glasshouse (n=16)
- Inputs: fertilisers, energy, materials, seedlings, irrigation

### Background data

- ecoinvent v3.9 (allocation at point of substitution)
- Environmental Footprint 3.1 characterisation factors
- IPCC 2019 Refinement emission factors (adapted for soilless substrate)

## Methods

Full methods are described in the accompanying manuscript. Key methodological choices:

| Parameter | Value | Justification |
|-----------|-------|---------------|
| Functional unit | 1 kg strawberries | Farm gate |
| EF₁ (direct N₂O) | 0.005 | Soilless substrate, aerobic conditions |
| Frac_LEACH | 0.10 | Semi-open drainage fertigation |
| Frac_GASF | 0.02 | CAN + drip fertigation |
| Monte Carlo | 5,000 iterations | Per system-year combination |

## Software

- **SimaPro 9.5** — Primary LCA modelling (SimaPro export files are not included in this repository)
- **R 4.x** — Data processing, visualisation
- **Python 3.x** — Notebook used alongside R for analysis

## License

- **Data**: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- **Code**: [MIT License](LICENSE)




