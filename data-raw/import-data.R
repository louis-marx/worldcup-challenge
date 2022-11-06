# install.packages("readxl", repos = "http://cloud.r-project.org")
# install.packages("dplyr", repos = "http://cloud.r-project.org")
library("readxl")
library("dplyr")





################################################## Load data ##################################################

# Load international games dataset
international_games <- read_xlsx("data-raw/DA Challenge - Data International Soccer Games.xlsx",
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

# Load selected teams dataset
selected_teams <- read.csv("data-raw/teams_selection.csv", colClasses = c("character"))
selected_teams <- selected_teams[, "country"]

###############################################################################################################





################## Create a version of the dataset with games from the home team perspective ##################

# Rename columns from home team perspective
home_team_perspective <- rename_with(international_games, ~ gsub("home_", "", .x))
home_team_perspective <- rename_with(home_team_perspective, ~ gsub("away_team", "opponent", .x))

# Replace neutral_location with team_hosting and opponent_hosting variables from home team perspective
home_team_perspective <- mutate(home_team_perspective, team_hosting = !neutral_location, .keep = "unused")
home_team_perspective <- mutate(home_team_perspective, opponent_hosting = FALSE)

# Replace team_result with result variable from home team perspective
home_team_perspective <- rename(home_team_perspective, result = team_result)

###############################################################################################################





################## Create a version of the dataset with games from the away team perspective ##################

# Rename columns from away team perspective
away_team_perspective <- rename_with(international_games, ~ gsub("away_", "", .x))
away_team_perspective <- rename_with(away_team_perspective, ~ gsub("home_team", "opponent", .x))

# Replace neutral_location with team_hosting and opponent_hosting variables from away team perspective
away_team_perspective <- mutate(away_team_perspective, team_hosting = FALSE)
away_team_perspective <- mutate(away_team_perspective, opponent_hosting = !neutral_location, .keep = "unused")

# Replace opponent_result with result variable from away team perspective
away_team_perspective <- mutate(away_team_perspective, result = recode(opponent_result, Win = "Lose", Lose = "Win"), .keep = "unused")

###############################################################################################################





################# Combine the two datasets generated into one with double the number of rows ##################

# Bind datasets from both perspectives
international_games <- bind_rows(home_team_perspective, away_team_perspective)

# Transform fifa rank and points variables into differences
international_games <- mutate(international_games, fifa_rank_difference = opponent_fifa_rank - team_fifa_rank, .keep = "unused", .after = opponent_fifa_rank)
international_games <- mutate(international_games, fifa_points_difference = team_total_fifa_points - opponent_total_fifa_points, .keep = "unused", .after = opponent_total_fifa_points)

# Keep only selected teams games
international_games <- filter(international_games, team %in% selected_teams & opponent %in% selected_teams & country %in% selected_teams)

# Convert string and boolean variables as factors
international_games <- mutate(international_games, across(c(team, opponent, team_continent, opponent_continent, tournament, city, country, team_hosting, opponent_hosting, shoot_out, result), as.factor))

###############################################################################################################





#######################  Finalize the international_games dataset for modelling purpose #######################

# Rearrange rows in chronological order
international_games <- arrange(international_games, date, city)

# Drop useless variables for future modeling
international_games <- mutate(international_games, opponent_score = NULL, date = NULL, result = NULL, shoot_out = NULL, city = NULL)

# Convert tibble to dataframe
international_games <- as.data.frame(unclass(international_games))

# Quick preview of the dataframe to check if everything's ok
print(str(international_games))

# Export the resulting dataset into a RDS format
saveRDS(international_games, "data/games_restructured.rds")

###############################################################################################################
