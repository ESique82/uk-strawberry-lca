# =============================================================================
# UK Strawberry LCA — Monte Carlo Results Visualisation
# =============================================================================
# Project:  Cradle-to-farm-gate LCA of UK strawberry production
#           Systems: Polytunnel (PT), Heated Glasshouse (HG),
#                    Non-heated Glasshouse (NG)
# Data:     MC_All_Systems_Consolidated.csv
#           (12 system-year combinations x 28 impact categories, EF 3.1)
# Date:     April 2026
# Status:   Work in progress — pre-submission review version
# =============================================================================


# 0. LOADING PACKAGES


required_packages <- c("tidyverse", "ggplot2", "patchwork", "scales", "ggrepel")

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
invisible(lapply(required_packages, install_if_missing))

library(tidyverse)
library(ggplot2)
library(patchwork)
library(scales)
library(ggrepel)


# -----------------------------------------------------------------------------
# 1. GLOBAL THEME
# -----------------------------------------------------------------------------

theme_lca <- theme_minimal(base_size = 11) +
  theme(
    panel.border    = element_rect(fill = NA, colour = "grey70", linewidth = 0.5),
    strip.background = element_rect(fill = "grey95", colour = "grey70"),
    legend.position = "right",
    plot.title      = element_text(face = "bold", size = 12),
    plot.subtitle   = element_text(colour = "grey40", size = 10),
    axis.text.x     = element_text(angle = 15, hjust = 1)
  )

theme_set(theme_lca)

# Consistent, colourblind-friendly palette
system_colours <- c(
  "Heated Glasshouse"     = "#D55E00",
  "Non-heated Glasshouse" = "#0072B2",
  "Polytunnel"            = "#009E73"
)


# -----------------------------------------------------------------------------
# 2. LOAD DATA
# -----------------------------------------------------------------------------

mc_data <- read.csv("MC_All_Systems_Consolidated.csv", stringsAsFactors = FALSE)

# Basic validation — stops early with a clear message if columns are missing
required_cols <- c("System", "Year", "Impact_Category", "Unit",
                   "Mean", "Median", "SD", "CV", "CI_Lower_95", "CI_Upper_95")
missing_cols <- setdiff(required_cols, names(mc_data))
if (length(missing_cols) > 0) {
  stop("Missing columns in CSV: ", paste(missing_cols, collapse = ", "))
}

cat("Data loaded:", nrow(mc_data), "rows\n")
cat("Systems:    ", paste(unique(mc_data$System), collapse = ", "), "\n")
cat("Years:      ", paste(sort(unique(mc_data$Year)), collapse = ", "), "\n")
cat("Categories: ", length(unique(mc_data$Impact_Category)), "\n\n")

# Ordered factor — controls plot order throughout
mc_data <- mc_data %>%
  mutate(
    System = factor(System, levels = c("Polytunnel",
                                       "Non-heated Glasshouse",
                                       "Heated Glasshouse")),
    Year = as.integer(Year)
  )

mc_data <- mc_data %>%
  filter(
    Impact_Category != "",
    !is.na(Impact_Category),
    !str_starts(Impact_Category, "Confidence")
  ) %>%
  mutate(Impact_Category = str_trim(Impact_Category),
         Unit = str_trim(Unit))

mc_data %>% distinct(System_Code, System)
# =============================================================================
# SECTION A — GLOBAL WARMING POTENTIAL (GWP100)
# =============================================================================

gwp <- mc_data %>%
  filter(Impact_Category == "Climate change - Fossil")


# --- Table 1: All system x year combinations (supplementary) ----------------

table_1 <- gwp %>%
  select(System, Year, Mean, Median, SD, CV, CI_Lower_95, CI_Upper_95) %>%
  mutate(across(where(is.numeric), \(x) round(x, 3))) %>%
  arrange(System, Year)

print(table_1)
write.csv(table_1, "Table_1_GWP_All_SystemYears.csv", row.names = FALSE)

mc_data %>% distinct(System_Code, System)
# --- Table 2: System summary pooled across years ----------------------------

table_2 <- gwp %>%
  group_by(System) %>%
  summarise(
    N_years       = n(),
    Mean_GWP      = mean(Mean),
    SD_across_yrs = sd(Mean),
    Min_GWP       = min(Mean),
    Max_GWP       = max(Mean),
    Avg_CV        = mean(CV),
    Avg_CI_Lower  = mean(CI_Lower_95),
    Avg_CI_Upper  = mean(CI_Upper_95),
    .groups       = "drop"
  ) %>%
  mutate(across(where(is.double), \(x) round(x, 3))) %>%
  arrange(desc(Mean_GWP))

print(table_2)
write.csv(table_2, "Table_2_GWP_SystemSummary.csv", row.names = FALSE)

unique(mc_data$System)

#str(mc_data)
# --- Table 3: % reduction vs heated glasshouse (key result) -----------------

baseline_gwp <- table_2 %>%
  filter(System == "Heated Glasshouse") %>%
  pull(Mean_GWP)

table_3 <- table_2 %>%
  mutate(
    Reduction_pct = round((1 - Mean_GWP / baseline_gwp) * 100, 1),
    Reduction_abs = round(baseline_gwp - Mean_GWP, 3)
  ) %>%
  select(System, Mean_GWP, Avg_CV, Reduction_pct, Reduction_abs)

print(table_3)
write.csv(table_3, "Table_3_GWP_EnvironmentalBenefit.csv", row.names = FALSE)


# --- Figure 1: Faceted time series with 95% CI ribbons ----------------------

figure_1 <- gwp %>%
  ggplot(aes(x = Year, y = Mean, colour = System, fill = System)) +
  geom_ribbon(aes(ymin = CI_Lower_95, ymax = CI_Upper_95),
              alpha = 0.2, colour = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 3, shape = 21, colour = "white", stroke = 1.5) +
  scale_colour_manual(values = system_colours, guide = "none") +
  scale_fill_manual(values = system_colours, guide = "none") +
  scale_x_continuous(breaks = 2020:2023) +
  facet_wrap(~ System, ncol = 3) +
  labs(
    title    = "Global Warming Potential (GWP100) by growing system, 2020-2023",
    subtitle = "Points = annual mean; ribbons = 95% CI (Monte Carlo, 1,000 iterations)",
    x        = "Year",
    y        = expression(GWP ~ (kg ~ CO[2]*"-eq" ~ kg^{-1} ~ "fresh strawberries"))
  )

figure_1
ggsave("Figure_1_GWP_TimeSeries.pdf", figure_1, width = 10, height = 4.5, dpi = 300)
ggsave("Figure_1_GWP_TimeSeries.png", figure_1, width = 10, height = 4.5, dpi = 300)


# --- Figure 2: Bar chart — pooled means with 95% CI -------------------------

figure_2 <- table_2 %>%
  ggplot(aes(x = reorder(System, -Mean_GWP), y = Mean_GWP, fill = System)) +
  geom_col(colour = "black", alpha = 0.75, linewidth = 0.6) +
  geom_errorbar(aes(ymin = Avg_CI_Lower, ymax = Avg_CI_Upper),
                width = 0.15, colour = "black", linewidth = 0.8) +
  geom_text(aes(label = sprintf("%.3f", Mean_GWP)),
            hjust = -1, vjust = -.3, size = 3.5) +         
  scale_fill_manual(values = system_colours, guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Mean GWP100 by growing system (pooled 2020-2023)",
    subtitle = "Error bars = 95% CI; values in kg CO2-eq / kg fresh strawberries",
    x        = NULL,
    y        = expression(GWP ~ (kg ~ CO[2]*"-eq" ~ kg^{-1}))
  )

figure_2
ggsave("Figure_2_GWP_BarChart.pdf", figure_2, width = 7, height = 5, dpi = 300)
ggsave("Figure_2_GWP_BarChart.png", figure_2, width = 7, height = 5, dpi = 300)


# --- Figure 3: Coefficient of variation (uncertainty / data quality) ---------

figure_3 <- gwp %>%
  ggplot(aes(x = System, y = CV, colour = System)) +
  geom_boxplot(alpha = 0.6, linewidth = 0.7,
               outlier.shape = NA) +
  geom_jitter(aes(shape = factor(Year)), width = 0.15, size = 3, alpha = 0.8) +
  scale_fill_manual(values = system_colours, guide = "none") +
  scale_shape_manual(values = c(21, 22, 23, 24), name = "Year") +
  labs(
    title    = "Monte Carlo uncertainty: coefficient of variation by system",
    subtitle = "Lower CV = more consistent results across iterations",
    x        = NULL,
    y        = "Coefficient of Variation (CV)"
  )

figure_3
ggsave("Figure_3_GWP_Uncertainty.pdf", figure_3, width = 7, height = 5, dpi = 300)
ggsave("Figure_3_GWP_Uncertainty.png", figure_3, width = 7, height = 5, dpi = 300)


# =============================================================================
# SECTION B — ALL 28 IMPACT CATEGORIES
# =============================================================================

# Priority categories for protected horticulture under EF 3.1
# NOTE: these strings must match exactly what SimaPro exported.
# Run the diagnostic below if any are missing.
priority_categories <- c(
  "Climate change",
  "Acidification",
  "Eutrophication, freshwater",
  "Eutrophication, marine",
  "Eutrophication, terrestrial",
  "Land use",
  "Water use"
)

# Diagnostic: which priority categories are actually in the data?
cat("\nPriority categories found in data:\n")
mc_data %>%
  filter(Impact_Category %in% priority_categories) %>%
  distinct(Impact_Category, Unit) %>%
  print()

cat("\nAll categories in data:\n")
mc_data %>%
  distinct(Impact_Category, Unit) %>%
  arrange(Impact_Category) %>%
  print()


mc_data %>% 
  distinct(Impact_Category) %>% 
  filter(str_detect(Impact_Category, 
                    "Eutro|Acid|Water|Land|Human|Climate change$"))
# --- Table 4: All categories, system means pooled across years ---------------

table_4 <- mc_data %>% filter(Impact_Category != "") %>% 
  group_by(System, Impact_Category, Unit) %>%
  summarise(
    Mean_pooled  = mean(Mean),
    SD_pooled    = sd(Mean),
    Avg_CV       = mean(CV),
    Avg_CI_Lower = mean(CI_Lower_95),
    Avg_CI_Upper = mean(CI_Upper_95),
    .groups      = "drop"
  ) %>%
  mutate(across(where(is.double), \(x) round(x, 4))) %>%
  arrange(Impact_Category, System)

write.csv(table_4, "Table_4_AllImpacts_SystemSummary.csv", row.names = FALSE)
cat("Table 4 saved:", nrow(table_4), "rows\n")


# --- Table 5: % reduction vs HG, all categories -----------------------------

table_5 <- table_4 %>%
  select(System, Impact_Category, Unit, Mean_pooled) %>%
  pivot_wider(names_from = System, values_from = Mean_pooled) %>%
  mutate(
    PT_vs_HG_pct = round((1 - Polytunnel / `Heated Glasshouse`) * 100, 1),
    NG_vs_HG_pct = round((1 - `Non-heated Glasshouse` / `Heated Glasshouse`) * 100, 1),
    PT_vs_NG_pct = round((1 - Polytunnel / `Non-heated Glasshouse`) * 100, 1)
  ) %>%
  arrange(Impact_Category)

write.csv(table_5, "Table_5_AllImpacts_RelativeComparison.csv", row.names = FALSE)
cat("Table 5 saved:", nrow(table_5), "rows\n")


# --- Figure 4: Multi-impact bar chart, normalised to HG = 1 -----------------

# Short labels for axis
label_map <- c(
  "Climate change"              = "GWP (Climate change)",
  "Acidification"               = "Acidification",
  "Eutrophication, freshwater"  = "Eutro. freshwater",
  "Eutrophication, marine"      = "Eutro. marine",
  "Eutrophication, terrestrial" = "Eutro. terrestrial",
  "Land use"                    = "Land use",
  "Water use"                   = "Water use"
)

multi_norm <- table_4 %>% filter(!is.na(Impact_Category), Impact_Category != "") %>% 
  filter(Impact_Category %in% priority_categories) %>%
  group_by(Impact_Category) %>%
  mutate(
    HG_mean       = Mean_pooled[System == "Heated Glasshouse"],
    Mean_norm     = Mean_pooled / HG_mean,
    CI_Lower_norm = Avg_CI_Lower / HG_mean,
    CI_Upper_norm = Avg_CI_Upper / HG_mean,
    Cat_label     = label_map[Impact_Category]
  ) %>%
  ungroup()

multi_norm$Cat_label

figure_4 <- multi_norm %>%
  ggplot(aes(x = Cat_label, y = Mean_norm, fill = System)) +
  geom_col(position = position_dodge(width = 0.8),
           colour = "black", alpha = 0.75, linewidth = 0.4, width = 0.75) +
  geom_errorbar(aes(ymin = CI_Lower_norm, ymax = CI_Upper_norm),
                position = position_dodge(width = 0.8),
                width = 0.2, linewidth = 0.6) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey40") +
  scale_fill_manual(values = system_colours, name = "System") +
  coord_flip(ylim = c(0, 2.5)) +
  labs(
    title    = "Relative environmental performance across EF 3.1 priority categories",
    subtitle = "Normalised to Heated Glasshouse = 1.0 (dashed); lower = better",
    x        = NULL,
    y        = "Impact relative to heated glasshouse",
    caption  = "Error bars = 95% CI. Some CI upper bounds exceed axis limit — see Table 5 for full values."
  ) +
  theme(legend.position = "bottom",
        axis.text.x     = element_text(angle = 0, hjust = 0.5))

figure_4
ggsave("Figure_4_MultiImpact_Normalised.pdf", figure_4, width = 10, height = 6, dpi = 300)
ggsave("Figure_4_MultiImpact_Normalised.png", figure_4, width = 10, height = 6, dpi = 300)

mc_data %>%
  filter(Impact_Category == "Eutrophication, freshwater") %>%
  select(System, Year, Mean, CV, CI_Lower_95, CI_Upper_95)
# --- Figure 5: Eutrophication time series (all three types) ------------------

eutro_cats <- c("Eutrophication, freshwater",
                "Eutrophication, marine",
                "Eutrophication, terrestrial")

eutro_data <- mc_data %>%
  filter(Impact_Category %in% eutro_cats) %>%
  mutate(Cat_label = recode(Impact_Category,
                            "Eutrophication, freshwater"  = "Freshwater eutrophication",
                            "Eutrophication, marine"      = "Marine eutrophication",
                            "Eutrophication, terrestrial" = "Terrestrial eutrophication"
  ))

figure_5 <- eutro_data %>%
  ggplot(aes(x = Year, y = Mean, colour = System, fill = System)) +
  geom_ribbon(aes(ymin = CI_Lower_95, ymax = CI_Upper_95),
              alpha = 0.2, colour = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.5, shape = 21, colour = "white", stroke = 1.2) +
  scale_colour_manual(values = system_colours) +
  scale_fill_manual(values = system_colours) +
  scale_x_continuous(breaks = 2020:2023) +
  facet_grid(Cat_label ~ System, scales = "free_y") +
  labs(
    title    = "Eutrophication potential by type and growing system, 2020-2023",
    subtitle = "Ribbons = 95% CI; y-axes free (units differ between eutrophication types)",
    x        = "Year",
    y        = "Impact (units vary — see Table 4)"
  ) +
  theme(
    legend.position = "none",
    strip.text.y    = element_text(angle = 0, hjust = 0)
  )

figure_5
ggsave("Figure_5_Eutrophication_TimeSeries.pdf", figure_5,
       width = 11, height = 7, dpi = 300)
ggsave("Figure_5_Eutrophication_TimeSeries.png", figure_5,
       width = 11, height = 7, dpi = 300)


# =============================================================================
# SECTION C — COLLECT ALL OUTPUTS INTO ONE FOLDER
# =============================================================================

dir.create("LCA_Publication_Outputs", showWarnings = FALSE)

all_outputs <- c(
  "Table_1_GWP_All_SystemYears.csv",
  "Table_2_GWP_SystemSummary.csv",
  "Table_3_GWP_EnvironmentalBenefit.csv",
  "Table_4_AllImpacts_SystemSummary.csv",
  "Table_5_AllImpacts_RelativeComparison.csv",
  "Figure_1_GWP_TimeSeries.pdf",
  "Figure_1_GWP_TimeSeries.png",
  "Figure_2_GWP_BarChart.pdf",
  "Figure_2_GWP_BarChart.png",
  "Figure_3_GWP_Uncertainty.pdf",
  "Figure_3_GWP_Uncertainty.png",
  "Figure_4_MultiImpact_Normalised.pdf",
  "Figure_4_MultiImpact_Normalised.png",
  "Figure_5_Eutrophication_TimeSeries.pdf",
  "Figure_5_Eutrophication_TimeSeries.png"
)

existing <- all_outputs[file.exists(all_outputs)]
file.copy(existing,
          file.path("LCA_Publication_Outputs", basename(existing)),
          overwrite = TRUE)

cat("\n=== Output summary ===\n")
cat("Saved to LCA_Publication_Outputs/:\n")
cat(paste0("  ", basename(existing), "\n"), sep = "")

not_generated <- setdiff(all_outputs, existing)
if (length(not_generated) > 0) {
  cat("\nNot yet generated (run the relevant section above):\n")
  cat(paste0("  ", basename(not_generated), "\n"), sep = "")
}

