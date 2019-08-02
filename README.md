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
      

## Instructions for Using this Repo
### Using egrid_zipcodes.R Code, No Table Alteration in Excel 

On uploading zip code (Zip-Subregion sheet) and egrid (Table 1) .xlsx files: egrid_zipcode.R contains code that cleans up the imported tables. The Zip-Subregion sheet loads simply into a readable data frame using read_excel(). egrid2016_summarytables.xlsx table 1 if loaded as is, has format issues due to merged columns, and multi-columned sections/ columns with subsections. The R script separates the data into two tables. total_output_emission_rates is the total output emission rates section (not including the U.S row), combined with the eGRID subregion acronym column, the eGRID subregion name, and the Grid Gross Loss (%) column. The Non-baseloaded output emission rates section is saved as a table (non_baseload_output_emission_rates) in the same way. The tables have columns and corresponding names for the acronym, subregion name, the 7 emission names, and grid gross loss. Not included in the two tables are the title for the imported data (1.Subregion Output Emission Rates (eGRID2016)), and the last rows that corresponds to the United States and date created. 

### Using egrid_zipcodes.R Code, No Table Alteration in Excel Alternative: Tables altered in Excel

Use commented out code at the end of egrid_zipcode.R to read in tables that were formatted nicely in excel.

1.Open "1. Subregion Output Emission Rates (eGRID2016)" (Table 1) in egrid2016_summarytables.xlsx. 

2.Unmerge the headers "eGRID subregion acronym column" and "eGRID subregion name column", and copy these columns, not including the U.S row at the bottom. This will serve as the key for two tables. Paste this in two new sheets. Delete the two empty rows.

3.Copy the seven columns under Total output emission rates, but do not include "Total output emission rates", "lb/MWh" or the "U.S" row at bottom. Your column names should be the emissions, CO2 through SO2. Paste this in the first sheet created in step 2, next to the column "eGRID subregion name column".

4.Copy the seven columns under Non-baseload output emission rates, but do not include "Non-baseload output emission rates", "lb/MWh" or the "U.S" row at bottom. Your column names should be the emissions, CO2 through SO2. Paste this in the second sheet created in step 2, next to the column "eGRID subregion name column".

5.Unmerge the header "Grid Gross Loss (%)" and copy this column, not including the U.S row. Paste that in the first and second sheet created in step 2, right after the last column (So2).

6.Sheets now contain tables easily readable.


## Choice for non-baseload vs total emission output rates

We are using total output emission rates because the EPA’s Power Profiler Emissions Tool ([here]( https://www.epa.gov/energy/power-profiler#/NEWE)) uses this. 

### Further Readings for choice:

**Source 1:** Abt Associates, “The Emissions & Generation Resource Integrated Database Technical Support Document for eGRID with Year 2016 Data,” Prepared for the Clean Air Markets Division , Washington, DC, February 2018.
[website]( https://www.epa.gov/energy/emissions-generation-resource-integrated-database-egrid)>> technical support document [link](https://www.epa.gov/sites/production/files/2018-02/documents/egrid2016_technicalsupportdocument_0.pdf) 

For projects that displace marginal fossil fuel generation and are looking to determine emission reduction benefits, non-baseload emission rates are sometimes used. Improving energy efficiency or renewable energy are some examples of these project types. However, non-baseload emission  rates should not be used for estimating emissions associated with electrical use in carbon footprinting exercises or Greenhouse Gas emissions inventory.

[website](https://www3.epa.gov/ttn/chief/conference/ei18/)
**Source 2:** "Total, Non-baseload, eGRID Subregion, State - Guidance on the Use of eGRID Output Emission Rates," S. S. Rothschild, E.H. Pechan & Associates; A. Diem, US EPA OAP. April 2009 
[pdf](https://www3.epa.gov/ttn/chief/conference/ei18/session5/rothschild.pdf)

**Source 3:** presentation April 2009
[presentation](https://www3.epa.gov/ttnchie1/conference/ei18/session5/rothschild_pres.pdf)

The annual total output emission rate is the measure of the emissions as it relates to the generation output (2). Examples: The EPA’s Power Profiler tool and the EPA’s Personal Emissions Calculator use this data. Such tools give users ability to assess electricity usage impacts, compare fuel mix and air emission rates and estimate carbon footprints. 

Non-baseload emission rate values may be less appropriate when attempting to determine the emissions benefits of some intermittent resources, such as wind power. 


**Presentation: Source (3)**
To determine GHG emissions from electricity purchases in GHG inventories or carbon footprint calculations -- use eGRID subregion total output emission rates

For rough estimates of emission reductions from energy efficiency and/or renewable energy usage -- use eGRID subregion non-baseload output emission rates

## Summary of Variables

Column Name | Description
------------------ | ----------------
eGRID.subregion.acronym | acronym to represent the subregion name, and serve as a key to matching location (ie. Zip code) with subregion name
eGrid.subregion.name | eGRID subregion in U.S associated with specific locations and electric service provider. 
CO2 | Annual carbon dioxide emission rate in lb/MWh
CH4 | Annual methane emission rate in lb/MWh
N2O | Annual nitrous oxide emission rate in lb/MWh
CO2e | Annual carbon dioxide equivalent emission rate in lb/MWh
Annual NOx | Annual  nitrogen oxide emission rate in lb/MWh
Ozone Season NOx | Ozone season nitrogen oxide emission rate in lb/MWh
SO2 | Annual sulfur dioxide emission rate in lb/MWh
Grid.Gross.Loss | Estimate of the energy lost in the process of supplying electricity to consumers


