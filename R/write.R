#' Write data from R to a spark connection
#'
#' Either write a table to Spark or write the results of a query to Spark.
#'
#' Given a SQL query, this function will execute it within a Spark context and then cache the results of that query in
#' a Spark DataFrame. This caching is the default to match the behaviour of uploading a table into Spark memory.
#'
#' @param what `character(1)`. A SQL query.
#' @param sc A `spark_connection`.
#' @param name `character(1)`. The name of the resulting table in Spark.
#' @param ... Additional parameters to be passed to [sparklyr::spark_read_csv()]. Not used for queries.
#' @param overwrite `logical(1)`. Overwrite an existing table (default: `TRUE`)?
#' @param cache_results `logical(1)`. Cache the results of a query in Spark (default: `TRUE`)?
#'
#' @return
#' A `tbl_spark`. A pointer to the Spark DataFrame.
#'
#' @examples
#' \dontrun{
#' sc <- sparklyr::spark_connect(master = "local")
#' # Upload a table to Spark
#' write_to_spark(mtcars, sc = sc, name = "mtcars")
#' # Write the results of a query
#' write_to_spark(what = "SELECT mpg, cyl FROM mtcars", sc = sc, name = "mtcars_subset")
#'
#' @seealso
#' [sparklyr::tbl_cache()], [sparklyr::spark_read_csv()], [sparklyr::sdf_register()]
#'
#' @importFrom data.table fwrite
#' @importFrom DBI dbExistsTable
#' @importFrom sparklyr sdf_register spark_read_csv tbl_cache
#' @importFrom dplyr sql tbl
#' @export
write_to_spark <- function(what, sc, name, ..., overwrite = TRUE, cache_results =  TRUE) {
  if (missing(what)) stop("Please provide `what` you wish to write")
  if (!is_open_spark_connection(sc)) stop(deparse(substitute(sc)), " is not a valid, open, Spark connection")
  if (missing(name)) stop("Please provide a `name` for your object in Spark")

  if (is.character(what)) {
    if (DBI::dbExistsTable(sc, name) & !isTRUE(overwrite)) {
      stop(name, " exists within the Spark connection but overwrite = FALSE; ", name, " will not be overwritten.")
    }
    reference <- sparklyr::sdf_register(dplyr::tbl(sc, dplyr::sql(what)), name = name)
    if (isTRUE(cache_results)) sparklyr::tbl_cache(sc, name)
    return(reference)
  } else if (is.list(what) & length(unique(lengths(what))) == 1L) {
    tmp_file <- paste0(tempfile(), ".csv")
    on.exit(unlink(tmp_file))
    data.table::fwrite(what, file = tmp_file, showProgress = FALSE)
    if (DBI::dbExistsTable(sc, name) & !isTRUE(overwrite)) {
      stop(name, " exists within the Spark connection but overwrite = FALSE; ", name, " will not be overwritten.")
    }
    sparklyr::spark_read_csv(sc, name = name, path = tmp_file, overwrite = overwrite, ...)
  } else {
    stop("Class `", class(what), "` not supported")
  }
}
