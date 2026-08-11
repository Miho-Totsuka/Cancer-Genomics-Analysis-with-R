################################################################################
# Introduction to Bioconductor and TCGA Data: Mutation Analysis
################################################################################

# In this tutorial, you'll learn:
# - What Bioconductor is and why it's important
# - How to access real cancer data from TCGA (The Cancer Genome Atlas)
# - How to work with mutation data (MAF files)
# - How to create publication-quality mutation visualizations


################################################################################
# PART 2: WHAT IS BIOCONDUCTOR?
################################################################################

# Bioconductor is a collection of R packages for analyzing biological data
# It includes over 2,000 packages for:
# - Genomics
# - Transcriptomics (gene expression)
# - Proteomics
# - Flow cytometry
# - And much more!

# Bioconductor packages are peer-reviewed and well-documented
# They follow consistent design principles, making them easier to learn

# Key Bioconductor packages we'll use today:
# - BiocManager: Install and manage Bioconductor packages
# - TCGAbiolinks: Access TCGA data
# - maftools: Analyze and visualize mutation data

################################################################################
# PART 3: INSTALLING BIOCONDUCTOR PACKAGES
################################################################################

# First, install BiocManager (only need to do this ONCE)
# Uncomment the line below if you haven't installed it:

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# Load BiocManager
library(BiocManager)

# Install Bioconductor packages using BiocManager
# Uncomment these lines if you haven't installed them yet:
BiocManager::install("TCGAbiolinks")
BiocManager::install("maftools")
BiocManager::install("SummarizedExperiment")

# Also install some helper packages:
install.packages("tidyverse")
install.packages("data.table")

# Load the packages we'll use
library(TCGAbiolinks)
library(maftools)
library(data.table)
library(tidyverse)
# Check versions (good practice!)
packageVersion("TCGAbiolinks")
packageVersion("maftools")

################################################################################
# PART 4: INTRODUCTION TO TCGA (The Cancer Genome Atlas)
################################################################################

# TCGA is a landmark cancer genomics project that:
# - Characterized over 20,000 primary cancer samples
# - Covered 33 different cancer types
# - Generated multiple data types: mutations, gene expression, copy number, etc.
# - Made all data publicly available for research

# TCGA cancer type codes (GDC project names):
# TCGA-BRCA = Breast Cancer
# TCGA-LUAD = Lung Adenocarcinoma
# TCGA-LUSC = Lung Squamous Cell Carcinoma
# TCGA-COAD = Colon Adenocarcinoma
# TCGA-GBM  = Glioblastoma
# TCGA-OV   = Ovarian Cancer
# TCGA-KIRC = Kidney Renal Clear Cell Carcinoma
# TCGA-UCEC = Uterine Corpus Endometrial Carcinoma
# ... and many more!

# Let's explore what projects are available
gdcprojects <- getGDCprojects()
View(gdcprojects)
#To look at one specific project
getProjectSummary("TCGA-LGG")
tcga_projects <- gdcprojects |> 
  filter(grepl("TCGA", project_id)) |> 
  select(project_id, name, tumor) |> 
  arrange(project_id)

# View the projects
head(tcga_projects, 10)

# How many TCGA projects?


################################################################################
# PART 5: UNDERSTANDING MAF FILES
################################################################################

# MAF = Mutation Annotation Format
# It's a tab-delimited file that contains information about mutations

# Key columns in a MAF file:
# - Hugo_Symbol: Gene name (e.g., TP53, KRAS)
# - Chromosome: Which chromosome (chr1, chr2, etc.)
# - Start_Position: Where the mutation starts
# - End_Position: Where the mutation ends
# - Variant_Classification: Type of mutation (Missense, Nonsense, etc.)
# - Variant_Type: SNP, INS, DEL
# - Reference_Allele: Normal DNA base(s)
# - Tumor_Seq_Allele2: Mutated DNA base(s)
# - Tumor_Sample_Barcode: Patient ID

# Mutation types:
# - Missense_Mutation: Changes one amino acid
# - Nonsense_Mutation: Creates a stop codon (truncates protein)
# - Frame_Shift_Del: Deletion that shifts reading frame
# - Frame_Shift_Ins: Insertion that shifts reading frame
# - In_Frame_Del: Deletion without frame shift
# - In_Frame_Ins: Insertion without frame shift
# - Splice_Site: Affects RNA splicing
# - Silent: Doesn't change amino acid

################################################################################
# PART 6: QUERY AND DOWNLOAD TCGA MUTATION DATA
################################################################################

# I am going to walk you through how you can look at  TCGA Data
# We'll use the TCGA Kidney Renal Clear Cell Carcinoma (KIRC) as an example
# This is a common kidney cancer type with lots of mutations


#Help Document: https://bioconductor.org/packages/release/bioc/vignettes/TCGAbiolinks/inst/doc/query.html

# IMPORTANT: This downloads real data from the internet!

#GDCquery will let us build a query for the data we want to examine. 
?GDCquery

#a minimum of 2 arguments are needed: project and data.category. 
#use this to generate a query and see what data is available for your specific dataset. 
query_TCGA <- GDCquery(project = "TCGA-KIRC",
  data.category = "Simple Nucleotide Variation")

#need to use getResults() to visualize the data. 



#Using the GDCquery we can query for the specific data. 

#We are going to start with mutation data. 

# Step 1: Query for mutation data
query_kirc <- GDCquery(
  project = "TCGA-KIRC",
  data.category = "Simple Nucleotide Variation",
  data.type = "Masked Somatic Mutation",
  workflow.type = "Aliquot Ensemble Somatic Variant Merging and Masking"
)

#Pay attention to the data.category, experimental.strategy, workflow.type
output_query_KIRC <- getResults(query_kirc)

library(TCGAbiolinks)
# Check what we queried
query_kirc

# Once we generate this query we would normally download the data and save it. 
#Since these files are pretty big however, and are not incredibly easy to work with, we will use a dataset
#that I have already downloaded


################################################################################
# PART 7: LOADING AND EXPLORING MAF DATA WITH MAFTOOLS
################################################################################

# For teaching purposes, we will use a smaller dataset



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

# This creates a MAF object - a special data structure for mutation data

################################################################################
# PART 8: BASIC MAF EXPLORATION
################################################################################

# Get a summary of the MAF object
kirc

# The summary shows:
# - NCBI Build (Reference genome)
# - Number of samples (patients)
# - Number of genes
# - Total mutations
# - Mutation types
# - Top mutated genes

# Get more detailed summary
kirc_summary <- getSampleSummary(kirc)

# This shows for each sample:
# - Total mutations
# - Frame shifts
# - In-frame mutations
# - Missense mutations
# - Nonsense mutations
# - Splice site mutations

# Get gene summary
kirc_gene <- getGeneSummary(kirc)

# This shows for each gene:
# - How many samples have mutations
# - Types of mutations
# - Mutation rate

# Get clinical data
kirc_clinical <- getClinicalData(kirc)
# Extract fields (columns) available
getFields(kirc)

################################################################################
# PART 9: VISUALIZING MUTATION DATA
################################################################################

# maftools provides many visualization functions
# Let's explore the most important ones

# 1. Summary plot - Overview of mutation landscape
plotmafSummary(
  maf = kirc, 
  rmOutlier = TRUE,
  addStat = "mean",
  dashboard =  TRUE
)

# This creates multiple panels showing:
# - Variant classification (types of mutations)
# - Variant type (SNP vs INS vs DEL)
# - SNV class (transition vs transversion)
# - Top 10 mutated genes
# - Mutation load per sample

# 2. Oncoplot - Most commonly mutated genes across samples
# This is one of the most important plots in cancer genomics!
oncoplot(
  maf = kirc,
  top = 20,
  fontSize = 0.8
)

# How to read an oncoplot:
# - Each row is a gene
# - Each column is a patient/sample
# - Colors indicate mutation types
# - Genes are ordered by mutation frequency (top to bottom)
# - The bar plot on left shows % of samples mutated
# - The bar plot on top shows total mutations per sample

# 3. Oncoplot with specific genes
oncoplot(
  maf = kirc,
  genes = c("DNMT3A", "FLT3", "NPM1", "RUNX1", "TP53"),
  fontSize = 1
)

# 4. Transition and transversion plot
titv <- titv(
  maf = kirc,
  plot = TRUE,
  useSyn = TRUE
)

# This shows:
# - Ti = Transitions (A↔G or C↔T, chemically similar)
# - Tv = Transversions (purine↔pyrimidine, chemically different)
# - Ti/Tv ratio varies by cancer type and mutational process

################################################################################
# PART 10: ANALYZING SPECIFIC GENES
################################################################################

# Let's focus on specific genes commonly mutated in this cancer

# 1. Lollipop plot - Shows where mutations occur in a protein
lollipopPlot(
  maf = kirc,
  gene = "SETD2",
  showMutationRate = FALSE,
  labelPos = "all",
  labPosSize = 0.9,
  labPosAngle = 45
)

# How to read a lollipop plot:
# - X-axis: position in the protein (amino acids)
# - Colored rectangles: protein domains
# - Lollipops: mutations (height = number of samples)
# - This shows mutation "hotspots"

# Try other genes
lollipopPlot(
  maf = kirc,
  gene = "TP53",
)

# 2. Compare mutations in two genes
# Are they mutually exclusive or co-occurring?
somaticInteractions(
  maf = kirc,
  top = 20,
  pvalue = c(0.05, 0.1)
)

# This creates a plot showing:
# - Green = genes tend to be mutated together (co-occurring)
# - Brown = genes are rarely mutated together (mutually exclusive)
# - Statistical significance shown with asterisks



################################################################################
# PART 11: PRACTICE EXERCISES
################################################################################

# Using the kirc data, complete these exercises:

# BEGINNER EXERCISES

# 1. How many total samples are in the kirc dataset?


# 2. What are the top 5 most frequently mutated genes?


# 3. Create an oncoplot showing the top 10 mutated genes


# 4. What is the most common variant classification (mutation type)?


# INTERMEDIATE EXERCISES

# 5. Create a lollipop plot for NPM1


# 6. How many samples have mutations in BOTH DNMT3A and FLT3?
#    (Hint: use subsetMaf and look at sample overlap)


# 7. What is the average number of mutations per sample?
#    (Hint: use getSampleSummary)


# 8. Create a histogram of mutation burden across samples


# ADVANCED EXERCISES

# 9. Find all genes mutated in more than 10% of samples


# 10. For the gene RUNX1, create a complete analysis including:
#     - Mutation frequency
#     - Lollipop plot
#     - List of mutation types
#     - Hotspot analysis


# 11. Compare mutation patterns between FAB_M0 and FAB_M1 subtypes
#     Which genes are significantly different?


# 12. Extract all frameshift mutations from the entire dataset
#     Which gene has the most frameshifts?


# PROJECT EXERCISES

# 13. Choose YOUR assigned gene and answer:
#     - Is it mutated in this cancer type?
#     - What is the mutation frequency?
#     - What types of mutations occur?
#     - Are there hotspots?


# 14. Download mutation data for a different cancer type (e.g., TCGA-BRCA)
#     and analyze your gene in that cancer


# 15. Compare your gene's mutation frequency across 3 different cancer types
#     Which cancer type has the highest mutation rate?



#################################################################################
# PART 21: YOUR PROJECT — WHAT TO BUILD AND WHY
################################################################################
# Your project has four required figures. Three of them describe your CANCER
# TYPE as a whole; the last one zooms in on YOUR assigned GENE.
#
# Everything you need is already in this script. If you get stuck on a
# function, scroll back to Parts 9 and 10 and adapt the example.

# ---- STEP 1: Choose your cancer type ----------------------------------------
#    - Pick a cancer where your gene is plausibly relevant
#    - Some genes are cancer-type specific; others are mutated broadly
#    - Common, well-covered starting points: BRCA, LUAD, COAD
#    - Read your MAF in before doing anything else

# ---- STEP 2: FIGURE 1 — Oncoplot (the mutation landscape) -------------------
#    - Each row is a gene, each column is a patient
#    - Answer: what are the top mutated genes in this cancer?
#    - Answer: where does YOUR gene rank? Is it even in the top 20?
#    - Then make a second version that forces your gene onto the plot
#      alongside 4-5 of the top drivers

# ---- STEP 3: FIGURE 2 — Somatic interactions plot ---------------------------
#    - Green = co-occurring (mutated together more often than chance)
#    - Brown = mutually exclusive (rarely mutated in the same patient)
#    - Answer: does your gene co-occur with, or exclude, any other gene?
#    - Mutual exclusivity often means two genes hit

################################################################################
# PART 22: SAVING YOUR WORK
################################################################################

################################################################################
# PART 22: SAVING YOUR WORK
################################################################################

# HOW THIS WORKS: Saving a plot is a three-step sandwich.
#   1. png(...)   opens an empty image file
#   2. your plot  gets sent INTO that file instead of the Plots pane
#   3. dev.off()  closes the file and finishes saving it
# So you will NOT see the plot appear on screen while this runs. That is
# normal. Check your working directory for the file instead.
# The width, height, and res settings just control how big and how sharp
# the image comes out.

# Save plots
png("fig1_oncoplot.png", width = 10, height = 8, units = "in", res = 300)
oncoplot(maf = xxxx, top = 20)
dev.off()

png("fig2_somatic_interactions.png", width = 8, height = 8, units = "in", res = 300)
somaticInteractions(maf = xxx, top = 20, pvalue = c(0.05, 0.1))
dev.off()

png("fig3_titv.png", width = 10, height = 6, units = "in", res = 300)
titv(maf = xxx, plot = TRUE, useSyn = TRUE)
dev.off()

png("fig4_lollipop.png", width = 10, height = 5, units = "in", res = 300)
lollipopPlot(maf = xxxx, gene = "YOUR_GENE")
dev.off()

# dev.off() closes the file. If you forget it, the png will be empty.
# res = 300 keeps the image sharp when you put it in a slide.

# Save data
gene_data <- subsetMaf(maf = kirc, genes = "YOUR_GENE", mafObj = FALSE)
write.csv(gene_data, "my_gene_mutations.csv", row.names = FALSE)

# Save MAF object
saveRDS(kirc, "my_maf_object.rds")

# Load later
my_maf <- readRDS("my_maf_object.rds")

# Everything saves to your working directory. To find it:
getwd()

################################################################################
# PART 23: NEXT STEPS
################################################################################

# You've learned:
# ✓ What Bioconductor is
# ✓ How to access TCGA data
# ✓ How to work with MAF files
# ✓ How to visualize mutations
# ✓ How to identify hotspots
# ✓ How to compare mutation patterns

# Next tutorials will cover:
# - Gene expression analysis (RNA-seq data)
# - Survival analysis (Kaplan-Meier curves)
# - Pathway analysis (GSEA)
# - Integrating multiple data types

# Resources:
# - maftools documentation: https://bioconductor.org/packages/maftools
# - TCGAbiolinks guide: https://bioconductor.org/packages/TCGAbiolinks
# - TCGA data portal: https://portal.gdc.cancer.gov/

# Keep practicing! Mutation analysis is fundamental to cancer genomics.

################################################################################
# CONGRATULATIONS!
################################################################################

# You can now:
# - Download real cancer mutation data from TCGA
# - Analyze mutation patterns
# - Create professional visualizations
# - Identify cancer driver genes
# - Understand mutation signatures

# This is real bioinformatics research!
# The skills you're learning are used by scientists worldwide
# to understand cancer and develop new treatments.

