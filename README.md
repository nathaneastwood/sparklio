
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sparklio

<!-- badges: start -->

<!-- badges: end -->

`{sparklio}` extends the `{sparklyr}` IO interface by providing a faster
and cleaner interface for pushing and pulling data between R and Spark
amongst other things.

## Installation

You can install the development version of `{sparklio}` from
[GitHub](https://github.com/nathaneastwood/sparklio) with:

``` r
# install.packages("remotes")
remotes::install_github("nathaneastwood/sparklio")
```

## Usage

``` r
library(sparklio)
sc <- sparklyr::spark_connect(master = "local")
```

`{sparklio}` allows the user to:

  - push data from R to Spark:

<!-- end list -->

``` r
# This is equivalent to dplyr::copy_to() but it faster
mtcars_spark <- spark_push_data(sc, mtcars, "mtcars")
```

  - pull data from Spark into R:

<!-- end list -->

``` r
mtcars <- spark_pull_data(mtcars, sc)
mtcars <- spark_pull_data("mtcars", sc)
mtcars <- spark_pull_data(mtcars_spark)
```

  - query data in Spark

<!-- end list -->

``` r
mpg <- spark_query_data(
  sc,
  "SELECT mpg FROM mtcars",
  type = "lazy",
  name = "mpg"
)
```

``` r
mpg <- spark_query_data(
  sc,
  "SELECT mpg FROM mtcars",
  type = "compute",
  name = "mpg"
)
```

``` r
mpg <- spark_query_data(
  sc,
  "SELECT mpg FROM mtcars",
  type = "collect"
)
```

  - drop data from Spark

<!-- end list -->

``` r
spark_drop_table(sc, "mtcars")
# [1] TRUE
```
