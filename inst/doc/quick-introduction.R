## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(message=FALSE,warning = FALSE, comment = NA)
old.hooks <- fansi::set_knit_hooks(knitr::knit_hooks)

## ----setup--------------------------------------------------------------------
library(psycModel)

## ----fig.width=14, fig.height=8,out.width=700,out.height=400------------------
integrated_model_summary(
   data = iris,
   response_variable = Sepal.Length,
   predictor_variable = tidyselect::everything(),
   two_way_interaction_factor = c(Sepal.Width, Petal.Width), 
   model_summary = TRUE, 
   interaction_plot = TRUE, 
   assumption_plot = TRUE,
   simple_slope = TRUE
 )

## ----fig.width=14,fig.height=8,out.width=700,out.height=400-------------------
integrated_multilevel_model_summary(
   data = popular,
   response_variable = popular,
   random_effect_factors = c(extrav, sex),
   non_random_effect_factors = texp,
   three_way_interaction_factor = c(extrav, sex, texp),
   graph_label_name = c("popular", "extraversion", "sex", "teacher experience"), # change interaction plot label
   id = class,
   simple_slope = TRUE, 
   assumption_plot = TRUE,
   plot_color = TRUE 
 )

## -----------------------------------------------------------------------------
 fit1 <- lm_model(
   data = popular,
   response_variable = popular,
   predictor_var = c(sex, extrav),
   quite = TRUE
 )

 fit2 <- lm_model(
   data = popular,
   response_variable = popular,
   predictor_var = c(sex, extrav),
   two_way_interaction_factor = c(sex, extrav),
   quite = TRUE
 )

 compare_fit(fit1, fit2)

## ----fig.width=10.5,fig.height=6,out.width=700,out.height=400-----------------
cfa_summary(
   data = lavaan::HolzingerSwineford1939,
   x1:x3,
   x4:x6,
   x7:x9,
 )

## ----fig.width=10.5,fig.height=6,out.width=700,out.height=400-----------------
efa_summary(lavaan::HolzingerSwineford1939, 
            starts_with("x"), # x1, x2, x3 ... x9
            post_hoc_cfa = TRUE) # run a post-hoc CFA 

## -----------------------------------------------------------------------------
 measurement_invariance(
   x1:x3,
   x4:x6,
   x7:x9,
   data = lavaan::HolzingerSwineford1939,
   group = "school",
   invariance_level = "scalar" # you can change this to metric
 )

## -----------------------------------------------------------------------------
mediation_summary(
   data = lmerTest::carrots,
   response_variable = Preference,
   mediator = Sweetness,
   predictor_variable = Crisp
 )

## -----------------------------------------------------------------------------
reliability_summary(data = lavaan::HolzingerSwineford1939, cols = x1:x3)

## ----fig.width=10.5,fig.height=6,out.width=700,out.height=400-----------------
reliability_summary(data = lavaan::HolzingerSwineford1939, cols = x1:x9)

## -----------------------------------------------------------------------------
cor_test(iris, where(is.numeric))

## -----------------------------------------------------------------------------
descriptive_table(iris, cols = where(is.numeric)) # all numeric columns

## -----------------------------------------------------------------------------
knit_to_Rmd()

