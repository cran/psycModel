#' Integrated Function for Linear Regression
#'
#' `r lifecycle::badge("stable")` \cr
#' It will first compute the linear regression. Then, it will graph the interaction using the two_way_interaction_plot or the three_way_interaction_plot function.
#' If you requested simple slope summary, it will calls the `interaction::sim_slopes()`
#'
#' @param data data frame
#' @param response_variable DV (i.e., outcome variable / response variable). Length of 1. Support `dplyr::select()` syntax.
#' @param predictor_variable IV. Support `dplyr::select()` syntax.
#' @param three_way_interaction_factor three-way interaction factor. You need to pass exactly 3 factors. Specifying three-way interaction factors automatically included all two-way interactions, so please do not specify the two_way_interaction_factor argument. Support `dplyr::select()` syntax.
#' @param graph_label_name optional vector or function. vector of length 2 for two-way interaction graph. vector of length 3 for three-way interaction graph. Vector should be passed in the form of c(response_var, predict_var1, predict_var2, ...). Function should be passed as a switch function (see ?two_way_interaction_plot for an example)
#' @param return_result If it is set to `TRUE` (default is `FALSE`), it will return the `model`, `model_summary`, and `plot` (if the interaction term is included)
#' @param cateogrical_var list. Specify the upper bound and lower bound directly instead of using ± 1 SD from the mean. Passed in the form of `list(var_name1 = c(upper_bound1, lower_bound1),var_name2 = c(upper_bound2, lower_bound2))`
#' @param y_lim the plot's upper and lower limit for the y-axis. Length of 2. Example: `c(lower_limit, upper_limit)`
#' @param plot_color If it is set to `TRUE` (default is `FALSE`), the interaction plot will plot with color.
#' @param quite suppress printing output
#' @param digits number of digits to round to
#' @param simple_slope Slope estimate at +1/-1 SD and the mean of the moderator. Uses `interactions::sim_slope()` in the background.
#' @param assumption_plot Generate an panel of plots that check major assumptions. It is usually recommended to inspect model assumption violation visually. In the background, it calls `performance::check_model()`
#' @param streamline print streamlined output
#' @param two_way_interaction_factor two-way interaction factors. You need to pass 2+ factor. Support `dplyr::select()` syntax.
#' @param family a GLM family. It will passed to the family argument in glm. See `?glm` for possible options. `r lifecycle::badge("experimental")`
#' @param model_summary print model summary. Required to be `TRUE` if you want `assumption_plot`.
#' @param interaction_plot generate the interaction plot. Default is `TRUE`
#'
#' @return  a list of all requested items in the order of model, model_summary, interaction_plot, simple_slope
#' @export
#'
#' @examples
#' fit <- integrated_model_summary(
#'   data = iris,
#'   response_variable = "Sepal.Length",
#'   predictor_variable = tidyselect::everything(),
#'   two_way_interaction_factor = c(Sepal.Width, Species)
#' )
#' \donttest{
#' fit <- integrated_model_summary(
#'   data = iris,
#'   response_variable = "Sepal.Length",
#'   predictor_variable = tidyselect::everything(),
#'   two_way_interaction_factor = c(Sepal.Width, Species),
#'   simple_slope = TRUE, # you can request simple slope
#'   assumption_plot = TRUE, # you can also request assumption plot
#'   plot_color = TRUE # you can also request the plot in color
#' )
#' }
integrated_model_summary <- function(data,
                                     response_variable = NULL,
                                     predictor_variable = NULL,
                                     two_way_interaction_factor = NULL,
                                     three_way_interaction_factor = NULL,
                                     family = NULL,
                                     cateogrical_var = NULL,
                                     graph_label_name = NULL,
                                     model_summary = TRUE,
                                     interaction_plot = TRUE,
                                     y_lim = NULL,
                                     plot_color = FALSE,
                                     digits = 3,
                                     simple_slope = FALSE,
                                     assumption_plot = FALSE,
                                     quite = FALSE,
                                     streamline = FALSE,
                                     return_result = FALSE) {

  ##################################### Set up #########################################
  # parse select syntax
  response_variable <- data %>%
    dplyr::select(!!enquo(response_variable)) %>%
    names()
  predictor_variable <- data %>%
    dplyr::select(!!enquo(predictor_variable)) %>%
    names()
  two_way_interaction_factor <- data %>%
    dplyr::select(!!enquo(two_way_interaction_factor)) %>%
    names()
  three_way_interaction_factor <- data %>%
    dplyr::select(!!enquo(three_way_interaction_factor)) %>%
    names()
  # coerced into numeric after selecting variables
  data <- data_check(data)

  ##################################### Running Model #########################################
  if (is.null(family)) {
    model <- lm_model(
      data = data,
      response_variable = dplyr::all_of(response_variable),
      predictor_variable = dplyr::all_of(predictor_variable),
      two_way_interaction_factor = dplyr::all_of(two_way_interaction_factor),
      three_way_interaction_factor = dplyr::all_of(three_way_interaction_factor),
      quite = TRUE
    )
  } else {
    if (simple_slope == TRUE | interaction_plot == TRUE) {
      simple_slope <- FALSE
      interaction_plot <- FALSE
      warning("interaction_plot & simple_slope is not avaliable for glme model for now")
    }
    model <- glm_model(
      data = data,
      response_variable = tidyselect::all_of(response_variable),
      predictor_variable = tidyselect::all_of(predictor_variable),
      two_way_interaction_factor = tidyselect::all_of(two_way_interaction_factor),
      three_way_interaction_factor = tidyselect::all_of(three_way_interaction_factor),
      family = family,
      quite = TRUE
    )
  }


  ############################### Generate Interaction Plots ###############################
  two_way_interaction_factor <- data %>%
    dplyr::select(!!enquo(two_way_interaction_factor)) %>%
    names()
  three_way_interaction_factor <- data %>%
    dplyr::select(!!enquo(three_way_interaction_factor)) %>%
    names()
  interaction_plot_object <- NULL
  if (length(two_way_interaction_factor) != 0 & (interaction_plot == TRUE | return_result == TRUE)) {
    interaction_plot_object <- two_way_interaction_plot(
      model = model,
      cateogrical_var = cateogrical_var,
      graph_label_name = graph_label_name,
      y_lim = y_lim,
      plot_color = plot_color
    )
  } else if (length(three_way_interaction_factor) != 0 & (interaction_plot == TRUE | return_result == TRUE)) {
    interaction_plot_object <- three_way_interaction_plot(
      model = model,
      cateogrical_var = cateogrical_var,
      graph_label_name = graph_label_name,
      y_lim = y_lim,
      plot_color = plot_color
    )
  } else {
    interaction_plot_object <- NULL
    interaction_plot <- FALSE
  }


  ############################### Generate Simple Slope Output ###############################
  if (simple_slope == TRUE) {
    simple_slope_list <- simple_slope(
      data = data,
      model = model,
      two_way_interaction_factor = two_way_interaction_factor,
      three_way_interaction_factor = three_way_interaction_factor
    )
  } else {
    simple_slope_list <- list(
      simple_slope_df = NULL,
      jn_plot = NULL
    )
  }

  ######################################### Output Result  #########################################
  if (model_summary == TRUE | return_result == TRUE) {
    model_summary_list <- model_summary(
      model = model,
      streamline = streamline,
      digits = digits,
      return_result = TRUE,
      assumption_plot = assumption_plot,
      quite = quite
    )
  }

  if (simple_slope == TRUE & quite == FALSE) {
    super_print("underline|Slope Estimates at Each Level of Moderators")
    print_table(simple_slope_list$simple_slope_df)
    super_print("italic|Note: For continuous variable, low and high represent -1 and +1 SD from the mean, respectively.")
    print(simple_slope_list$jn_plot)
  }

  if (interaction_plot == TRUE) {
    try(print(interaction_plot_object))
  }

  # warning message
  plot_logical <- c(interaction_plot, simple_slope, assumption_plot)
  number_of_plot_requested <- length(plot_logical[plot_logical])
  if (number_of_plot_requested > 1) {
    warning("You requested > 2 plots. Since 1 plot can be displayed at a time, considering using Rmd for better viewing experience.")
  }

  # Return Result
  if (return_result == TRUE) {
    return_list <- list(
      model = model,
      summary = model_summary_list,
      interaction_plot = interaction_plot_object,
      simple_slope = simple_slope_list
    )
    return(return_list)
  }
}
