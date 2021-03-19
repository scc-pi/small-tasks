# Households by Ward

# Setup -------------------------------------------------------------------
library(tidyverse); library(magrittr); library(sf); library(writexl)

# Location of local (relative or absolute) or GitHub ssc-pi functions repo
functions <- "https://raw.githubusercontent.com/scc-pi/functions/main/"

# Load functions
source(str_c(functions, "ShefAreas.R"))

# Wards -----
sf_wards <- shef_ward_features(detail = "onsFullResolution")

# Homes -----
sf_homes <- st_read(dsn = "../C19Surveillance/data/Clusters.gdb",
                    layer = "llpg") %>% 
  filter(primaryclassification == "Residential") %>% 
  filter(secondaryclassification %in% c("Dwellings", 
                                        "Houses in Multiple Occupation", 
                                        "Residential Institutions", 
                                        ""))
# TODO: read from SCC Portal or OS Data Hub instead

# Filter out bedrooms in HMO (e.g. student) cluster flats
unique(sf_homes$tertiaryclassification)
sf_homes %<>% filter(tertiaryclassification != "HMO Bedsit") 

# Homes by Ward ------  
## Add Ward to Homes via spatial join -----
sf_homes %<>%   
  st_transform(crs = st_crs(sf_wards)) %>% # same coordinate systems
  st_join(sf_wards)
  
## Count Homes by Ward ------
homes_by_ward <- sf_homes %>% 
  as_tibble() %>% 
  count(WD20NM, name = "households") %>% 
  rename(ward = WD20NM) %>%
  filter(!is.na(ward))

# Write to spreadsheet -----
write_xlsx(homes_by_ward, "output/HomesByWard.xlsx")