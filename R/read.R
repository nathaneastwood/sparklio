#' Read from Spark
#'
#' Read data from a Spark connection into R either by reference or by query.
#'
#' @param what Either a `tbl_spark` or a SQL query `character(1)` string.
#' @param sc A `spark_connection` used in conjunction with a SQL query given to `what`.
#' @param ... Additional parameters passed on to [dplyr::collect()] or [DBI::dbGetQuery()]
#'
#' @return A tibble.
#'
#' @examples
#' sc <- sparklyr::spark_connect(master = "local")
#' mt_spark <- write_to_spark(what = mtcars, sc = sc, name = "mtcars")
#' read_from_spark(what = mt_spark)
#' read_from_spark(what = "SELECT * FROM mtcars", sc = sc)
#'
#' @seealso
#' [dplyr::collect()], [DBI::dbGetQuery()]
#'
#' @importFrom DBI dbGetQuery
#' @importFrom sparklyr collect
#' @importFrom dplyr as_tibble sql
#' @export
read_from_spark <- function(what, sc, ...) {
  if (is_spark_tbl(what)) {
    sparklyr::collect(what, ...)
  } else if (is.character(what)) {
    if (!is_open_spark_connection(sc)) stop(deparse(substitute(sc)), " is not a valid, open, Spark connection")
    dplyr::as_tibble(DBI::dbGetQuery(sc, dplyr::sql(what), ...))
  } else {
    stop("Unknown object type, `what`")
  }
}
