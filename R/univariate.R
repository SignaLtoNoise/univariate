#' Univariate Plot
#'
#' Plot predicted and actual values over an aggregating variable, with histogram
#' @param frame Dataframe, containing groupvar, actual, predict as columns
#' @param groupvar Variable to aggregate over
#' @param actual Observed values
#' @param model Predicted values
#' @param grouprange Range to plot groupvar over. Defaults to full range
#' @param roundvalue Optional rounding accuracy for groupvar. Defaults to no rounding
#' @param roundfunc Rounding function (round, floor, ceiling). Defaults to round
#' @param labelangle Degrees from zero to display X-axis labels
#' @param titlestring String for plot title. Default title used if NULL
#'
#' @return A ggplot object
#' @examples
#' univariate(train, "SalesBranch", "STPFlag", "predict")
#' univariate(df, "InterestRate", "FundedFlag", "predict", c(2, 4.5))
#' univariate(test, "FICO", "FundedFlag", "predict", c(580, 850), roundvalue=5)
#'
#' @export

univariate <- function(frame, groupvar, actual, model, grouprange=NULL,
                       roundvalue = NULL, roundfunc = 'round', labelangle = 0,
                       titlestring=NULL) {
  # Calculate modeled and actual values as aggregated over a single variable,
  # graphs result with underlying histogram.
  #
  # Author: Michael Wilcox
  #         loanDepot, Business Intelligence, Data Science
  # Date: 04/21/2015
  #
  # Args:
  #   frame: data frame containing groupvar, actual, model values
  #   groupvar: variable to aggregate modeled and actual values over
  #   actual: variable containing actual boolean values (T/F, 1/0)
  #   model: variable containing modeled predicted values (probability)
  #   grouprange: range of integers to graph groupvar over, c(min, max)
  #
  # Returns:
  #   A ggplot2 object

  # Check if required packages are downloaded. Download if not found.
  # for (package in c('ggplot2', 'gridExtra', 'dplyr', 'lazyeval')) {
  #   if (!(require(package, character.only = T, quietly = T))) {
  #     install.packages(package)
  #     library(package, character.only = T)
  #   }
  # }

  import::from(plyr, round_any)
  library(dplyr)
  library(lazyeval)
  library(ggplot2)
  library(grid)
  library(gridExtra)

  # if (!is.null(roundvalue)) {
  #   frame <- frame %>%
  #     mutate_(a = interp(~round_any(x, y, z),
  #                        a = as.name(groupvar),
  #                        x = as.name(groupvar),
  #                        y = roundvalue,
  #                        z = as.name(roundfunc)
  #                        )
  #     )
  # }

  if (!is.null(roundvalue)) {
    mutate_call <- interp(~round_any(x, y, z),
                         x = as.name(groupvar),
                         y = roundvalue,
                         z = as.name(roundfunc)
      )
    frame <- frame %>%
      mutate_(.dots = setNames(list(mutate_call), groupvar))
  }


  # Group by variable
  grouped <- frame %>%
    group_by_(groupvar) %>%
    summarise_(n = "n()",
               actual = interp(~mean(x, na.rm = TRUE), x = as.name(actual)),
               model = interp(~mean(y, na.rm = TRUE), y = as.name(model))
               )

#   grouped <- aggregate(cbind(frame[, actual], frame[, model]) ~ frame[, groupvar],
#                          data = frame, FUN = mean)
#   colnames(grouped) <- c(groupvar, actual, model)


  # check groupvar type, determine graph options
  # if (is.factor(grouped[, 1])) {

  hjustvar <- NULL

  if (labelangle != 0) {
    hjustvar <- 1
  }

  if (is.factor(grouped[[groupvar]])) {
    actual.geom <- geom_point(aes(color = "Actual"), size = 3)
    model.geom <- geom_point(aes(y = model, color = "Model"), size = 3)
    # hist.geom <- geom_histogram()
    hist.geom <- geom_bar(aes(y = n), stat = "identity")
    theme.top <- theme(legend.title = element_blank(),
                       legend.position = "top",
                       axis.text.x = element_text(angle = labelangle,
                                                  hjust = hjustvar))
    theme.bot <- theme(legend.position = "none", title = element_blank(),
                       axis.text.x = element_text(angle = labelangle,
                                                  hjust = hjustvar))
  } else {
    actual.geom <- geom_point()
    model.geom <- geom_line(aes(y = model), color = "red")
    hist.geom <- geom_density(alpha = 0.5, fill = "black")
    theme.top <- theme(legend.title = element_blank(),
                       axis.text.x = element_text(angle = labelangle,
                                                  hjust = hjustvar))
    theme.bot <- theme(legend.position = "top", axis.title.x = element_blank(),
                       axis.text.x = element_text(angle = labelangle,
                                                  hjust = hjustvar))
  }
  cood <- coord_cartesian(xlim = grouprange)

  # Default title
  if (is.null(titlestring)) {
    titlestring <- paste("Likelihood of ", actual, ", by ", groupvar, sep = "")
  }

  # create ggplot objects
  localenv <- environment()
  # plot.top <- ggplot(grouped, aes(x = grouped[, 1], y = grouped[, 2]),
  plot.top <- ggplot(grouped, aes_string(x = groupvar, y = "actual"),
                     environment = localenv) +
    actual.geom +
    model.geom +
    labs(title = titlestring, y = "Probability", x = groupvar) +
    theme.top +
    coord_cartesian(xlim = grouprange)

  if (is.factor(grouped[[groupvar]])) {
    plot.bot <- ggplot(grouped, aes_string(x = groupvar), environment = localenv) +
      hist.geom +
      theme.bot +
      coord_cartesian(xlim = grouprange)
  } else {
    plot.bot <- ggplot(frame, aes_string(x = groupvar), environment = localenv) +
      hist.geom +
      theme.bot +
      coord_cartesian(xlim = grouprange)

  }

  # combine and return
  gp1 <- ggplot_gtable(ggplot_build(plot.top))
  gp2 <- ggplot_gtable(ggplot_build(plot.bot))
  maxWidth <- unit.pmax(gp1$widths[2:5], gp2$widths[2:5])
  gp1$widths[2:5] <- as.list(maxWidth)
  gp2$widths[2:5] <- as.list(maxWidth)
  result <- arrangeGrob(gp1, gp2, nrow = 2, heights = c(4, 1))

  grid.arrange(gp1, gp2, nrow = 2, heights = c(4, 1))
  return(result)
}

