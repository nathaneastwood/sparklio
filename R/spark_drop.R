#' Drop tables from a Spark session
#'
#' Remove either a single table or all tables from a Spark session.
#'
#' @param sc A `spark_connection`.
#' @param name `character(1)`. The name of the table to remove.
#'
#' @return
#' * `spark_drop_table()`: A `logical(1)` referring to whether the removal was
#'   successful (`TRUE`) or not (`FALSE`).
#' * `spark_drop_all_tables()`: A `list()` of `logical(1)` vectors indicating
#'   whether the removals were successful (`TRUE`) or not (`FALSE`).
#'
#' @examples
#' \dontrun{
#' sc <- sparklyr::spark_connect(master = "local")
#' mtcars_spark <- sparklyr::copy_to(dest = sc, df = mtcars)
#' airquality_spark <- sparklyr::copy_to(dest = sc, df = airquality)
#' cars_spark <- sparklyr::copy_to(dest = sc, df = cars)
#'
#' # We can drop a single table
#' spark_drop_table(sc = sc, name = "mtcars")
#'
#' # Or all tables
#' spark_drop_all_tables(sc = sc)
#' }
#'
#' @importFrom DBI dbListTables
#' @importFrom sparklyr spark_session invoke
#' @name spark_drop
NULL

#' @rdname spark_drop
#' @export
spark_drop_table <- function(sc, name) {
  if (!is.character(name) || length(name) != 1) {
    stop("`name` needs to be a length 1 character vector")
  }
  catalog <- spark_catalog(sc)
  res <- sparklyr::invoke(catalog, "dropTempView", name)
  names(res) <- name
  res
}

#' @rdname spark_drop
#' @export
spark_drop_all_tables <- function(sc) {
  vapply(
    DBI::dbListTables(sc),
    function(x, sc) spark_drop_table(sc, x),
    TRUE,
    sc = sc
  )
}
