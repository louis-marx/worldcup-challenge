# install.packages("randomForest", repos = "http://cloud.r-project.org")
library(randomForest)
detach(games)


### Load data
games <- readRDS(file = "data/games_restructured.rds")
# games <- readRDS(file = "data/games_imputed.rds")
print(str(games))
attach(games)


### Missing Value Imputations by randomForest
# games <- rfImpute(team_score ~ ., games)
# saveRDS(games, "data/games_imputed.rds")


### Tune randomForest for the optimal mtry parameter
# score.rf <- tuneRF(games[, -1], games[, 1], ntreeTry = 50, stepFactor = 1.2, improve = 0.001)


### Regression with Random Forest
# games_wt <- ifelse(games$tournament == "FIFA World Cup", 3, 1)
# score.rf <- randomForest(team_score ~ ., data = games, ntree = 500, mtry = 3, importance = TRUE, na.action = na.omit, do.trace = TRUE)
# print(score.rf)
# print(round(importance(score.rf), 2))
# varImpPlot(score.rf)


# detach(games)


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
        match <- mutate(match, team_hosting = team == country)
        match <- mutate(match, opponent_hosting = opponent == country)
        match <- mutate(match, fifa_rank_difference = opponent_fifa_rank - team_fifa_rank, .keep = "unused", .after = opponent_fifa_rank)
        match <- mutate(match, fifa_points_difference = team_total_fifa_points - opponent_total_fifa_points, .keep = "unused", .after = opponent_total_fifa_points)
        match <- mutate(match, across(c(team, opponent, team_continent, opponent_continent, tournament, country, team_hosting, opponent_hosting), as.factor))
        print(str(match))
        xgoal[i, j] <- predict(score.rf, match, type = "response")
    }
}

print(xgoal)
write.csv(xgoal, file = "data/xgoal.csv")
