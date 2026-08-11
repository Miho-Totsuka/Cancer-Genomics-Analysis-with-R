#######################################################################################
# Lesson 4: Gene Expression Analysis Part 1 #
######################################################################################

# So far we have learned how to use MUTATION data to analyze genes in cancer
# While mutations are very important in cancer, gene expression also plays a big role. 
# When oncogenes are overexpressed what might happen? When tumor supressors are downregulated what happpens?
# In this activity, and the next, we will look at gene expressions in tumor and normal samples. 


# Just like in our previous lesson, we are going to upload data from TCGA. 
# For this lesson we are going to evaluate an example TCGA dataset that examines cholangiocarcinoma (bile cancer).
# If you haven't already, download the CHOL_expression.rds file from the Google Drive and place it in your working 
# directory folder. 

#Upload the data into your workspace using the following code
KIRC_expression <- readRDS("KIRC_expression.rds")

#This should make a larged Ranged Summarized Experiment in your environment.

#Now let's load the packages we will need for today. Most are ones we used last time but there are a few new ones. 

library(tidyverse) #includes dplyr and ggplot2 for us to use today. 
library(TCGAbiolinks) #TCGA data examination
library(SummarizedExperiment)#Lets us work with Summarized Experiment files

#These are new packages
install.packages("ggpubr")
library("ggpubr")
library("scales")

#Let's do a quick review and look at our TCGA datset. If I wanted to get a summary of all datasets how 
# would I do that?

gdcprojects <- getGDCprojects()


#And if I wanted information on TCGA_CHOL exclusively?
getProjectSummary("TCGA-CHOL")

#Last time we looked at Single Nucleotide Variation (SNV) data for mutations.
#Which dataset should we look at for gene expression data?

#Lets do a summary of CHOL data for the right dataset 
query_TCGA_Transcriptome <- GDCquery(
  project = "TCGA-CHOL",
  data.category = "Transcriptome Profiling",
  experimental.strategy = "RNA-Seq",
  workflow.type = "STAR - Counts",
  sample.type = c('Solid Tissue Normal', 'Primary Tumor'),
  data.type = "Gene Expression Quantification"
)

query_TCGA_results <- getResults(query_TCGA_Transcriptome)
table(query_TCGA_results$sample_type)

#Take a look at the query TCGA results and look at specific columns. For this time, lets look at 
# column sample.type
# What type of samples do we have? How many of each type are there?



# And we will make a data frame version of CHOL_expression to use for future work 
# (this is a bit handwavy so don't mind it too much)

KIRC_Data.frame <- as.data.frame(colData(KIRC_expression))

#Open up CHOL_Data.frame. What kind of data does this lok like? 


# Talk about TCGA number codes. 

#TCGA CODES: TCGA-AA-3712-11A is normal tissue 
# TCGA-SS-A7HO-01A is primary tumor,

#01-09 tumor samples, 10-29 normal samples, 20-29 controls
# 01 = Primary tumor
# 02 = Recurrent Tumor
# 06 = Metastatic 
# 10 = healthy blood
# 11 = solid tissue normal


#We are going to select some specific columns we will need for later. 
 #These variables are different for each dataset. 

KIRC_Data.frame_patient <- KIRC_Data.frame |> 
  select("patient",
    "barcode",
    "shortLetterCode",
    "vital_status",
    "days_to_death",
    "race",
    "ethnicity",
    "ajcc_pathologic_stage",
    "sample_type")


# Now we need to prep our expression data by turning it into a matrix. 
mRNA_KIRC <- assay(KIRC_expression)


# look at mRNA_CHOL and look at the data. What are the rownames? What are column names?
# what are the values?

#Ok let's do some prep work to compare a gene between Normal tissue and primary tumor tissue. 
mRNA_KIRC_dataframe <- as.data.frame(t(mRNA_KIRC)) #the t is important


#what changed?

mRNA_KIRC_dataframe$ID <- row.names(mRNA_KIRC_dataframe)

 #ads ID as variable

KIRC_Data.frame_patient$ID <- row.names(KIRC_Data.frame_patient)
 #same thing. 

combined_KIRC <- left_join(mRNA_KIRC_dataframe, KIRC_Data.frame_patient, by = c("ID"="ID"), copy =TRUE)

#Look at the last columns of combined_CHOL

#In this case, we only have two sample types but some others will have more. 
# To fix this run the following code. We will also rename to make things easier

combined_KIRC <- combined_KIRC |> 
  filter(sample_type %in% c("Solid Tissue Normal", "Primary Tumor")) |> 
  mutate(sample_type = recode(sample_type,
    "Primary Tumor"= "Tumor",
    "Solid Tissue Normal"= "Normal"))

grep("ENSG00000181555.21", colnames(combined_KIRC), value = TRUE)


TCGA_KIRC_SETD2_TPM <- ggplot(combined_CHOL, aes(x=sample_type, y = ENSG00000181555.21, fill=sample_type))+
  geom_boxplot()+
  stat_boxplot(geom= 'errorbar', width = 0.3)+
  stat_compare_means(
    method = "wilcox.test",
    label = "p.signif",
    size = 5,
    label.x.npc = "center",
    label.y.npc = "top")+
  scale_fill_manual(values = c("Normal"= "#4575b4", "Tumor"= "#D73027"))+
  theme_classic()+
  labs(title = "Normal vs Tumor SETD2 Expression", x= "Sample", y = "SETD2 Counts 
    \n(Transcripts per Million)")


TCGA_CHOL_KRT19_TPM

#WHAT DOES THIS MEAN??
# Lets save the data (you don't actually have to it here but you will in the activity)
ggsave(
  filename = "KIRC_SETD2_TPM.png",
  plot = TCGA_KIRC_SETD2_TPM,
  width = 7,
  height = 7,
  dpi = 300
)


#Now lets dive a bit more closely into our gene. 

#First lets create a dataset with just tumor samples. 
KIRC_q <- combined_KIRC |> 
  filter(sample_type == "Tumor")

colnames(KIRC_q)
# Define the column of interest
SETD2_expr <- KIRC_q$ENSG00000181555.21


# Compute IQR-based bounds
Q1 <- quantile(SETD2_expr, 0.25, na.rm=TRUE)
Q3 <- quantile(SETD2_expr,0.75, na.rm=TRUE)
IQR <- Q3-Q1

lower_bound <- Q1-1.5*IQR
upper_bound <- Q3+1.5*IQR

KIRC_q$quartiles <- cut(KIRC_q$ENSG00000171345.13,
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
#ONE MORE THING. WE need to save our quartile dataframe for future work. 
# YOU DO NOT NEED TO SAVE THIS ONE, BUT YOU WILL FOR YOUR ACTIVITY. USE THE FOLLOWING AS TEMPLATE

write.csv(CHOL_q, "CHOL_KRT19_quartiles.csv")
 

#OK SO WHAT HAVE WE LEARNED:
#We should be able to
#1. Look at expression data, 
#2. Compare expression data for genes in normal and tumor samples
#3. Quartile patients based on gene expression. 