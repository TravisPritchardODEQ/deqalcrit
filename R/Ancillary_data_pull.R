

al_df <- test_al_data
ancillary_df <- al_get_ancillary(al_df)


al_combine_ancillary <- function(al_df, ancillary_df){
ancillary_data <- ancillary_df %>%
  select(MLocID, Lat_DD, Long_DD, SampleStartDate,SampleStartTime, SampleStartTZ,SampleMedia, SampleSubmedia, chr_uid,
         Char_Name, Sample_Fraction, Result_Numeric, Result_Operator, Result_Unit) %>%
  filter(!(Char_Name == 'Organic carbon' & Sample_Fraction == 'Bed Sediment')) %>%
  mutate(Char_Name = ifelse(chr_uid %in% c(544, 100331), 'Alkalinity',
                            ifelse(chr_uid %in% c(1097, 1099), 'Hardness',
                                   ifelse(chr_uid == 2174 & Sample_Fraction %in% c("Total", 'Total Recoverable','Suspended')  , 'TOC',
                                          ifelse(chr_uid == 2174 & Sample_Fraction == "Dissolved", 'DOC', Char_Name ))))) %>%
  mutate(Result_Numeric = ifelse(Result_Unit == 'ug/l', Result_Numeric / 1000, Result_Numeric),
         Result_Unit = ifelse(Result_Unit == 'ug/l', "mg/L", Result_Unit)) %>%
  mutate(Simplified_sample_fraction = ifelse(Sample_Fraction %in% c("Total", "Extractable",
                                                                    "Total Recoverable","Total Residual",
                                                                    "None", "volatile", "Semivolatile",
                                                                    "Acid Soluble", "Suspended")  |
                                               is.na(Sample_Fraction), 'Total',
                                             ifelse(Sample_Fraction == "Dissolved"  |
                                                      Sample_Fraction == "Filtered, field"  |
                                                      Sample_Fraction == "Filtered, lab"  , "Dissolved", "Error"))) %>%
  group_by(MLocID, Lat_DD, Long_DD, SampleStartDate,Char_Name,SampleMedia, SampleSubmedia ) %>%
  mutate(Has_dissolved = ifelse(min(Simplified_sample_fraction) == "Dissolved", 1, 0 )) %>%
  ungroup() %>%
  filter((Has_dissolved == 1 & Simplified_sample_fraction == "Dissolved") | Has_dissolved == 0) %>%
  select(-Has_dissolved) %>%
  #mutate(Char_Name = paste0(Char_Name, "-", Simplified_sample_fraction)) %>%
  group_by(MLocID, Lat_DD, Long_DD, SampleStartDate,Char_Name,SampleMedia, SampleSubmedia ) %>%
  summarise(result = max(Result_Numeric)) %>%
  arrange(MLocID, SampleStartDate) %>%
  spread(key = Char_Name, value = result)

colnames(ancillary_data) <- make.names(names(ancillary_data), unique = TRUE, allow_ = TRUE)

ancillary_data_calculated <- ancillary_data %>%
  mutate(DOC2 = case_when(!is.na(DOC) ~ DOC,
                          is.na(DOC) & !is.na(TOC) ~ TOC * 0.83,
                          TRUE ~ 9999),
         DOC_cmt = case_when(!is.na(DOC) ~ NA_character_,
                             is.na(DOC) & !is.na(TOC) ~ "Calculated DOC from TOC",
                             TRUE ~ "Used default DOC value"),
         Hardness2 =  case_when(!is.na(Hardness) ~ Hardness,
                                 !is.na(Calcium) & !is.na(Magnesium) ~  2.497*Calcium + 4.1189*Magnesium,
                                 !is.na(Specific.conductance) ~ exp(1.06*log(Specific.conductance) - 1.26),
                                 TRUE ~ 9999),
         Hardness_cmt =  case_when(!is.na(Hardness) ~ NA_character_,
                                !is.na(Calcium) & !is.na(Magnesium) ~ "Hardness based on Ca and Mg",
                                !is.na(Specific.conductance) ~ "Hardness based on sp conductivity",
                                TRUE ~ "No hardness value"),
                          )

default_DOC <- ancillary_data_calculated %>%
  ungroup() %>%
  filter(DOC2 == 9999) %>%
  select(MLocID, Lat_DD, Long_DD) %>%
  distinct(MLocID, .keep_all = TRUE) %>%
  rowwise() %>%
  mutate(def_DOC = Al_default_DOC(Lat_DD, Long_DD)) %>%
  select(MLocID, def_DOC) %>%
  ungroup()

ancillary_data_calculated_2 <- ancillary_data_calculated %>%
  ungroup() %>%
  left_join(default_DOC, by = "MLocID") %>%
  mutate(DOC = case_when(DOC2 != 9999 ~ DOC2,
                         TRUE ~ def_DOC),
         al_ancillary_cmt = case_when(!is.na(DOC_cmt) & !is.na(Hardness_cmt) ~ str_c(DOC_cmt,Hardness_cmt, sep = "; " ),
                         !is.na(DOC_cmt) & is.na(Hardness_cmt) ~ DOC_cmt,
                         is.na(DOC_cmt) & !is.na(Hardness_cmt) ~ Hardness_cmt,
                         TRUE ~ NA_character_))%>%
  select(MLocID, Lat_DD, Long_DD, SampleStartDate, SampleMedia, SampleSubmedia,  DOC, Hardness, pH, al_ancillary_cmt)



combined_df <- al_df %>%
  left_join(ancillary_data_calculated_2, by = c('MLocID', 'Lat_DD', 'Long_DD', 'SampleStartDate', 'SampleMedia', 'SampleSubmedia'))

return(combined_df)

}
