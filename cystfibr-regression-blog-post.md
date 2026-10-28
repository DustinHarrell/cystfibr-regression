# Cystic Fibrosis Lung Function: ANOVA and Multiple Regression in R

*By Dustin Harrell · Posted October 28, 2026 · Based on Chapter 11 (Multiple Linear Regression) of* Introductory Statistics with R

For this post I used the `cystfibr` dataset from the ISwR package. It holds lung function and body measurements for 25 patients with cystic fibrosis, and I wanted to see which measurements help explain how strong a patient's respiratory muscles are. I ran the same model two ways, as a regression summary and as an ANOVA table, and the two views tell slightly different stories. That difference turned out to be the most interesting part.

## The data and my model

The response variable is **pemax**, the maximal expiratory pressure (in cm H2O), which is a measure of respiratory muscle strength. I chose four predictors:

- **age**: age in years
- **weight**: body weight in kg
- **bmp**: body mass as a percentage of the normal value for the patient's age
- **fev1**: forced expiratory volume in one second, a standard lung function measure

A note on names: the assignment code writes `spemax`, `cystfiber` and `cystfibr` in different places. In the ISwR package the dataset is called `cystfibr` and the response column is `pemax`, so those are the names I used below.

```r
library(ISwR)
data(cystfibr)
```

## Part 1: Multiple regression

```r
m <- lm(pemax ~ age + weight + bmp + fev1, data = cystfibr)
summary(m)
```

```
Call:
lm(formula = pemax ~ age + weight + bmp + fev1, data = cystfibr)

Residuals:
    Min      1Q  Median      3Q     Max 
-42.521 -10.885   3.003  15.488  41.767 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)   
(Intercept) 179.2957    61.8855   2.897  0.00891 **
age          -3.4181     3.3086  -1.033  0.31389   
weight        2.6882     1.1727   2.292  0.03287 * 
bmp          -2.0657     0.8198  -2.520  0.02036 * 
fev1          1.0882     0.5139   2.117  0.04695 * 
---
Residual standard error: 23.4 on 20 degrees of freedom
Multiple R-squared:  0.5918,	Adjusted R-squared:  0.5101 
F-statistic: 7.248 on 4 and 20 DF,  p-value: 0.0008891
```

### Reading the coefficients

**Intercept (179.30).** This is the predicted pemax for a patient with age = 0, weight = 0, bmp = 0 and fev1 = 0. No such patient exists (the youngest person in the data is 7 and the lightest is 12.9 kg), so the number is an extrapolation and has no clinical meaning on its own. It simply anchors the fitted plane. It is statistically different from zero (p = 0.009), but I would not make anything of that. Its 95% confidence interval is very wide, roughly 50 to 308, which also shows how far outside the data it sits.

**weight (+2.69, p = 0.033).** Holding age, bmp and fev1 fixed, each extra kilogram goes with about 2.7 cm H2O more expiratory pressure. This is significant at the 5% level.

**fev1 (+1.09, p = 0.047).** Holding the other three fixed, each additional unit of fev1 goes with about 1.1 cm H2O more pressure. This is only just significant.

**bmp (−2.07, p = 0.020).** Holding the others fixed, a higher bmp goes with *lower* pemax. This surprised me, because bmp on its own is positively correlated with pemax (r = 0.23). I come back to this below.

**age (−3.42, p = 0.314).** The estimate is negative, but the standard error (3.31) is as large as the estimate, so there is no evidence of an age effect once the other variables are in the model. Again, age alone is positively correlated with pemax (r = 0.61), so the sign has flipped.

### Reading the overall fit

The model explains 59.2% of the variation in pemax (R² = 0.592). The adjusted R² of 0.510 is the more honest figure, because it penalises the model for having four predictors on only 25 patients. The F-test (F = 7.25 on 4 and 20 df, p = 0.0009) says that the four predictors together explain significantly more than a model with no predictors at all. The residual standard error of 23.4 means a typical prediction misses by about 23 cm H2O, which is large relative to the mean pemax of about 109.

## Part 2: Analysis of variance

```r
anova(lm(pemax ~ age + weight + bmp + fev1, data = cystfibr))
```

```
Analysis of Variance Table

Response: pemax
          Df  Sum Sq Mean Sq F value    Pr(>F)    
age        1 10098.5 10098.5 18.4385 0.0003538 ***
weight     1   945.2   945.2  1.7258 0.2038195    
bmp        1  2379.7  2379.7  4.3450 0.0501483 .  
fev1       1  2455.6  2455.6  4.4836 0.0469468 *  
Residuals 20 10953.7   547.7                      
```

### Reading the ANOVA table

The table splits the total variation in pemax (total sum of squares about 26,833) into a part explained by each predictor and a leftover residual part. The four predictor rows add up to 15,879, and 15,879 / 26,833 = 0.592, which is exactly the R² from the regression. So the ANOVA and the regression are two views of the same fitted model.

**What happens to the intercept?** The ANOVA table has no intercept row, because it does not test the intercept. In the ANOVA setting the intercept plays the role of the grand mean. A model with no predictors, `lm(pemax ~ 1)`, has an intercept equal to the mean pemax of about 109.1, and the table measures how much each predictor reduces the leftover variation around that mean. That is why the regression intercept (179.3) and the ANOVA "intercept" (109.1) differ: they belong to different models.

**Sequential (Type I) sums of squares.** R's `anova()` adds the variables in the order they appear in the formula, and each row shows what that variable explains *after* the ones above it:

- **age** is tested first, on its own, and is highly significant (F = 18.4, p = 0.0004). It alone accounts for 10,098 of the 15,879 explained.
- **weight** adds very little once age is in (p = 0.204).
- **bmp** adds a borderline amount (p = 0.0501, just missing the 5% line).
- **fev1** adds a significant amount (p = 0.047).

## Why the two tables seem to disagree

| Predictor | Regression p-value (adjusted for all others) | ANOVA p-value (sequential) |
|---|---|---|
| age | 0.314 | 0.0004 |
| weight | 0.033 | 0.204 |
| bmp | 0.020 | 0.050 |
| fev1 | 0.047 | 0.047 |

Age looks like the star of the ANOVA table but is not significant in the regression, and weight shows the opposite pattern. The explanation is **multicollinearity**: age and weight are very strongly correlated (r = 0.906), and weight and bmp are also correlated (r = 0.673). When two predictors carry almost the same information, whichever goes first in the ANOVA claims the shared variation, and in the regression the two have to split it, so neither gets much credit. I checked this by computing variance inflation factors by hand, and they were high for weight (about 19) and age (about 12), versus 4.3 for bmp and 1.5 for fev1. When I reversed the order in the formula (`fev1 + bmp + weight + age`), the ANOVA flipped: fev1 (p = 0.005) and weight (p = 0.0004) were significant, while bmp (p = 0.88) and age (p = 0.31) were not.

Two details support this reading. First, fev1 has the identical p-value (0.047) in both tables, because it is last in the formula, so its sequential test is the same as its adjusted test (F = 4.48 is the square of the t-value 2.117). Second, the sign flips for age and bmp are a classic symptom of correlated predictors: each is positively related to pemax alone, but once weight is in the model, the leftover part of age or bmp points the other way.

## My interpretation

1. **The model as a whole is useful.** Four ordinary body and lung measurements explain about half of the variation in respiratory muscle strength (adjusted R² = 0.51), and the overall F-test is clearly significant (p = 0.0009).
2. **Body size (weight) and lung function (fev1) are the most defensible predictors.** Both are positively related to pemax after adjustment, which makes physical sense: bigger patients with better airflow tend to generate more pressure.
3. **I would not interpret individual coefficients causally.** Because age, weight and bmp overlap so heavily, the separate effects of each are poorly determined. The negative signs on age and bmp are most likely a statistical artifact of that overlap, not evidence that growing older or having a higher bmp weakens the muscles.
4. **The sample is small.** With 25 patients, several p-values sit right at the 0.05 boundary (bmp 0.020, fev1 0.047, ANOVA bmp 0.0501). I would treat them as hints, not firm conclusions.
5. **A sensible next step** would be to drop one of the overlapping predictors (for example, keep weight and drop age) and refit, then check whether the remaining coefficients are more stable.

The main lesson for me is that ANOVA and regression output answer different questions. ANOVA asks what a variable adds *in the order entered*, while regression asks what it adds *given everything else*. When predictors are correlated, you need to look at both before deciding which variables matter.

*Software: R with the ISwR package. Full code: `lm(pemax ~ age + weight + bmp + fev1, data = cystfibr)` and `anova()` of the same model.*
