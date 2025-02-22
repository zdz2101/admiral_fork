#' Derive Duration
#'
#' Derives duration between two dates, specified by the variables present in
#' input dataset e.g., duration of adverse events, relative day, age, ...
#'
#' @param dataset Input dataset
#'
#'   The variables specified by the `start_date` and the `end_date` parameter are
#'   expected.
#'
#' @param new_var Name of variable to create
#'
#' @param new_var_unit Name of the unit variable If the parameter is not
#'   specified, no variable for the unit is created.
#'
#' @param start_date The start date
#'
#'   A date or date-time variable is expected. This variable must be present in
#'   specified input dataset.
#'
#'   Refer to `derive_vars_dt()` to impute and derive a date from a date
#'   character vector to a date object.
#'
#' @param end_date The end date
#'
#'   A date or date-time variable is expected. This variable must be present in
#'   specified input dataset.
#'
#'   Refer to `derive_vars_dt()` to impute and derive a date from a date
#'   character vector to a date object.
#'
#' @param in_unit Input unit
#'
#'   See floor_in and add_one parameter for details.
#'
#'   Default: 'days'
#'
#'   Permitted Values: 'years', 'months', 'days', 'hours', 'minutes', 'min',
#'   'seconds', 'sec'
#'
#' @param out_unit Output unit
#'
#'   The duration is derived in the specified unit
#'
#'   Default: 'days'
#'
#'   Permitted Values: 'years', 'months', 'days', 'hours', 'minutes', 'min',
#'   'seconds', 'sec'
#'
#' @param floor_in Round down input dates?
#'
#'   The input dates are round down with respect to the input unit, e.g., if the
#'   input unit is 'days', the time of the input dates is ignored.
#'
#'   Default: `TRUE``
#'
#'   Permitted Values: `TRUE`, `FALSE`
#'
#' @param add_one Add one input unit?
#'
#'   If the duration is non-negative, one input unit is added. I.e., the
#'   duration can not be zero.
#'
#'   Default: `TRUE` Permitted Values: `TRUE`, `FALSE`
#'
#' @param trunc_out Return integer part
#'
#'   The fractional part of the duration (in output unit) is removed, i.e., the
#'   integer part is returned.
#'
#'   Default: `FALSE`
#'
#'   Permitted Values: `TRUE`, `FALSE`
#'
#' @details The duration is derived as time from start to end date in the
#'   specified output unit. If the end date is before the start date, the duration
#'   is negative. The start and end date variable must be present in the specified
#'   input dataset.
#'
#'
#' @return The input dataset with the duration and unit variable added
#'
#' @family der_date_time
#' @keywords der_gen der_date_time
#'
#' @export
#'
#' @seealso [compute_duration()]
#'
#' @examples
#' library(lubridate)
#' library(tibble)
#'
#' # Derive age in years
#' data <- tribble(
#'   ~USUBJID, ~BRTHDT, ~RANDDT,
#'   "P01", ymd("1984-09-06"), ymd("2020-02-24"),
#'   "P02", ymd("1985-01-01"), NA,
#'   "P03", NA, ymd("2021-03-10"),
#'   "P04", NA, NA
#' )
#'
#' derive_vars_duration(data,
#'   new_var = AAGE,
#'   new_var_unit = AAGEU,
#'   start_date = BRTHDT,
#'   end_date = RANDDT,
#'   out_unit = "years",
#'   add_one = FALSE,
#'   trunc_out = TRUE
#' )
#'
#' # Derive adverse event duration in days
#' data <- tribble(
#'   ~USUBJID, ~ASTDT, ~AENDT,
#'   "P01", ymd("2021-03-05"), ymd("2021-03-02"),
#'   "P02", ymd("2019-09-18"), ymd("2019-09-18"),
#'   "P03", ymd("1985-01-01"), NA,
#'   "P04", NA, NA
#' )
#'
#' derive_vars_duration(data,
#'   new_var = ADURN,
#'   new_var_unit = ADURU,
#'   start_date = ASTDT,
#'   end_date = AENDT,
#'   out_unit = "days"
#' )
#'
#' # Derive adverse event duration in minutes
#' data <- tribble(
#'   ~USUBJID, ~ADTM, ~TRTSDTM,
#'   "P01", ymd_hms("2019-08-09T04:30:56"), ymd_hms("2019-08-09T05:00:00"),
#'   "P02", ymd_hms("2019-11-11T10:30:00"), ymd_hms("2019-11-11T11:30:00"),
#'   "P03", ymd_hms("2019-11-11T00:00:00"), ymd_hms("2019-11-11T04:00:00"),
#'   "P04", NA, ymd_hms("2019-11-11T12:34:56"),
#' )
#'
#' derive_vars_duration(data,
#'   new_var = ADURN,
#'   new_var_unit = ADURU,
#'   start_date = ADTM,
#'   end_date = TRTSDTM,
#'   in_unit = "minutes",
#'   out_unit = "minutes",
#'   add_one = FALSE
#' )
#'
#' # Derive adverse event start time since last dose in hours
#' data <- tribble(
#'   ~USUBJID, ~ASTDTM, ~LDOSEDTM,
#'   "P01", ymd_hms("2019-08-09T04:30:56"), ymd_hms("2019-08-08T10:05:00"),
#'   "P02", ymd_hms("2019-11-11T23:59:59"), ymd_hms("2019-10-11T11:37:00"),
#'   "P03", ymd_hms("2019-11-11T00:00:00"), ymd_hms("2019-11-10T23:59:59"),
#'   "P04", ymd_hms("2019-11-11T12:34:56"), NA,
#'   "P05", NA, ymd_hms("2019-09-28T12:34:56")
#' )
#' derive_vars_duration(
#'   data,
#'   new_var = LDRELTM,
#'   new_var_unit = LDRELTMU,
#'   start_date = LDOSEDTM,
#'   end_date = ASTDTM,
#'   in_unit = "hours",
#'   out_unit = "hours",
#'   add_one = FALSE
#' )
derive_vars_duration <- function(dataset,
                                 new_var,
                                 new_var_unit = NULL,
                                 start_date,
                                 end_date,
                                 in_unit = "days",
                                 out_unit = "days",
                                 floor_in = TRUE,
                                 add_one = TRUE,
                                 trunc_out = FALSE) {
  new_var <- assert_symbol(enexpr(new_var))
  new_var_unit <- assert_symbol(enexpr(new_var_unit), optional = TRUE)
  start_date <- assert_symbol(enexpr(start_date))
  end_date <- assert_symbol(enexpr(end_date))
  assert_data_frame(dataset, required_vars = exprs(!!start_date, !!end_date))
  assert_character_scalar(in_unit, values = valid_time_units())
  assert_character_scalar(out_unit, values = c(
    valid_time_units(), "weeks",
    "min", "sec"
  ))
  assert_logical_scalar(floor_in)
  assert_logical_scalar(add_one)
  assert_logical_scalar(trunc_out)

  warn_if_vars_exist(
    dataset,
    c(
      deparse(substitute(new_var)),
      deparse(substitute(new_var_unit))
    )
  )

  dataset <- dataset %>%
    mutate(
      !!new_var := compute_duration(
        !!start_date,
        !!end_date,
        in_unit = in_unit,
        out_unit = out_unit,
        floor_in = floor_in,
        add_one = add_one,
        trunc_out = trunc_out
      )
    )

  if (!is.null(new_var_unit)) {
    dataset <- dataset %>%
      mutate(!!new_var_unit := if_else(is.na(!!new_var), NA_character_, toupper(out_unit)))
  }

  dataset
}
