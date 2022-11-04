# install.packages("tree", repos = "http://cloud.r-project.org")
# install.packages("randomForest", repos = "http://cloud.r-project.org")
# install.packages("dplyr", repos = "http://cloud.r-project.org")
library(tree)
library(randomForest)
library(dplyr)

# detach(Games)

# Load data
Games <- readRDS(file = "data/games_restructured.rds")
Games <- subset(Games, select = -c(date, result, shoot_out, city))
Games <- na.omit(Games)
attach(Games)

# Prepare training and test sets
set.seed(4)
train <- sample(1:nrow(Games), 3 * nrow(Games) / 4)
games.test <- subset(Games[-train, ], select = -c(team_score))
score.test <- unlist(Games[-train, "team_score"])

# Random forest modelling
# Parameters to optimize:  mtry and ntree
score.rf <- randomForest(team_score ~ ., data = Games, subset = train, keep.forest = TRUE, importance = TRUE, xtest = games.test, ytest = score.test)
print(score.rf)
print(importance(score.rf))
# varImpPlot(score.rf)
# r2pmml(rf.games, "models/random_forest.pmml")

detach(Games)

teams <- read.csv("data/teams.csv", colClasses = c("character", "character", "character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))
teams <- mutate(teams, group = NULL)

tournament <- data.frame(tournament = "FIFA World Cup", country = "Qatar")

xgoal <- matrix(0, ncol = nrow(teams), nrow = nrow(teams))
rownames(xgoal) <- teams$team_fifa_code
colnames(xgoal) <- teams$team_fifa_code

teams <- mutate(teams, team_fifa_code = NULL)

for (i in 1:nrow(teams)) {
    for (j in 1:nrow(teams)) {
        team <- teams[i, ]
        opponent <- rename_with(teams[j, ], ~ gsub("team", "opponent", .x))
        match <- bind_cols(team, opponent, tournament)
        # match <- mutate(match, across(c(team_continent, opponent_continent), as.factor))
        match <- mutate(match, team_hosting = team == country)
        match <- mutate(match, opponent_hosting = opponent == country)
        xgoal[i, j] <- predict(score.rf, match, type = "response")
    }
}

print(xgoal)
