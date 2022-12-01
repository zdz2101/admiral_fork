.datasets <- new.env(parent = emptyenv())

#' Get Duplicate Records that Lead to a Prior Error
#'
#' @export
#'
#' @author Thomas Neitmann
#'
#' @details
#' Many {admiral} function check that the input dataset contains only one record
#' per `by_vars` group and throw an error otherwise. The `get_duplicates_dataset()`
#' function allows one to retrieve the duplicate records that lead to an error.
#'
#' Note that the function always returns the dataset of duplicates from the last
#' error that has been thrown in the current R session. Thus, after restarting the
#' R sessions `get_duplicates_dataset()` will return `NULL` and after a second error
#' has been thrown, the dataset of the first error can no longer be accessed (unless
#' it has been saved in a variable).
#'
#' @return A `data.frame` or `NULL`
#'
#' @family utils_ds_chk
#'
#' @keywords utils_ds_chk
#'
#' @examples
#' data(admiral_adsl)
#'
#' # Duplicate the first record
#' adsl <- rbind(admiral_adsl[1L, ], admiral_adsl)
#'
#' signal_duplicate_records(adsl, vars(USUBJID), cnd_type = "warning")
#'
#' get_duplicates_dataset()
get_duplicates_dataset <- function() {

  # If using an IDE, search if error message was prompted
  if(interactive()){

    # Grab RHistory of user's current session
    savehistory(file = "./temphistory.Rhistory")
    temphistory = readLines("./temphistory.Rhistory")

    # Try and filter down the rhistory to most recent commands
    # Ideally get the prior command, but tricky so use prior assignment operator as proxy
    last_assignment_command = max(grep("<-", temphistory))
    last_get_call = max(grep("get_duplicates_dataset()", temphistory))

    # Write these snippets of code into a temporary R script
    temptext = file("./temphistory.R")
    writeLines(temphistory[last_assignment_command:(last_get_call - 1)], temptext)
    close(temptext)

    # Create a temporary message and error log
    file_path = "./templog.txt"
    file_con = file(file_path, open = "a")
    sink(file_con, type = "message")
    try(source("./temphistory.R"))
    sink(type = "message")
    close(file_con)

    error_log = readLines("./templog.txt")

    # Delete all these temporary files
    unlink("./temphistory.Rhistory")
    unlink("./temphistory.R")
    unlink("./templog.txt")

    # Search log for whether or not our warning message was inside
    if(!any(str_detect(error_log, "Run \\`get_duplicates_dataset\\(\\)\\` to access the duplicate records"))){
      message("Duplicate records may not be up to date, run `get_duplicates_dataset()` only after the prompt: \n   Run `get_duplicates_dataset()` to access the duplicate records.")
    }
  }
  .datasets$duplicates
}

#' Extract Duplicate Records
#'
#' @param dataset A data frame
#' @param by_vars A list of variables created using `vars()` identifying groups of
#'   records in which to look for duplicates
#'
#' @return A `data.frame` of duplicate records within `dataset`
#'
#' @export
#' @family utils_ds_chk
#'
#' @keywords utils_ds_chk
#' @author Thomas Neitmann
#'
#' @examples
#' data(admiral_adsl)
#'
#' # Duplicate the first record
#' adsl <- rbind(admiral_adsl[1L, ], admiral_adsl)
#'
#' extract_duplicate_records(adsl, vars(USUBJID))
extract_duplicate_records <- function(dataset, by_vars) {
  assert_vars(by_vars)
  assert_data_frame(dataset, required_vars = by_vars, check_is_grouped = FALSE)

  data_by <- dataset %>%
    ungroup() %>%
    select(!!!by_vars)

  is_duplicate <- duplicated(data_by) | duplicated(data_by, fromLast = TRUE)

  dataset %>%
    ungroup() %>%
    select(!!!by_vars, dplyr::everything()) %>%
    filter(is_duplicate) %>%
    arrange(!!!by_vars)
}

#' Signal Duplicate Records
#'
#' @param dataset A data frame
#' @param by_vars A list of variables created using `vars()` identifying groups of
#'   records in which to look for duplicates
#' @param msg The condition message
#' @param cnd_type Type of condition to signal when detecting duplicate records.
#'   One of `"message"`, `"warning"` or `"error"`. Default is `"error"`.
#'
#' @return No return value, called for side effects
#'
#' @export
#' @family utils_help
#' @keywords utils_help
#' @author Thomas Neitmann
#'
#' @examples
#' data(admiral_adsl)
#'
#' # Duplicate the first record
#' adsl <- rbind(admiral_adsl[1L, ], admiral_adsl)
#'
#' signal_duplicate_records(adsl, vars(USUBJID), cnd_type = "message")
signal_duplicate_records <- function(dataset,
                                     by_vars,
                                     msg = paste("Dataset contains duplicate records with respect to", enumerate(vars2chr(by_vars))), # nolint
                                     cnd_type = "error") {
  assert_vars(by_vars)
  assert_data_frame(dataset, required_vars = by_vars, check_is_grouped = FALSE)
  assert_character_scalar(msg)
  assert_character_scalar(cnd_type, values = c("message", "warning", "error"))

  cnd_funs <- list(message = inform, warning = warn, error = abort)

  duplicate_records <- extract_duplicate_records(dataset, by_vars)
  if (nrow(duplicate_records) >= 1L) {
    .datasets$duplicates <- structure(
      duplicate_records,
      class = union("duplicates", class(duplicate_records)),
      by_vars = vars2chr(by_vars)
    )
    full_msg <- paste0(msg, "\nRun `get_duplicates_dataset()` to access the duplicate records")
    cnd_funs[[cnd_type]](full_msg)
  }
}

print.duplicates <- function(x, ...) {
  cat(
    "Dataset contains duplicate records with respect to ",
    enumerate(attr(x, "by_vars")),
    ".\n",
    sep = ""
  )
  NextMethod()
}
