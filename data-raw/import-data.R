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
games$date <- as.Date(games$date)

# Load teams_to_train dataset
teams_to_train <- read.csv("data-raw/countries_selection.csv", colClasses = c("character", "character"))
teams_to_train <- teams_to_train[, "country"]

# Load country to continent mapping
country_continent <- read.csv("data-raw/country_continent.csv", colClasses = c("character", "character"))

# Load hapiness scores dataset
hapiness_scores <- read.csv("data-raw/hapiness_scores.csv", colClasses = c("character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

# Load teams_to_predict dataset
teams_to_predict <- read.csv("data-raw/worldcup_teams.csv", colClasses = c("character", "character", "character"))
teams_to_predict <- teams_to_predict[, "team"]

# Load worldcup_winners dataset
worldcup_winners <- read.csv("data-raw/worldcup_winners.csv", colClasses = c("Date", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))

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
games <- filter(games, team %in% teams_to_train & opponent %in% teams_to_train)

# # Rearrange rows in chronological order
games <- arrange(games, date, city)

games <- mutate(games, team_world_champion = FALSE, opponent_world_champion = FALSE, team_stars = 0, opponent_stars = 0)
for (i in seq_len(nrow(games))){

    # Add world_champion and stars variables based on historical world cups
    for (j in (seq_len(nrow(worldcup_winners)) - 1)){
        if (games$date[i] <= worldcup_winners$date[j + 1]) {
            if (games$team[i] %in% names(worldcup_winners)) {
                k <- which(colnames(worldcup_winners) == games$team[i])
                games$team_stars[i] <- worldcup_winners[j, k]
                games$team_world_champion[i] <- games$team[i] == worldcup_winners$world_champion[j]
            }
            if (games$opponent[i] %in% names(worldcup_winners)) {
                l <- which(colnames(worldcup_winners) == games$opponent[i])
                games$opponent_stars[i] <- worldcup_winners[j, l]
                games$opponent_world_champion[i] <- games$opponent[i] == worldcup_winners$world_champion[j]
            }
            break
        }
    }

    # Add continent variable
    games$continent[i] <- country_continent$continent[country_continent$country == games$country[i]]

    # Add hapiness score variable
    # games$team_hapiness_score[i] <- 
    year <- make.names(format(games$date[i], format = "%Y"))
    if (year %in% names(hapiness_scores)){
        a <- which(colnames(hapiness_scores) == year)
        b <- which(hapiness_scores$country == games$team[i])
        c <- which(hapiness_scores$country == games$opponent[i])
        games$team_hapiness_score[i] <- hapiness_scores[b, a]
        games$opponent_hapiness_score[i] <- hapiness_scores[c, a]
    } else {
        games$team_hapiness_score[i] <- NaN
        games$opponent_hapiness_score[i] <- NaN
    }
}

# Convert string and boolean variables as factors
games <- mutate(games, across(c(team, opponent, team_continent, opponent_continent, tournament, city, country, team_hosting, opponent_hosting, shoot_out, result, team_world_champion, opponent_world_champion), as.factor))

# Quick preview of the dataframe to check if everything's ok
print(str(games))
# print(sample_n(games, 10))

###############################################################################################################





###########################  Create a games_to_train dataset for modelling purpose ############################

# Transform fifa rank and points variables into differences
games_to_train <- mutate(games, fifa_rank_difference = opponent_fifa_rank - team_fifa_rank, .keep = "unused", .after = opponent_fifa_rank)
games_to_train <- mutate(games_to_train, fifa_points_difference = team_total_fifa_points - opponent_total_fifa_points, .keep = "unused", .after = opponent_total_fifa_points)

# Transform continent informations into boolean
games_to_train <- mutate(games_to_train, team_same_continent = factor(team_continent == continent))
games_to_train <- mutate(games_to_train, opponent_same_continent = factor(opponent_continent == continent))

# Drop useless variables for future modeling
games_to_train <- mutate(games_to_train, opponent_score = NULL, date = NULL, result = NULL, shoot_out = NULL, city = NULL, country = NULL, continent = NULL)

# Convert tibble to dataframe
games_to_train <- as.data.frame(games_to_train)

# Store country and tournament levels for later
tournaments <- levels(games_to_train$tournament)
# countries <- levels(games_to_train$country)
hosting <- levels(games_to_train$team_hosting)

# Quick preview of the dataframe to check if everything's ok
print(str(games_to_train))
# print(sample_n(games_to_train, 10))

# Export the resulting dataset into a RDS format
saveRDS(games_to_train, "data/games_to_train.rds")

###############################################################################################################





####################### Generate a dataframe of teams_to_predict with most recent data ########################

# Keep only teams_to_predict games
teams <- filter(games, team %in% teams_to_predict)

# Retrieve the last game played by each team to get the most recent data
teams <- group_by(teams, team)
teams <- arrange(teams, desc(date), .by_group = TRUE)
teams <- filter(teams, row_number() == 1)
teams <- ungroup(teams)

# Drop useless variables for future modeling
teams <- select(teams, -starts_with("opponent"))
teams <- mutate(teams, date = NULL, tournament = NULL, country = NULL, team_hosting = NULL, team_score = NULL, result = NULL, shoot_out = NULL, city = NULL, continent = NULL)

# Impute missing data with random forest
teams <- rfImpute(team_fifa_rank ~ ., teams)

# Quick preview of the dataframe to check if everything's ok
print(str(teams))
# print(sample_n(teams, 10))

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
        game <- mutate(game, team_same_continent = team_continent == "Asia")
        game <- mutate(game, opponent_same_continent = opponent_continent == "Asia")
        game <- mutate(game, tournament = "FIFA World Cup")
        games_to_predict <- bind_rows(games_to_predict, game)
    }
}

# Transforme variables to factor to match training data types
# games_to_predict <- mutate(games_to_predict, country = factor(country, levels = countries))
games_to_predict <- mutate(games_to_predict, tournament = factor(tournament, levels = tournaments))
games_to_predict <- mutate(games_to_predict, team_hosting = factor(team_hosting, levels = hosting))
games_to_predict <- mutate(games_to_predict, opponent_hosting = factor(opponent_hosting, levels = hosting))
games_to_predict <- mutate(games_to_predict, team_same_continent = factor(team_same_continent, levels = hosting))
games_to_predict <- mutate(games_to_predict, opponent_same_continent = factor(opponent_same_continent, levels = hosting))

# Convert tibble to dataframe
games_to_predict <- as.data.frame(games_to_predict)

# Quick preview of the dataframe to check if everything's ok
print(str(games_to_predict))

# # Export the resulting dataset into a RDS format
saveRDS(games_to_predict, "data/games_to_predict.rds")

###############################################################################################################
