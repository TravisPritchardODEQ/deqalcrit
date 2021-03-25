#' Aluminum get ancillary data
#'
#' This function queries AWQMS to get ancillary data needed to calculate Al criteria
#'
#' @param al_df data from AWQMS that contains al data. Ancillary data gets joined to this.
#' @return data from AWQMS that contains al ancillary data.
#' @export




al_anc_query <- function(al_df){

  print("Start AWQMS data pull...")

  ancillary_data_AWQMS <- AWQMSdata::AWQMS_Data(station = unique(al_df$MLocID),
                                     char = Al_ancillary_params,
                                     startdate = min(al_df$SampleStartDate),
                                     enddate = max(al_df$SampleStartDate))

  print("Finished AWQMSdata pull")

  return(ancillary_data_AWQMS)

}


