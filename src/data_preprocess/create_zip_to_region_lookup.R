#' Script formats a lookup table to return region or division given a zip code:
#'   zip   county State_name Region  Division           State_FIPS County_FIPS Area_name     
#'  60001 17111  Illinois   Midwest  East North Central    17         111         McHenry County
#'  60002 17097  Illinois   Midwest  East North Central    17         097         Lake County   
#'  60004 17031  Illinois   Midwest  East North Central    17         031         Cook County   
# Note: some zip codes cross county boundaries (map one to multiple)

# Regions (4) > Divisions (9)
#' Northeast > New England, Middle Atlantic
#' Midwest > East North Central, West North Central
#' South > South Atlantic , East South Central, West South Central
#' West > Mountain, Pacific

library(dplyr)
# devtools::install_github("hadley/readxl")
library(readxl)

# Crosswalk file with zips to county (state fips + county fips = county code)
# (1st Q 2012, to match CEBSC 2012 data)
# accessed from https://www.huduser.gov/portal/datasets/usps_crosswalk.html#data
zips_to_county_FIPS <- read_excel('~/Downloads/ZIP_COUNTY_032012.xlsx') %>% 
  select(zip = ZIP, county = COUNTY)

# 2012 Census Bureau Region and Division Codes and State FIPS Codes
# accessed from https://www.census.gov/geographies/reference-files/2012/demo/popest/2012-geocodes-all.html
# FIPS to state
county_FIPS_to_state <- read_excel('~/Downloads/all-geocodes-v2012.xls', skip = 5) %>% 
  select(`Summary\nLevel`,
         `State\nCode\n(FIPS)`,
         `County\nCode\n(FIPS)`,
         `Area Name\n(including legal/statistical area description)`)

colnames(county_FIPS_to_state) <- c('Summary', 'State_FIPS', 'County_FIPS', 'Area_name')
county_FIPS_to_state <- county_FIPS_to_state %>% 
  mutate(County_code = paste0(State_FIPS, County_FIPS))
county_FIPS_to_state <- county_FIPS_to_state %>% 
  # add State Name column
  left_join(county_FIPS_to_state %>% 
              filter(Summary == '040') %>% 
              select(State_name = Area_name, State_FIPS), by = 'State_FIPS')

# combine files to create a state lookup, given a known zip code
lookup <- zips_to_county_FIPS %>% 
  left_join(county_FIPS_to_state %>% filter(Summary == '050'), 
            by = c('county' = 'County_code')) %>% 
  select(-Summary) %>% 
  # add region
  mutate(Division = case_when(.$State_name %in% c('Maine', 'New Hampshire', 'Vermont', 
                                                 'Massachusetts', 'Rhode Island', 'Connecticut') ~ 'New England',
                              .$State_name %in% c('New York', 'New Jersey', 'Pennsylvania') ~ 'Mid-Atlantic',
                              .$State_name %in% c('Ohio', 'Michigan', 'Indiana', 'Wisconsin', 'Illinois') ~ 'East North Central',
                              .$State_name %in% c('Minnesota', 'Iowa', 'Missouri', 'North Dakota', 
                                                  'South Dakota', 'Nebraska', 'Kansas')  ~ 'West North Central',
                              .$State_name %in% c('Delaware', 'Maryland', 'West Virginia', 
                                                  'Virginia', 'North Carolina', 'South Carolina', 
                                                  'Georgia', 'Florida', 'District of Columbia') ~ 'South Atlantic',
                              .$State_name %in% c('Kentucky', 'Tennessee', 'Alabama', 'Mississippi') ~ 'East South Central',
                              .$State_name %in% c('Arkansas', 'Louisiana', 'Oklahoma', 'Texas') ~ 'West South Central',
                              .$State_name %in% c('Montana', 'Idaho', 'Wyoming', 'Colorado', 
                                                  'New Mexico', 'Arizona', 'Utah', 'Nevada') ~ 'Mountain',
                              .$State_name %in% c('California', 'Oregon', 'Washington',
                                                  'Alaska', 'Hawaii') ~ 'Pacific',
                              .$State_name == 'Puerto Rico' ~ 'Puerto Rico',
                              .$zip %in% c('00802', '00820', '00830', '00840', '00850') ~ 'St. Thomas/Virgin Isl',
                              T ~ 'NA')) %>% 
         mutate(Region = case_when(.$Division %in% c('New England', 'Mid-Atlantic') ~ 'Northeast',
                            .$Division %in% c('East North Central','West North Central') ~ 'Midwest',
                            .$Division %in% c('South Atlantic', 'East South Central', 'West South Central') ~ 'South',
                            .$Division %in% c('Mountain', 'Pacific') ~ 'West',
                            .$State_name == 'Puerto Rico' ~ 'Puerto Rico',
                            .$zip %in% c('00802', '00820', '00830', '00840', '00850') ~ 'St. Thomas/Virgin Isl',
                            T ~ 'NA')) %>%
  select(zip, county, State_name, Region, Division, everything()) %>% 
  arrange(Region, State_name, zip)

table(lookup$Division, lookup$Region, useNA = 'always')
sum(is.na(lookup$Division))

# check joins -- turns out Amherst zip code is in two counties. confirmed online
lookup %>% filter(zip == '01002')

write_csv(lookup, 'data/zip_to_region_lookup.csv')
