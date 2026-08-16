################################################################################
# Analysis 3: SETD2 Expression in Normal vs Tumor Samples in TCGA-KIRC
#
# Question:
# Does SETD2 expression differ between normal and tumor samples in TCGA-KIRC?
################################################################################

# Load packages
library(SummarizedExperiment)
library(dplyr)
library(ggplot2)
library(ggpubr)

# Load the KIRC expression data
KIRC_expression <- readRDS("04_Data/KIRC_expression.rds")

# Check which expression assays are available
assayNames(KIRC_expression)

# Use TPM values if available; otherwise use the first available assay
available_assays <- assayNames(KIRC_expression)

if ("tpm_unstrand" %in% available_assays) {
  expression_matrix <- assay(KIRC_expression, "tpm_unstrand")
  y_label <- "SETD2 Expression (TPM)"
} else {
  expression_matrix <- assay(KIRC_expression, available_assays[1])
  y_label <- paste0("SETD2 Expression (", available_assays[1], ")")
}

# Find the SETD2 row
setd2_row <- grep(
  "^ENSG00000181555(\\.|$)",
  rownames(expression_matrix),
  value = TRUE
)

if (length(setd2_row) == 0) {
  stop("SETD2 was not found in the expression dataset.")
}

setd2_row <- setd2_row[1]

# Create a dataframe containing SETD2 expression and sample information
setd2_data <- data.frame(
  sample_id = colnames(expression_matrix),
  SETD2_expression = as.numeric(expression_matrix[setd2_row, ]),
  sample_type = colData(KIRC_expression)$sample_type
)

# Keep only normal tissue and primary tumor samples
setd2_data <- setd2_data |>
  filter(sample_type %in% c("Solid Tissue Normal", "Primary Tumor")) |>
  mutate(
    sample_type = recode(
      sample_type,
      "Solid Tissue Normal" = "Normal",
      "Primary Tumor" = "Tumor"
    )
  )

# Check the number of samples in each group
table(setd2_data$sample_type)

# Statistical comparison
wilcox.test(
  SETD2_expression ~ sample_type,
  data = setd2_data
)

# Create the plot
setd2_expression_plot <- ggplot(
  setd2_data,
  aes(
    x = sample_type,
    y = SETD2_expression,
    fill = sample_type
  )
) +
  geom_boxplot() +
  stat_boxplot(
    geom = "errorbar",
    width = 0.3
  ) +
  stat_compare_means(
    method = "wilcox.test",
    label = "p.signif"
  ) +
  theme_classic() +
  labs(
    title = "SETD2 Expression in TCGA-KIRC",
    subtitle = "Normal Tissue vs Primary Tumor",
    x = "Sample Type",
    y = y_label
  ) +
  guides(fill = "none")

# Display the plot
setd2_expression_plot

# Save the plot
ggsave(
  filename = "02_Figures/03_setd2_expression_normal_vs_tumor.png",
  plot = setd2_expression_plot,
  width = 7,
  height = 7,
  dpi = 300
)