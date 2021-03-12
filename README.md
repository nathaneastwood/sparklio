
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sparklio

<!-- badges: start -->
<!-- badges: end -->

`{sparklio}` extends the `{sparklyr}` IO interface by providing
additional utility functions for querying data, dropping tables and
collecting data into R.

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
mtcars_spark <- sparklyr::copy_to(sc, mtcars)
```

### Collect Data From Spark Into R

``` r
# Using the Spark table name
spark_collect_data(x = "mtcars", sc = sc)
# # A tibble: 32 x 11
#      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
# 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
# # … with 22 more rows


# Or using the R reference object
spark_collect_data(x = mtcars_spark)
# # A tibble: 32 x 11
#      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
# 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
# # … with 22 more rows
```

### Querying Data In Spark

``` r
# Lazily query data in Spark and always return a `tibble`
spark_query_data(
  sc = sc,
  qry = "SELECT mpg FROM mtcars"
)
# # Source: spark<SELECT mpg FROM mtcars> [?? x 1]
#      mpg
#    <dbl>
#  1  21  
#  2  21  
#  3  22.8
#  4  21.4
#  5  18.7
#  6  18.1
#  7  14.3
#  8  24.4
#  9  22.8
# 10  19.2
# # … with more rows


# We can specify whether we want to cache the data
qry <- spark_query_data(
  sc = sc,
  qry = "SELECT mpg FROM mtcars",
  name = "mpg_mtcars",
  type = "compute"
)
# The query result has been registered in Spark as 'mpg_mtcars'
spark_collect_data(x = "mpg_mtcars", sc = sc)
# # A tibble: 32 x 1
#      mpg
#    <dbl>
#  1  21  
#  2  21  
#  3  22.8
#  4  21.4
#  5  18.7
#  6  18.1
#  7  14.3
#  8  24.4
#  9  22.8
# 10  19.2
# # … with 22 more rows


# Or if we want to collect the data into R itself
spark_query_data(
  sc = sc,
  qry = "SELECT mpg FROM mtcars",
  type = "collect"
)
# # A tibble: 32 x 1
#      mpg
#    <dbl>
#  1  21  
#  2  21  
#  3  22.8
#  4  21.4
#  5  18.7
#  6  18.1
#  7  14.3
#  8  24.4
#  9  22.8
# 10  19.2
# # … with 22 more rows
```

### Droping Data From Spark

``` r
# We can drop single tables by name
spark_drop_table(sc = sc, "mtcars")
# mtcars 
#   TRUE
```

``` r
# Or drop all tables at once
mtcars_spark <- sparklyr::copy_to(sc, mtcars)
airquality_spark <- sparklyr::copy_to(sc, airquality)
spark_drop_all_tables(sc = sc)
# airquality mpg_mtcars     mtcars 
#       TRUE       TRUE       TRUE
```
