# SolarImpactOnEmissions
DDFG 2019: InOurHands.love project
Using cleaing_electricity_usage_table.R Code
## Getting Started
cleaing_electricity_usage_table.R contains code that cleans up tables downloaded from eia website.

### 1. Download tables 

  Link to the eia webist: https://www.eia.gov/consumption/commercial/data/2012/
  * Once you at the page, under the tab "Consumption & Expenditures" >> Electricity >> Download Table C13 and Table C15. 
    * Table C13 provides otal electricity consumption and expenditures in 2012. 
       * (We use Table C13 to derive the average size for different building types in thousand sqaure feet)
    * Table C15 provides electricity consumption and conditional energy intensity by region in 2012. 
      * (Use Table C15 to derive the average electricity usage for different building types)
  More information on the table - see section Data Dictionary 
  
### 2. import table into R 

* **c13.xlsx:**  The first secion of the code is dealing with the c13.xlsx. 
  1. Load table intp R by using read_excel(). 
     * it extract the "principal building activity" table from the file. 
  3. Select the "Floorspace per buidling(thousan sqaure feet)" and the "Principal building activity" columns. The later one will serve as a key when we join tables. 
  4. Saved the cleaned table as Average_size
  
*  **c16.xlsx:**  The second secion of the code is dealing with the c15.xlsx. 
   1. It extract "principal building activity" table from the file. 
   2. Select the "Principal building activity", "Electricity energy intensity (kwh/sqaure foot) North-east", "Electricity energy intensity (kwh/sqaure foot) Mid-west", "Electricity energy intensity (kwh/sqaure foot) South", "Electricity energy intensity (kwh/sqaure foot) West". 
   3. Replace any missing value with the row mean.
   4. Saved the cleaned table as Average_usage

*  **Join two tables:**  The last section of the code is joining the two tables we previously created. 
   1. Join the two tables by the column "principal building activity". 
   2. Create total electricity usage for different region by multiply the average building size with the appropriate average usage per region column.
  
       example: 
          Total usage of electricity in 2012 in northeast for education buidling type = (average building size for education) * (average usage for education type buiilding in northeast)
  
   3. Select "principal building activity" and the four total usage columns 
   4. Reomove the Health care and Mercantile row and rename "inpatient" as "Health (inpatient)" and "outpatient" as "Health (outpatient)"
   5. Saved it as "Total_usage_building_type.csv" 

## Data Dictionary 
  The tables extracted from the eia webiste focused on all commercial buildings whose principal activities are nonresidential, nonagricultural, and nonindustrial and that are larger than 1,000 square feet. 
  
  **Principal building activity:**
  
*  **Education:** Buildings used for academic or technical classroom instruction. Main use is not classroom are included in the category relating to their use. For example, administration buildings are part of "Office," dormitories are "Lodging," and libraries are "Public Assembly."
     
*  **Food Sales:** Buildings used for retail or wholesale of food.
     
*  **Food Service:** Buildings used for preparation and sale of food and beverages for consumption.
     
*  **Health Care (Inpatient):** Buildings used as diagnostic and treatment facilities for inpatient care.
     
        ex: hospital, inpatient rehabilitation 
*  **Health Care (Outpatient):** Buildings used as diagnostic and treatment facilities for outpatient care.
     
        ex: medical office, veterinarian, outpatient rehabilitation 
*  **Lodging:** Buildings used to offer multiple accommodations for short-term or long-term residents
     
        ex: motel, dormitory, shelter, nursing home
*  **Mercantile (Retail Other than Mall):** Buildings used for the sale and display of goods other than food.
     
        ex: retail store, win store, rental center, studio. gallery 
*  **Mercantile (Enclosed and Strip Malls):** Shopping malls comprised of multiple connected establishments.
     
*  **Office:** Buildings used for general office space, professional office, or administrative offices. 
     
*  **Public Assembly:** Buildings in which people gather for social or recreational activities.
     
        ex: recreation(e,g, gymnasium, bowling valley), library, entertainment or culture (e.g. museum, casino)
*  **Public Order and Safety:** Buildings used for the preservation of law and order or public safety.
     
*  **Religious Worship:** Buildings in which people gather for religious activities
        ex: chapels, churches
*  **Service:** Buildings in which some type of service is provided, other than food service or retail sales of goods
     
        ex: gas station, repair shop, dry cleaner or laundromat
*  **Warehouse and Storage:** Buildings used to store goods, manufactured products, merchandise, raw materials, or personal belongings
     
*  **Other:** all other miscellaneous buildings that do not fit into any other category.
     
        ex: airplane hangar, laboratory, data center or server farm, crematorium
*  **Vacant:** Buildings in which more floorspace was vacant than was used for any single commercial activity at the time of interview
     
*  more information go to https://www.eia.gov/consumption/commercial/building-type-definitions.php
      
