################################################################################
# Analysis 1: KIRC Mutation Landscape
#
# Question:
# What are the most frequently mutated genes in TCGA-KIRC?
################################################################################

# Load package
library(maftools)

# Load the mutation data
KIRC_mutation <- readRDS("04_Data/KIRC_mutation.rds")

# Convert the mutation data into a MAF object
kirc <- read.maf(
  maf = KIRC_mutation,
  verbose = TRUE
)

# View a summary of the mutation data
kirc

# View gene-level mutation summary
kirc_gene_summary <- getGeneSummary(kirc)
head(kirc_gene_summary, 10)

# Create an oncoplot showing the top 20 mutated genes
oncoplot(
  maf = kirc,
  top = 20,
  fontSize = 0.8
)

# Save the oncoplot
png(
  "02_Figures/01_kirc_oncoplot.png",
  width = 10,
  height = 8,
  units = "in",
  res = 300
)

oncoplot(
  maf = kirc,
  top = 20,
  fontSize = 0.8
)

dev.off()