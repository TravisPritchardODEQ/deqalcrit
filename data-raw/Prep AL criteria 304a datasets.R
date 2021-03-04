
# Read in 304(a) acute and chronic datasets and prepare for processing --------------------------
  ac <- read.csv("data-raw/final304a_acute.csv", stringsAsFactors = FALSE, strip.white = TRUE, skip = 2)
  ac$data <- "Acute"
  ac <- ac[, c(1, 3:5, 7:8, 11, 16:20)] # remove blank columns
  colnm <- c("Species", "Hardness", "pH", "DOC", "EC_LC", "Reference", "Reason_Excluded",
             "Genus", "Taxa_Group", "DOC_Notes", "Dilution_Water", "data")
  names(ac) <- colnm
  NArows <- row.names(ac[is.na(ac$pH), ]) # remove blank rows
  ac <- ac[!row.names(ac) %in% NArows, ]
  rm(NArows)
  NOinput <- row.names(ac[ac$Hardness == "-", ]) # remove studies lacking input parameters
  ac <- ac[!row.names(ac) %in% NOinput, ]

  ch <- read.csv("data-raw/final304a_chronic.csv", stringsAsFactors = FALSE, strip.white = TRUE, skip = 2)
  ch$data <- "Chronic"
  ch <- ch[, c(1:4, 7:8, 11, 16:20)] # remove blank columns
  names(ch) <- colnm
  NArows <- row.names(ch[is.na(ch$pH), ]) # remove blank rows
  ch <- ch[!row.names(ch) %in% NArows, ]
  rm(NArows)

  all <- rbind(ac, ch) # merge acute and chronic datasets
  all$EC_LC <- gsub(",", "", all$EC_LC) # remove special characters
  fields <- c("Hardness", "pH", "DOC", "EC_LC") # convert fields to numeric format
  all[fields] <- sapply(all[fields], as.numeric)

  invert <- c("Physa", "Lampsilis", "Lymnaea", "Aeolosoma", "Brachionus", "Ceriodaphnia",
              "Daphnia", "Stenocypris", "Crangonyx", "Hyalella", "Acroneuria", "Chironomus",
              "Paratanytarsus", "Nais", "Melanoides")
  vert <- c("Hyla", "Rana", "Oncorhynchus", "Salmo", "Salvelinus", "Lepomis", "Hybognathus",
            "Pimephales", "Micropterus", "Danio", "Poecilia")

  all$Grouping <- ifelse(all$Genus %in% invert, "Invertebrate",
                         ifelse(all$Genus %in% vert, "Vertebrate",
                                ""
                         )
  )

  all <- all[all$Reason_Excluded == "", ] # remove studies excluded from SMAV




usethis::use_data(all, overwrite = TRUE)
