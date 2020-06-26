#' Query a Spark DataFrame
#'
#' Query a Spark DataFrame and optionally return the results to Spark memory or
#' to R's memory.
#'
#' @details
#' This function differs depending on the `type` given by the user. There are
#' three scenarios:
#'
#' 1. The default, `"lazy"`, ensures that the query is registered within the
#'    spark context but it is only evaluated, for example when the user collects
#'    the data (see [spark_pull_data()] or [sparklyr::collect()]).
#' 2. `"compute"` ensures that the query is executed and the resulting data are
#'    stored within Spark's memory.
#' 3. `"collect"` executes the query and returns the resulting data to R's
#'    memory.
#'
#' @param sc A `spark_connection`.
#' @param x A SQL query.
#' @param type `character(1)`. One of "lazy", "compute" or "collect". See
#' details for more.
#' @param name `character(1)`. The name to be given to the Spark DataFrame if
#' `type` is not `collect` (default: `NULL`).
#'
#' @return
#' One of two:
#' 1. A `tbl_spark` reference to a Spark DataFrame in the event `type` is
#'    `"compute"` or `"lazy"`.
#' 2. A `tibble` in the event `type` is `"collect"`.
#'
#' @importFrom DBI dbGetQuery
#' @importFrom dplyr as_tibble sql tbl
#' @importFrom sparklyr sdf_register tbl_cache
#' @export
spark_query_data <- function(
  sc,
  x,
  type = c("lazy", "compute", "collect"),
  name = NULL
) {
  type <- match.arg(type, choices = c("lazy", "compute", "collect"))
  if (!inherits(x, "sql")) x <- dplyr::sql(x)
  res <- if (type == "collect") {
    dplyr::as_tibble(DBI::dbGetQuery(sc, x))
  } else {
    res <- sparklyr::sdf_register(dplyr::tbl(sc, x), name = name)
    if (type == "compute") res <- sparklyr::tbl_cache(sc, name)
    res
  }
  res
}
