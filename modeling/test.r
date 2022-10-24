# install.packages("ISLR2", repos='http://cran.us.r-project.org')

library(MASS)
library(ISLR2)

attach(Bikeshare)
# print(dim(Bikeshare))
# print(names(Bikeshare))

# mod.lm <- lm(bikers ~ mnth + hr + workingday + temp + weathersit, data = Bikeshare)
# print(summary(mod.lm))

# contrasts(Bikeshare$hr) = contr.sum(24)
# contrasts(Bikeshare$mnth) = contr.sum(12)

# mod.lm2 <- lm(bikers ~ mnth + hr + workingday + temp + weathersit, data = Bikeshare )
# print(summary(mod.lm2))

# oef.months <- c(coef(mod.lm2)[2:12], -sum(coef(mod.lm2)[2:12]))
# plot(coef.months, xlab = "Month", ylab = "Coefficient", xaxt = "n", col = "blue", pch = 19, type = "o")
# axis(side = 1, at = 1:12, labels = c("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"))

# coef.hours <- c(coef(mod.lm2)[13:35], -sum(coef(mod.lm2)[13:35]))
# plot(coef.hours, xlab = "Hour", ylab = "Coefficient", col = "blue", pch = 19, type = "o")

mod.pois <- glm(bikers ~ mnth + hr + workingday + temp + weathersit, data = Bikeshare, family = poisson)
print(summary(mod.pois))

coef.mnth <- c(coef(mod.pois)[2:12], -sum(coef(mod.pois)[2:12]))
plot(coef.mnth, xlab = "Month", ylab = "Coefficient", xaxt = "n", col = "blue", pch = 19, type = "o")
axis(side = 1, at = 1:12, labels = c("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"))
coef.hours <- c(coef(mod.pois)[13:35], -sum(coef(mod.pois)[13:35]))
plot(coef.hours, xlab = "Hour", ylab = "Coefficient", col = "blue", pch = 19, type = "o")
plot(predict(mod.lm2), predict(mod.pois, type = "response"))
abline(0, 1, col = 2, lwd = 3)