% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_param_computed.R
\name{derive_param_computed}
\alias{derive_param_computed}
\title{Adds a Parameter Computed from the Analysis Value of Other Parameters}
\usage{
derive_param_computed(
  dataset,
  by_vars,
  parameters,
  analysis_value,
  set_values_to,
  filter = NULL,
  constant_by_vars = NULL,
  constant_parameters = NULL
)
}
\arguments{
\item{dataset}{Input dataset

The variables specified by the \code{by_vars} parameter, \code{PARAMCD}, and \code{AVAL}
are expected.

The variable specified by \code{by_vars} and \code{PARAMCD} must be a unique key of
the input dataset after restricting it by the filter condition (\code{filter}
parameter) and to the parameters specified by \code{parameters}.}

\item{by_vars}{Grouping variables

For each group defined by \code{by_vars} an observation is added to the output
dataset. Only variables specified in \code{by_vars} will be populated
in the newly created records.

\emph{Permitted Values:} list of variables}

\item{parameters}{Required parameter codes

It is expected that all parameter codes (\code{PARAMCD}) which are required to
derive the new parameter are specified for this parameter or the
\code{constant_parameters} parameter.

\emph{Permitted Values:} A character vector of \code{PARAMCD} values}

\item{analysis_value}{Definition of the analysis value

An expression defining the analysis value (\code{AVAL}) of the new parameter is
expected. The analysis values of the parameters specified by \code{parameters}
can be accessed using \verb{AVAL.<parameter code>}, e.g., \code{AVAL.SYSBP}.

\emph{Permitted Values:} An unquoted expression}

\item{set_values_to}{Variables to be set

The specified variables are set to the specified values for the new
observations. For example \code{exprs(PARAMCD = "MAP")} defines the parameter
code for the new parameter.

\emph{Permitted Values:} List of variable-value pairs}

\item{filter}{Filter condition

The specified condition is applied to the input dataset before deriving the
new parameter, i.e., only observations fulfilling the condition are taken
into account.

\emph{Permitted Values:} a condition}

\item{constant_by_vars}{By variables for constant parameters

The constant parameters (parameters that are measured only once) are merged
to the other parameters using the specified variables. (Refer to Example 2)

\emph{Permitted Values:} list of variables}

\item{constant_parameters}{Required constant parameter codes

It is expected that all the parameter codes (\code{PARAMCD}) which are required
to derive the new parameter and are measured only once are specified here.
For example if BMI should be derived and height is measured only once while
weight is measured at each visit. Height could be specified in the
\code{constant_parameters} parameter. (Refer to Example 2)

\emph{Permitted Values:} A character vector of \code{PARAMCD} values}
}
\value{
The input dataset with the new parameter added. Note, a variable will only
be populated in the new parameter rows if it is specified in \code{by_vars}.
}
\description{
Adds a parameter computed from the analysis value of other parameters. It is
expected that the analysis value of the new parameter is defined by an
expression using the analysis values of other parameters. For example mean
arterial pressure (MAP) can be derived from systolic (SYSBP) and diastolic
blood pressure (DIABP) with the formula
\deqn{MAP = \frac{SYSBP + 2 DIABP}{3}}{MAP = (SYSBP + 2 DIABP) / 3}
}
\details{
For each group (with respect to the variables specified for the
\code{by_vars} parameter) an observation is added to the output dataset if the
filtered input dataset contains exactly one observation for each parameter
code specified for \code{parameters}.

For the new observations \code{AVAL} is set to the value specified by
\code{analysis_value} and the variables specified for \code{set_values_to} are set to
the provided values. The values of the other variables of the input dataset
are set to \code{NA}.
}
\examples{
library(tibble)

# Example 1: Derive MAP
advs <- tribble(
  ~USUBJID, ~PARAMCD, ~PARAM, ~AVAL, ~AVALU, ~VISIT,
  "01-701-1015", "DIABP", "Diastolic Blood Pressure (mmHg)", 51, "mmHg", "BASELINE",
  "01-701-1015", "DIABP", "Diastolic Blood Pressure (mmHg)", 50, "mmHg", "WEEK 2",
  "01-701-1015", "SYSBP", "Systolic Blood Pressure (mmHg)", 121, "mmHg", "BASELINE",
  "01-701-1015", "SYSBP", "Systolic Blood Pressure (mmHg)", 121, "mmHg", "WEEK 2",
  "01-701-1028", "DIABP", "Diastolic Blood Pressure (mmHg)", 79, "mmHg", "BASELINE",
  "01-701-1028", "DIABP", "Diastolic Blood Pressure (mmHg)", 80, "mmHg", "WEEK 2",
  "01-701-1028", "SYSBP", "Systolic Blood Pressure (mmHg)", 130, "mmHg", "BASELINE",
  "01-701-1028", "SYSBP", "Systolic Blood Pressure (mmHg)", 132, "mmHg", "WEEK 2"
)

derive_param_computed(
  advs,
  by_vars = exprs(USUBJID, VISIT),
  parameters = c("SYSBP", "DIABP"),
  analysis_value = (AVAL.SYSBP + 2 * AVAL.DIABP) / 3,
  set_values_to = exprs(
    PARAMCD = "MAP",
    PARAM = "Mean Arterial Pressure (mmHg)",
    AVALU = "mmHg"
  )
)

# Example 2: Derive BMI where height is measured only once
advs <- tribble(
  ~USUBJID, ~PARAMCD, ~PARAM, ~AVAL, ~AVALU, ~VISIT,
  "01-701-1015", "HEIGHT", "Height (cm)", 147, "cm", "SCREENING",
  "01-701-1015", "WEIGHT", "Weight (kg)", 54.0, "kg", "SCREENING",
  "01-701-1015", "WEIGHT", "Weight (kg)", 54.4, "kg", "BASELINE",
  "01-701-1015", "WEIGHT", "Weight (kg)", 53.1, "kg", "WEEK 2",
  "01-701-1028", "HEIGHT", "Height (cm)", 163, "cm", "SCREENING",
  "01-701-1028", "WEIGHT", "Weight (kg)", 78.5, "kg", "SCREENING",
  "01-701-1028", "WEIGHT", "Weight (kg)", 80.3, "kg", "BASELINE",
  "01-701-1028", "WEIGHT", "Weight (kg)", 80.7, "kg", "WEEK 2"
)

derive_param_computed(
  advs,
  by_vars = exprs(USUBJID, VISIT),
  parameters = "WEIGHT",
  analysis_value = AVAL.WEIGHT / (AVAL.HEIGHT / 100)^2,
  set_values_to = exprs(
    PARAMCD = "BMI",
    PARAM = "Body Mass Index (kg/m^2)",
    AVALU = "kg/m^2"
  ),
  constant_parameters = c("HEIGHT"),
  constant_by_vars = exprs(USUBJID)
)
}
\seealso{
BDS-Findings Functions for adding Parameters/Records: 
\code{\link{default_qtc_paramcd}()},
\code{\link{derive_expected_records}()},
\code{\link{derive_extreme_event}()},
\code{\link{derive_extreme_records}()},
\code{\link{derive_locf_records}()},
\code{\link{derive_param_bmi}()},
\code{\link{derive_param_bsa}()},
\code{\link{derive_param_doseint}()},
\code{\link{derive_param_exist_flag}()},
\code{\link{derive_param_exposure}()},
\code{\link{derive_param_extreme_event}()},
\code{\link{derive_param_framingham}()},
\code{\link{derive_param_map}()},
\code{\link{derive_param_qtc}()},
\code{\link{derive_param_rr}()},
\code{\link{derive_param_wbc_abs}()},
\code{\link{derive_summary_records}()}
}
\concept{der_prm_bds_findings}
\keyword{der_prm_bds_findings}
