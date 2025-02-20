% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_param_extreme_event.R
\name{derive_param_first_event}
\alias{derive_param_first_event}
\title{Add a First Event Parameter}
\usage{
derive_param_first_event(
  dataset,
  dataset_adsl,
  dataset_source,
  filter_source,
  date_var,
  subject_keys = exprs(STUDYID, USUBJID),
  set_values_to,
  check_type = "warning"
)
}
\arguments{
\item{dataset}{Input dataset

The \code{PARAMCD} variable is expected.}

\item{dataset_adsl}{ADSL input dataset

The variables specified for \code{subject_keys} are expected. For each
observation of the specified dataset a new observation is added to the
input dataset.}

\item{dataset_source}{Source dataset

All observations in the specified dataset fulfilling the condition
specified by \code{filter_source} are considered as event.

The variables specified by the \code{subject_keys} and
\code{date_var} parameter are expected.}

\item{filter_source}{Source filter

All observations in \code{dataset_source} fulfilling the specified condition are
considered as event.

For subjects with at least one event \code{AVALC} is set to \code{"Y"}, \code{AVAL} to
\code{1}, and \code{ADT} to the first date where the condition is fulfilled.

For all other subjects \code{AVALC} is set to \code{"N"}, \code{AVAL} to \code{0}, and \code{ADT} to
\code{NA}.}

\item{date_var}{Date variable

Date variable in the source dataset (\code{dataset_source}). The variable is
used to sort the source dataset. \code{ADT} is set to the specified variable for
events.}

\item{subject_keys}{Variables to uniquely identify a subject

A list of symbols created using \code{exprs()} is expected.}

\item{set_values_to}{Variables to set

A named list returned by \code{exprs()} defining the variables to be set for the
new parameter, e.g. \code{exprs(PARAMCD = "PD", PARAM = "Disease Progression")}
is expected. The values must be symbols, character strings, numeric values,
or \code{NA}.}

\item{check_type}{Check uniqueness?

If \code{"warning"} or \code{"error"} is specified, a message is issued if the
observations of the input dataset restricted to the source parameter
(\code{source_param}) are not unique with respect to the subject keys
(\code{subject_key} parameter) and \code{ADT}.

\emph{Permitted Values}: \code{"none"}, \code{"warning"}, \code{"error"}}
}
\value{
The input dataset with a new parameter indicating if and when an
event occurred
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}

This function is \emph{deprecated}, please use \code{derive_param_extreme_event()} instead with the \code{order} argument instead of the \code{date_var} argument.
}
\details{
\enumerate{
\item The input dataset is restricted to observations fulfilling
\code{filter_source}.
\item For each subject (with respect to the variables specified for the
\code{subject_keys} parameter) the first observation (with respect to
\code{date_var}) where the event condition (\code{filter_source} parameter) is
fulfilled is selected.
\item For each observation in \code{dataset_adsl} a new observation is created. For
subjects with event \code{AVALC} is set to \code{"Y"}, \code{AVAL} to \code{1}, and \code{ADT} to
the first date where the event condition is fulfilled. For all other
subjects \code{AVALC} is set to \code{"N"}, \code{AVAL} to \code{0}, and \code{ADT} to \code{NA}.
For subjects with event all variables from \code{dataset_source} are kept. For
subjects without event all variables which are in both \code{dataset_adsl} and
\code{dataset_source} are kept.
\item The variables specified by the \code{set_values_to} parameter are added to
the new observations.
\item The new observations are added to input dataset.
}
}
\seealso{
Other deprecated: 
\code{\link{derive_derived_param}()},
\code{\link{derive_var_agegr_fda}()},
\code{\link{derive_var_confirmation_flag}()},
\code{\link{derive_var_disposition_status}()},
\code{\link{derive_var_worst_flag}()},
\code{\link{derive_vars_disposition_reason}()},
\code{\link{derive_vars_merged_dtm}()},
\code{\link{derive_vars_merged_dt}()},
\code{\link{filter_confirmation}()},
\code{\link{format_eoxxstt_default}()},
\code{\link{format_reason_default}()},
\code{\link{vars}()}
}
\concept{deprecated}
\keyword{deprecated}
