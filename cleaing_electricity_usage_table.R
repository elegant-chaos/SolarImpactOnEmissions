library(mmlib)
source("config.txt")

# Set up vertica 

vertica_setup(server='aws_qa',
              user=user,
              password=password)

query = "SELECT label, ibe9350_9350 AS stability,
ibe7607_Home_Length_of_Residence_TO_100PCT_LOR AS house_residence, 
ibe7629_Household_Size_Premier_COMPLETE_Size AS house_size,
ibe1273_Population_Density_Refresh_IBE_Model_PersonicxPopulationDensity_2 AS population_density,
state,
ibe7641_Income_Code_Estimated_Household_Premier_COMPLETE_Income AS income,
Gc142_Prop_Price_Sensitive_Penny_Pinchers_gc142_rank AS price_sensitivity,
ibe8617_8617 AS age_2, ibe8616_8616 AS age_1,
ibe8605_8605 AS  occ_2, ibe8604_8604 AS occ_1,
Gc998_Bank_Fin_Srvc_Mthds_Used_Bank_Online_Internet_gc998_rank AS Perference,
AP004325_Prop_Not_Majmdcl_Ins_ap004325_rank AS Insurance ,
Mn1850_Prop_Own_Apple_Iphone_mn1850_rank_base_10 AS Iphone,
Gc2227_Retirement_Or_College_Savings_Plans_Ira_Any_gc2227_rank saving_option,
ibe7469_7469 AS new_parent,
ibe8652_8652 AS generation_range, 
ibe7629_Household_Size_Premier_COMPLETE_Precisioin_Level AS household_size,
ibe7602_Children_Number_in_Household_Premier_COMPLETE_Children AS num_child,
ibe3101_3101 AS race_gen, 
ibe9514_9514 AS education, 
ibe8628_8628 AS num_adults, 
ibe8622_8622 AS presence_of_child,
ibe8610_IBE_Premier_NameGenderof1stIndividual_Gender AS gender_1,
ibe8612_IBE_Premier_NameGenderof2ndIndividual_Gender AS gender_2,
ibe8609_8609 AS marital_status, 
ibe8606_8606 AS home_ownership, 
ibe8479_8479 AS networth,
ibe8463_8463 AS home_market_percentile, 
ibe7827_7827 AS healthlifestyle, 
ibe7780_7780 AS grandchild,
ibe6142_6142 AS women_plussize,
ibe8692_8692 AS senior_presence,
ibe8619_8619 AS working_women, 
ibe7468_7468 AS recent_mortgage_borrower, 
ibe6436_6436 AS weight_loss,
ibe6429_6429 AS medical_supplies_beauty,
ibe6446_6446 AS medical_supplies_senior,
ibe7722_7722 AS smoking, 
ibe2351_2351 AS single_parent, 
ibe2067_2067 AS active_investing
FROM leads_lab.leads_data"
data_5=get_query(query)

library(dplyr)
library(tidyverse)


convert_to_factor_initial <- function (df=data_5){
  for(i in 2:(which(colnames(df)=="healthlifestyle")-1)){ 
    df[[i]]=as.factor(df[[i]])
  } 
  return (df)
}

convert_to_factor <- function (df=data_5){
  for(i in 2:ncol(df)){ 
    df[[i]]=as.factor(df[[i]])
  } 
  return (df)
}
missing_ratio <- function (x, df=data_5){
  missing= df%>%
    filter(is.na(df[[x]])) %>%
    summarise(ratio_missing = round(n()/20658*100))
  return (missing)
}

data_5= convert_to_factor_initial(data_5)


for(i in 2:ncol(data_5)){ 
  if(nlevels(data_5[[i]])>1){
    if (missing_ratio(i)>5){
      data_5[[paste('null_indi_',colnames(data_5)[i],sep="")]] <- ifelse(is.na(data_5[[i]]) == TRUE ,'missing', 'not_missing')
    }
  }
  else {
    data_5[[i]][is.na(data_5[[i]])] = 0
  }
} 
data_5= convert_to_factor(data_5)
summary(data_5)

table2 <-function(x, df=data_5){
  temp = data_5 %>%
    group_by(df[[x]]) %>%
    summarise(total=n(), converted = sum(label), ratio= mean((label)), converted_percentage = converted / 626, group_ratio = total/20658) %>%
    arrange((desc(ratio)))
  return (temp)
}

for(i in  which(colnames(data_5)=="healthlifestyle") : ncol(data_5)){ 
  temp3= table(data_5[,i], data_5$label)
  print(colnames(data_5[i]))
  print(table2(i))
  print(chisq.test(temp3))
}

for(i in  2: ncol(data_5)){ 
  print(colnames(data_5[i]))
  print(table(i))
  temp3= table(data_5[,i], data_5$label)
  print(chisq.test(temp3))
}











