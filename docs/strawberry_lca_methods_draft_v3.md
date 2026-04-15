# 2. Methods

## 2.1 Goal and scope

The objective of the present study was to quantify the environmental impacts of strawberry (*Fragaria × ananassa*) production under three protected cultivation systems in the United Kingdom: polytunnel (open-sided), heated glasshouse, and non-heated glasshouse. The functional unit was defined as 1 kg of fresh strawberries at the farm gate. The system boundary was determined as cradle-to-farm-gate (Fig. 1), encompassing upstream production of inputs (fertilisers, energy, materials, propagation material), on-farm cultivation, and field emissions, but excluding post-harvest handling, packaging, distribution, and end-of-life treatment of crop residues.

The study was conducted as an attributional life cycle assessment (LCA) in accordance with the ISO 14040/14044 standards (ISO, 2006a, 2006b). When relevant, the study aligned with the European Commission's Product Environmental Footprint (PEF) methodology.

## 2.2 System description and data collection

### 2.2.1 Production systems

Three protected cultivation systems were assessed:

**Polytunnel (open-sided):** Steel-framed structures with polyethylene film covering, open sides for natural ventilation. Plants grown in coir substrate on raised tabletops with drip fertigation. No supplementary heating; season extension achieved through passive solar gain and frost protection.

**Heated glasshouse:** Permanent glass-clad structures with gas-fired heating systems maintaining minimum temperatures during propagation and early cropping. Automated climate control including ventilation, thermal screens, and supplementary lighting where installed. Coir substrate cultivation with recirculating fertigation.

**Non-heated glasshouse:** Glass-clad structures without active heating systems. Climate management through ventilation and thermal screens only. Otherwise similar to heated glasshouse in terms of substrate and irrigation infrastructure.

All systems utilised tabletop production with coir substrate bags, precision fertigation with partial nutrient solution recirculation, and integrated pest management practices typical of commercial UK strawberry production.

### 2.2.2 Data collection

Primary data were collected from a commercial strawberry enterprise in the UK over four production years (2020–2023). The dataset comprised 117 production records: polytunnel (n = 73), heated glasshouse (n = 24), and non-heated glasshouse (n = 20). Each record represented an individual cropping unit (tunnel or glasshouse compartment) with associated inputs and yield data.

Data collected included: marketable yield (kg), cropping area (m²), fertiliser inputs (N, P, K as nutrient mass), crop protection products, substrate quantities, irrigation volumes, and energy consumption (electricity, heating fuel where applicable). Seedling (plug plant) quantities and origins were recorded, with propagation material sourced from specialist nurseries in the Netherlands, Spain, and Italy (Supplementary Table S1).

Background data for upstream processes (fertiliser production, energy generation, substrate manufacture, transport) were obtained from the ecoinvent v3.8 database (Wernet et al., 2016). Transport distances for seedlings were calculated using road freight routing (IMPARGO HGV Route Planner) from nursery locations to the farm.

### 2.2.3 Data aggregation

Production records were stratified by cultivation system and year, yielding 12 system-year combinations. For each stratum, input quantities were aggregated using the median of individual record values, chosen for robustness to outliers in farm data where extreme values may reflect atypical conditions rather than representative practice (Limpert & Stahel, 2011). Land use intensity (m² per kg) was calculated as the ratio of total cropping area to total yield within each stratum, preserving the relationship between area and productivity.

Uncertainty in aggregated values was characterised by the geometric standard deviation squared (GSD²) derived from the observed variability across records within each stratum (Slob, 1994). This approach captures genuine production variability while providing parameters suitable for lognormal distributions in Monte Carlo simulation.

## 2.3 Life cycle inventory

Inventory data were compiled for each of the 12 system-year combinations. Foreground data (farm inputs and yields) were derived from aggregated production records as described in Section 2.2.3. Background processes were modelled using ecoinvent v3.8 allocation at point of substitution.

Nitrogen emissions from fertigation were estimated using an adapted IPCC Tier 2 approach. Direct N₂O emissions were calculated using an emission factor (EF₁) of 0.005 kg N₂O-N per kg N applied, reflecting the aerobic conditions and controlled moisture regime of soilless coir substrate (Karlowsky et al., 2021; Halbert-Howard et al., 2020). This value is lower than the IPCC default for agricultural soils (0.01) due to the fundamentally different biogeochemical conditions in inert substrates with precision fertigation.

Ammonia volatilisation was estimated using a volatilisation fraction (Frac_GASF) of 0.02, based on UK-specific emission factors for calcium ammonium nitrate (Carswell et al., 2025) adjusted for the reduced volatilisation potential of drip fertigation systems delivering nutrients directly to the root zone. Indirect N₂O emissions from volatilised nitrogen were calculated using EF₄ = 0.014 kg N₂O-N per kg NH₃-N (IPCC, 2019).

Nitrogen leaching was modelled using a leaching fraction (Frac_LEACH) of 0.10, reflecting partial recirculation of drainage solution in semi-closed fertigation systems typical of UK commercial practice. This value is substantially lower than the IPCC default (0.24) applicable to open-field agriculture where nitrogen readily leaches below the root zone. Indirect N₂O emissions from leached nitrogen were calculated using EF₅ = 0.011 kg N₂O-N per kg NO₃-N (IPCC, 2019). Detailed parameter values and uncertainty characterisation are provided in Supplementary Table S2.

## 2.4 Life cycle impact assessment

Life cycle impact assessment was conducted using the Environmental Footprint 3.1 method (EC-JRC, 2022), selected for consistency with European Commission Product Environmental Footprint guidelines. Characterisation factors incorporate IPCC AR6 global warming potentials: GWP₁₀₀ = 273 for N₂O and GWP₁₀₀ = 27 for biogenic CH₄ (Forster et al., 2021). Climate change (kg CO₂-eq per kg strawberries) was the primary impact category. Five additional midpoint categories were assessed: acidification (mol H⁺-eq), freshwater eutrophication (kg P-eq), marine eutrophication (kg N-eq), land use (m²a crop-eq), and water use (m³ world-eq deprived). Normalisation and weighting were not applied.

## 2.5 Sensitivity analysis

The sensitivity of climate change results to emission factor assumptions was assessed by varying EF₁ and Frac_LEACH, the parameters with greatest uncertainty when adapting IPCC Tier 1 methodology to soilless substrate systems. Values were varied across plausible ranges derived from soilless cultivation literature and IPCC defaults (Table 1), with all other inventory parameters held constant.

**Table 1.** Sensitivity analysis scenarios for N₂O emission parameters.

| Scenario | Frac_LEACH | EF₁ | Description |
|----------|------------|-----|-------------|
| Coir-adjusted (baseline) | 0.10 | 0.005 | Semi-closed fertigation, aerobic substrate |
| IPCC defaults | 0.24 | 0.010 | Standard Tier 1 field agriculture values |
| IPCC leaching only | 0.24 | 0.005 | High leaching, low direct EF |
| IPCC direct EF only | 0.10 | 0.010 | Low leaching, IPCC direct EF |
| Low estimate | 0.05 | 0.002 | Near-closed system, minimal emissions |
| High estimate | 0.15 | 0.007 | Partial recirculation, intermediate EF |

This analysis tests the robustness of system rankings and the influence of methodological choices on conclusions (Van Stappen et al., 2018).

## 2.6 Uncertainty analysis

Uncertainty in input parameters was characterised using the pedigree matrix approach (Weidema & Wesnæs, 1996), as implemented in ecoinvent v3 (Muller et al., 2016), to derive uncertainty factors for Monte Carlo simulation. Farm input data were assigned lognormal distributions with geometric standard deviations squared (GSD²) derived from observed variability across production records within each system-year stratum. Emission factor parameters were assigned triangular distributions with ranges based on literature values and pedigree assessment (Supplementary Table S2).

Monte Carlo simulation (1,000 iterations) was conducted in SimaPro for each of the 12 system-year combinations, generating probability distributions for climate change impact. Results are presented as medians with interquartile ranges (IQR) and 5th–95th percentile intervals. This approach captures parameter uncertainty but does not account for model structure uncertainty or correlations between input parameters.

### Limitations

Several limitations should be acknowledged:

1. *Site specificity*: Data were collected from a single commercial farm over four production years (2020–2023), which may not fully represent the diversity of UK strawberry production practices. However, the farm operates multiple cultivation systems under consistent management, enabling direct comparison between systems while controlling for site-level confounding factors.

2. *Frac_LEACH uncertainty*: Direct measurement of drainage recirculation rates was not available. The assumed value (0.10) is based on typical UK commercial practice for semi-closed fertigation systems but may not reflect site-specific management. Sensitivity analysis demonstrates that conclusions are robust across the plausible range (0.05–0.24).

3. *Emission factor transferability*: The EF₁ value for soilless substrates is derived from studies on rockwool and NFT systems (Karlowsky et al., 2021; Halbert-Howard et al., 2020). Direct N₂O measurements from coir substrate are limited, though the aerobic conditions and precision fertigation regime are comparable to the systems from which emission factors were derived.

4. *Biowaste treatment exclusion*: End-of-life treatment of crop residues and spent coir substrate was excluded from the system boundary. This is a common simplification in cradle-to-farm-gate LCA studies but may underestimate total life cycle impacts, particularly for substrate disposal.

---

# References

Carswell, A., Sherlock, A., Anthony, S., Sheridan, H., Sheridan, F., & Sherwood, M. (2025). *UK Agriculture Ammonia Emission Report 1990–2021*. Defra Contract C21258. Department for Environment, Food and Rural Affairs, London.

EC-JRC. (2022). *Environmental Footprint 3.1 Reference Package*. European Commission Joint Research Centre. https://eplca.jrc.ec.europa.eu/LCDN/EF_archive.html

Forster, P., Storelvmo, T., Armour, K., Collins, W., Dufresne, J.-L., Frame, D., Lunt, D.J., Mauritsen, T., Palmer, M.D., Watanabe, M., Wild, M., & Zhang, H. (2021). The Earth's energy budget, climate feedbacks, and climate sensitivity. In V. Masson-Delmotte et al. (Eds.), *Climate Change 2021: The Physical Science Basis. Contribution of Working Group I to the Sixth Assessment Report of the Intergovernmental Panel on Climate Change* (pp. 923–1054). Cambridge University Press. https://doi.org/10.1017/9781009157896.009

Galafton, C., Gutowski, V.S., Weber-Blaschke, G., & Richter, K. (2023). Life cycle assessment of different strawberry production methods in Germany with a particular focus on plastic emissions. *The International Journal of Life Cycle Assessment*, 28, 1576–1590. https://doi.org/10.1007/s11367-023-02218-9

Halbert-Howard, A., Häfner, F., Karlowsky, S., Schwarz, D., & Gronauer, A. (2020). Greenhouse gas emissions from hydroponic tomato production in a commercial greenhouse in Germany. *Environmental Science and Pollution Research*, 28, 10461–10473. https://doi.org/10.1007/s11356-020-11241-6

IPCC. (2019). *2019 Refinement to the 2006 IPCC Guidelines for National Greenhouse Gas Inventories*. Volume 4: Agriculture, Forestry and Other Land Use. Intergovernmental Panel on Climate Change, Geneva.

ISO. (2006a). *ISO 14040:2006. Environmental management — Life cycle assessment — Principles and framework*. International Organization for Standardization, Geneva.

ISO. (2006b). *ISO 14044:2006. Environmental management — Life cycle assessment — Requirements and guidelines*. International Organization for Standardization, Geneva.

Karlowsky, S., Gläser, M., Tränkner, M., Gregory, A., 't Lam, G.P., & 't Lam, H.P. (2021). Nitrogen use efficiency of rockwool-grown tomatoes and peppers in a commercial greenhouse. *Frontiers in Sustainable Food Systems*, 5, 626053. https://doi.org/10.3389/fsufs.2021.626053

Limpert, E., & Stahel, W.A. (2011). Problems with using the normal distribution—and ways to improve quality and efficiency of data analysis. *PLoS ONE*, 6(7), e21403. https://doi.org/10.1371/journal.pone.0021403

Muller, S., Lesage, P., Ciroth, A., Mutel, C., Weidema, B.P., & Samson, R. (2016). The application of the pedigree approach to the distributions foreseen in ecoinvent v3. *The International Journal of Life Cycle Assessment*, 21, 1327–1337. https://doi.org/10.1007/s11367-014-0759-5

Slob, W. (1994). Uncertainty analysis in multiplicative models. *Risk Analysis*, 14, 571–576. https://doi.org/10.1111/j.1539-6924.1994.tb00271.x

Van Stappen, F., Mathot, M., Loriers, A., Delcour, A., Stil, V., Crahay, S., Associés, A., Crahay, B., & Bielders, C. (2018). Sensitive parameters in local agricultural life cycle assessments: the illustrative case of cereal production in Wallonia, Belgium. *The International Journal of Life Cycle Assessment*, 23, 2286–2302. https://doi.org/10.1007/s11367-018-1449-y

Weidema, B.P., & Wesnæs, M.S. (1996). Data quality management for life cycle inventories—an example of using data quality indicators. *Journal of Cleaner Production*, 4, 167–174. https://doi.org/10.1016/S0959-6526(96)00043-1

Wernet, G., Bauer, C., Steubing, B., Reinhard, J., Moreno-Ruiz, E., & Weidema, B. (2016). The ecoinvent database version 3 (part I): overview and methodology. *The International Journal of Life Cycle Assessment*, 21, 1218–1230. https://doi.org/10.1007/s11367-016-1087-8
