################################################
# ORIGINAL CODE – full setup for final script
# Step 1: Load libraries and construct base dataset
##################################################


# Clear environment
rm(list = ls())

# Load required packages
library(dplyr)        # Data manipulation
library(ggplot2)      # Visualizations
library(NHANES)       # NHANES dataset
library(doBy)         # summaryBy() for grouped stats
library(stats)        # t.test(), chisq.test(), glm
library(car)          # Optional: vif() if used for diagnostics

# Load NHANES and de-duplicate
data("NHANES")
NHANES <- NHANES[!duplicated(NHANES$ID), ]

# Construct working dataset
df <- data.frame(
  ID = NHANES$ID,
  Age = NHANES$Age,
  Sex = NHANES$Gender,
  Height = NHANES$Height,
  Weight = NHANES$Weight,
  SleepTrouble = NHANES$SleepTrouble,
  PhysActive = NHANES$PhysActive
)

# Compute BMI
df$BMI <- df$Weight / ((df$Height / 100)^2)


##############################
# ORIGINAL CODE
# Step 2: Filter and clean dataset for analytic cohort
###############################
df_clean <- df %>%
  filter(Age > 30,
         !is.na(SleepTrouble),
         !is.na(BMI),
         !is.na(PhysActive)) %>%
  mutate(
    SleepTrouble_bin = ifelse(SleepTrouble == "Yes", 1, 0),
    BMI_5unit = BMI / 5
  ) %>%
  filter(BMI >= 15 & BMI <= 60)


#######################
###Code Block 3: Create BMI Categories 

# ORIGINAL CODE – technique taught, application original
# Instructor labs (e.g., PLAB13) teach the use of cut() for binning continuous variables.
# This code applies that taught method to derive WHO-defined BMI categories,
# which are not used elsewhere in the course code.


##################

df_clean <- df_clean %>%
  mutate(
    BMI_cat = cut(BMI,
                  breaks = c(-Inf, 18.5, 25, 30, Inf),
                  labels = c("Underweight", "Normal", "Overweight", "Obese"))
  )

##################################################

#Code Block 4: Sample Flow Diagram Counts

#################################################

# ORIGINAL CODE – required for final report Appendix B
# Compute sample size at each stage of filtering

# Step 0: Raw NHANES total (including duplicates)
n_raw <- nrow(NHANES)

# Step 1: After deduplication
NHANES_dedup <- NHANES[!duplicated(NHANES$ID), ]
n_dedup <- nrow(NHANES_dedup)

# Step 2: Age > 30 and non-missing key variables
df_step2 <- df %>%
  filter(Age > 30,
         !is.na(SleepTrouble),
         !is.na(BMI),
         !is.na(PhysActive))
n_age_and_vars <- nrow(df_step2)

# Step 3: Valid BMI range (15–60)
n_bmi_valid <- nrow(df_clean)

# Print flow counts
cat("Sample Flow Counts:\n")
cat("Raw NHANES: ", n_raw, "\n")
cat("After deduplication: ", n_dedup, "\n")
cat("After Age > 30 & non-missing SleepTrouble, BMI, PhysActive: ", n_age_and_vars, "\n")
cat("After BMI filter (15–60): ", n_bmi_valid, "\n")
cat("Final analytic set: ", n_bmi_valid, "\n")



##############################

# Code Block 5: Continuous & Categorical Variables 

#############################################

#Code Block 5A: Table 1 – Continuous Variable Summary


# Instructor-based code – applied to project-specific grouping (SleepTrouble)
# Summarize continuous variables (Age, BMI) for: All, SleepTrouble = 0, and SleepTrouble = 1

library(doBy)

# Create summary function
summary_stats <- function(x) {
  data.frame(
    N = length(x),
    Mean = round(mean(x, na.rm = TRUE), 2),
    SD = round(sd(x, na.rm = TRUE), 2),
    SE = round(sd(x, na.rm = TRUE)/sqrt(length(x)), 2),
    CI_Lower = round(mean(x, na.rm = TRUE) - 1.96 * sd(x, na.rm = TRUE)/sqrt(length(x)), 2),
    CI_Upper = round(mean(x, na.rm = TRUE) + 1.96 * sd(x, na.rm = TRUE)/sqrt(length(x)), 2),
    Median = round(median(x, na.rm = TRUE), 2)
  )
}

# Apply to full dataset
all_summary <- rbind(
  cbind(Group = "All", summary_stats(df_clean$Age)),
  cbind(Group = "All", summary_stats(df_clean$BMI))
)

# Apply to SleepTrouble groups
grouped_summary <- df_clean %>%
  group_by(SleepTrouble_bin) %>%
  summarise(
    Age_N = n(),
    Age_Mean = mean(Age, na.rm = TRUE),
    Age_SD = sd(Age, na.rm = TRUE),
    Age_SE = sd(Age, na.rm = TRUE)/sqrt(n()),
    Age_CI_L = Age_Mean - 1.96 * Age_SE,
    Age_CI_U = Age_Mean + 1.96 * Age_SE,
    Age_Median = median(Age, na.rm = TRUE),
    BMI_Mean = mean(BMI, na.rm = TRUE),
    BMI_SD = sd(BMI, na.rm = TRUE),
    BMI_SE = sd(BMI, na.rm = TRUE)/sqrt(n()),
    BMI_CI_L = BMI_Mean - 1.96 * BMI_SE,
    BMI_CI_U = BMI_Mean + 1.96 * BMI_SE,
    BMI_Median = median(BMI, na.rm = TRUE)
  )

# View results
print("Continuous Variable Summary for Table 1")
print(all_summary)
print(grouped_summary)



##############################################
#Code Block 5B: Table 1 – Categorical Variable Summary#

# Instructor-based code – adapted for final project grouping
# Summarize n (%) for categorical variables by SleepTrouble_bin

# List of categorical variables
cat_vars <- c("Sex", "PhysActive", "BMI_cat")

# Function to summarize n and % per group
summarize_categorical <- function(varname) {
  tab_all <- table(df_clean[[varname]])
  prop_all <- prop.table(tab_all)
  
  tab_group <- table(df_clean[[varname]], df_clean$SleepTrouble_bin)
  prop_group <- prop.table(tab_group, margin = 2)  # column percentages
  
  # Combine results
  summary_df <- data.frame(
    Category = rownames(tab_all),
    Count_All = as.numeric(tab_all),
    Pct_All = round(100 * as.numeric(prop_all), 1),
    Count_ST0 = as.numeric(tab_group[, "0"]),
    Pct_ST0 = round(100 * prop_group[, "0"], 1),
    Count_ST1 = as.numeric(tab_group[, "1"]),
    Pct_ST1 = round(100 * prop_group[, "1"], 1)
  )
  return(summary_df)
}

# Apply to all categorical vars
cat_summary_list <- lapply(cat_vars, summarize_categorical)
names(cat_summary_list) <- cat_vars

# View results
print("Categorical Variable Summary for Table 1")
cat_summary_list



############################

#Code Block 6: Figure 1 – Bar Plot of Sleep Trouble Prevalence

############################


# Instructor-based plot – applied to SleepTrouble variable
# Figure 1: Bar plot of SleepTrouble prevalence with counts labeled

library(ggplot2)

# Generate summary counts
sleep_counts <- df_clean %>%
  group_by(SleepTrouble_bin) %>%
  summarise(n = n()) %>%
  mutate(SleepTrouble_label = ifelse(SleepTrouble_bin == 1, "Yes", "No"))

# Plot
ggplot(sleep_counts, aes(x = SleepTrouble_label, y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = n), vjust = -0.5, size = 5) +
  labs(title = "Prevalence of Reported Sleep Trouble",
       x = "Reported Sleep Trouble",
       y = "Number of Participants") +
  theme_bw()


################################
#Code Block 7: Figure 2 – Boxplot of BMI by Sleep Trouble Group

#####################################

# Instructor-based plot – stratified boxplot applied to BMI and SleepTrouble
# Figure 2: Boxplot of BMI by SleepTrouble group, with group sizes labeled

# Create group labels with n counts
label_df <- df_clean %>%
  group_by(SleepTrouble_bin) %>%
  summarise(n = n()) %>%
  mutate(SleepTrouble_label = ifelse(SleepTrouble_bin == 1, "Yes", "No"),
         Label = paste0(SleepTrouble_label, " (n = ", n, ")"))

# Merge labels with df
df_plot <- df_clean %>%
  left_join(label_df, by = "SleepTrouble_bin")

# Plot
ggplot(df_plot, aes(x = Label, y = BMI)) +
  geom_boxplot(fill = "skyblue") +
  labs(title = "BMI Distribution by Reported Sleep Trouble",
       x = "Reported Sleep Trouble",
       y = "BMI (kg/m²)") +
  theme_bw()


#####################################

#Code Block 8: SleepTrouble × PhysActive

######################################

#Code Block 8A: Contingency Table for SleepTrouble × PhysActive

# Instructor-based code – chi-square prep (table + prop.table)
# Step 1: Create contingency table for SleepTrouble_bin × PhysActive

# Clean levels (drop unused)
df_clean$PhysActive <- droplevels(df_clean$PhysActive)

# Build raw count table
ct_PA_ST <- table(df_clean$PhysActive, df_clean$SleepTrouble_bin)

# Show absolute counts
print("Contingency Table: PhysActive × SleepTrouble")
print(ct_PA_ST)

# Show column-wise proportions (within each SleepTrouble group)
print("Proportions within each SleepTrouble group (column %)")
print(prop.table(ct_PA_ST, margin = 2))



####################################
#Code Block 8B: Chi-Square Test – SleepTrouble × PhysActive


# Instructor-based code – chi-square test of independence
# Step 2: Run the chi-square test on SleepTrouble × PhysActive

# Run the test
chi_PA_ST <- chisq.test(ct_PA_ST)

# Output test results
print("Chi-Square Test Results: PhysActive × SleepTrouble")
print(chi_PA_ST)

# Show expected counts
print("Expected Counts:")
print(chi_PA_ST$expected)

# Show Pearson residuals (strength of contribution per cell)
print("Residuals:")
print(chi_PA_ST$residuals)


#####################################

#Code Block 9: SleepTrouble × BMI_cat

######################################


# Code Block 9A: Contingency Table for SleepTrouble × BMI_cat

# Instructor-based code – chi-square prep for BMI category
# Step 1: Create contingency table for SleepTrouble_bin × BMI_cat

# Clean BMI category levels (if needed)
df_clean$BMI_cat <- droplevels(df_clean$BMI_cat)

# Build contingency table
ct_BMI_ST <- table(df_clean$BMI_cat, df_clean$SleepTrouble_bin)

# Show absolute counts
print("Contingency Table: BMI Category × SleepTrouble")
print(ct_BMI_ST)

# Show proportions within each SleepTrouble group
print("Proportions within each SleepTrouble group (column %)")
print(prop.table(ct_BMI_ST, margin = 2))


########################################

#Code Block 9B: Chi-Square Test – SleepTrouble × BMI_cat

# Instructor-based code – chi-square test for BMI category
# Step 2: Run chi-square test for association between BMI category and Sleep Trouble

# Run test
chi_BMI_ST <- chisq.test(ct_BMI_ST)

# Output main test results
print("Chi-Square Test Results: BMI Category × SleepTrouble")
print(chi_BMI_ST)

# Expected counts under independence
print("Expected Counts:")
print(chi_BMI_ST$expected)

# Pearson residuals (contribution of each cell)
print("Residuals:")
print(chi_BMI_ST$residuals)


#########################################
#Code Block 10: T-Test – Mean BMI by SleepTrouble

##################################################


# Instructor-based code – exploratory t-test by group
# Compare mean BMI between SleepTrouble groups (0 vs 1)

# Check group means
mean_BMI_ST0 <- mean(df_clean$BMI[df_clean$SleepTrouble_bin == 0], na.rm = TRUE)
mean_BMI_ST1 <- mean(df_clean$BMI[df_clean$SleepTrouble_bin == 1], na.rm = TRUE)

cat("Mean BMI (SleepTrouble = 0):", round(mean_BMI_ST0, 2), "\n")
cat("Mean BMI (SleepTrouble = 1):", round(mean_BMI_ST1, 2), "\n")

# Run independent-samples t-test
ttest_BMI_ST <- t.test(BMI ~ SleepTrouble_bin, data = df_clean)

# Show test results
print("T-Test: Mean BMI by SleepTrouble group")
print(ttest_BMI_ST)



#########################################

#Code Block 11: Model M0 – (Intercept-Only) Logistic Regression

##############################################


# Instructor-based structure – logistic baseline model M0
# M0: Baseline logistic regression model (intercept only)

# Fit the model
model_M0 <- glm(SleepTrouble_bin ~ 1, data = df_clean, family = binomial("logit"))

# Summary output
summary(model_M0)

# Store baseline AIC for model comparison
AIC_M0 <- AIC(model_M0)
cat("AIC of M0 (intercept-only model):", AIC_M0, "\n")


########################################

#Code Block 12: Model M1 – SleepTrouble ~ BMI_5unit

##########################################


# Instructor-based structure – logistic model M1: BMI effect
# M1: Add BMI (per 5-unit increase) as predictor

# Fit the model
model_M1 <- glm(SleepTrouble_bin ~ BMI_5unit, data = df_clean, family = binomial("logit"))

# Model summary
summary(model_M1)

# Likelihood ratio test comparing M0 → M1
anova(model_M0, model_M1, test = "LRT")

# AIC for M1
AIC_M1 <- AIC(model_M1)
cat("AIC of M1:", AIC_M1, "\n")

# Odds ratio + 95% CI
OR_BMI <- exp(coef(model_M1)["BMI_5unit"])
CI_BMI <- exp(confint(model_M1)["BMI_5unit", ])
cat("OR for BMI_5unit:", round(OR_BMI, 2), "\n")
cat("95% CI:", round(CI_BMI[1], 2), "to", round(CI_BMI[2], 2), "\n")


#######################################
# Code Block 13: Model M2 – SleepTrouble ~ BMI_5unit + PhysActive

###########################################

# Instructor-based structure – logistic model M2: add main effect of PhysActive
# M2: Add PhysActive to model with BMI_5unit

# Ensure PhysActive is a factor
df_clean$PhysActive <- factor(df_clean$PhysActive)

# Fit model
model_M2 <- glm(SleepTrouble_bin ~ BMI_5unit + PhysActive, data = df_clean, family = binomial("logit"))

# Model summary
summary(model_M2)

# Likelihood ratio test: M1 → M2
anova(model_M1, model_M2, test = "LRT")

# AIC for M2
AIC_M2 <- AIC(model_M2)
cat("AIC of M2:", AIC_M2, "\n")

# Odds ratio and CI for PhysActiveYes
OR_PA <- exp(coef(model_M2)["PhysActiveYes"])
CI_PA <- exp(confint(model_M2)["PhysActiveYes", ])
cat("OR for PhysActive = Yes:", round(OR_PA, 2), "\n")
cat("95% CI:", round(CI_PA[1], 2), "to", round(CI_PA[2], 2), "\n")



#########################################

# Code Block 14: Model M3 – Interaction Between BMI and PhysActive

##############################################

# Instructor-based structure – logistic model M3: test moderation
# M3: Add interaction term between BMI_5unit and PhysActive

# Fit the model
model_M3 <- glm(SleepTrouble_bin ~ BMI_5unit * PhysActive, data = df_clean, family = binomial("logit"))

# Summary output
summary(model_M3)

# Likelihood ratio test: M2 → M3
anova(model_M2, model_M3, test = "LRT")

# AIC for M3
AIC_M3 <- AIC(model_M3)
cat("AIC of M3:", AIC_M3, "\n")

# OR and 95% CI for interaction term
OR_interact <- exp(coef(model_M3)["BMI_5unit:PhysActiveYes"])
CI_interact <- exp(confint(model_M3)["BMI_5unit:PhysActiveYes", ])
cat("Interaction OR:", round(OR_interact, 2), "\n")
cat("95% CI:", round(CI_interact[1], 2), "to", round(CI_interact[2], 2), "\n")


###########################################################

#Code Block 15: Predicted Probabilities by BMI × PhysActive

##############################################################

# Instructor-based structure – interaction plot from logistic model M3
# Figure 3: Predicted probability of SleepTrouble by BMI × PhysActive

# Create new data for prediction
newdata <- expand.grid(
  BMI_5unit = seq(min(df_clean$BMI_5unit), max(df_clean$BMI_5unit), length.out = 100),
  PhysActive = c("Yes", "No")
)

# Predict probabilities with CI
pred <- predict(model_M3, newdata = newdata, type = "link", se.fit = TRUE)
newdata$fit <- pred$fit
newdata$se <- pred$se.fit
newdata$prob <- plogis(newdata$fit)
newdata$lower <- plogis(newdata$fit - 1.96 * newdata$se)
newdata$upper <- plogis(newdata$fit + 1.96 * newdata$se)

# Plot
ggplot(newdata, aes(x = BMI_5unit * 5, y = prob, color = PhysActive)) +
  geom_line(size = 1.2) +
  geom_ribbon(aes(ymin = lower, ymax = upper, fill = PhysActive), alpha = 0.2, color = NA) +
  labs(title = "Predicted Probability of Sleep Trouble",
       x = "BMI (kg/m²)",
       y = "P(SleepTrouble = 1)",
       color = "Physically Active",
       fill = "Physically Active") +
  theme_bw()




































































