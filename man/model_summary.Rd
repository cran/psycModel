% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model_summary.R
\name{model_summary}
\alias{model_summary}
\title{Model Summary for Regression Models}
\usage{
model_summary(
  model,
  digits = 3,
  assumption_plot = FALSE,
  quite = FALSE,
  streamline = FALSE,
  return_result = FALSE
)
}
\arguments{
\item{model}{an model object. The following model are tested for accuracy: \code{lm}, \code{glm}, \code{lme}, \code{lmer}, \code{glmer}. Other model object may work if it work with parameters::model_parameters()}

\item{digits}{number of digits to round to}

\item{assumption_plot}{Generate an panel of plots that check major assumptions. It is usually recommended to inspect model assumption violation visually. In the background, it calls \code{performance::check_model()}.}

\item{quite}{suppress printing output}

\item{streamline}{print streamlined output. Only print model estimate and performance.}

\item{return_result}{It set to \code{TRUE}, it return the model estimates data frame.}
}
\value{
a list of model estimate data frame, model performance data frame, and the assumption plot (an \code{ggplot} object)
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}} \cr
The function will extract the relevant coefficients from the regression models (see below for supported model).
}
\examples{
# I am going to show the more generic usage of this function
# You can also use this package's built in function to fit the models
# I recommend using the integrated_multilevel_model_summary to get everything

# lme example
lme_fit <- lme4::lmer("popular ~ texp  + (1 | class)",
  data = popular
)

model_summary(lme_fit)

# lm example

lm_fit <- lm(Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width,
  data = iris
)

model_summary(lm_fit, assumption_plot = TRUE)
}
\references{
Nakagawa, S., & Schielzeth, H. (2013). A general and simple method for obtaining R2 from generalized linear mixed-effects models. Methods in Ecology and Evolution, 4(2), 133–142. https://doi.org/10.1111/j.2041-210x.2012.00261.x
}
