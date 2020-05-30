#' Upload Data to Spark
#'
#' Given a `data.frame` in R, upload it to a Spark context.
#'
#' @details
#' This function is a faster version of [dplyr::copy_to()].
#'
#' @param sc A `spark_connection`.
#' @param x A `data.frame`.
#' @param name `character(1)`. The name to give to the data in the Spark
#' context.
#' @param ... Additional arguments to be passed on to
#' [sparklyr::spark_read_csv()].
#'
#' @return
#' A `tbl_spark` which is a pointer to a Spark DataFrame within `sc`
#'
#' @importFrom DBI dbListTables
#' @importFrom sparklyr spark_read_csv
#' @importFrom data.table fwrite
#' @export
spark_push_data <- function(sc, x, name, overwrite = FALSE) {
  if (!is.data.frame(x)) stop("`x` must be a data.frame")
  if (!is.logical(overwrite)) stop("`overwrite` must be a logical value")
  if (isTRUE(name %in% DBI::dbListTables(sc)) && !isTRUE(overwrite)) {
    stop(name, " exists within the Spark connection but overwrite = FALSE.")
  }
  tmp_file <- paste0(tempfile(), ".csv")
  on.exit(unlink(tmp_file), add = TRUE)
  data.table::fwrite(x, file = tmp_file, showProgress = FALSE)
  sparklyr::spark_read_csv(
    sc,
    name = name,
    path = tmp_file,
    overwrite = overwrite,
    ...
  )
}
