# install.packages("tree", repos = "http://cloud.r-project.org")
# install.packages("randomForest", repos = "http://cloud.r-project.org")
# install.packages("r2pmml", repos = "http://cloud.r-project.org")
# install.packages("gbm", repos = "http://cloud.r-project.org")
# install.packages("BART", repos = "http://cloud.r-project.org")
library(tree)
library(randomForest)
# library(r2pmml)
library(gbm)
library(BART)

# detach(Games)

# Load data
Games <- readRDS(file = "data/games_restructured.rds")
Games <- subset(Games, select = -c(date, result, shoot_out))
Games <- na.omit(Games)
attach(Games)

# Prepare training and test sets
set.seed(4)
train <- sample(1:nrow(Games), 3 * nrow(Games) / 4)
games.test <- subset(Games[-train, ], select = -c(team_score))
score.test <- Games[-train, "team_score"]

# Random forest modelling
# Parameters to optimize:  mtry and ntree
score.rf <- randomForest(team_score ~ ., data = Games, subset = train, importance = TRUE, xtest = games.test, ytest = score.test)
print(score.rf)
print(importance(score.rf))
varImpPlot(score.rf)
# r2pmml(rf.games, "models/random_forest.pmml")

detach(Games)
