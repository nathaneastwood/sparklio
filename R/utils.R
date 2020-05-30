#' Check A Spark Object's Validity
#'
#' Check whether an R object is a valid, open Spark connection.
#'
#' @param sc An R object
#'
#' @return
#' `logical(1)`
#'
#' @importFrom sparklyr connection_is_open
#' @noRd
is_open_spark_connection <- function(sc) {
  if (inherits(sc, "spark_connection")) {
    sparklyr::connection_is_open(sc)
  } else {
    FALSE
  }
}
