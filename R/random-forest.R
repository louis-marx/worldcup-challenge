# install.packages("randomForest", repos = "http://cloud.r-project.org")
library(randomForest)
# detach(games)


### Load data
games <- readRDS(file = "data/games_restructured.rds")
# games <- readRDS(file = "data/games_imputed.rds")
attach(games)


### Missing Value Imputations by randomForest
# games <- rfImpute(team_score ~ ., games)
# saveRDS(games, "data/games_imputed.rds")


### Tune randomForest for the optimal mtry parameter
# score.rf <- tuneRF(games[, -1], games[, 1], ntreeTry = 50, stepFactor = 1.2, improve = 0.001)


### Regression with Random Forest
games_wt <- ifelse(games$tournament == "FIFA World Cup", 3.5, 1)
score.rf <- randomForest(team_score ~ ., data = games, ntree = 500, mtry = 3, importance = TRUE, na.action = na.omit, do.trace = TRUE)
print(score.rf)
print(round(importance(score.rf), 2))
varImpPlot(score.rf)







# Prepare training and test sets
# set.seed(4)
# train <- sample(1:nrow(Games), nrow(Games))
# games.train <- data.frame(subset(Games[train, ], select = -c(team_score)))
# games.test <- subset(Games[-train, ], select = -c(team_score))
# score.train <- as.vector(unlist(data.frame(Games[train, "team_score"])))
# score.test <- unlist(Games[-train, "team_score"])

# Random forest modelling
# Parameters to optimize:  mtry and ntree
# tst <- tuneRF(games.train, score.train,
#     improve = 0.0001, ntreeTry = 500, stepFactor = .5,
#     trace = TRUE, plot = TRUE, doBest = FALSE
# )
# print(tst)
# score.rf <- randomForest(team_score ~ ., data = Games, subset = train, keep.forest = TRUE, importance = TRUE, xtest = games.test, ytest = score.test)
# score.rf <- randomForest(team_score ~ ., data = Games, ntree = 100, do.trace = TRUE)
# plot(score.rf)
# print(importance(score.rf))
# varImpPlot(score.rf)
# r2pmml(rf.games, "models/random_forest.pmml")

detach(games)

# teams <- read.csv("data/teams.csv", colClasses = c("character", "character", "character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))
# teams <- mutate(teams, group = NULL)

# tournament <- data.frame(tournament = "FIFA World Cup", country = "Qatar")

# xgoal <- matrix(0, ncol = nrow(teams), nrow = nrow(teams))
# rownames(xgoal) <- teams$team_fifa_code
# colnames(xgoal) <- teams$team_fifa_code

# teams <- mutate(teams, team_fifa_code = NULL)

# for (i in 1:nrow(teams)) {
#     for (j in 1:nrow(teams)) {
#         team <- teams[i, ]
#         opponent <- rename_with(teams[j, ], ~ gsub("team", "opponent", .x))
#         match <- bind_cols(team, opponent, tournament)
#         # match <- mutate(match, across(c(team_continent, opponent_continent), as.factor))
#         match <- mutate(match, team_hosting = team == country)
#         match <- mutate(match, opponent_hosting = opponent == country)
#         xgoal[i, j] <- predict(score.rf, match, type = "response")
#     }
# }

# print(xgoal)
# write.csv(xgoal, file = "data/xgoal.csv")
