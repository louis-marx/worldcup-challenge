# install.packages("randomForest", repos = "http://cloud.r-project.org")
library(randomForest)
# detach(games)


### Load data
games_to_train <- readRDS(file = "data/games_to_train.rds")
games_to_train <- na.omit(games_to_train)


### Tune randomForest for the optimal mtry parameter
# mse <- Inf
# mtry <- Inf
# for (i in (ncol(games_to_train) - 1):1) {
#     score.rf <- randomForest(team_score ~ ., data = games_to_train, ntree = 100, mtry = i)
#     print(i)
#     print(tail(score.rf$mse, 1))
#     if (tail(score.rf$mse, 1) < mse) {
#         mse <- tail(score.rf$mse, 1)
#         mtry <- i
#     }
# }
# print(mtry)
# print(mse)


### Regression with Random Forest

# games_wt <- ifelse(games$tournament == "FIFA World Cup", 3, 1)
score.rf <- randomForest(team_score ~ ., data = games_to_train, mtry = 1, importance = TRUE)
# score.rf <- randomForest(team_score ~ ., data = games_to_train, importance = TRUE)
print(score.rf)
print(importance(score.rf))

# ### Save variables importance plot as a jpeg file
jpeg("outputs/varImpPlot.jpg", width = 1050, height = 1485)
varImpPlot(score.rf)
dev.off()


### Generate an expected goals matrix for each encounter

games_to_predict <- readRDS("data/games_to_predict.rds")

xgoal <- matrix(0, ncol = sqrt(nrow(games_to_predict)), nrow = sqrt(nrow(games_to_predict)))
rownames(xgoal) <- pull(group_keys(group_by(games_to_predict, team)), team)
colnames(xgoal) <- pull(group_keys(group_by(games_to_predict, team)), team)

for (i in 0:(nrow(games_to_predict) - 1)) {
    x <- i %/% ncol(xgoal) + 1
    y <- i %% nrow(xgoal) + 1
    xgoal[x, y] <- predict(score.rf, games_to_predict[i + 1, ], type = "response")
}

print(xgoal)
write.csv(xgoal, file = "data/xgoal.csv")
