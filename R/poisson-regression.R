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