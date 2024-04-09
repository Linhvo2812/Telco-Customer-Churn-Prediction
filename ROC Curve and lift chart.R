ROC Curve
# Define a custom function to calculate and print the confusion matrix custom_confusion_matrix <- function(glmmodel, testData, threshold = 0.5) {
preds <- predict(glmmodel, testData[, -20], type = 'response')
# Adjust predictions based on the threshold
adjusted_predictions <- as.factor(ifelse(preds >= threshold, "1", "0"))
# Create a confusion matrix. Set the positive class to "1"
confusion_matrix <- confusionMatrix(adjusted_predictions, testData$Churn, positive = "1")
# Print the confusion matrix
print(confusion_matrix) }
# Call the custom function with various threshold custom_confusion_matrix(glmmodel, testData, threshold = 0.5)

  custom_confusion_matrix(glmmodel, testData, threshold = 0.7) custom_confusion_matrix(glmmodel, testData, threshold = 0.3)
# Install and load the pROC package install.packages("pROC") library(pROC)
# Generate predictions for the test set using the logistic regression model ('glmmodel') roc_predictions <- predict(glmmodel, testData, type = "response")
# Compute ROC curve.
roc_obj <- roc(testData$Churn, roc_predictions)
# Plot the ROC curve and display the threshold at which the sum of sensitivity and specificity is maximized.
plot(roc_obj, main = "ROC Curve", col = "blue", lwd = 2,
     print.auc = TRUE, auc.polygon = TRUE, legacy.axes = TRUE, print.thres = "best")
#generate new predicted classes and a corresponding confusion matrix with an optimal cutoff
opt_thresh <- coords(roc_obj, x='best', best.method='closest.topleft')
opt_thresh
Gains Curve
#import gains library
install.packages("gains")
library(gains)
#Here we prepare the data for plotting. We need a few key pieces of information: #1) the actual (ground truth) class;
#2) our predicted class based on our selected threshold value;
#3) the cumulative number of correct predictions for the class of interest (‘delayed’). actual <- ifelse(testData$Churn == 1, 1, 0)
pred_prob <- predict(glmmodel, testData, type = 'response')
# Adjust predictions based on the optimal threshold value pred <- ifelse(pred_prob >= opt_thresh, 1, 0)
# Calculate gains
gain <- gains(actual, pred_prob, groups = length(pred_prob)) nactual <- sum(actual)
#Now we can plot the results.

  ggplot() +
  geom_line(aes(gain$cume.obs, y=gain$cume.pct.of.total*nactual)) + geom_line(aes(x=c(0, max(gain$cume.obs)), y=c(0,nactual)), color='darkgrey') + labs(x='# Cases', y='Cumulative', title = "Gains Curve Over Test Set")
Decile-wise lift charts
#Variation of the gains curve: Decile-wise lift charts
gain10 <- gains(actual, pred_prob, groups= 10) ggplot(mapping = aes(x=gain10$depth, y=gain10$lift/ 100)) +
  geom_col(fill='steelblue') +
  geom_text(aes(label=round(gain10$lift / 100, 1)), vjust=-0.2, size=3) + ylim(0,8) +
  labs(x='Percentile', y='Lift', title='Decile wise lift chart')