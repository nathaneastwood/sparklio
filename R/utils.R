#' Check whether an object is a `tbl_spark` object
#'
#' @param x An R object.
#'
#' @return
#' A `logical(1)` vector.
#'
#' @export
is.tbl_spark <- function(x) {
  inherits(x = x, what = "tbl_spark")
}

#' Check whether an object is a `sql` query
#'
#' @param An R object.
#'
#' @return
#' A `logical(1)` vector.
#'
#' @export
is.sql <- function(x) {
  inherits(x = x, what = "sql")
}
