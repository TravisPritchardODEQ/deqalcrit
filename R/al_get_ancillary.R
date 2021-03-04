al_get_ancillary <- function(al_df){

  print("Start AWQMS data pull...")

  ancillary_data_AWQMS <- AWQMS_Data(station = unique(al_df$MLocID),
                                     char = Al_ancillary_params,
                                     startdate = min(al_df$SampleStartDate),
                                     enddate = max(al_df$SampleStartDate))

  print("Finished AWQMSdata pull")

  return(ancillary_data_AWQMS)

}


