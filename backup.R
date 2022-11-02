# import-data.R

# install.packages("readxl", repos = "http://cloud.r-project.org")
# install.packages("dplyr", repos = "http://cloud.r-project.org")
library("readxl")
library("dplyr")

internationalGames <- read_xlsx("data-raw/DA Challenge - Data International Soccer Games.xlsx",
    col_types = c(
        "date", "text", "text", "text", "text",
        "numeric", "numeric", "numeric", "numeric",
        "numeric", "numeric", "text", "text",
        "text", "logical", "text", "text",
        "numeric", "numeric", "numeric",
        "numeric", "numeric", "numeric",
        "numeric", "numeric"
    )
)

internationalGamesCopy <- internationalGames

# Rename columns from team perspective
internationalGames <- rename_with(internationalGames, ~ gsub("home_", "", .x))
internationalGames <- rename_with(internationalGames, ~ gsub("away_team", "opponent", .x))

# Rename columns from opponent perspective
internationalGamesCopy <- rename_with(internationalGamesCopy, ~ gsub("away_", "", .x))
internationalGamesCopy <- rename_with(internationalGamesCopy, ~ gsub("home_team", "opponent", .x))

# Replace neutral_location with team_hosting and opponent_hosting variables from team perspective
internationalGames <-  mutate(internationalGames, team_hosting = !neutral_location, .keep = "unused", .after = neutral_location)
internationalGames <- mutate(internationalGames, opponent_hosting = FALSE, .after = team_hosting)

# Replace neutral_location with team_hosting and opponent_hosting variables from opponent perspective
internationalGamesCopy <-  mutate(internationalGamesCopy, team_hosting = FALSE, .after = neutral_location)
internationalGamesCopy <- mutate(internationalGamesCopy, opponent_hosting = !neutral_location, .keep = "unused", .after = team_hosting)

# Replace team_result with result variable from team perspective
internationalGames <- rename(internationalGames, result = team_result)

# Replace opponent_result with result variable from opponent perspective
internationalGamesCopy <-  mutate(internationalGamesCopy, result = recode(opponent_result, Win = "Lose", Lose = "Win"), .keep = "unused", .after = opponent_result)

Games <- bind_rows(internationalGames, internationalGamesCopy)
Games <- mutate(Games, opponent_score = NULL)
Games <- mutate(Games, across(c(team_continent, opponent_continent, shoot_out, result), as.factor))
Games <- arrange(Games, date, city)

saveRDS(Games, "data/games_restructured.rds")


# poisson-regression.R

Games <- readRDS(file = "data/games_restructured.rds")

# attach(Games)

Games <- data.frame(lapply(Games, function(x) Reduce(c, x)), stringsAsFactors = TRUE)



# contrasts(games$team) <- contr.sum(length(unique(team)))
# contrasts(games$opponent) <- contr.sum(length(unique(opponent)))

# mod.lm <- lm(goals ~ team + opponent + rank + host + host_oppo, data = games)
# print(summary(mod.lm))

# mod.pois <- glm(goals ~ team + opponent + rank + host + host_oppo, data = games, family = poisson)
# print(summary(mod.pois))

# brazil <- data.frame(team = "Brazil", opponent = "Qatar", rank = 49, host = FALSE, host_oppo = FALSE, stringsAsFactors = TRUE)
# print(predict(mod.pois, brazil, type = "response"))
# qatar <- data.frame(team = "Qatar", opponent = "Brazil", rank = -49, host = FALSE, host_oppo = FALSE, stringsAsFactors = TRUE)
# print(predict(mod.pois, qatar, type = "response"))

# detach(Games)

# random-forest.R

# install.packages("tree", repos = "http://cloud.r-project.org")
# install.packages("randomForest", repos = "http://cloud.r-project.org")
library(tree)
library(randomForest)

# Load data
Games <- readRDS(file = "data/games_restructured.rds")
attach(Games)

# Prepare training and test sets
set.seed(1)
train <- sample (1: nrow(Games), nrow(Games)/2)
games.test <- unlist(Games[-train, 'team_score'])

# Regression tree modelling
# tree.games <- tree(team_score ~ team + opponent + team_fifa_rank + opponent_fifa_rank + team_hosting + opponent_hosting, Games , subset = train)
# print(summary(tree.games))
# plot(tree.games)
# text(tree.games, , pretty=0)
# cv.games <- cv.tree(tree.games)
# plot(cv.games$size, cv.games$dev, type="b")
# predicted.score <- predict(tree.games, newdata = Games[-train,])
# print(mean((yhat - games.test)^2))

# Random forest modelling
rf.games <- randomForest(team_score ~ team + opponent + team*opponent + team_fifa_rank + opponent_fifa_rank + team_hosting + opponent_hosting, data = Games, subset = train, importance = TRUE)
predicted.score <- predict(rf.games, newdata = Games[-train,])
print(mean((predicted.score - games.test)^2))
print(importance(rf.games))
varImpPlot(rf.games)

detach(Games)