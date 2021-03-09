#' Aluminum Combine Ancillary Data
#'
#' This function combines Al data and output from al_get_ancillary in preparation to calculate criteria
#'
#' @param al_df data from AWQMS that contains al data. Ancillary data gets joined to this.
#' @param ancillary_df Output of al_get_ancillary()
#' @return Dataframe with DOC, Hardness, pH, al_ancillary_cmt added to al_df
#' @export



al_combine_ancillary <- function(al_df, ancillary_df){
  
ancillary_data <- ancillary_df %>%
  #Some samples have no times. If no times, midnight
  dplyr::mutate(SampleStartTime = ifelse(is.na(SampleStartTime), "00:00:00", SampleStartTime)) %>%
  #create dateformatte ddatetime
  dplyr::mutate(datetime = lubridate::ymd_hms(paste(SampleStartDate, SampleStartTime))) %>%
  dplyr::select(MLocID, Lat_DD, Long_DD,SampleStartDate, datetime, SampleMedia, SampleSubmedia, chr_uid,
         Char_Name, Sample_Fraction, Result_Numeric, Result_Operator, Result_Unit) %>%
  dplyr::filter(!(Char_Name == 'Organic carbon' & Sample_Fraction == 'Bed Sediment')) %>%
  dplyr::mutate(Char_Name = ifelse(chr_uid %in% c(544, 100331), 'Alkalinity',
                            ifelse(chr_uid %in% c(1097, 1099), 'Hardness',
                                   ifelse(chr_uid == 2174 & Sample_Fraction %in% c("Total", 'Total Recoverable','Suspended')  , 'TOC',
                                          ifelse(chr_uid == 2174 & Sample_Fraction == "Dissolved", 'DOC', Char_Name ))))) %>%
  dplyr::mutate(Result_Numeric = ifelse(Result_Unit == 'ug/l', Result_Numeric / 1000, Result_Numeric),
         Result_Unit = ifelse(Result_Unit == 'ug/l', "mg/L", Result_Unit)) %>%
  dplyr::mutate(Simplified_sample_fraction = ifelse(Sample_Fraction %in% c("Total", "Extractable",
                                                                    "Total Recoverable","Total Residual",
                                                                    "None", "volatile", "Semivolatile",
                                                                    "Acid Soluble", "Suspended")  |
                                               is.na(Sample_Fraction), 'Total',
                                             ifelse(Sample_Fraction == "Dissolved"  |
                                                      Sample_Fraction == "Filtered, field"  |
                                                      Sample_Fraction == "Filtered, lab"  , "Dissolved", "Error"))) %>%
  dplyr::group_by(MLocID, Lat_DD, Long_DD, SampleStartDate,datetime,Char_Name,SampleMedia, SampleSubmedia ) %>%
  dplyr::mutate(Has_dissolved = ifelse(min(Simplified_sample_fraction) == "Dissolved", 1, 0 )) %>%
  dplyr::ungroup() %>%
  dplyr::filter((Has_dissolved == 1 & Simplified_sample_fraction == "Dissolved") | Has_dissolved == 0) %>%
  dplyr::select(-Has_dissolved) %>%
  #mutate(Char_Name = paste0(Char_Name, "-", Simplified_sample_fraction)) %>%
  dplyr::group_by(MLocID, Lat_DD, Long_DD, SampleStartDate, datetime,Char_Name,SampleMedia, SampleSubmedia ) %>%
  dplyr::summarise(result = max(Result_Numeric)) %>%
  dplyr::arrange(MLocID, datetime) %>%
  tidyr::spread(key = Char_Name, value = result)

colnames(ancillary_data) <- make.names(names(ancillary_data), unique = TRUE, allow_ = TRUE)



# Add missing parameters ------------------------------------------------------------------------------------------
 #This section adds columns for missing parameters. These are treated as NAs, but must exist for code to work. 

anc_col <- c("DOC", "TOC", "Hardness","Calcium","Magnesium", "Specific.conductance" )

fncols <- function(data, cname) {
  add <-cname[!cname%in%names(data)]
  
  if(length(add)!=0) data[add] <- NA
  data
}


ancillary_data2 <- fncols(ancillary_data, anc_col)


# calculate values ------------------------------------------------------------------------------------------------


ancillary_data_calculated <- ancillary_data2 %>%
  dplyr::mutate(DOC2 = dplyr::case_when(!is.na(DOC) ~ DOC,
                          is.na(DOC) & !is.na(TOC) ~ TOC * 0.83,
                          TRUE ~ NA_real_),
         DOC_cmt = dplyr::case_when(!is.na(DOC) ~ NA_character_,
                             is.na(DOC) & !is.na(TOC) ~ "Calculated DOC from TOC",
                             TRUE ~ "Used default DOC value"),
         Hardness2 =  dplyr::case_when(!is.na(Hardness) ~ Hardness,
                                 !is.na(Calcium) & !is.na(Magnesium) ~  2.497*Calcium + 4.1189*Magnesium,
                                 !is.na(Specific.conductance) ~ exp(1.06*log(Specific.conductance) - 1.26),
                                 TRUE ~ NA_real_),
         Hardness_cmt =  dplyr::case_when(!is.na(Hardness) ~ NA_character_,
                                !is.na(Calcium) & !is.na(Magnesium) ~ "Hardness based on Ca and Mg",
                                !is.na(Specific.conductance) ~ "Hardness based on sp conductivity",
                                TRUE ~ "No hardness value"),
                          )

if(anyNA(ancillary_data_calculated$DOC2) ){
  
  default_DOC <- ancillary_data_calculated %>%
    dplyr::ungroup() %>%
    dplyr::filter(is.na(DOC2)) %>%
    dplyr::select(MLocID, Lat_DD, Long_DD) %>%
    dplyr::distinct(MLocID, .keep_all = TRUE) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(def_DOC = Al_default_DOC(Lat_DD, Long_DD)) %>%
    dplyr::select(MLocID, def_DOC) %>%
    dplyr::ungroup()
  
  ancillary_data_calculated_2 <- ancillary_data_calculated %>%
    dplyr::ungroup() %>%
    dplyr::left_join(default_DOC, by = "MLocID") %>%
    dplyr::mutate(DOC = dplyr::case_when(!is.na(DOC2) ~ DOC2,
                                         TRUE ~ def_DOC))%>%
    dplyr::select(MLocID, Lat_DD, Long_DD, SampleStartDate, datetime, SampleMedia, SampleSubmedia,  DOC, Hardness, pH, DOC_cmt, Hardness_cmt)
  
  
} else {
  
  ancillary_data_calculated_2 <- ancillary_data_calculated %>%
    dplyr::ungroup() %>%
    dplyr::select(MLocID, Lat_DD, Long_DD, SampleStartDate, datetime, SampleMedia, SampleSubmedia,  DOC, Hardness, pH, DOC_cmt, Hardness_cmt)
  
}

#separate out anc params
keep_cols <- c("MLocID","Lat_DD", "Long_DD", "SampleStartDate", "datetime", "SampleMedia", "SampleSubmedia" )

anc_DOC <- select(ancillary_data_calculated_2, all_of(keep_cols), DOC, DOC_cmt)

anc_hardness <- select(ancillary_data_calculated_2, all_of(keep_cols), Hardness, Hardness_cmt)

anc_pH <- select(ancillary_data_calculated_2, all_of(keep_cols), pH)


# combine it all --------------------------------------------------------------------------------------------------


combined_df <- al_df %>%
  dplyr::mutate(SampleStartTime2 = ifelse(is.na(SampleStartTime), "00:00:00", SampleStartTime)) %>%
  #create date formatted as datetime
  dplyr::mutate(datetime_orig = lubridate::ymd_hms(paste(SampleStartDate, SampleStartTime2))) %>%
  dplyr::left_join(anc_DOC, by = c('MLocID', 'Lat_DD', 'Long_DD', 'SampleStartDate', 'SampleMedia', 'SampleSubmedia')) %>%
  dplyr::mutate(time_diff = abs(datetime_orig - datetime)) %>%
  dplyr::group_by(across(c(-datetime, -DOC, -DOC_cmt, -time_diff))) %>%
  dplyr::filter(time_diff == min(time_diff) | is.na(time_diff) ) %>%
  dplyr::select(-datetime, -time_diff) %>%
  #HArdness
  dplyr::left_join(anc_hardness, by = c('MLocID', 'Lat_DD', 'Long_DD', 'SampleStartDate', 'SampleMedia', 'SampleSubmedia')) %>%
  dplyr::mutate(time_diff = abs(datetime_orig - datetime)) %>%
  dplyr::group_by(across(c(-datetime, -Hardness, -Hardness_cmt, -time_diff))) %>%
  dplyr::filter(time_diff == min(time_diff) | is.na(time_diff) ) %>%
  dplyr::select(-datetime, -time_diff) %>%
  #pH
  dplyr::left_join(anc_pH, by = c('MLocID', 'Lat_DD', 'Long_DD', 'SampleStartDate', 'SampleMedia', 'SampleSubmedia')) %>%
  dplyr::mutate(time_diff = abs(datetime_orig - datetime)) %>%
  dplyr::group_by(across(c(-datetime, -pH, -time_diff))) %>%
  dplyr::filter(time_diff == min(time_diff) | is.na(time_diff) ) %>%
  dplyr::select(-datetime, -time_diff) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(al_ancillary_cmt = dplyr::case_when(!is.na(DOC_cmt) & !is.na(Hardness_cmt) ~ stringr::str_c(DOC_cmt,Hardness_cmt, sep = "; " ),
                                                    !is.na(DOC_cmt) & is.na(Hardness_cmt) ~ DOC_cmt,
                                                    is.na(DOC_cmt) & !is.na(Hardness_cmt) ~ Hardness_cmt,
                                                    TRUE ~ NA_character_)) %>%
  dplyr::select(-SampleStartTime2, -datetime_orig, -DOC_cmt, -Hardness_cmt) 
  
  
 
return(combined_df)

}
