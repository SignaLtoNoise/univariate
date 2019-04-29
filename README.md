Univariate
================

## Overview

The univariate package creates ggplot graphs specialized in comparing
model predictions with actual outcomes over a given variable. This can
be helpful in illustrating what predictive behavior a model is catching
(or failing to catch), especially with regard to potentially-correlated
variables. It can also be useful in determining if a dependent variable
requires transformation to better capture the targeted behavior.

This plot function was designed primarily for use with logistic
regression where the target is either a 1 or 0.

## Installation

The easiest way is to install from GitHub directly using devtools:

``` r
# install.packages("devtools")
devtools::install_github("SignaLtoNoise/univariate")
```

## Basic Usage

`univariate()` uses lazyeval to interpret variable columns in the data
frame. The first four arguments are required:

  - `df`: the dataframe containing the variables
  - `groupvar`: the X-axis variable name to plot actual vs prediction
    across
  - `actual`: the targeted observed value column name (1 or 0)
  - `model`: the predicted model result column name

Because of lazyeval, the three column variables must be wrapped in
quotes.

``` r
library(univariate)
univariate(df, "age", "HighIncomeFlag", "predict")
```

![](readme_files/figure-gfm/initial%20example-1.png)<!-- -->

The modeled predictions are graphed as a red line, while the actual
target is graphed as a black scatterplot. Underneath is plotted a
histogram of the groupvar to better understand the underlying behavior.

`univariate()` will detect if the groupvar is a continous or a factor,
and will change the plot accordingly:

``` r
# groupvar is a factor
univariate(df, "sex", "HighIncomeFlag", "predict")
```

![](readme_files/figure-gfm/example%20factor-1.png)<!-- -->

## Secondary Features

### Rounding

On continuous variables, it is sometimes necessary to create rounded
values to make a more comprehensible plot. The `roundvalue` argument
sets the accuracy to round to. The `roundfunc` argument defaults to
“round”, but can be additionally set to “floor” or
“ceiling”.

``` r
univariate(df, "fnlwgt", "HighIncomeFlag", "predict", roundvalue = 10000, roundfunc = 'floor')
```

![](readme_files/figure-gfm/example%20round-1.png)<!-- -->

### Range Limit

Similarly, it is sometimes necessary to truncate long tails so that the
relevant range is given clarity. The `grouprange` argument defines the
numeric range to plot along the `groupvar`
variable:

``` r
univariate(df, "fnlwgt", "HighIncomeFlag", "predict", grouprange = c(0, 600000),
           roundvalue = 10000, roundfunc = 'floor')
```

![](readme_files/figure-gfm/example%20range-1.png)<!-- -->

By default, the entire range of `groupvar` will be plotted. For factor
variables, `grouprange` selects the values along the X-Axis
corresponding to the range.

### Custom Title and Label Angles

Univariate will create a default title, but you can replace it by
feeding a string to the `titlestring` argument.

If there are many factor variables, you can specify a degree to angle
the labels from the X-axis using the `labelangle` argument.

``` r
univariate(df, "occupation", "HighIncomeFlag", "predict",
           labelangle = 20, titlestring = "Univariate Plot with 20-Degree Labels")
```

![](readme_files/figure-gfm/example%20title%20angle-1.png)<!-- -->

## Additional Information

#### Example Dataset

Th data used in this ReadMe came from the [Adult Data
Set](https://archive.ics.uci.edu/ml/datasets/adult) in the UCI Machince
Learning Repository, accessed on April 2019.
