#Data Challenge - Win World Cup 22#

#clear working environment
remove(list=ls())

#set working directory
setwd("~/D&A team/Data Challenge - Win the World Cup 22/Data")

#packages
library("readxl")
library("plyr")
library("dplyr")
library("randomForest")

#import database
games <- read_excel("~/D&A team/Data Challenge - Win the World Cup 22/Data/DA Challenge - Data International Soccer Games.xlsx", 
                    sheet = "international_matches", 
                    col_types = c("date", "text", "text", "text", "text", 
                                  "numeric","numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "text", "text", 
                                  "text", "logical", "text", "text", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric"))                                
head(games)
tail(games)

#explore data

summary(games) #last rows (scores) have about 15.000 NAs, other variables don't have any

#clean data

#create a "Year" column for analysis' sake
games$year <- as.Date(substr(games$date,1,4), "%Y")
unique(games$year) #From 1993 to 2022

#any cleaning actions ?

#describing data

#Top 10 ranked teams
teams_rank_home_all <- subset(games, select = c("date", "home_team", "home_team_fifa_rank"))
teams_rank_home_s <- teams_rank_home_all[order(teams_rank_home_all$date, decreasing = TRUE),]
colnames(teams_rank_home_s) <- c("date", "team", "fifa_rank")


teams_rank_away_all <- subset(games, select = c("date", "away_team", "away_team_fifa_rank"))
teams_rank_away_s <- teams_rank_away_all[order(teams_rank_away_all$date, decreasing = TRUE),]
colnames(teams_rank_away_s) <- c("date", "team", "fifa_rank")

teams_rank <- rbind(teams_rank_home_s, teams_rank_away_s)

arranged_teams_rank <- arrange(teams_rank, teams_rank$date, teams_rank$fifa_rank, decreasing = c(TRUE, FALSE))

#years described in the data ( = is data recent ?)
my_tab_barplot <- table(games$year)
barplot(my_tab_barplot,
        ylab = "Frequency",
        xlab = "Dates",
        col = c("#EB8C00"),
        main = "Games repartition in time") #it is kind of old but ok

#countries described in the data ( = is data overfitted for Europe ?)

#away team
my_tab_barplot_continents_away <- table(games$away_team_continent)
barplot(my_tab_barplot_continents_away,
        ylab = "Frequency",
        xlab = "Continents",
        col = c("#FFD300"),
        main = "Away teams' continents") #seems ok

#home team
my_tab_barplot_continents_home <- table(games$home_team_continent)
barplot(my_tab_barplot_continents_home,
        ylab = "Frequency",
        xlab = "Continents",
        col = c("#D6B85A"),
        main = "Home teams' continents") #seems ok

#home team result vs. fifa rank
boxplot(games$home_team_fifa_rank~games$home_team_result,
        ylab = "FIFA rank",
        xlab = "Game result",
        main = "Game result against FIFA rank (home team)")

#home advantage ?
my_tab_barplot_neutral_games <- table(games$home_team_result, games$neutral_location)
barplot(my_tab_barplot_neutral_games, col=c("lightgrey", "#FF7F7F", "lightgreen"), legend.text = T)

my_tab_neutral_games_perc <- 100*prop.table(my_tab_barplot_neutral_games)
my_tab_neutral_games_perc # % on all games

#creating subsets
neutral_games <- subset(games, games$neutral_location == "TRUE")
home_games <- subset(games, games$neutral_location == "FALSE")

#neutral location
my_tab_barplot_neutral_games_V2 <- table(neutral_games$home_team_result, neutral_games$neutral_location)
my_tab_neutral_games_perc_V2 <- 100*prop.table(my_tab_barplot_neutral_games_V2)
my_tab_neutral_games_perc_V2

#home team location
my_tab_barplot_non_neutral_games <- table(home_games$home_team_result, home_games$neutral_location)
my_tab_home_games_perc <- 100*prop.table(my_tab_barplot_non_neutral_games)
my_tab_home_games_perc #petite différence (43% win quand neutre et 51% quand home)

###################################################################

#restructuration de la database

games_1 <- read_excel("~/D&A team/Data Challenge - Win the World Cup 22/Data/V2_DA Challenge - Data International Soccer Games.xlsx", 
                    sheet = "international_matches", 
                    col_types = c("date", "text", "text", "text", "text", 
                                  "numeric","numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "text", "text", 
                                  "text", "logical","logical", "text", "text", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric", "numeric", 
                                  "numeric", "numeric"))

games_2 <- read_excel("~/D&A team/Data Challenge - Win the World Cup 22/Data/V3_DA Challenge - Data International Soccer Games.xlsx", 
                      sheet = "international_matches", 
                      col_types = c("date", "text", "text", "text", "text", 
                                    "numeric","numeric", "numeric", "numeric", 
                                    "numeric", "numeric", "text", "text", 
                                    "text", "logical","logical", "text", "text", 
                                    "numeric", "numeric", "numeric", 
                                    "numeric", "numeric", "numeric", 
                                    "numeric", "numeric"))

colnames(games_2)
games_3 <- games_2[, c(1, 3, 2, 5, 4, 7, 6, 9, 8, 11, 10, 12, 13, 14, 16, 15, 17, 18, 20, 19, 24, 25, 26, 21, 22, 23)]

games <- rbind(games_1, games_3)
class(games)

summary(games)
str(games)

games <- as.data.frame(games)
class(games) #data.frame

##random forest

#separate the data into training and testing sets
set.seed(2022)

training <- sample(1:nrow(games), nrow(games)*0.7)
games.train <- games[training,]
games.test <- games[-training,]

#random forest
games.rf <- randomForest(team_a_score ~ team_a + team_b,
                         data=games.train,
                         importance = TRUE) #error (missing values in object ?)


#It seems that the error might have occured because the underlying randomForest R
#package cannot handle categorical predictors with more than 53 categories

unique(games$team_a) #We have 211 country teams

unique(games$country) #We have 217 country locations

unique(games$date) #Does it count ? More than 5.000 different dates

unique(games$team_a_continent) # OK, 6 continents

unique(games$tournament) #82 tournoi différents



#predictions on testing set
pred.rf <- predict(games.rf,games.test)

#confusion matrix
table()

#variable importance

#Variable importance (VI) is computed as the total decrease in node
#impurities from splitting on the variable, averaged over all trees.
#The node impurity is measured by the Gini index for classification and MSE for regression
varImpPlot(games.rf)

#Add stars (World Cup victories ) to teams (time-sensitive)

games$team_a_stars <- 0

#Uruguay

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "Uruguay"){
    games$team_a_stars[i] <- 2
  } else {
    games$team_a_stars[i] <- 0
  }
}

#test
games [15,] #OK
    
#Italy

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "Italy" && games$date[i]< "2006-07-09"){
    games$team_a_stars[i] <- 3
  } else {
    if (games$team_a[i] == "Italy" && games$date[i]>= "2006-07-09"){
      games$team_a_stars[i] <- 4
    } else {
      games$team_a_stars[i] <- 0
    }
  }
}

#test
games [84,] #OK

#Germany

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "Germany" && games$date[i]< "2014-07-13"){
    games$team_a_stars[i] <- 3
  } else {
    if (games$team_a[i] == "Germany" && games$date[i]>= "2014-07-13"){
      games$team_a_stars[i] <- 4
    } else {
      games$team_a_stars[i] <- 0
    }
  }
}


#test
games [252,] #OK


#Brazil

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "Brazil" && games$date[i]< "1994-07-17"){
    games$team_a_stars[i] <- 3
  } else {
    if (games$team_a[i] == "Brazil" && games$date[i]>= "1994-07-17" && games$date[i]<"2002-06-30"){
      games$team_a_stars[i] <- 4 
    } else {
      if (games$team_a[i] == "Brazil" && games$date[i]>= "2002-06-30"){
      games$team_a_stars[i] <- 5
      } else {
      games$team_a_stars[i] <- 0
    }
  }
}
}

#test
games [724,] #OK

#England

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "England") {
    games$team_a_stars[i] <- 1
  } else {
    games$team_a_stars[i] <- 0
    }
}

#Argentina

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "Argentina") {
    games$team_a_stars[i] <- 2
  } else {
    games$team_a_stars[i] <- 0
  }
}

#France

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "France" && games$date[i]< "1998-07-12"){
    games$team_a_stars[i] <- 0
  } else {
    if (games$team_a[i] == "France" && games$date[i]>= "1998-07-12" && games$date[i]<"2018-07-15"){
      games$team_a_stars[i] <- 1
    } else {
      if (games$team_a[i] == "France" && games$date[i]>= "2018-07-15"){
        games$team_a_stars[i] <- 2
      } else {
        games$team_a_stars[i] <- 0
      }
    }
  }
}

#Spain

for (i in 1:nrow(games)) {
  if(games$team_a[i] == "Spain" && games$date[i]< "2010-07-11"){
    games$team_a_stars[i] <- 0
  } else {
    if (games$team_a[i] == "Spain" && games$date[i]>= "2010-07-11"){
      games$team_a_stars[i] <- 1 
    } else {
      games$team_a_stars[i] <- 0
    }
  }
}

#all_coutries
for (i in 1:nrow(games)) {
  if(games$team_a[i] == "Uruguay"){
    games$team_a_stars[i] <- 2
  } else {
    if(games$team_a[i] == "Italy" && games$date[i]< "2006-07-09"){
      games$team_a_stars[i] <- 3
    } else {
      if (games$team_a[i] == "Italy" && games$date[i]>= "2006-07-09"){
        games$team_a_stars[i] <- 4
      } else {
        if(games$team_a[i] == "Germany" && games$date[i]< "2014-07-13"){
          games$team_a_stars[i] <- 3
        } else {
          if (games$team_a[i] == "Germany" && games$date[i]>= "2014-07-13"){
            games$team_a_stars[i] <- 4
          } else {
            if(games$team_a[i] == "Brazil" && games$date[i]< "1994-07-17"){
              games$team_a_stars[i] <- 3
            } else {
              if (games$team_a[i] == "Brazil" && games$date[i]>= "1994-07-17" && games$date[i]<"2002-06-30"){
                games$team_a_stars[i] <- 4 
              } else {
                if (games$team_a[i] == "Brazil" && games$date[i]>= "2002-06-30"){
                  games$team_a_stars[i] <- 5
                } else {
                  if(games$team_a[i] == "England") {
                    games$team_a_stars[i] <- 1
                  } else {
                    if(games$team_a[i] == "Argentina") {
                      games$team_a_stars[i] <- 2
                    } else {
                      if(games$team_a[i] == "France" && games$date[i]< "1998-07-12"){
                        games$team_a_stars[i] <- 0
                      } else {
                        if (games$team_a[i] == "France" && games$date[i]>= "1998-07-12" && games$date[i]<"2018-07-15"){
                          games$team_a_stars[i] <- 1
                        } else {
                          if (games$team_a[i] == "France" && games$date[i]>= "2018-07-15"){
                            games$team_a_stars[i] <- 2
                          } else {
                            if(games$team_a[i] == "Spain" && games$date[i]< "2010-07-11"){
                              games$team_a_stars[i] <- 0
                            } else {
                              if (games$team_a[i] == "Spain" && games$date[i]>= "2010-07-11"){
                                games$team_a_stars[i] <- 1
                              } else {
                                games$team_a_stars[i] <- 0
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

str(games)
games$team_a_stars <- as.numeric(games$team_a_stars)

#same for team_b
games$team_b_stars <- 0
games$team_b_stars <- as.numeric(games$team_b_stars)

#all_coutries
for (i in 1:nrow(games)) {
  if(games$team_b[i] == "Uruguay"){
    games$team_b_stars[i] <- 2
  } else {
    if(games$team_b[i] == "Italy" && games$date[i]< "2006-07-09"){
      games$team_b_stars[i] <- 3
    } else {
      if (games$team_b[i] == "Italy" && games$date[i]>= "2006-07-09"){
        games$team_b_stars[i] <- 4
      } else {
        if(games$team_b[i] == "Germany" && games$date[i]< "2014-07-13"){
          games$team_b_stars[i] <- 3
        } else {
          if (games$team_b[i] == "Germany" && games$date[i]>= "2014-07-13"){
            games$team_b_stars[i] <- 4
          } else {
            if(games$team_b[i] == "Brazil" && games$date[i]< "1994-07-17"){
              games$team_b_stars[i] <- 3
            } else {
              if (games$team_b[i] == "Brazil" && games$date[i]>= "1994-07-17" && games$date[i]<"2002-06-30"){
                games$team_b_stars[i] <- 4 
              } else {
                if (games$team_b[i] == "Brazil" && games$date[i]>= "2002-06-30"){
                  games$team_b_stars[i] <- 5
                } else {
                  if(games$team_b[i] == "England") {
                    games$team_b_stars[i] <- 1
                  } else {
                    if(games$team_b[i] == "Argentina") {
                      games$team_b_stars[i] <- 2
                    } else {
                      if(games$team_b[i] == "France" && games$date[i]< "1998-07-12"){
                        games$team_b_stars[i] <- 0
                      } else {
                        if (games$team_b[i] == "France" && games$date[i]>= "1998-07-12" && games$date[i]<"2018-07-15"){
                          games$team_b_stars[i] <- 1
                        } else {
                          if (games$team_b[i] == "France" && games$date[i]>= "2018-07-15"){
                            games$team_b_stars[i] <- 2
                          } else {
                            if(games$team_b[i] == "Spain" && games$date[i]< "2010-07-11"){
                              games$team_b_stars[i] <- 0
                            } else {
                              if (games$team_b[i] == "Spain" && games$date[i]>= "2010-07-11"){
                                games$team_b_stars[i] <- 1
                              } else {
                                games$team_b_stars[i] <- 0
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

#select teams according to Maxime
selected_teams = c("Argentina", "Australia", "Belgium", "Brazil", "Cameroon", 
                   "Canada", "Costa Rica", "Croatia", "Denmark", "Ecuador", "England",
                   "France", "Germany", "Ghana", "Iran", "Japan", "Mexico", "Morocco",
                   "Netherlands", "Poland", "Portugal", "Qatar", "Saudi Arabia",
                   "Senegal", "Serbia", "South Korea", "Spain", "Switzerland",
                   "Tunisia", "United States", "Uruguay", "Wales", "Paraguay",
                   "Peru", "Sweden", "Colombia", "Austria", "Iceland", "Finland",
                   "Republic of Ireland", "Norway", "Scotland", "Algeria", "Italy",
                   "Turkey", "Egypt", "Greece", "Côte d'Ivoire", "Chile",
                   "Czech Republic", "Ukraine", "Russia", "Nigeria")

selected_games <- games[games$team_a %in% selected_teams, ]

#Do we also want to do the same for team_b i.e. only good teams against good teams or do we want all their games ?

#Selected tournaments according to Maxime
selected_tournaments = c("FIFA World Cup qualification", "Friendly", "African Cup of Nations qualification",
                        "CFU Caribbean Cup qualification", "African Cup of Nations","CFU Caribbean Cup",
                        "UEFA Euro qualification", "FIFA World Cup","Oceania Nations Cup qualification",
                        "Baltic Cup", "CECAFA Cup", "Confederations Cup", "Copa Paz del Chaco","Copa América",
                        "AFC Asian Cup qualification", "UEFA Euro", "AFC Asian Cup", "Arab Cup qualification",
                        "Arab Cup", "Afro-Asian Games", "Copa del Pacífico", "Nations Cup", "Pacific Games",
                        "Copa América qualification", "Intercontinental Cup", "UEFA Nations League", 
                        "CONCACAF Nations League qualification", "African Nations Championship qualification",
                        "CONCACAF Nations League")

selected_games_2 <- selected_games[selected_games$tournament %in% selected_tournaments, ]

#excel Maxime
games$tournament<-factor(games$tournament)
write.table(unique(games$tournament), file = "data_tournament.csv", row.names = F, col.names = T)
