#' Aluminum Criteria Calculator
#'
#' This function calculates aluminum criteria based on EPA's 2018 national recommended freshwater aquatic life criteria
#' for aluminum. This function is based on the EPA provided function located here:
#' https://www.epa.gov/sites/production/files/2020-01/aluminum-criteria-calculator-rcode-data.zip
#' The dataframe needs to have columns for pH, hardness, and DOC values. This function adds 6 columns to original
#' dataframe:  CCC, FAV, CMC, Final_CMC, FINAL_CCC, Flag.
#'
#' @param df Dataframe to modify
#' @param ph_col Name of column containing pH values. Must be surrounded by quotes
#' @param hardness_col Name of column containing hardness values. Must be surrounded by quotes
#' @param DOC_col Name of column containing DOC values. Must be surrounded by quotes
#' @param verbose If true, return genus, and other toxicity background information.
#' @export
#'


AL_crit_calculator <- function(df, ph_col = "pH", hardness_col = "hardness", DOC_col = "DOC", verbose = FALSE){

  print("Beginning AL criteria calculations")

  pb <- txtProgressBar(min = 0, max = nrow(df), style = 3)

  for (i in 1:nrow(df)){

    pH <- df[ph_col][i,]
    hardness <- df[hardness_col][i,]
    DOC <-  df[DOC_col][i,]

    Flag <-
      ifelse(pH <= 10.5 &
               pH >= 5 &
               hardness <= 430 &
               DOC <= 12,
             "",
             "Outside MLR model bounds. Caps applied.")

    pH <- ifelse(pH > 10.5, 10.5,
                 ifelse(pH < 5, 5,
                        pH
                 )
    )

    hardness <- ifelse(hardness > 430, 430,
                       ifelse(hardness <= 0, 0.01,
                              hardness
                       )
    )

    DOC <- ifelse(DOC > 12, 12,
                  ifelse(DOC <= 0, 0.08,
                         DOC
                  )
    )



    toxicity_data <- odeqALcrit::all
    # MLRs
    toxicity_data$Normalized_Conc <- ifelse(all$Grouping == "Invertebrate",
                                   # if invertebrate, apply invertebrate MLR
                                   exp(log(all$EC_LC) - 0.597 * (log(all$DOC) - log(DOC)) -
                                         8.802 * (all$pH - pH) - 2.089 * (log(all$Hardness) - log(hardness)) +
                                         0.491 * (all$pH^2 - pH^2) + 0.23 * (all$pH * (log(all$Hardness)) - pH * (log(hardness)))),
                                   # if not invertebrate, apply vertebrate MLR
                                   exp(log(all$EC_LC) - 2.209 * (log(all$DOC) - log(DOC)) -
                                         2.041 * (all$pH - pH) - 1.862 * (log(all$Hardness) - log(hardness)) +
                                         0.232 * (all$pH * (log(all$Hardness)) - pH * (log(hardness))) +
                                         0.261 * (all$pH * log(all$DOC) - pH * log(DOC)))
    )


    # calculate SMVs
    toxicity_data <- toxicity_data %>%
      dplyr::group_by(data, Species) %>%
      dplyr::mutate(Species_Mean_Value_ug_L = exp(mean(log(Normalized_Conc))))

    # calculate GMVs - take geomean of unique SMAVs
    toxicity_data <- toxicity_data %>%
      dplyr::group_by(data, Genus) %>%
      dplyr::mutate(Genus_Mean_Value_ug_L = exp(mean(log(unique(Species_Mean_Value_ug_L)))))

    # generate ranked GMAV/GMCV table
    summary <- toxicity_data[, c(16, 8, 12)] # subset to "Genus_Mean_Value_ug_l", "Genus", and "data"
    summary <- unique(summary)
    summary <- summary %>%
      dplyr::arrange(data, Genus_Mean_Value_ug_L) %>%
      dplyr::group_by(data) %>%
      dplyr::mutate(N = length(Genus_Mean_Value_ug_L)) %>%
      dplyr::mutate(Rank = c(1:length(Genus_Mean_Value_ug_L))) %>%
      dplyr::filter(Rank %in% c(1:4)) %>%
      # mutate_at(vars(Rank, N), list(~as.numeric)) %>%
      dplyr:: group_by(data) %>%
      dplyr::mutate(lnGMV = log(Genus_Mean_Value_ug_L)) %>%
      dplyr::mutate(lnGMV2 = lnGMV^2) %>%
      dplyr::mutate(P = Rank / (N + 1)) %>%
      dplyr::mutate(sqrtP = sqrt(P)) %>%
      dplyr::mutate(sum_lnGMV = sum(lnGMV)) %>%
      dplyr::mutate(sum_lnGMV2 = sum(lnGMV2)) %>%
      dplyr::mutate(sum_P = sum(P)) %>%
      dplyr::mutate(sum_sqrtP = sum(sqrtP)) %>%
      dplyr::group_by(data) %>%
      dplyr::mutate(S2 = (sum_lnGMV2 - ((sum_lnGMV^2) / 4)) / (sum_P - ((sum_sqrtP^2) / 4))) %>%
      dplyr::mutate(L = (sum_lnGMV - (sqrt(S2) * sum_sqrtP)) / 4) %>%
      dplyr::mutate(A = (sqrt(S2) * sqrt(0.05)) + L) %>%
      dplyr::mutate(FV = exp(A))

    CCC <- as.numeric(unique(summary[summary$data == "Chronic", "FV"]))
    FAV <- as.numeric(unique(summary[summary$data == "Acute", "FV"]))
    CMC <- FAV / 2
    Final_CMC <- round(CMC, digits = 2 - (1 + trunc(log10((abs(CMC))))))
    Final_CCC <- round(CCC, digits = 2 - (1 + trunc(log10((abs(CCC))))))


    df[i, 'CCC'] <- CCC
    df[i, 'FAV'] <- FAV
    df[i, 'CMC'] <- CMC
    df[i, 'Final_CMC'] <- Final_CMC
    df[i, 'Final_CCC'] <- Final_CCC
    df[i, "Flag"] <- Flag


    # If verbose = TRUE, include toxicity study information
    if(verbose){


      ranks <- summary %>%
        dplyr::mutate(rowid = dplyr::row_number()) %>%
        dplyr::select(rowid, Genus_Mean_Value_ug_L, Genus, Rank,data)
      ranks <- reshape2::melt(ranks, id.vars=c("rowid","Rank", "data"))
      ranks$rowid <- 1
      ranks <- reshape2::dcast(ranks, rowid ~ Rank+data+variable, value.var="value")
      print_results <-dplyr::bind_rows(df, ranks[,c(4:5,8:9,12:13,16:17,2:3,6:7,10:11,14:15)])


      df[i, names(ranks[,c(4:5,8:9,12:13,16:17,2:3,6:7,10:11,14:15)])] <- ranks[,c(4:5,8:9,12:13,16:17,2:3,6:7,10:11,14:15)][1,]

    }

    setTxtProgressBar(pb, i)

  }
  close(pb)

  return(df)

}


