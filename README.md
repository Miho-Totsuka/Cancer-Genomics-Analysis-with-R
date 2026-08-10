# Analyzing-Cancer-Data-through-Graph
This is my code analyzing my gene called SETD2 often in a type of kidney cancer called KIRC. I am also using other datas from the breast cancer BRCA and the gene called TP53.

library(dplyr)
read.csv("brca_metabric_clinical_data.csv")
# Load BiocManager
library(BiocManager)
library(TCGAbiolinks)
library(maftools)
library(data.table)
library(tidyverse)
# Check versions (good practice!)
packageVersion("TCGAbiolinks")
packageVersion("maftools")

# Step 1: Query for mutation data
query_kirc <- GDCquery(
  project = "TCGA-KIRC",
  data.category = "Simple Nucleotide Variation",
  data.type = "Masked Somatic Mutation",
  workflow.type = "Aliquot Ensemble Somatic Variant Merging and Masking"
)

# For now, we'll use maftools' built-in example data
# Load example TCGA kirc (Acute Myeloid Leukemia) data
kirc.maf <- system.file("extdata", "tcga_kirc.maf.gz", package = "maftools")
kirc.clin <- system.file("extdata", "tcga_kirc_annot.tsv", package = "maftools")
KIRC_mutation <- readRDS("KIRC_mutation.rds")

# Read the MAF file
kirc <- read.maf(
  maf = KIRC_mutation,
  verbose = TRUE
)

# 1. Summary plot - Overview of mutation landscape
plotmafSummary(
  maf = kirc, 
  rmOutlier = TRUE,
  addStat = "mean",
  dashboard =  TRUE
)

#2. Oncoplot - Most commonly mutated genes across samples
# This is one of the most important plots in cancer genomics!
oncoplot(
  maf = kirc,
  top = 20,
  fontSize = 0.8
)

# 3. Lollipop plot - Shows where mutations occur in a protein
lollipopPlot(
  maf = kirc,
  gene = "SETD2",
  showMutationRate = FALSE,
  labelPos = "all",
  labPosSize = 0.9,
  labPosAngle = 45
)

#4. Whisker - box plot
#First lets create a dataset with just tumor samples. 
CHOL_q <- combined_CHOL |> 
  filter(sample_type == "Tumor")

colnames(CHOL_q)
# Define the column of interest
krt19_expr <- CHOL_q$ENSG00000171345.13


# Compute IQR-based bounds
Q1 <- quantile(krt19_expr, 0.25, na.rm=TRUE)
Q3 <- quantile(krt19_expr,0.75, na.rm=TRUE)
IQR <- Q3-Q1

lower_bound <- Q1-1.5*IQR
upper_bound <- Q3+1.5*IQR

CHOL_q$quartiles <- cut(CHOL_q$ENSG00000171345.13,
  breaks = quantile(CHOL_q$ENSG00000171345.13, probs = seq(0,1,0.25), na.rm =TRUE),
  include.lowest = TRUE,
  labels = c("Q1", "Q2", "Q3", "Q4"))

table(CHOL_q$quartiles)

#Now lets do another boxplot
TCGA_CHOL_KRT19_quartiles <- ggplot(CHOL_q, aes(x=sample_type, y= krt19_expr, fill = quartiles))+
  geom_boxplot(outlier.size = 0.8)+
  scale_fill_manual(values = c("Q1"= "#4575B4",
    "Q2" = "#91BFDB",
    "Q3"= "#FC8D59",
    "Q4"= "#D73027"))+
  theme_classic()+
  labs(title = "KRT19 Expression by Quartile",
    x= "Quartile",
    y= "KRT19 Counts \n(Transcripts per Million)")
  
TCGA_CHOL_KRT19_quartiles

#no stastitics for this one because they will obviously be different.
#save our work
ggsave(
  filename = "TCGA_CHOL_KRT19_quartiles.png",
  plot = TCGA_CHOL_KRT19_quartiles,
  width = 7,
  height = 7,
  dpi = 300
)

# 5. Kaplan - Meier Survival
#Dropping unused levels is the fix — another habit that transfers straight to the gene analysis.
fit_1_4 <- survfit(Surv(time_months, status)~stage, data = clin_1_4)

ggsurvplot(fit_1_4, data = clin_1_4,
           pval = TRUE, risk.table = TRUE,
           palette = c("lightblue", "pink"),
           legend.title = "Stage",
           legend.labs = c("Stage 1", "Stage 4"),
           xlab = "Months", ylab = "Survival Property")
