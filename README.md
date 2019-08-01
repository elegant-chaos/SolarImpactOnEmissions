# SolarImpactOnEmissions
DDFG 2019: InOurHands.love project

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

**Source 1:** [website]( https://www.epa.gov/energy/emissions-generation-resource-integrated-database-egrid)>> technical support document [link](https://www.epa.gov/sites/production/files/2018-02/documents/egrid2016_technicalsupportdocument_0.pdf) 

Abt Associates, “The Emissions & Generation Resource Integrated Database Technical Support Document for eGRID with Year 2016 Data,” Prepared for the Clean Air Markets Division , Washington, DC, February 2018.

For projects that displace marginal fossil fuel generation and are looking to determine emission reduction benefits, non-baseload emission rates are sometimes used. Improving energy efficiency or renewable energy are some examples of these project types. However, non-baseload emission  rates should not be used for estimating emissions associated with electrical use in carbon footprinting exercises or Greenhouse Gas emissions inventory.


**Source 2:** "Total, Non-baseload, eGRID Subregion, State - Guidance on the Use of eGRID Output Emission Rates," S. S. Rothschild, E.H. Pechan & Associates; A. Diem, US EPA OAP. April 2009

**Source 3:** presentation April 2009 
[website](https://www3.epa.gov/ttn/chief/conference/ei18/), [website 2](ftp://ftp.epa.gov/EmisInventory/ei_conference/EI18/session5/)

The annual total output emission rate is the measure of the emissions as it relates to the generation output (2). Examples: The EPA’s Power Profiler tool and the EPA’s Personal Emissions Calculator use this data. Such tools give users ability to assess electricity usage impacts, compare fuel mix and air emission rates and estimate carbon footprints. 

Non-baseload emission rate values may be less appropriate when attempting to determine the emissions benefits of some intermittent resources, such as wind power. 


**Presentation: Source (3)**
To determine GHG emissions from electricity purchases in GHG inventories or carbon footprint calculations -- use eGRID subregion total output emission rates

For rough estimates of emission reductions from energy efficiency and/or renewable energy usage -- use eGRID subregion non-baseload output emission rates

