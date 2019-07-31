

library(tidyverse)
library (dplyr)
library(xlsx)
library(readxl)

#__________________________________________________
#file saved in same directory, use sheet 2, start row at 2 to avoid the title of table
egrid <- read.xlsx("egrid2016_summarytables.xlsx", 2, startRow = 2)

#file saved in same directory, use Zip-subregion sheet
zipcode <- read_excel("power_profiler_zipcode_tool_2016_6_14_18._v8.xlsx", 
                                                          sheet = "Zip-subregion")

#Reformat imported data 
#_______________________________________________

#delete last row that contains "created [date]"
#delete row containing U.S as whole
egrid<- egrid %>%
  slice(1:(n()-2))

#select acyonym subregion pair columns and remove incompleted
subregion <- egrid %>%
  select("eGRID.subregion.acronym", "eGRID.subregion.name") %>%
  filter(complete.cases(.))

#select the grid loss percent column, delete the first two NA rows from importing excel table
grid_gross_loss <- egrid%>%
  select("Grid.Gross.Loss....")%>%
  rename(Grid.Gross.Loss=Grid.Gross.Loss....)%>%
  slice(3:n())


#do not select the acyonym subregion pair columns
#do not select the grid loss percent column
#ignore rows up to emission names that should be column names
#do not inclue U.S. row at bottom
#'data' includes total output emission rates and non-based output emission rates in same table, in that order
data<- egrid%>%
  slice(2:n())%>%
  select(Total.output.emission.rates:(ncol(egrid)-1))

#get the column names from the first row, for each of the tables within data
table1<- data%>%
  select(Total.output.emission.rates:7)
table2<- data%>%
  select(Non.baseload.output.emission.rates:ncol(data))

#the 1 is the row where the column names are located
#n is the number of columns in the first table, ie. where to separate the two
n=7
colz1<-as.data.frame(data[1, 1:n])
colz2<-as.data.frame(data[1, (n+1):ncol(data)])

#gather and rename the columns based on value (first row col names), gather needed to make type
# work with names, as I understand
colz1<- colz1%>%
  gather(key = key,value =  value)
names(table1)<-colz1$value

colz2<- colz2%>%
  gather(key = key,value =  value)
names(table2)<-colz2$value

#delete column names from 1st row
table1<- table1 %>%
  slice(2:n())

table2<- table2 %>%
  slice(2:n())

#add grid loss, and acryonym subregion pair to separated tables
total_output_emission_rates<- cbind(subregion,table1,grid_gross_loss)

non_baseload_output_emission_rates<- cbind(subregion,table2,grid_gross_loss)

#__________________________________________________

#CODE for altered excel sheets
#___________________________________________________

#library(readxl)
##Looking at egrid2016_summarytables.xlsx, the column names read by R were unuseable. Saved copies of the 
#total_output_emission_rates <- read.xlsx("egrid2016_revised.xlsx", 1)

#non_baseload_output_emission_rates <- read.xlsx("egrid2016_revised.xlsx", 2)

#zipcode <- read.xlsx("power_profiler_zipcode_tool_2016_6_14_18._v8.xlsx", 2, header = TRUE)

#___________________________________________________
