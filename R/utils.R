#' Is `spark_tbl`
#'
#' Check if an R object is a reference to a valid Spark DataFrame
#'
#' @param what An R object
#'
#' @return `logical(1)`
#'
#' @export
is_spark_tbl <- function(what) {
  all(class(what) %in% c("tbl_spark", "tbl_sql", "tbl_lazy", "tbl"))
}

#' Check A Spark Object's Validity
#'
#' Check whether an R object is a valid, open Spark connection
#'
#' @param sc An R object
#'
#' @return
#' `logical(1)`
#'
#' @importFrom sparklyr connection_is_open
#' @export
is_open_spark_connection <- function(sc) {
  if (all(class(sc) %in% c("spark_connection", "spark_shell_connection", "DBIConnection"))) {
    sparklyr::connection_is_open(sc)
  } else {
    FALSE
  }
}
