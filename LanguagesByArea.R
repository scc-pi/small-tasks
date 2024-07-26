# Languages by Area (Ward & Locality)

# Tegan Barker 26/07/24:
# I’m looking to find out the most commonly spoken languages in the different
# areas of the city. Ideally it would be great to know the top 5 languages for
# each area.

library(tidyverse)
library(readxl)
library(here)
library(janitor)
library(writexl)


# Read language data ----
# data from https://www.ons.gov.uk/datasets/create/filter-outputs/b7d71466-ccf9-4459-b29b-054a702ee9d1#get-data 
lang <- read_xlsx(here("data", "custom-filtered-2023-08-18T13_32_50Z.xlsx")) |> 
  clean_names() |> 
  select(-3) |> 
  rename(
    ward_code = 1,
    ward_name = 2,
    language = 3
  )

# Read Ward LA lookup data ----
# data from https://geoportal.statistics.gov.uk/documents/ac74a22ea90f4d56a83c53b8d3d4e208/about 
ward_la <- read_xlsx(here("data", "WD21_LAD21_UK_LU_provisional.xlsx")) |> 
  rename(
    ward_code = 1,
    ward_name = 2,
    la_code = 3,
    la_name = 4
  )

# List of Sheffield Wards ----
sheff_ward <- ward_la |> 
  filter(la_name == "Sheffield") |> 
  select(starts_with("ward_"))

# Language data for Sheffield wards ----  
sheff_lang <- lang |> 
  select(-ward_name) |> 
  right_join(sheff_ward, join_by("ward_code")) |> 
  relocate(ward_name, .after = ward_code)

# Select top 5 languages for each Ward ----
sheff_lang_top5 <- sheff_lang |> 
  # count(ward_name, language) |> 
  group_by(ward_name) |> 
  arrange(ward_name, desc(observation)) |> 
  slice_max(observation, n = 5) |> 
  ungroup()

# Write to spreadsheet -----
write_xlsx(
    list(language_by_ward = sheff_lang_top5),
    here("output", "LanguagesByArea.xlsx")
  )
