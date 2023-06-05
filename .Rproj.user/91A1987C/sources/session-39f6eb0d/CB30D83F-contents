library(ggmap)
library(dplyr)
library(mapview)
library(sf)
library(tbeptools)
library(here)

# Read CSV file into locsraw data frame
locsraw <- read.csv(here('data-raw/eo_fl.csv'))

# Load tbshedzip.RData file from GitHub and extract Name column into tbzips
load(file = url('https://github.com/tbep-tech/BlueGAP-sandbox/raw/main/data/tbshedzip.RData'))
tbzips <- tbshedzip %>%
  pull(Name)

# Process locsraw data frame
locs <- locsraw %>%
  mutate(
    zipshrt = gsub('\\-.*$', '', ZIP)  # Remove everything after hyphen in ZIP column and create zipshrt column
  ) %>%
  filter(zipshrt %in% tbzips) %>%     # Filter rows where zipshrt is present in tbzips
  select(EIN, NAME, STREET, CITY, STATE, ZIP, zipshrt) %>%   # Select specific columns
  unite('address', STREET, CITY, STATE, ZIP, sep = ', ', remove = F)  # Concatenate columns into address column

# Geocode addresses to obtain latitude and longitude coordinates
# This step may take a while
latlon <- geocode(locs$address)

# Add latitude and longitude columns to locs data frame and filter out rows with missing values
nonprofitlocs <- locs %>%
  bind_cols(latlon) %>%
  filter(!(is.na(lon) | is.na(lat))) %>%
  st_as_sf(coords = c('lon', 'lat'), crs = 4326, remove = F) %>%
  .[tbshed, ]  # Subset the data frame using the tbshed object

# savelocssv data frame to RData file
save(nonprofitlocs, file = here('data/nonprofitsloc.RData'))
