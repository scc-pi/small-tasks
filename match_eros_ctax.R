# HEADER ---------------------
# Description: For our Elections Service, match their outstanding properties 
#              data (from EROS) to two files from Council Tax (CTAX):
#               1. empty properties
#               2. single person discount
#              "Two sets of CTAX data (with EROS House ID) back stripped
#               down to match."
# Author: Laurie Platt

# SETUP -------------------------
library(tidyverse); library(readxl); library(writexl)

## Local variables --------------

# Location of the data
es_data_folder <- "data/es"

# Name of the file from EROS with outstanding properties 
eros_file <- "CANVASSFORM_2021-10-25_10-08-4410_CF.xlsx"

# Name of the empty properties file from Council Tax 
ctax_empty_file <- "Xref_Empty Properties.xlsx"

# Name of the single person discount file from Council Tax 
ctax_single_file <- "15.10.2021 SPD UPRNs.xlsx"

# Name of the empty properties file from Council Tax matched to EROS
ctax_empty_eros_file <- "ctax_empty_eros_28Oct2021.xlsx"

# Name of the single person discount file from Council Tax matched to EROS
ctax_single_eros_file <- "ctax_single_eros_28Oct2021.xlsx"

# READ --------------------

# Get the EROS data
df_eros <- read_xlsx(str_c(es_data_folder, "/", eros_file), 
                     sheet = "selected_columns", col_types = "text") %>% 
  mutate(UPRN2 = parse_number(UPRN1),
         HOUSE_ID2 = parse_number(HOUSE_ID)) %>% 
  relocate(HOUSE_ID, .before = HOUSE_ID2)

# Get the empty properties Council Tax data
df_ctax_empty <- read_xlsx(str_c(es_data_folder, "/", ctax_empty_file),
                           col_types = "text")

# Get the single person discount Council Tax data
df_ctax_single <- read_xlsx(str_c(es_data_folder, "/", ctax_single_file),
                           col_types = "text")

# MATCH ------------------------

## Remove records with duplicate UPRNs

df_eros_distinct <- df_eros %>% 
  distinct(UPRN1, .keep_all = TRUE)

df_ctax_empty_distinct <- df_ctax_empty %>% 
  distinct(UPRN, .keep_all = TRUE)

df_ctax_single_distinct <- df_ctax_single %>% 
  distinct(UPRN, .keep_all = TRUE)

## Join Council Tax data to EROS data via the UPRN

df_ctax_empty_eros <- df_ctax_empty_distinct %>% 
  inner_join(df_eros_distinct, by = c("UPRN" = "UPRN1"))

df_ctax_single_eros <- df_ctax_single_distinct %>% 
  inner_join(df_eros_distinct, by = c("UPRN" = "UPRN1"))


# WRITE -------------------------

write_xlsx(df_ctax_empty_eros, 
           str_c(es_data_folder, "/", ctax_empty_eros_file))

write_xlsx(df_ctax_single_eros, 
           str_c(es_data_folder, "/", ctax_single_eros_file))