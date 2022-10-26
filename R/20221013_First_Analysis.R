# Data Challenge - Win World Cup 22#

# clear working environment
remove(list = ls())

# set working directory
# setwd("~/D&A team/Data Challenge - Win the World Cup 22/Data")

# packages
# install.packages("plyr", repos = "http://cloud.r-project.org")
# install.packages("dplyr", repos = "http://cloud.r-project.org")
library("readxl")
library("plyr")
library("dplyr")

# import database
games <- read_excel("./data/raw/DA Challenge - Data International Soccer Games.xlsx",
        sheet = "international_matches",
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
head(games)
tail(games)

# explore data

summary(games) # last rows (scores) have about 15.000 NAs, other variables don't have any

# clean data

# create a "Year" column for analysis' sake
games$year <- as.Date(substr(games$date, 1, 4), "%Y")
unique(games$year) # From 1993 to 2022

# any cleaning actions ?

# describing data

# Top 10 ranked teams
teams_rank_home_all <- subset(games, select = c("date", "home_team", "home_team_fifa_rank"))
teams_rank_home_s <- teams_rank_home_all[order(teams_rank_home_all$date, decreasing = TRUE), ]
colnames(teams_rank_home_s) <- c("date", "team", "fifa_rank")


teams_rank_away_all <- subset(games, select = c("date", "away_team", "away_team_fifa_rank"))
teams_rank_away_s <- teams_rank_away_all[order(teams_rank_away_all$date, decreasing = TRUE), ]
colnames(teams_rank_away_s) <- c("date", "team", "fifa_rank")

teams_rank <- rbind(teams_rank_home_s, teams_rank_away_s)

arranged_teams_rank <- arrange(teams_rank, teams_rank$date, teams_rank$fifa_rank, decreasing = c(TRUE, FALSE))

# years described in the data ( = is data recent ?)
my_tab_barplot <- table(games$year)
barplot(my_tab_barplot,
        ylab = "Frequency",
        xlab = "Dates",
        col = c("#EB8C00"),
        main = "Games repartition in time"
) # it is kind of old but ok

# countries described in the data ( = is data overfitted for Europe ?)

# away team
my_tab_barplot_continents_away <- table(games$away_team_continent)
barplot(my_tab_barplot_continents_away,
        ylab = "Frequency",
        xlab = "Continents",
        col = c("#FFD300"),
        main = "Away teams' continents"
) # seems ok

# home team
my_tab_barplot_continents_home <- table(games$home_team_continent)
barplot(my_tab_barplot_continents_home,
        ylab = "Frequency",
        xlab = "Continents",
        col = c("#D6B85A"),
        main = "Home teams' continents"
) # seems ok

# home team result vs. fifa rank
boxplot(games$home_team_fifa_rank ~ games$home_team_result,
        ylab = "FIFA rank",
        xlab = "Game result",
        main = "Game result against FIFA rank (home team)"
)

# home advantage ?
my_tab_barplot_neutral_games <- table(games$home_team_result, games$neutral_location)
barplot(my_tab_barplot_neutral_games, col = c("lightgrey", "#FF7F7F", "lightgreen"), legend.text = T)

my_tab_neutral_games_perc <- 100 * prop.table(my_tab_barplot_neutral_games)
my_tab_neutral_games_perc # % on all games

# creating subsets
neutral_games <- subset(games, games$neutral_location == "TRUE")
home_games <- subset(games, games$neutral_location == "FALSE")

# neutral location
my_tab_barplot_neutral_games_V2 <- table(neutral_games$home_team_result, neutral_games$neutral_location)
my_tab_neutral_games_perc_V2 <- 100 * prop.table(my_tab_barplot_neutral_games_V2)
my_tab_neutral_games_perc_V2

# home team location
my_tab_barplot_non_neutral_games <- table(home_games$home_team_result, home_games$neutral_location)
my_tab_home_games_perc <- 100 * prop.table(my_tab_barplot_non_neutral_games)
my_tab_home_games_perc # petite différence (43% win quand neutre et 51% quand home)

###################################################################

# restructuration de la database

games_1 <- read_excel("~/D&A team/Data Challenge - Win the World Cup 22/Data/V2_DA Challenge - Data International Soccer Games.xlsx",
        sheet = "international_matches",
        col_types = c(
                "date", "text", "text", "text", "text",
                "numeric", "numeric", "numeric", "numeric",
                "numeric", "numeric", "text", "text",
                "text", "logical", "logical", "text", "text",
                "numeric", "numeric", "numeric",
                "numeric", "numeric", "numeric",
                "numeric", "numeric"
        )
)

games_2 <- read_excel("~/D&A team/Data Challenge - Win the World Cup 22/Data/V3_DA Challenge - Data International Soccer Games.xlsx",
        sheet = "international_matches",
        col_types = c(
                "date", "text", "text", "text", "text",
                "numeric", "numeric", "numeric", "numeric",
                "numeric", "numeric", "text", "text",
                "text", "logical", "logical", "text", "text",
                "numeric", "numeric", "numeric",
                "numeric", "numeric", "numeric",
                "numeric", "numeric"
        )
)

colnames(games_2)
games_3 <- games_2[, c(1, 3, 2, 5, 4, 7, 6, 9, 8, 11, 10, 12, 13, 14, 16, 15, 17, 18, 20, 19, 24, 25, 26, 21, 22, 23)]

games <- rbind(games_1, games_3)
