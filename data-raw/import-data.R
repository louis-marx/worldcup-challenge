# install.packages("readxl", repos = "http://cloud.r-project.org")
# install.packages("dplyr", repos = "http://cloud.r-project.org")
library(readxl)
library(dplyr)
library(randomForest)





################################################## Load data ##################################################

# Load international games dataset
games <- read_xlsx("data-raw/DA Challenge - Data International Soccer Games.xlsx",
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

# Load teams_to_train dataset
teams_to_train <- read.csv("data-raw/teams_selection.csv", colClasses = c("character"))
teams_to_train <- teams_to_train[, "country"]

# Load teams_to_predict dataset
teams_to_predict <- read.csv("data-raw/teams.csv", colClasses = c("character", "character", "character"))
teams_to_predict <- teams_to_predict[, "team"]

###############################################################################################################





################## Create a version of the dataset with games from the home team perspective ##################

# Rename columns from home team perspective
home_team_perspective <- rename_with(games, ~ gsub("home_", "", .x))
home_team_perspective <- rename_with(home_team_perspective, ~ gsub("away_team", "opponent", .x))

# Replace neutral_location with team_hosting and opponent_hosting variables from home team perspective
home_team_perspective <- mutate(home_team_perspective, team_hosting = !neutral_location, .keep = "unused")
home_team_perspective <- mutate(home_team_perspective, opponent_hosting = FALSE)

# Replace team_result with result variable from home team perspective
home_team_perspective <- rename(home_team_perspective, result = team_result)

###############################################################################################################





################## Create a version of the dataset with games from the away team perspective ##################

# Rename columns from away team perspective
away_team_perspective <- rename_with(games, ~ gsub("away_", "", .x))
away_team_perspective <- rename_with(away_team_perspective, ~ gsub("home_team", "opponent", .x))

# Replace neutral_location with team_hosting and opponent_hosting variables from away team perspective
away_team_perspective <- mutate(away_team_perspective, team_hosting = FALSE)
away_team_perspective <- mutate(away_team_perspective, opponent_hosting = !neutral_location, .keep = "unused")

# Replace opponent_result with result variable from away team perspective
away_team_perspective <- mutate(away_team_perspective, result = recode(opponent_result, Win = "Lose", Lose = "Win"), .keep = "unused")

###############################################################################################################





################# Combine the two datasets generated into one with double the number of rows ##################

# Bind datasets from both perspectives
games <- bind_rows(home_team_perspective, away_team_perspective)

# Keep only teams_to_train games
games <- filter(games, team %in% teams_to_train & opponent %in% teams_to_train & country %in% teams_to_train)

# Convert string and boolean variables as factors
games <- mutate(games, across(c(team, opponent, team_continent, opponent_continent, tournament, city, country, team_hosting, opponent_hosting, shoot_out, result), as.factor))

###############################################################################################################





###########################  Create a games_to_train dataset for modelling purpose ############################

# Transform fifa rank and points variables into differences
games_to_train <- mutate(games, fifa_rank_difference = opponent_fifa_rank - team_fifa_rank, .keep = "unused", .after = opponent_fifa_rank)
games_to_train <- mutate(games_to_train, fifa_points_difference = team_total_fifa_points - opponent_total_fifa_points, .keep = "unused", .after = opponent_total_fifa_points)

# Rearrange rows in chronological order
games_to_train <- arrange(games_to_train, date, city)

# Drop useless variables for future modeling
games_to_train <- mutate(games_to_train, opponent_score = NULL, date = NULL, result = NULL, shoot_out = NULL, city = NULL)

# Convert tibble to dataframe
games_to_train <- as.data.frame(games_to_train)

# Store country and tournament levels for later
tournaments <- levels(games_to_train$tournament)
countries <- levels(games_to_train$country)
hosting <- levels(games_to_train$team_hosting)

# Quick preview of the dataframe to check if everything's ok
print(str(games_to_train))

# Export the resulting dataset into a RDS format
saveRDS(games_to_train, "data/games_to_train.rds")

###############################################################################################################





####################### Generate a dataframe of teams_to_predict with most recent data ########################

# Keep only teams_to_predict games
teams <- filter(games, team %in% teams_to_predict & opponent %in% teams_to_predict)

# Retrieve the last game played by each team to get the most recent data
teams <- group_by(teams, team)
teams <- arrange(teams, desc(date), .by_group = TRUE)
teams <- filter(teams, row_number() == 1)
teams <- ungroup(teams)

# Drop useless variables for future modeling
teams <- select(teams, -starts_with("opponent"))
teams <- mutate(teams, date = NULL, tournament = NULL, country = NULL, team_hosting = NULL, team_score = NULL, result = NULL, shoot_out = NULL, city = NULL)

# Impute missing data with random forest
teams <- rfImpute(team_fifa_rank ~ ., teams)

# Quick preview of the dataframe to check if everything's ok
print(str(teams))

###############################################################################################################





#########################  Create a games_to_predict dataset to prepare the simuation ####################

# Create an empty list
games_to_predict <- NULL

# Generate all possible games
for (i in 1:nrow(teams)) {
    for (j in 1:nrow(teams)) {
        team <- teams[i, ]
        opponent <- rename_with(teams[j, ], ~ gsub("team", "opponent", .x))
        game <- bind_cols(team, opponent)
        game <- mutate(game, fifa_rank_difference = opponent_fifa_rank - team_fifa_rank, .keep = "unused", .after = opponent_fifa_rank)
        game <- mutate(game, fifa_points_difference = team_total_fifa_points - opponent_total_fifa_points, .keep = "unused", .after = opponent_total_fifa_points)
        game <- mutate(game, team_hosting = team == "Qatar")
        game <- mutate(game, opponent_hosting = opponent == "Qatar")
        game <- mutate(game, country = "Qatar")
        game <- mutate(game, tournament = "FIFA World Cup")
        games_to_predict <- bind_rows(games_to_predict, game)
    }
}

# Transforme variables to factor to match training data types
games_to_predict <- mutate(games_to_predict, country = factor(country, levels = countries))
games_to_predict <- mutate(games_to_predict, tournament = factor(tournament, levels = tournaments))
games_to_predict <- mutate(games_to_predict, team_hosting = factor(team_hosting, levels = hosting))
games_to_predict <- mutate(games_to_predict, opponent_hosting = factor(opponent_hosting, levels = hosting))

# Convert tibble to dataframe
games_to_predict <- as.data.frame(games_to_predict)

# Quick preview of the dataframe to check if everything's ok
print(str(games_to_predict))

# # Export the resulting dataset into a RDS format
saveRDS(games_to_predict, "data/games_to_predict.rds")

###############################################################################################################
