################################################################################
# Analysis 4: Survival Analysis by Clinical Stage in TCGA-KIRC
#
# Question:
# How does overall survival differ between Stage 1 and Stage 4
# patients in TCGA-KIRC?
################################################################################

# Load packages
library(dplyr)
library(survival)
library(survminer)

# Load clinical data
clin <- readRDS("04_Data/KIRC_clinical.rds")

# Check that the required columns are present
required_columns <- c(
  "submitter_id",
  "status",
  "time_months",
  "ajcc_pathologic_stage"
)

missing_columns <- setdiff(required_columns, colnames(clin))

if (length(missing_columns) > 0) {
  stop(
    paste(
      "Missing required columns:",
      paste(missing_columns, collapse = ", ")
    )
  )
}

# Convert AJCC stage information into four main stage groups
# Important: check Stage IV before Stage III, II, and I
clin_survival <- clin |>
  mutate(
    stage = case_when(
      grepl("IV", ajcc_pathologic_stage) ~ "Stage 4",
      grepl("III", ajcc_pathologic_stage) ~ "Stage 3",
      grepl("II", ajcc_pathologic_stage) ~ "Stage 2",
      grepl("I", ajcc_pathologic_stage) ~ "Stage 1",
      TRUE ~ NA_character_
    )
  ) |>
  filter(
    !is.na(stage),
    !is.na(time_months),
    !is.na(status),
    time_months >= 0
  ) |>
  mutate(
    stage = factor(
      stage,
      levels = c("Stage 1", "Stage 2", "Stage 3", "Stage 4")
    )
  )

# Keep only Stage 1 and Stage 4 patients
clin_1_4 <- clin_survival |>
  filter(stage %in% c("Stage 1", "Stage 4")) |>
  droplevels()

# Check the number of patients in each group
table(clin_1_4$stage)

# Check survival status
table(clin_1_4$status)

# Fit Kaplan-Meier survival curves
fit_1_4 <- survfit(
  Surv(time_months, status) ~ stage,
  data = clin_1_4
)

# Create the Kaplan-Meier plot
survival_plot <- ggsurvplot(
  fit_1_4,
  data = clin_1_4,
  pval = TRUE,
  risk.table = TRUE,
  legend.title = "Stage",
  legend.labs = c("Stage 1", "Stage 4"),
  xlab = "Months",
  ylab = "Survival Probability",
  title = "Overall Survival in TCGA-KIRC: Stage 1 vs Stage 4"
)

# Display the plot
survival_plot

# Save the plot
png(
  filename = "02_Figures/04_kirc_stage1_vs_stage4_survival.png",
  width = 8,
  height = 7,
  units = "in",
  res = 300
)

print(survival_plot)

dev.off()