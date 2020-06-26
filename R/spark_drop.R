#' Drop tables from a Spark session
#'
#' This functionality is similar to `dbplyr::drop_db_table()` but invokes the
#' Spark method without the long call stack.
#'
#' @param sc A `spark_connection`.
#' @param tbl `character(1)`. The name of the table to remove.
#'
#' @return `logical(1)` referring to whether the removal was successful (`TRUE`)
#' or not (`FALSE`).
#'
#' @importFrom DBI dbListTables
#' @importFrom sparklyr spark_session invoke
#' @name spark_drop
NULL

#' @rdname spark_drop
#' @export
spark_drop_table <- function(sc, tbl) {
  if (!is.character(tbl) || length(tbl) != 1) {
    stop("`tbl` needs to be a length 1 character vector")
  }
  ss <- sparklyr::spark_session(sc)
  catalog <- sparklyr::invoke(ss, "catalog")
  sparklyr::invoke(catalog, "dropTempView", tbl)
}

#' @rdname spark_drop
#' @export
spark_drop_all_tables <- function(sc) {
  lapply(
    DBI::dbListTables(sc),
    function(x, sc) spark_drop_table(sc, x),
    sc = sc
  )
}
