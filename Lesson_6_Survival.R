################################################################################
# Working with Patient data
################################################################################

# In this tutorial, you'll learn:
# - What Bioconductor is and why it's important
# - How to access real cancer data from TCGA (The Cancer Genome Atlas)
# - How to work with mutation data (MAF files)
# - How to create publication-quality mutation visualizations

################################################################################
# Looking at clinical data
################################################################################
library(dplyr) #load packages

clin <- readRDS("KIRC_clinical.rds")
# How many patients (rows)? How many columns?
dim(clin)
# what type of observations are there?
colnames(clin)

# How many patients are in this whole cohort?
nrow(clin)

# Look at a few clinically meaningful columns
clin_subset <- clin |> 
  select(submitter_id,vital_status, age_at_index, ajcc_pathologic_stage)

# Liver-specific fields that ARE relevant to bile-duct cancer
clan_kirc_specific <- clin |> 
  select(ishak_fibrosis_score, child_pugh_classification)

#What about these columns?
sum(is.na(clin$primary_gleason_grade))
   # Gleason grade is a PROSTATE measure
             # FIGO is a GYNECOLOGIC measure
              sum(is.na(clin$figo_stage))

#TCGA uses one clinical form for all cancer types so many of these fields are blank
#lets clean up the data a bit. 
clin_clean <- clin |> 
  select(submitter_id, status, time_days, time_months,
         vital_status, age_at_index, ajcc_pathologic_stage)
head(clin_clean)
#Now let's look at survival data. 
#When we look at survival in cancer it typically is involving two factors.
table(clin$status)
#1. Time
#2. Status/event indicator (could be death could be something else). 
table(clin$status)   # Expect two values: event vs. censored

#What do you think the 0 and 1 mean? 

# For most data in this class we will look at Overall Survival (OS)
# Which basically means we are asking. Did the patient die or not
# And we usually compare this to a treatment or some other variable. 

#For example let's look at a survival plot comparing patients diagnosed at different stages. 

#Two new packages
install.packages("survival")
install.packages("survminer")
library(survival)
library(survminer) #notice how this will load other packages we need (ggplot and ggpubr)



fit_stage <- survfit(Surv(time_months, status)~tumor_grade, data = clin)
ggsurvplot(fit_stage, data = clin, pval = TRUE,
           xlob = "Months", ylob = "Survival Probability")
fit_stage
table(clin$tumor_stage)

#Lets try to look at stage data. 

table(clin$ajcc_pathologic_stage, useNA = "ifany")

#Ok lets rename and combine these groups into the four stages. 
# How would we do that? 
clin <- clin %>%
  mutate(stage = case_when(
    grepl("IV",  ajcc_pathologic_stage) ~ "Stage 4",
    grepl("III", ajcc_pathologic_stage) ~ "Stage 3",
    grepl("II",  ajcc_pathologic_stage) ~ "Stage 2",
    grepl("I",   ajcc_pathologic_stage) ~ "Stage 1",
    TRUE ~ NA_character_
  ))
# we actually need to do it in this order for a very specific reason. ANy guesses why?

# Fix the ordering so plots/legends go 1→4, not alphabetically
clin <- clin |> 
  mutate(stage=factor(stage,
                      levels = c("Stage 1", "Stage 2", "Stage 3", "Stage 4")))
table(clin$stage, useNA = "ifany")
fit_4stages <- survfit(Surv(time_months, status)~stage, data = clin)
ggsurvplot(fit_4stages, data = clin,
           pval = TRUE, risk.table = TRUE,
           legend.title = "Stage",
           xlab = "Months", ylab = "Survival Property")


#now lets add color, because these ones suck. 
ggsurvplot(fit_4stages, data = clin,
           pval = TRUE, risk.table = TRUE,
           palette = c("lightblue", "lightgreen", "pink", "violet"),
           legend.title = "Stage",
           xlab = "Months", ylab = "Survival Property")
colors = colors()
#now lets just do stage 1 and 4.
clin_1_4 <- clin |> 
  filter(stage %in% c("Stage 1", "Stage 4")) |> 
  droplevels()
         # <- important!
#even after you filter out Stages 2 and 3, the factor still remembers those levels exist. Without droplevels(), 
#survminer can throw a confusing error or add phantom empty entries to the legend, because your legend.labs (2 labels) 
#won't match the factor's remembered levels (4). 
#Dropping unused levels is the fix — another habit that transfers straight to the gene analysis.
fit_1_4 <- survfit(Surv(time_months, status)~stage, data = clin_1_4)

ggsurvplot(fit_1_4, data = clin_1_4,
           pval = TRUE, risk.table = TRUE,
           palette = c("lightblue", "pink"),
           legend.title = "Stage",
           legend.labs = c("Stage 1", "Stage 4"),
           xlab = "Months", ylab = "Survival Property")

#notice default colors. 

#ok now lets take a look at patients stratified by gene information. 
#REMEMBER THE DATASET I HAD YOU SAVE LAST TIME LETS LOAD IT NOW. 
# If you didn't save it I will LITERALLY SOB (should be called XXX_q)

dim(KIRC_q)


my_gene <- "ENSG00000181555.21"

# ---- 3. Pull the gene + patient barcode out of the expression object ----
gene_expr <- data.frame(
  patient = KIRC_q$patient,                 # 12-char patient barcode
  expr    = as.numeric(KIRC_q[[my_gene]])   # as.numeric guards against text coercion
)

head(gene_expr)                # eyeball it: barcodes + numeric values?
summary(gene_expr$expr)

#Le'ts merge the data together
merged <- clin |> 
  inner_join(gene_expr, by = c("submitter_id" = "patient"))
nrow(merged)
#Ok Now to do survival we can do 2 different approaches. Median or Quartiles. 
# We will go through both below

# Median
merged <- merged |>
  mutate(median_group=ifelse(expr>=median(expr,na.rm = TRUE),
                             "High", "Low"))
table(merged$mediangroup)
fit_median <- survfit(Surv(time_months, status)~median_group, data = merged)

ggsurvplot(
  fit_median, data = merged,
  pval = TRUE, risk.table = TRUE,
  palette = c("pink", "cyan"),
  legend.title = my_gene,
  legend.labs = c("High", "Low"),
  xlab = "Months", ylab = "Survival Probability",
  title = paste(my_gene,"-median split")
)

#quartiles
q <- quantile(merged$expr, probs = c(0.25, 0.75), na.rm = TRUE)

merged_ends <- merged |> 
  filter(expr <= q[1] | expr >= q[2]) |> 
  mutate(quartile_group = ifelse(expr >= q[2], "Q4(high)", "Q1(low)"))

fit_q=survfit(Surv(time_months,status)~median_group,data=merged)

ggsurvplot(
  fit_q, data = merged_ends,
  pval = TRUE, risk.table = TRUE,
  palette = c("pink", "lightblue"),
  legend.title = my_gene,
  legend.labs = c("Q1", "Q4"),
  xlab = "Months", ylab = "Survival Probability",
  title = paste(my_gene, "-Q1 vs Q4")
)



#OK SO WHAT HAVE WE LEARNED:
#We should be able to
#1. Evaluate survival 
#2. Seperate patients based off of differing status
#3. Generate Kaplan-Meyer Plots to evaluate survial in patients. 

#Now its your turn. 


