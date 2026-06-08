# =============================================================================
# UK Strawberry LCA — Monte Carlo Results Visualisation
# =============================================================================
# Project:  Cradle-to-farm-gate LCA of UK strawberry production
#           Systems: Polytunnel (PT), Heated Glasshouse (HG),
#                    Non-heated Glasshouse (NHG)
# Data:     12 SimaPro Monte Carlo XLSX outputs (5,000 iterations each)
#           Corrected files used for PT 2021 and PT 2022 (plastic process fix)
# Authors:  Eric Siqueros, Graham McAuliffe
# Date:     June 2026
# =============================================================================


# =============================================================================
# 0.  PACKAGES
# =============================================================================

required_packages <- c("readxl", "tidyverse", "ggplot2",
                        "patchwork", "scales", "ggrepel")

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
invisible(lapply(required_packages, install_if_missing))

library(readxl)
library(tidyverse)
library(ggplot2)
library(patchwork)
library(scales)
library(ggrepel)


# =============================================================================
# 1.  DATA LOADING — reads directly from SimaPro XLSX exports
# =============================================================================
# Set data_dir to the folder containing the XLSX files.
# If your R project (.Rproj) is in the same folder as the files, use ".".
# If the files are one level up (e.g. project is inside a subfolder), use "..".

data_dir <- ".."   # <-- adjust if needed

# File list — PT 2021 and PT 2022 use corrected files (plastic process fix)
mc_files <- list(
  PT  = list(
    `2020` = file.path(data_dir, "MC_green_2020.XLSX"),
    `2021` = file.path(data_dir, "greenhouse_MC_corr.XLSX"),  # corrected
    `2022` = file.path(data_dir, "2022MC_corr.XLSX"),         # corrected
    `2023` = file.path(data_dir, "MC_green_2023.XLSX")
  ),
  NHG = list(
    `2020` = file.path(data_dir, "MC_glass_non_2020.XLSX"),
    `2021` = file.path(data_dir, "MC_glass_non_2021.XLSX"),
    `2022` = file.path(data_dir, "MC_glass_non_2022.XLSX"),
    `2023` = file.path(data_dir, "MC_glass_non_2023.XLSX")
  ),
  HG  = list(
    `2020` = file.path(data_dir, "MC_glass_2020.XLSX"),
    `2021` = file.path(data_dir, "MC_glass_2021.XLSX"),
    `2022` = file.path(data_dir, "MC_glass_2022.XLSX"),
    `2023` = file.path(data_dir, "MC_glass_2023.XLSX")
  )
)

# Maps short code → full system name used throughout figures
system_name_map <- c(
  PT  = "Polytunnel",
  NHG = "Non-heated glasshouse",
  HG  = "Heated glasshouse"
)

read_mc_xlsx <- function(path, system_code, year) {
  raw <- read_excel(path, skip = 6, col_names = TRUE)
  colnames(raw) <- c("Impact_Category", "Unit", "Mean", "Median",
                     "SD", "CV", "CI_Lower_95", "CI_Upper_95", "SEM")
  raw %>%
    filter(!is.na(Impact_Category),
           !Impact_Category %in% c("Impact category",
                                   "Confidence interval:", "NA")) %>%
    mutate(
      across(c(Mean, CI_Lower_95, CI_Upper_95, CV), as.numeric),
      Impact_Category = str_trim(Impact_Category),
      Unit            = str_trim(Unit),
      System_Code     = system_code,
      System          = system_name_map[[system_code]],
      Year            = as.integer(year)
    )
}

mc_raw <- map_dfr(names(mc_files), function(sys) {
  map_dfr(names(mc_files[[sys]]), function(yr) {
    read_mc_xlsx(mc_files[[sys]][[yr]], sys, yr)
  })
})

# Categories to retain (8 key EF 3.1 midpoint categories)
keep_cats <- c(
  "Climate change",
  "Eutrophication, marine",
  "Eutrophication, terrestrial",
  "Eutrophication, freshwater",
  "Acidification",
  "Water use",
  "Resource use, fossils",
  "Land use"
)

mc_data <- mc_raw %>%
  filter(Impact_Category %in% keep_cats) %>%
  mutate(
    System = factor(System,
                    levels = c("Polytunnel",
                               "Non-heated glasshouse",
                               "Heated glasshouse")),
    System_Code = factor(System_Code, levels = c("PT", "NHG", "HG")),
    Year = as.integer(Year)
  )

cat("Data loaded:", nrow(mc_data), "rows\n")
cat("Systems:    ", paste(levels(mc_data$System), collapse = ", "), "\n")
cat("Years:      ", paste(sort(unique(mc_data$Year)), collapse = ", "), "\n")
cat("Categories: ", length(unique(mc_data$Impact_Category)), "\n\n")


# =============================================================================
# 2.  GLOBAL AESTHETICS
# =============================================================================

# Colourblind-friendly palette — consistent across all figures
system_colours <- c(
  "Polytunnel"            = "#2D9E6B",
  "Non-heated glasshouse" = "#5B6EAD",
  "Heated glasshouse"     = "#D4721A"
)

system_colours_code <- c(PT = "#2D9E6B", NHG = "#5B6EAD", HG = "#D4721A")

theme_lca <- function(base_size = 9) {
  theme_classic(base_size = base_size) +
    theme(
      axis.line        = element_line(linewidth = 0.4, colour = "#444444"),
      axis.ticks       = element_line(linewidth = 0.4, colour = "#444444"),
      axis.text        = element_text(size = 8,   colour = "#333333"),
      axis.title       = element_text(size = 9,   colour = "#222222"),
      plot.title       = element_text(size = 10,  face = "bold",
                                      colour = "#111111", margin = margin(b = 4)),
      plot.subtitle    = element_text(size = 8,   colour = "#666666",
                                      margin = margin(b = 6)),
      panel.grid.major.y = element_line(colour = "#e8e8e8", linewidth = 0.3),
      panel.grid.major.x = element_blank(),
      strip.background = element_rect(fill = "#f5f5f5", colour = "#cccccc",
                                      linewidth = 0.4),
      strip.text       = element_text(size = 8.5, face = "bold"),
      legend.text      = element_text(size = 8),
      legend.title     = element_blank(),
      legend.key.size  = unit(0.4, "cm")
    )
}


# =============================================================================
# SECTION A — CLIMATE CHANGE
# =============================================================================

gwp <- mc_data %>% filter(Impact_Category == "Climate change")

# --- Table 1: Year-by-year results ------------------------------------------
table_1 <- gwp %>%
  select(System, Year, Mean, Median, SD, CV, CI_Lower_95, CI_Upper_95) %>%
  mutate(across(where(is.numeric), \(x) round(x, 3))) %>%
  arrange(System, Year)
write.csv(table_1, "Table_1_ClimateChange_AllYears.csv", row.names = FALSE)
cat("Table 1 saved\n")

# --- Table 2: Pooled system summary -----------------------------------------
table_2 <- gwp %>%
  group_by(System) %>%
  summarise(
    N_years       = n(),
    Mean_pooled   = mean(Mean),
    SD_across_yrs = sd(Mean),
    Min_year      = min(Mean),
    Max_year      = max(Mean),
    Avg_CV        = mean(CV),
    Avg_CI_Lower  = mean(CI_Lower_95),
    Avg_CI_Upper  = mean(CI_Upper_95),
    .groups = "drop"
  ) %>%
  mutate(across(where(is.double), \(x) round(x, 3))) %>%
  arrange(Mean_pooled)
write.csv(table_2, "Table_2_ClimateChange_SystemSummary.csv", row.names = FALSE)
cat("Table 2 saved\n")

# --- Figure 1: Climate change — annual trend, line + CI ribbon ---------------
figure_1 <- gwp %>%
  ggplot(aes(x = Year, y = Mean, colour = System, fill = System)) +
  geom_ribbon(aes(ymin = CI_Lower_95, ymax = CI_Upper_95),
              alpha = 0.15, colour = NA) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.8, shape = 21, colour = "white", stroke = 1.4) +
  scale_colour_manual(values = system_colours) +
  scale_fill_manual(values = system_colours) +
  scale_x_continuous(breaks = 2020:2023) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)), limits = c(0, NA)) +
  labs(
    title    = "Climate change impact by growing system, 2020\u20132023",
    subtitle = "Mean \u00b1 95% CI (Monte Carlo, 5,000 iterations per system-year)",
    x        = "Production year",
    y        = expression(kg~CO[2]*"-eq"~kg^{-1}~"fresh strawberries")
  ) +
  theme_lca() +
  theme(legend.position = c(0.02, 0.97),
        legend.justification = c(0, 1),
        legend.background = element_blank())

ggsave("Figure_1_ClimateChange_Trend.pdf", figure_1,
       width = 120, height = 80, units = "mm", device = cairo_pdf)
ggsave("Figure_1_ClimateChange_Trend.png", figure_1,
       width = 120, height = 80, units = "mm", dpi = 300)
cat("Figure 1 saved\n")


# =============================================================================
# SECTION B — SIX KEY IMPACT CATEGORIES (annual, bar + CI)
# =============================================================================

fig2_cats <- c(
  "Climate change"              = "Climate change",
  "Eutrophication, marine"      = "Marine eutrophication",
  "Eutrophication, terrestrial" = "Terrestrial eutrophication",
  "Acidification"               = "Acidification",
  "Resource use, fossils"       = "Fossil resource use",
  "Water use"                   = "Water use"
)

fig2_units <- c(
  "Climate change"              = "kg CO\u2082-eq kg\u207b\u00b9",
  "Eutrophication, marine"      = "kg N-eq kg\u207b\u00b9",
  "Eutrophication, terrestrial" = "mol N-eq kg\u207b\u00b9",
  "Acidification"               = "mol H\u207a-eq kg\u207b\u00b9",
  "Resource use, fossils"       = "MJ kg\u207b\u00b9",
  "Water use"                   = "m\u00b3 depriv. kg\u207b\u00b9"
)

panel_labels <- c("(a)", "(b)", "(c)", "(d)", "(e)", "(f)")

fig2_panels <- imap(names(fig2_cats), function(cat, idx) {
  mc_data %>%
    filter(Impact_Category == cat) %>%
    ggplot(aes(x = factor(Year), y = Mean,
               fill = System, colour = System)) +
    geom_col(position = position_dodge(width = 0.72),
             width = 0.68, alpha = 0.88, linewidth = 0.3) +
    geom_errorbar(
      aes(ymin = CI_Lower_95, ymax = CI_Upper_95),
      position = position_dodge(width = 0.72),
      width = 0.18, linewidth = 0.5, colour = "#333333"
    ) +
    scale_fill_manual(values   = system_colours, labels = names(system_colours)) +
    scale_colour_manual(values = system_colours, labels = names(system_colours)) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
    labs(
      title = fig2_cats[[cat]],
      x     = NULL,
      y     = fig2_units[[cat]]
    ) +
    annotate("text", x = -Inf, y = Inf, label = panel_labels[idx],
             hjust = -0.3, vjust = 1.5, fontface = "bold", size = 3.2) +
    theme_lca() +
    theme(legend.position = "none")
})

figure_2 <- wrap_plots(fig2_panels, ncol = 3) +
  plot_layout(guides = "collect") &
  theme(
    legend.position  = "bottom",
    legend.direction = "horizontal",
    legend.margin    = margin(t = 4)
  )

ggsave("Figure_2_SixCategories_Annual.pdf", figure_2,
       width = 178, height = 120, units = "mm", device = cairo_pdf)
ggsave("Figure_2_SixCategories_Annual.png", figure_2,
       width = 178, height = 120, units = "mm", dpi = 300)
cat("Figure 2 saved\n")


# =============================================================================
# SECTION C — MARINE EUTROPHICATION vs NITROGEN APPLICATION
# =============================================================================
# Key finding: polytunnel has highest marine EU despite lowest N application.
# Driven by semi-open fertigation drainage, not nitrogen intensity.

marine_pooled <- mc_data %>%
  filter(Impact_Category == "Eutrophication, marine") %>%
  group_by(System) %>%
  summarise(
    pooled_mean = mean(Mean),
    lo          = min(Mean),
    hi          = max(Mean),
    .groups = "drop"
  )

# N application data from inventory (g N per kg fruit, median annual range)
n_inventory <- tibble(
  System  = factor(c("Polytunnel", "Non-heated glasshouse", "Heated glasshouse"),
                   levels = levels(mc_data$System)),
  n_mid = c(15.0, 35.5, 62.5),
  n_lo  = c(13.0, 28.0, 46.0),
  n_hi  = c(17.0, 43.0, 79.0)
)

p_marine <- marine_pooled %>%
  ggplot(aes(x = System, y = pooled_mean, fill = System)) +
  geom_col(width = 0.55, alpha = 0.88, linewidth = 0.3) +
  geom_errorbar(aes(ymin = lo, ymax = hi),
                width = 0.18, linewidth = 0.6, colour = "#333333") +
  scale_fill_manual(values = system_colours) +
  scale_x_discrete(labels = c("Polytunnel\n(unheated)",
                               "Non-heated\nglasshouse",
                               "Heated\nglasshouse")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08)),
                     labels = label_scientific(digits = 2)) +
  labs(title = "Marine eutrophication",
       x = NULL,
       y = "kg N-eq kg\u207b\u00b9 fruit") +
  annotate("text", x = -Inf, y = Inf, label = "(a)",
           hjust = -0.4, vjust = 1.6, fontface = "bold", size = 3.2) +
  theme_lca() +
  theme(legend.position = "none")

p_nitrogen <- n_inventory %>%
  ggplot(aes(x = System, y = n_mid, fill = System)) +
  geom_col(width = 0.55, alpha = 0.88, linewidth = 0.3) +
  geom_errorbar(aes(ymin = n_lo, ymax = n_hi),
                width = 0.18, linewidth = 0.6, colour = "#333333") +
  scale_fill_manual(values = system_colours) +
  scale_x_discrete(labels = c("Polytunnel\n(unheated)",
                               "Non-heated\nglasshouse",
                               "Heated\nglasshouse")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "Nitrogen application",
       x = NULL,
       y = "g N kg\u207b\u00b9 fruit") +
  annotate("text", x = -Inf, y = Inf, label = "(b)",
           hjust = -0.4, vjust = 1.6, fontface = "bold", size = 3.2) +
  theme_lca() +
  theme(legend.position = "none")

figure_3 <- p_marine + p_nitrogen +
  plot_annotation(
    subtitle = paste0("Marine eutrophication is highest for the polytunnel despite\n",
                      "lowest nitrogen application \u2014 driven by semi-open drainage,\n",
                      "not nitrogen intensity. Error bars = annual range.")
  ) &
  theme(plot.subtitle = element_text(size = 7.5, colour = "#555555"))

ggsave("Figure_3_MarineEU_vs_Nitrogen.pdf", figure_3,
       width = 130, height = 80, units = "mm", device = cairo_pdf)
ggsave("Figure_3_MarineEU_vs_Nitrogen.png", figure_3,
       width = 130, height = 80, units = "mm", dpi = 300)
cat("Figure 3 saved\n")


# =============================================================================
# SECTION D — NORMALISED MULTI-CATEGORY COMPARISON
# =============================================================================

norm_cats <- c(
  "Climate change"              = "Climate change",
  "Eutrophication, terrestrial" = "Terrestrial eutrophication",
  "Acidification"               = "Acidification",
  "Resource use, fossils"       = "Fossil resource use",
  "Land use"                    = "Land use",
  "Water use"                   = "Water use",
  "Eutrophication, marine"      = "Marine eutrophication"
)

norm_data <- mc_data %>%
  filter(Impact_Category %in% names(norm_cats)) %>%
  group_by(Impact_Category, System) %>%
  summarise(pooled_mean = mean(Mean), .groups = "drop") %>%
  group_by(Impact_Category) %>%
  mutate(rel = pooled_mean / max(pooled_mean)) %>%
  ungroup() %>%
  mutate(
    cat_label = factor(norm_cats[Impact_Category],
                       levels = rev(unname(norm_cats)))
  )

figure_4 <- norm_data %>%
  ggplot(aes(x = rel, y = cat_label, fill = System)) +
  geom_col(
    position = position_dodge(width = 0.68),
    width = 0.62, alpha = 0.88, linewidth = 0.3
  ) +
  geom_vline(xintercept = 1, linetype = "dashed",
             colour = "#888888", linewidth = 0.5) +
  scale_fill_manual(values = system_colours) +
  scale_x_continuous(
    limits = c(0, 1.22),
    expand = expansion(mult = c(0, 0)),
    labels = label_number(accuracy = 0.1)
  ) +
  labs(
    title    = "Relative environmental performance across impact categories",
    subtitle = "Pooled means normalised to highest value = 1.0 (dashed line). Lower = better.",
    x        = "Relative impact (1.0 = highest value across systems)",
    y        = NULL
  ) +
  theme_lca() +
  theme(
    panel.grid.major.x = element_line(colour = "#e8e8e8", linewidth = 0.3),
    panel.grid.major.y = element_blank(),
    legend.position    = "bottom",
    legend.direction   = "horizontal"
  )

ggsave("Figure_4_Normalised_Comparison.pdf", figure_4,
       width = 148, height = 100, units = "mm", device = cairo_pdf)
ggsave("Figure_4_Normalised_Comparison.png", figure_4,
       width = 148, height = 100, units = "mm", dpi = 300)
cat("Figure 4 saved\n")


# =============================================================================
# SECTION E — SUMMARY TABLES (all categories)
# =============================================================================

table_3 <- mc_data %>%
  group_by(System, Impact_Category, Unit) %>%
  summarise(
    Mean_pooled  = mean(Mean),
    Min_year     = min(Mean),
    Max_year     = max(Mean),
    Avg_CV       = mean(CV),
    Avg_CI_Lower = mean(CI_Lower_95),
    Avg_CI_Upper = mean(CI_Upper_95),
    .groups = "drop"
  ) %>%
  mutate(across(where(is.double), \(x) round(x, 5))) %>%
  arrange(Impact_Category, System)
write.csv(table_3, "Table_3_AllCategories_Pooled.csv", row.names = FALSE)
cat("Table 3 saved:", nrow(table_3), "rows\n")

# Relative comparison table (PT vs HG, NHG vs HG)
table_4 <- table_3 %>%
  select(System, Impact_Category, Unit, Mean_pooled) %>%
  pivot_wider(names_from = System, values_from = Mean_pooled) %>%
  rename(PT = Polytunnel, NHG = `Non-heated glasshouse`, HG = `Heated glasshouse`) %>%
  mutate(
    PT_vs_HG_pct  = round((1 - PT  / HG) * 100, 1),
    NHG_vs_HG_pct = round((1 - NHG / HG) * 100, 1),
    PT_vs_NHG_pct = round((1 - PT  / NHG) * 100, 1)
  ) %>%
  arrange(Impact_Category)
write.csv(table_4, "Table_4_RelativeComparison.csv", row.names = FALSE)
cat("Table 4 saved\n")


# =============================================================================
# SECTION F — COLLECT OUTPUTS
# =============================================================================

dir.create("LCA_Publication_Outputs", showWarnings = FALSE)

all_outputs <- c(
  "Table_1_ClimateChange_AllYears.csv",
  "Table_2_ClimateChange_SystemSummary.csv",
  "Table_3_AllCategories_Pooled.csv",
  "Table_4_RelativeComparison.csv",
  "Figure_1_ClimateChange_Trend.pdf",
  "Figure_1_ClimateChange_Trend.png",
  "Figure_2_SixCategories_Annual.pdf",
  "Figure_2_SixCategories_Annual.png",
  "Figure_3_MarineEU_vs_Nitrogen.pdf",
  "Figure_3_MarineEU_vs_Nitrogen.png",
  "Figure_4_Normalised_Comparison.pdf",
  "Figure_4_Normalised_Comparison.png"
)

existing <- all_outputs[file.exists(all_outputs)]
file.copy(existing,
          file.path("LCA_Publication_Outputs", basename(existing)),
          overwrite = TRUE)

cat("\n=== All outputs saved to LCA_Publication_Outputs/ ===\n")
cat(paste0("  \u2713 ", basename(existing), "\n"), sep = "")
