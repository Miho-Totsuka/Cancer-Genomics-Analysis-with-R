################################################################################
# Analysis 2: SETD2 Mutation Positions in TCGA-KIRC
#
# Question:
# Where do mutations in SETD2 occur within the protein?
################################################################################

# Load package
library(maftools)

# Load the KIRC mutation data
KIRC_mutation <- readRDS("04_Data/KIRC_mutation.rds")

# Convert the mutation data into a MAF object
kirc <- read.maf(
  maf = KIRC_mutation,
  verbose = TRUE
)

# Create a lollipop plot for SETD2
lollipopPlot(
  maf = kirc,
  gene = "SETD2",
  showMutationRate = TRUE,
  labelPos = "all",
  labPosSize = 0.9,
  labPosAngle = 45
)

# Save the lollipop plot
png(
  "02_Figures/02_setd2_lollipop.png",
  width = 10,
  height = 5,
  units = "in",
  res = 300
)

lollipopPlot(
  maf = kirc,
  gene = "SETD2",
  showMutationRate = TRUE,
  labelPos = "all",
  labPosSize = 0.9,
  labPosAngle = 45
)

dev.off()