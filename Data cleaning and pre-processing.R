## Install and load packages ---- library(naniar)
library(visdat) library(tidyverse) install.packages("mice") library(mice)
## Load Data ---- setwd("/Users/linhvo/Documents/SOL/Big data analytics") # 0. Import dataset
df <- read.csv("Data/customer churn/Churn2.csv")
# Choose col with missing data
columns_to_replace <- c("OnlineSecurity", "OnlineBackup", "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies")
# Replace the value 2 with NA in the specified columns
df[, columns_to_replace] <- lapply(df[, columns_to_replace], function(x) replace(x, x == 2, NA))
# Now the value 2 is replaced with NA in the specified columns, and you can use df with the mcar_test function
# 3. Visualize the missing data pattern in the 'df' dataset using the 'vis_miss' function vis_miss(df)
# 4. Use the 'miss_var_summary' function to summarize missingness for each variable in the 'df' dataset.
miss_var_summary(df)
# 5. Apply Little's (1988) MCAR test to assess whether the data in the dataset is missing completely at random.
mcar_test(df)
#p-value = 0, data is not missing at random
# Perform multiple imputation using logistic regression for binary data #create a named vector with default methods for all variables
meth <- rep("", ncol(df))
names(meth) <- names(df)
- 24 -
  # Specify logistic regression for binary variables
  binary_vars <- c("OnlineSecurity", "OnlineBackup", "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies")
meth[binary_vars] <- "logreg"
#impute data
imputed_data <- mice(df, method = 'meth', m = 5, maxit = 5)
# Create a complete dataset by averaging the imputed datasets completed_data <- complete(imputed_data, action = 'long', include = TRUE) # Assuming 'imputed_data' is the object returned by the mice() function completed_data <- complete(imputed_data, action = 1)
# The 'completed_data' dataframe should now have the same number of rows as 'df' # Export the completed data into csv
write.csv(completed_data, file = "imputed_data.csv", row.names = FALSE)
