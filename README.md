
# sparklio

`sparklio` provides a common, faster interface for interacting with data between R and Spark.

## Installation

You can install development version of `sparklio` from GitHub using:

```r
# install.packages("remotes")
remotes::install_github("nathaneastwood/sparklio")
```

## Usage

```r
library(sparklio)
sc <- sparklyr::spark_connect(master = "local")
```

`sparklio` allows the user to:

* push data from R to Spark:

```r
# This is equivalent to dplyr::copy_to() but it faster
mtcars_spark <- spark_push_data(sc, mtcars, "mtcars")
```

* pull data from Spark into R:

```r
mtcars <- spark_pull_data(mtcars, sc)
mtcars <- spark_pull_data("mtcars", sc)
mtcars <- spark_pull_data(mtcars_spark)
```

* query data in Spark

```r
spark_query_data <- spark_query_data(
  sc,
  "SELECT * FROM mtcars",
  type = "lazy"
)
```

```r
spark_query_data <- spark_query_data(
  sc,
  "SELECT * FROM mtcars",
  type = "compute"
)
```

```r
spark_query_data <- spark_query_data(
  sc,
  "SELECT * FROM mtcars",
  type = "collect"
)
```
