#loading r-packages
library(tidyverse)
library(readxl)
# set directory to download 
setwd("~/Downloads")
#-------------------------------------------------------------------------------
#  Average building size table
#-------------------------------------------------------------------------------
# import excel file from download folder and rename the dataset as Average_size
Average_size <- read_excel("c13.xlsx")
# select principal building actvity table rows 16-34, select only the Floor per building column 4
Average_size= Average_size[c(16:34),c(1,4)]
# add and create column name 
Average_size[1,2]="Floorspace per building (thousand square feet)"
colnames(Average_size) <- as.character(unlist(Average_size[1,]))
Average_size= Average_size[2:nrow(Average_size),]
# convert column to numeric 
Average_size$`Floorspace per building (thousand square feet)`= as.numeric(Average_size$`Floorspace per building (thousand square feet)`)

#-------------------------------------------------------------------------------
#  Average electricity usage table
#-------------------------------------------------------------------------------
# separate table - average electricity usage 
# import data
Average_usage <- read_excel("c15.xlsx")
# select principal building actvity table row (14:32) and select average usage for different regions column 10:13
Average_usage= Average_usage[c(14:32),c(1,10:13)]

# create and rename colunn names 
Average_usage[1,1]="Principal building activity"
Average_usage[1,2]="North_East(kwh/square foot)"
Average_usage[1,3]="Mid_West"
Average_usage[1,4]="South"
Average_usage[1,5]="West"
colnames(Average_usage) <- as.character(unlist(Average_usage[1,]))
Average_usage= Average_usage[2:nrow(Average_usage),]
# convert columns to numeric 
Average_usage$`North_East(kwh/square foot)`=as.numeric(Average_usage$`North_East(kwh/square foot)`)
Average_usage$Mid_West=as.numeric(Average_usage$West)
Average_usage$South=as.numeric(Average_usage$South)
Average_usage$West=as.numeric(Average_usage$West)
# fill in missing data 
replace_missing_data_with_row_mean()
#-------------------------------------------------------------------------------
#  Join tables 
#-------------------------------------------------------------------------------
#join two tables to get estimated total eletricity usage for different building type
Total =merge(x=Average_usage,y=Average_size,by="Principal building activity",all=TRUE)
# create a new column called total usage by multiply average usage with the estimated building size for each region
# formula 
# education_type_building_total_usage_northeast = avg_usage_northeast * average_building_size_education 
Total[[paste('Total_usage_',colnames(Total)[2],sep="")]]= Total[,2]*Total[,6]
Total[[paste('Total_usage_',colnames(Total)[3],sep="")]]= Total[,3]*Total[,6]
Total[[paste('Total_usage_',colnames(Total)[4],sep="")]]= Total[,4]*Total[,6]
Total[[paste('Total_usage_',colnames(Total)[5],sep="")]]= Total[,5]*Total[,6]
# change building type names and remove Health care and mercantile rows 
Total[which(Total[,1]=="Inpatient"),1]="Health (inpatient)"
Total[which(Total[,1]=="Outpatient"),1]= "Health (outpatient)"
Total = Total[-c(which(Total[,1]=="Health care"), which(Total[,1]=="Mercantile")),]


# change the column name to fix the unit at the end 
colnames(Total)[colnames(Total)=="Total_usage_North_East(kwh/square foot)"] <- "Total_usage_Avg_usage_North_East(thousand kwh)"
Total = Total[,c(1,7:ncol(Total))]
write_csv(Total, "Total_usage_building_type.csv")

#-------------------------------------------------------------------------------
#  function for replacing missing data
#-------------------------------------------------------------------------------
replace_missing_data_with_row_mean <- function (df=Average_usage){
  for(i in 1:nrow(df)){
    for(n in 2:ncol(df)){
      if(is.na(df[i,n])){
        df[i,n]  <- rowMeans(df[i, 2:ncol(df)], na.rm = TRUE) 
      }
    }
  }
}








