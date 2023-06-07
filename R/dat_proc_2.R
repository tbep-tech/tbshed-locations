library(ggmap)
library(dplyr)
library(sf)
library(tbeptools)
library(here)

# Read CSV file into locsraw data frame
locsraw <- read.csv(here('data-raw/InstitutionCampus.csv'))

# Load tbshedzip.RData file from GitHub and extract Name column into tbzips
load(file = url('https://github.com/tbep-tech/BlueGAP-sandbox/raw/main/data/tbshedzip.RData'))
tbzips <- tbshedzip %>%
  pull(Name)

# Process locsraw data frame
locs <- locsraw %>%
  mutate(
    zip = gsub('^.*\\s(.*$)', "\\1", Address),
    zipshrt = gsub('\\-.*$', '', zip)
  ) %>%
  filter(zipshrt %in% tbzips)

# Geocode addresses to obtain latitude and longitude coordinates
# This step may take a while
latlon <- geocode(locs$Address)

# Add latitude and longitude columns to locs data frame and filter out rows with missing values
academiclocs <- locs %>%
  bind_cols(latlon) %>%
  filter(!(is.na(lon) | is.na(lat))) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326, remove = F) %>%
  .[tbshed, ]  # Subset the data frame using the tbshed object

# savelocssv data frame to RData file
save(academiclocs, file = here('data/academicloc.RData'))

# make the data a .csv file
academicdata <- st_set_geometry(academiclocs, NULL)
write.csv(academicdata, file = here("data/academicdata.csv"), row.names = FALSE)
