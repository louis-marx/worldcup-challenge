# install.packages("tree", repos = "http://cloud.r-project.org")
# install.packages("randomForest", repos = "http://cloud.r-project.org")
# install.packages("r2pmml", repos = "http://cloud.r-project.org")
library(tree)
library(randomForest)
# library(r2pmml)

# Load data
Games <- readRDS(file = "data/games_restructured.rds")
Games <- subset(Games, select = -c(result, shoot_out))
Games <- na.omit(Games)
attach(Games)

# Prepare training and test sets
set.seed(1)
train <- sample (1: nrow(Games), nrow(Games)/2)
games.test <- unlist(Games[-train, 'team_score'])

# Regression tree modelling
# tree.games <- tree(team_score ~ team + opponent + team_continent + opponent_continent + team_fifa_rank + opponent_fifa_rank + team_total_fifa_points + opponent_total_fifa_points + tournament + city + country + team_hosting + opponent_hosting, data = Games , subset = train)
# print(summary(tree.games))
# plot(tree.games)
# text(tree.games, , pretty=0)
# cv.games <- cv.tree(tree.games)
# plot(cv.games$size, cv.games$dev, type="b")
# predicted.score <- predict(tree.games, newdata = Games[-train,])
# print(mean((predicted.score - games.test)^2))

# Random forest modelling
rf.games <- randomForest(team_score ~ ., data = Games, subset = train, importance = TRUE, ntree = 500)
predicted.score <- predict(rf.games, newdata = Games[-train,])
print(mean((predicted.score - games.test)^2))
print(importance(rf.games))
varImpPlot(rf.games)
# r2pmml(rf.games, "models/random_forest.pmml")

detach(Games)