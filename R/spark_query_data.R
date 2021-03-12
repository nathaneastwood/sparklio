#' Query a Spark DataFrame
#'
#' Query a Spark DataFrame and optionally return the results to Spark memory or
#' to R's memory.
#'
#' @details
#' This function differs depending on the `type` given by the user. There are
#' three scenarios:
#'
#' 1. The default, `"lazy"`, is only evaluated, for example when the user
#'    collects the data (see [sparklyr::collect()]).
#' 2. `"compute"` ensures that the query is executed and the resulting data are
#'    stored within Spark's memory.
#' 3. `"collect"` executes the query and returns the resulting data to R's
#'    memory.
#'
#' @param sc A `spark_connection`.
#' @param qry A SQL query.
#' @param type `character(1)`. One of "lazy", "compute" or "collect". See
#' details for more.
#' @param name `character(1)`. If not `NULL`, the resulting object will be
#' registered within the Spark context under this name.
#'
#' @return
#' One of two:
#' 1. A `tbl_spark` reference to a Spark DataFrame in the event `type` is
#'    `"compute"` or `"lazy"`.
#' 2. A `tibble` in the event `type` is `"collect"`.
#'
#' @examples
#' \dontrun{
#' sc <- sparklyr::spark_connect(master = "local")
#' mtcars_spark <- sparklyr::copy_to(dest = sc, df = mtcars)
#'
#' # By default, queries are executed lazily
#' spark_query_data(sc = sc, qry = "select mpg from mtcars")
#'
#' # But we can cache the results
#' cache <- spark_query_data(
#'   sc = sc,
#'   qry = "select mpg from mtcars",
#'   name = "mpg_mtcars",
#'   type = "compute"
#' )
#' # And gather the results
#' spark_collect_data(x = "mpg_mtcars", sc = sc)
#'
#' # Or we can collect the data instantly
#' spark_query_data(
#'   sc = sc,
#'   qry = "select disp from mtcars",
#'   type = "collect"
#' )
#' }
#'
#' @importFrom dplyr collect compute sql tbl
#' @importFrom sparklyr sdf_register
#' @export
spark_query_data <- function(
  sc,
  qry,
  name,
  type = c("lazy", "compute", "collect")
) {

  type <- match.arg(
    arg = type,
    choices = c("lazy", "compute", "collect"),
    several.ok = FALSE
  )

  if (!is.sql(qry)) qry <- dplyr::sql(qry)
  out <- dplyr::tbl(src = sc, qry)
  if (!missing(name) && type != "compute") {
    warn_name_clash(sc = sc, name = name)
    sparklyr::sdf_register(x = out, name = name)
    inform_register(name = name)
  }
  if (type == "collect") out <- dplyr::collect(x = out)
  if (type == "compute") {
    if (missing(name)) name <- random_table_name()
    warn_name_clash(sc = sc, name = name)
    out <- dplyr::compute(x = out, name = name)
    inform_register(name = name)
  }
  out
}

# Helpers ----------------------------------------------------------------------

inform_register <- function(name) {
  message("The query result has been registered in Spark as ", sQuote(name))
}

#' @importFrom DBI dbExistsTable
#' @noRd
warn_name_clash <- function(sc, name) {
  if (DBI::dbExistsTable(conn = sc, name = name)) {
    warning(
      "A table with the name ", sQuote(name),
      " is already registered within Spark memory and will be overwritten."
    )
  }
}

random_table_name <- function(n = 10) {
  warning("`name` was not supplied, assigning name ", sQuote(name))
  paste0(
    "sparkio_",
    paste0(sample(x = letters, size = n, replace = TRUE),
    collapse = "")
  )
}
