# install.packages("readxl", repos = "http://cloud.r-project.org")
# install.packages("dplyr", repos = "http://cloud.r-project.org")
library("readxl")
library("dplyr")

internationalGames <- read_xlsx("./data/raw/DA Challenge - Data International Soccer Games.xlsx",
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

internationalGames <- rename_with(internationalGames, ~ gsub("home_", "", .x))
internationalGames <- rename_with(internationalGames, ~ gsub("away_team", "opponent", .x))

internationalGamesCopy <- rename_with(internationalGamesCopy, ~ gsub("away_", "", .x))
internationalGamesCopy <- rename_with(internationalGamesCopy, ~ gsub("home_team", "opponent", .x))

print(str(internationalGames))
print(str(internationalGamesCopy))
