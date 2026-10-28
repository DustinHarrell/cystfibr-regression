# Load the data
library(ISwR)
data(cystfibr)

# (i) Multiple regression
m <- lm(pemax ~ age + weight + bmp + fev1, data = cystfibr)
summary(m)
confint(m)

# (ii) ANOVA of the same model
anova(m)

# Extras used in the blog post
# Correlations between the variables
round(cor(cystfibr[, c("pemax", "age", "weight", "bmp", "fev1")]), 3)

# ANOVA with the variables entered in reverse order
anova(lm(pemax ~ fev1 + bmp + weight + age, data = cystfibr))

# Variance inflation factors, computed by hand
preds <- c("age", "weight", "bmp", "fev1")
for (v in preds) {
  f <- as.formula(paste(v, "~", paste(setdiff(preds, v), collapse = " + ")))
  cat(v, round(1 / (1 - summary(lm(f, data = cystfibr))$r.squared), 2), "\n")
}
