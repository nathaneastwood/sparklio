#' Collect a Spark DataFrame into R
#'
#' Given the name of a Spark DataFrame or a reference to a Spark DataFrame,
#' collect it into R from a `spark_connection`.
#'
#' @param x One of:
#' * A `tbl_spark` object.
#' * A `character(1)` name of the table to retrieve passed with `sc`.
#' @param sc A `spark_connection`, only required if `x` is passed as a
#' `character(1)` (def: `NULL`).
#'
#' @return
#' A `tibble`.
#'
#' @examples
#' \dontrun{
#' sc <- sparklyr::spark_connect(master = "local")
#' mtcars_spark <- dplyr::copy_to(sc, mtcars)
#'
#' # We can collect the data using the R objet
#' spark_collect_data(mtcars_spark)
#'
#' # Or by referencing the name within the spark connection
#' spark_collect_data(x = "mtcars", sc = sc)
#' }
#'
#' @importFrom DBI dbExistsTable
#' @importFrom dplyr as_tibble collect tbl
#' @export
spark_collect_data <- function(x, sc = NULL) {
  res <- if (is.tbl_spark(x)) {
    dplyr::collect(x)
  } else {
    if (!DBI::dbExistsTable(sc, x)) stop(sQuote(x), " could not be found.")
    dplyr::collect(dplyr::tbl(sc, x))
  }
  dplyr::as_tibble(res)
}
