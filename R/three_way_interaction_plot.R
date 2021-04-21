#' Three-way Interaction Plot
#'
#' `r lifecycle::badge("stable")` \cr
#' The function creates a two-way interaction plot. It will creates a plot with ± 1 SD from the mean of the independent variable. See below for supported model. I recommend using concurrently with `lm_model()`, `lme_model()`. 
#'
#' @param model object from `lme`, `lme4`, `lmerTest` object.
#' @param data data frame. If the function is unable to extract data frame from the object, then you may need to pass it directly
#' @param graph_label_name vector of length 4 or a switch function (see ?two_way_interaction_plot example). Vector should be passed in the form of c(response_var, predict_var1, predict_var2, predict_var3).
#' @param cateogrical_var list. Specify the upper bound and lower bound directly instead of using ± 1 SD from the mean. Passed in the form of `list(var_name1 = c(upper_bound1, lower_bound1),var_name2 = c(upper_bound2, lower_bound2))`
#' @param y_lim the plot's upper and lower limit for the y-axis. Length of 2. Example: `c(lower_limit, upper_limit)`
#' @param plot_color default if `FALSE`. Set to `TRUE` if you want to plot in color
#'
#'
#' @details It appears that ``predict` cannot handle categorical factors. All variables are converted to numeric before plotting.
#' @return a `ggplot` object
#'
#' @export
#'
#' @examples
#' # I am going to show the more generic usage of this function
#' # You can also use this package's built in function to fit the models
#' # I recommend using the integrated_multilevel_model_summary to get everything
#'
#' # lme example
#' lme_fit <- lme4::lmer("popular ~ extrav + sex + texp + extrav:sex:texp +
#' (1 + extrav + sex | class)", data = popular)
#'
#' three_way_interaction_plot(lme_fit, data = popular)
#'
#' # lm example
#'
#' lm_fit <- lm(Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width +
#'   Sepal.Width:Petal.Length:Petal.Width, data = iris)
#'
#' three_way_interaction_plot(lm_fit, data = iris)
three_way_interaction_plot <- function(model,
                                       data = NULL,
                                       cateogrical_var = NULL,
                                       graph_label_name = NULL,
                                       y_lim = NULL,
                                       plot_color = FALSE) {
  interaction_plot_check <- function(interaction_term) {
    if (length(interaction_term) > 1) {
      interaction_term <- interaction_term[1]
      warning(paste("Inputted > 2 interaction terms. Plotting the first interaction term:\n ", interaction_term))
    }
    return(interaction_term)
  }

  model_data <- NULL

  # get attributes based on model
  if (class(model) == "lme") {
    formula_attribute <- model$terms
    model_data <- model$data
    predict_var <- attributes(formula_attribute)$term.labels
    response_var <- as.character(attributes(formula_attribute)$variables)[2]
    interaction_term <- predict_var[stringr::str_detect(predict_var, ":.+:")]
    interaction_term <- interaction_plot_check(interaction_term)
  } else if (any(class(model) %in% c("lmerMod", "lmerModLmerTest"))) {
    formula_attribute <- stats::terms(model@call$formula)
    model_data <- model@call$data
    predict_var <- attributes(formula_attribute)$term.labels
    response_var <- as.character(attributes(formula_attribute)$variables)[2]
    interaction_term <- predict_var[stringr::str_detect(predict_var, ":.+:")]
    interaction_term <- interaction_plot_check(interaction_term)
  } else if (class(model) == "lm") {
    tryCatch(data <- eval(stats::getCall(model)$data, environment(stats::formula(model))), error = function(cond) {
      warning("Unable to extract data. Please pass the data directly as an arugment and ignore this warning")
    })
    predict_var <- as.character(attributes(model$terms)$term.labels)
    response_var <- predict_var[2]
    interaction_term <- predict_var[stringr::str_detect(predict_var, ":.+:")]
    interaction_term <- interaction_plot_check(interaction_term)
  }
  else {
    stop("It only support model object from nlme, lme4, and lmerTest")
  }

  predict_var1 <- gsub(pattern = ":.+", "", x = interaction_term)
  predict_var3 <- gsub(pattern = ".+:", "", x = interaction_term)
  remove1 <- stringr::str_remove(pattern = predict_var1, string = interaction_term)
  remove2 <- stringr::str_remove(pattern = predict_var3, string = remove1)
  predict_var2 <- gsub(pattern = ":", "", x = remove2)

  if (length(interaction_term) == 0) {
    stop("No three-way interaction term is found in the model")
  }

  if (any(class(model_data) == "data.frame")) {
    data <- model_data
  } else {
    if (is.null(data)) {
      stop("You need to pass the data directly")
    }
    if (!any(class(data) == "data.frame")) {
      stop("Data must be dataframe like object")
    }
  }

  data <- data_check(data)
  mean_df <- dplyr::summarise_all(data, mean, na.rm = TRUE)
  upper_df <- dplyr::summarise_all(data, .funs = function(.) {
    mean(., na.rm = TRUE) + 1 * stats::sd(., na.rm = TRUE)
  })

  lower_df <- dplyr::summarise_all(data, .funs = function(.) {
    mean(., na.rm = TRUE) - 1 * stats::sd(., na.rm = TRUE)
  })

  # Specify the categorical variable upper and lower bound directly
  if (!is.null(cateogrical_var)) {
    for (name in names(cateogrical_var)) {
      upper_df[name] <- cateogrical_var[[name]][1]
      lower_df[name] <- cateogrical_var[[name]][2]
    }
  }
  # Get the variable names of the model
  # Update values in the new_data_df to the values in predicted_df & get the predicted value
  # Plot 1
  upper_upper_upper_df <- mean_df
  upper_upper_upper_df[predict_var1] <- upper_df[predict_var1]
  upper_upper_upper_df[predict_var2] <- upper_df[predict_var2]
  upper_upper_upper_df[predict_var3] <- upper_df[predict_var3]

  upper_lower_upper_df <- mean_df
  upper_lower_upper_df[predict_var1] <- upper_df[predict_var1]
  upper_lower_upper_df[predict_var2] <- lower_df[predict_var2]
  upper_lower_upper_df[predict_var3] <- upper_df[predict_var3]

  lower_upper_upper_df <- mean_df
  lower_upper_upper_df[predict_var1] <- lower_df[predict_var1]
  lower_upper_upper_df[predict_var2] <- upper_df[predict_var2]
  lower_upper_upper_df[predict_var3] <- upper_df[predict_var3]


  lower_lower_upper_df <- mean_df
  lower_lower_upper_df[predict_var1] <- lower_df[predict_var1]
  lower_lower_upper_df[predict_var2] <- lower_df[predict_var2]
  lower_lower_upper_df[predict_var3] <- upper_df[predict_var3]

  if (class(model) == "lme") {
    upper_upper_upper_predicted_value <- stats::predict(model, newdata = upper_upper_upper_df, level = 0)
    upper_lower_upper_predicted_value <- stats::predict(model, newdata = upper_lower_upper_df, level = 0)
    lower_upper_upper_predicted_value <- stats::predict(model, newdata = lower_upper_upper_df, level = 0)
    lower_lower_upper_predicted_value <- stats::predict(model, newdata = lower_lower_upper_df, level = 0)
  } else if (class(model) == "lmerModLmerTest" | class(model) == "lmerMod") {
    upper_upper_upper_predicted_value <- stats::predict(model, newdata = upper_upper_upper_df, allow.new.levels = TRUE)
    upper_lower_upper_predicted_value <- stats::predict(model, newdata = upper_lower_upper_df, allow.new.levels = TRUE)
    lower_upper_upper_predicted_value <- stats::predict(model, newdata = lower_upper_upper_df, allow.new.levels = TRUE)
    lower_lower_upper_predicted_value <- stats::predict(model, newdata = lower_lower_upper_df, allow.new.levels = TRUE)
  } else if (class(model) == "lm") {
    upper_upper_upper_predicted_value <- stats::predict(model, newdata = upper_upper_upper_df)
    upper_lower_upper_predicted_value <- stats::predict(model, newdata = upper_lower_upper_df)
    lower_upper_upper_predicted_value <- stats::predict(model, newdata = lower_upper_upper_df)
    lower_lower_upper_predicted_value <- stats::predict(model, newdata = lower_lower_upper_df)
  }
  # Plot 2
  upper_upper_lower_df <- mean_df
  upper_upper_lower_df[predict_var1] <- upper_df[predict_var1]
  upper_upper_lower_df[predict_var2] <- upper_df[predict_var2]
  upper_upper_lower_df[predict_var3] <- lower_df[predict_var3]

  upper_lower_lower_df <- mean_df
  upper_lower_lower_df[predict_var1] <- upper_df[predict_var1]
  upper_lower_lower_df[predict_var2] <- lower_df[predict_var2]
  upper_lower_lower_df[predict_var3] <- lower_df[predict_var3]

  lower_upper_lower_df <- mean_df
  lower_upper_lower_df[predict_var1] <- lower_df[predict_var1]
  lower_upper_lower_df[predict_var2] <- upper_df[predict_var2]
  lower_upper_lower_df[predict_var3] <- lower_df[predict_var3]
  lower_lower_lower_df <- mean_df

  lower_lower_lower_df[predict_var1] <- lower_df[predict_var1]
  lower_lower_lower_df[predict_var2] <- lower_df[predict_var2]
  lower_lower_lower_df[predict_var3] <- lower_df[predict_var3]

  if (class(model) == "lme") {
    upper_upper_lower_predicted_value <- stats::predict(model, newdata = upper_upper_lower_df, level = 0)
    upper_lower_lower_predicted_value <- stats::predict(model, newdata = upper_lower_lower_df, level = 0)
    lower_upper_lower_predicted_value <- stats::predict(model, newdata = lower_upper_lower_df, level = 0)
    lower_lower_lower_predicted_value <- stats::predict(model, newdata = lower_lower_lower_df, level = 0)
  } else if (class(model) == "lmerModLmerTest" | class(model) == "glmerMod" | class(model) == "lmerMod") {
    upper_upper_lower_predicted_value <- stats::predict(model, newdata = upper_upper_lower_df, allow.new.levels = TRUE)
    upper_lower_lower_predicted_value <- stats::predict(model, newdata = upper_lower_lower_df, allow.new.levels = TRUE)
    lower_upper_lower_predicted_value <- stats::predict(model, newdata = lower_upper_lower_df, allow.new.levels = TRUE)
    lower_lower_lower_predicted_value <- stats::predict(model, newdata = lower_lower_lower_df, allow.new.levels = TRUE)
  } else if (class(model) == "lm") {
    upper_upper_lower_predicted_value <- stats::predict(model, newdata = upper_upper_lower_df)
    upper_lower_lower_predicted_value <- stats::predict(model, newdata = upper_lower_lower_df)
    lower_upper_lower_predicted_value <- stats::predict(model, newdata = lower_upper_lower_df)
    lower_lower_lower_predicted_value <- stats::predict(model, newdata = lower_lower_lower_df)
  }

  # Get the correct label for the plot
  if (!is.null(graph_label_name)) {
    # If a vector of string is passed as argument, slice the vector
    if (class(graph_label_name) == "character") {
      response_var_plot_label <- graph_label_name[1]
      predict_var1_plot_label <- graph_label_name[2]
      predict_var2_plot_label <- graph_label_name[3]
      predict_var3_plot_label <- graph_label_name[4]
      # if a function of switch_case is passed as an argument, use the function
    } else if (class(graph_label_name) == "function") {
      response_var_plot_label <- graph_label_name(response_var)
      predict_var1_plot_label <- graph_label_name(predict_var1)
      predict_var2_plot_label <- graph_label_name(predict_var2)
      predict_var3_plot_label <- graph_label_name(predict_var3)

      # All other case use the original label
    } else {
      response_var_plot_label <- response_var
      predict_var1_plot_label <- predict_var1
      predict_var2_plot_label <- predict_var2
      predict_var3_plot_label <- predict_var3
    }
    # All other case use the original label
  } else {
    response_var_plot_label <- response_var
    predict_var1_plot_label <- predict_var1
    predict_var2_plot_label <- predict_var2
    predict_var3_plot_label <- predict_var3
  }

  high <- stringr::str_c("High", " ", predict_var3_plot_label)
  low <- stringr::str_c("Low", " ", predict_var3_plot_label)

  final_df <- data.frame(
    value = c(
      upper_upper_upper_predicted_value,
      upper_lower_upper_predicted_value,
      lower_upper_upper_predicted_value,
      lower_lower_upper_predicted_value,
      upper_upper_lower_predicted_value,
      upper_lower_lower_predicted_value,
      lower_upper_lower_predicted_value,
      lower_lower_lower_predicted_value
    ),
    var1_category = factor(c("High", "High", "Low", "Low", "High", "High", "Low", "Low"), levels = c("Low", "High")),
    var2_category = factor(c("High", "Low", "High", "Low", "High", "Low", "High", "Low"), levels = c("Low", "High")),
    var3_category = factor(c(high, high, high, high, low, low, low, low), levels = c(low, high))
  )

  # Set auto ylim
  if (is.null(y_lim)) {
    y_lim <- c(floor(min(final_df$value)) - 0.5, ceiling(max(final_df$value)) + 0.5)
  }


  if (plot_color) {
    plot <-
      ggplot2::ggplot(data = final_df, ggplot2::aes(y = .data$value, x = .data$var1_category, color = .data$var2_category)) +
      ggplot2::geom_point() +
      ggplot2::geom_line(ggplot2::aes(group = .data$var2_category)) +
      ggplot2::labs(
        y = response_var_plot_label,
        x = predict_var1_plot_label,
        color = predict_var2_plot_label
      ) +
      ggplot2::facet_wrap(~var3_category) +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(), panel.grid.minor = ggplot2::element_blank(),
        panel.background = ggplot2::element_blank(), axis.line = ggplot2::element_line(colour = "black")
      ) +
      ggplot2::ylim(y_lim[1], y_lim[2])
  } else {
    plot <-
      ggplot2::ggplot(data = final_df, ggplot2::aes(y = .data$value, x = .data$var1_category, group = .data$var2_category)) +
      ggplot2::geom_point() +
      ggplot2::geom_line(ggplot2::aes(linetype = .data$var2_category)) +
      ggplot2::labs(
        y = response_var_plot_label,
        x = predict_var1_plot_label,
        linetype = predict_var2_plot_label
      ) +
      ggplot2::facet_wrap(~var3_category) +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(), panel.grid.minor = ggplot2::element_blank(),
        panel.background = ggplot2::element_blank(), axis.line = ggplot2::element_line(colour = "black")
      ) +
      ggplot2::ylim(y_lim[1], y_lim[2])
  }

  return(plot)
}