#' al_ancillary_params
#'
#' A vector of parameters needing to query to calculate Al criteria
#'
#' @format A vector with 7 elements
#' \describe{
#' \item{al_ancillary_params}{Characteristic name in AWQMS for needed parameters to calculate criteria}
#' }
"al_ancillary_params"

#' Toxicology data needed to calculate Al criteria
#'
#' A dataframe of 304(a) acute and chronic datasets prepared for processing. These are generated using lines 33-71 of
#' EPA supplied Al criteria calculator. It is awkwardly named all, beacuse that is what EPA named it.
#' @format A dataframe with 151 rows and 13 variables
#' @source \url{https://www.epa.gov/sites/production/files/2020-01/aluminum-criteria-calculator-rcode-data.zip}
'all'