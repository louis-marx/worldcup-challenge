# install.packages("randomForest", repos = "http://cloud.r-project.org")
library(randomForest)
library(dplyr)
# detach(games)


### Load data
games_to_train <- readRDS(file = "data/games_to_train.rds")
games_to_train <- na.omit(games_to_train)
gamesx <- games_to_train[, -7]
gamesy <- games_to_train[, 7]

# shootouts_to_train <- readRDS(file = "data/shootouts_to_train.rds")
# shootouts_to_train <- na.omit(shootouts_to_train)
# shootoutsx <- shootouts_to_train[, -10]
# shootoutsy <- droplevels(shootouts_to_train[, 10])

### Feature selection
p <- ncol(gamesx)
n.var <- seq(from = p, to = 1, by = -1)
k <- length(n.var)
all.rf <- randomForest(team_score ~ ., data = games_to_train, mtry = 1, ntree = 1000, importance = TRUE)
impvar <- (1:p)[order(importance(all.rf, type = 1), decreasing = TRUE)]
subset <- impvar
mse <- all.rf$mse[length(all.rf$mse)]
print(all.rf$mse[length(all.rf$mse)])
for (j in 2:k) {
    imp.idx <- impvar[1:n.var[j]]
    sub.rf <- randomForest(gamesx[, imp.idx, drop = FALSE], gamesy, mtry = 1, ntree = 1000, importance = TRUE)
    impvar <- (1:length(imp.idx))[order(importance(sub.rf, type = 1), decreasing = TRUE)]
    if (sub.rf$mse[length(sub.rf$mse)] < mse) {
        mse <- sub.rf$mse[length(sub.rf$mse)]
        subset <- impvar
    }
    print(sub.rf$mse[length(all.rf$mse)])
}

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
score.rf <- randomForest(gamesx[, subset], gamesy, mtry = 1, ntree = 10000, importance = TRUE, do.trace = TRUE)
print(score.rf)
print(importance(score.rf))

# ### Save variables importance plot as a jpeg file
jpeg("outputs/varImpPlot.jpg", width = 1050, height = 1485)
varImpPlot(score.rf)
dev.off()

### Classification with Random Forest

# shootout.rf <- randomForest(shootoutsx, shootoutsy, ntree = 1000, importance = TRUE, do.trace = TRUE)
# print(shootout.rf)
# print(varImpPlot(shootout.rf))


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


### Generate an expected result matrix for each possible match outcomes

# shootouts_to_predict <- readRDS("data/shootouts_to_predict.rds")

# xresult <- matrix(0, ncol = 4, nrow = nrow(shootouts_to_predict))
# colnames(xresult) <- c('team', 'opponent', 'score', 'result')

# for (i in seq_len(nrow(shootouts_to_predict))) {
#     xresult[i, 1] <- shootouts_to_predict[i, 1]
#     xresult[i, 2] <- shootouts_to_predict[i, 11]
#     xresult[i, 3] <- shootouts_to_predict[i, 26]
#     xresult[i, 4] <- predict(shootout.rf, shootouts_to_predict[i,], type = "response")
# }

# print(xresult)
# write.csv(xgoal, file = "data/xgoal.csv")
