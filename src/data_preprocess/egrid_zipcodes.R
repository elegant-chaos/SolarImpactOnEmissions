library(tidyverse)
library (dplyr)
library(xlsx)
library(readxl)

#__________________________________________________
#use sheet 2(Subregion Output Emission Rates (eGRID2016)), start row at 2 to avoid the title of table
egrid <- read.xlsx("data/egrid2016_summarytables.xlsx", 2, startRow=2)

#use Zip-subregion sheet in excel file
zipcode <- read_excel("data/power_profiler_zipcode_tool_2016_6_14_18._v8.xlsx",
                                                          sheet = "Zip-subregion")

#Reformat imported egrid
#_______________________________________________

#delete last row that contains "created [date]"
#delete second to last row containing U.S as whole
egrid<- egrid %>%
  slice(1:(n()-2))

#select acyonym subregion pair columns and remove incomplete rows
subregion <- egrid %>%
  select("eGRID.subregion.acronym", "eGRID.subregion.name") %>%
  filter(complete.cases(.))

#select the grid loss percent column, delete the first two NA rows due to importing excel table
grid_gross_loss <- egrid%>%
  select("Grid.Gross.Loss....")%>%
  rename(Grid.Gross.Loss=Grid.Gross.Loss....)%>%
  slice(3:n())


#do not select the acyonym subregion pair columns
#do not select the grid loss percent column
#ignore rows up to emission names (emission names should be column names)
#do not inclue U.S. row at bottom
#'egrid' now includes total output emission rates and non-based output emission rates in same table, in that order
egrid<- egrid%>%
  slice(2:n())%>%
  select(Total.output.emission.rates:(ncol(egrid)-1))

#get the column names from the first row, for each of the tables within egrid
total_output_emission_rates<- egrid%>%
  select(Total.output.emission.rates:7)
non_baseload_output_emission_rates<- egrid%>%
  select(Non.baseload.output.emission.rates:ncol(egrid))

#the 1st row is where the column names are located, named columns1, columns2 for the first and second table
#n is the number of columns in the first table, ie. where to separate the two tables
n=7
columns1<-as.data.frame(egrid[1, 1:n])
columns2<-as.data.frame(egrid[1, (n+1):ncol(egrid)])

#gather and rename the columns based on value (first row col names), gather needed to make type
# work with names, as I understand
columns1<- columns1%>%
  gather(key = key,value =  value)
names(total_output_emission_rates)<-columns1$value

columns2<- columns2%>%
  gather(key = key,value =  value)
names(non_baseload_output_emission_rates)<-columns2$value

#delete column names from 1st row, as they are now the column names
total_output_emission_rates<- total_output_emission_rates%>%
  slice(2:n())

non_baseload_output_emission_rates<- non_baseload_output_emission_rates%>%
  slice(2:n())

#add grid loss, and acryonym subregion pair to separated tables
total_output_emission_rates<- cbind(subregion,total_output_emission_rates,grid_gross_loss)
write_csv(total_output_emission_rates, "shinyApp/app/data/total_output_emission_rates.csv")

non_baseload_output_emission_rates<- cbind(subregion,non_baseload_output_emission_rates,grid_gross_loss)
write_csv(non_baseload_output_emission_rates, "shinyApp/app/data/non_baseload_emission_rates.csv")

# Clean and save zipcode data
zipcode <- zipcode %>% select(`ZIP (numeric)`, state, `eGRID Subregion #1`) %>%
  mutate(zip = `ZIP (numeric)`, egrid_region = `eGRID Subregion #1`) %>% select(zip, state, egrid_region)
write_csv(zipcode, "shinyApp/app/data/egrid_region_zip_lookup.csv")


# Clean and save usage_by_building_type
usage_by_building_type <- read_csv("shinyApp/app/data/Total_usage_building_type.csv")
usage_by_building_type <- usage_by_building_type %>% mutate(northeast = `Total_usage_Avg_usage_North_East(thousand kwh)`,
                                                            midwest = Total_usage_Mid_West,
                                                            south = Total_usage_South,
                                                            west = Total_usage_West) %>%
  select(`Principal building activity`, northeast, midwest, south, west) %>%
  gather(key = "region", value = "electric_usage", -`Principal building activity`)
write_csv(usage_by_building_type, "shinyApp/app/data/cleaned_building_type_usage.csv")

# move file into app data folder
file.copy('data/zip_to_region_lookup.csv', 'src/shinyApp/app/data/', overwrite = T, recursive = T)
#__________________________________________________

#CODE for altered excel sheets
#___________________________________________________


##Looking at egrid2016_summarytables.xlsx, the column names read by R were unuseable.
##The following code is for the altered excel sheets. The numbers refer to the sheet number
##where the altered table was saved

#library(readxl)

#total_output_emission_rates <- read.xlsx("egrid2016_revised.xlsx", 1)

#non_baseload_output_emission_rates <- read.xlsx("egrid2016_revised.xlsx", 2)

#zipcode <- read.xlsx("power_profiler_zipcode_tool_2016_6_14_18._v8.xlsx", 2, header = TRUE)

#___________________________________________________
