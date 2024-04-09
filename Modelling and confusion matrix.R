#Logistic regression
#Import dataset
data <- read.csv("imputed_data.csv")
# Remove the "Customer ID" column using the $ operator data$customerID <- NULL
#transform categorical data into factor
# List of columns to exclude from conversion
exclude_columns <- c("MonthlyCharges", "TotalCharges", "Tenure")
# Convert all other columns to factors
data[, !names(data) %in% exclude_columns] <- lapply(data[, !names(data) %in% exclude_columns], factor)
#run logistic regression
# Load necessary libraries library(glmnet) library(ROCR) library(caTools) library(caret) install.packages("broom") library(broom)
  # Step 1: Create data partitions
  set.seed(123)
# Split the data into train and test sets with stratified sampling
train_indices <- createDataPartition(data$Churn, p = 0.8, list = FALSE, times = 1) trainData <- data[train_indices, ]
testData <- data[-train_indices, ]
# Step 2: Build the logistic regression model
glmmodel <- glm(Churn ~ ., data = trainData, family = "binomial") summary(glmmodel)
#step 3. predict and report accuracy
myprobability <- predict(glmmodel, testData[,-20], type='response') predictionLR <- ifelse(myprobability > 0.5, "1", "0") classificationtable <- table(pred=predictionLR,testData[,20]) accglmmodel <- sum(diag(classificationtable))/sum(classificationtable) accglmmodel
classificationtable
#Visualize the model
tidy_model <- tidy(glmmodel, conf.int = TRUE)
library(ggplot2)
ggplot(tidy_model, aes(x = estimate, y = term)) +
  geom_vline(xintercept = 0, linetype = "dashed") + geom_point() +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high)) + labs(y = "Variable", x = "Coefficient Estimate")
# Convert the actual outcomes and predictions to factors with explicit levels, set 1 = positive
testData[,20] <- factor(testData[,20], levels = c('0', '1'))
predictionLR <- factor(predictionLR, levels = c('0', '1'))
confusion_matrix <- confusionMatrix(predictionLR,testData[,20], positive = "1") confusion_matrix


#Classfication Tree
library(fastDummies) library('tree') library('randomForest')
# Create dummy variables for 'InternetService' and 'Contract' and 'PaymentMethod' (variables with more than 3 levels)
  
  data_dummy <- dummy_cols(data, select_columns = c("InternetService", "Contract", "PaymentMethod"), remove_selected_columns = TRUE, remove_first_dummy = TRUE)
# Move the 'Churn' column to the end
data_dummy <- data_dummy[, c(setdiff(names(data_dummy), "Churn"), "Churn")]
# Split the data into train and test sets with stratified sampling
train_indices <- createDataPartition(data_dummy$Churn, p = 0.8, list = FALSE, times = 1)
trainData <- data_dummy[train_indices, ]
testData <- data_dummy[-train_indices, ]
churnratetable <- table(trainData$Churn)
notchurnrate <- churnratetable[1]/nrow(trainData)
churnrate <- churnratetable[2]/nrow(trainData)
notchurnrate
#Step 1: Using the trainData subsample build a tree using the crossvalidation function. mytree <- tree(Churn~.,trainData)
plot(mytree)
text(mytree)
summary(mytree)
set.seed(1)
mycrossval <- cv.tree(mytree,FUN=prune.tree)
#Classification tree:
tree(formula = Churn ~ ., data = trainData)
#Step 2. Use this tree to test the model in testDataand report the misclassification matrix as #well as the classification accuracy.
mybestsize <- mycrossval$size[which(mycrossval$dev==min(mycrossval$dev))] myprunedtree <- prune.tree(mytree,best =mybestsize[1])
plot(myprunedtree)
text(myprunedtree, cex = 0.8)
summary(myprunedtree)
myprediction <- predict(myprunedtree, testData[,-24], type='class') classificationtable <- table(myprediction,testData[,24])
acctesttree <- sum(diag(classificationtable))/sum(classificationtable)
Acctesttree
#Step 3: Print confusion matrix
library(caret)
confusion_matrix <- confusionMatrix(myprediction,testData[,24], positive = "1") confusion_matrix

  
#Random Forest
#Use Random Forests to model the yeast data.
#Step 1: Using the testData subsample build a random forest and report the variable importance of each explanatory variable.
myrf <- randomForest(Churn~.,trainData,ntree=500,mtry=4,importance=TRUE) importance(myrf)
varImpPlot(myrf)
print(myrf)
#Step 2. Use this random forest to test the model in testData myprediction <- predict(myrf, testData[,-24], type='class')
#Step 3: Print confusion matrix
library(caret)
confusion_matrix <- confusionMatrix(myprediction,testData[,24], positive = "1") confusion_matrix