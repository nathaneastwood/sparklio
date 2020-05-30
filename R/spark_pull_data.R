#' Pull a Spark DataFrame into R
#'
#' Given the name of a Spark DataFrame or a reference to a Spark DataFrame, pull
#' it into R from a `spark_connection`.
#'
#' @param x Either the name of the table to retrieve or a `tbl_spark` object.
#' @param sc A `spark_connection`.
#'
#' @return
#' A `tbl_df`.
#'
#' @importFrom DBI dbListTables
#' @importFrom dplyr as_tibble collect tbl
#' @export
spark_pull_data <- function(x, sc = NULL) {
  res <- if (inherits(x, "tbl_spark")) {
    dplyr::collect(x)
  } else {
    if (is_open_spark_connection(sc)) {
      if (!is.character(x)) x <- deparse(substitute(x))
      available_tables <- DBI::dbListTables(sc)
      if (!x %in% available_tables) stop(sQuote(x), " could not be found.")
      dplyr::collect(dplyr::tbl(sc, x))
    } else {
      stop("Is `sc` a valid, open Spark connection?")
    }
  }
  dplyr::as_tibble(res)
}
