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
