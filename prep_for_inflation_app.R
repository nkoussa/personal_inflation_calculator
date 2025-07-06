# prep for inflation data

### Imports
library(dplyr)

### Functions
# function to fill in quarterly data (or really any interstitial missing data)
fill_quarterly = function(data){
  last_value = data[1]
  for (n in 2:(length(data))){
    if(is.na(data[n])) {
      data[n] = last_value
    }
    else{
      last_value = data[n]
    }
  }
  return(data)
}

### Input data
income = read.csv("LEU0252918500A.csv")
housing = read.csv("CUUR0000SEHA.csv")
food = read.csv("CPIUFDNS.csv")
childcare = read.csv("CUUR0000SEEB.csv")
gas = read.csv("APU000074714.csv")
apparel = read.csv("CPIAPPSL.csv")
insurance_home = read.csv("PCU9241269241262.csv")
insurance_car = read.csv("PCU9241269241261.csv")
car_new = read.csv("CUUR0000SETA01.csv")
car_used = read.csv("CUSR0000SETA02.csv")
cpi = read.csv("CPIAUCSL.csv")


### Processing

# need to bind to housing
all_metrics_raw = food %>% 
  left_join(income) %>% 
  left_join(housing) %>% 
  left_join(childcare) %>% 
  left_join(gas) %>% 
  left_join(apparel) %>%
  left_join(insurance_home) %>%
  left_join(insurance_car) %>%
  left_join(car_new) %>%
  left_join(car_used) %>%
  left_join(cpi)


all_metrics_raw = all_metrics_raw[793:1345,]

all_metrics_raw = all_metrics_raw %>% rename(date = observation_date,
                                             income = LEU0252918500A, 
                                             housing = CUUR0000SEHA, 
                                             food = CPIUFDNS,
                                             childcare = CUUR0000SEEB,
                                             gas = APU000074714, 
                                             apparel = CPIAPPSL, 
                                             insurance_home = PCU9241269241262,
                                             insurance_car = PCU9241269241261,
                                             car_new = CUUR0000SETA01,
                                             car_used = CUSR0000SETA02,
                                             cpi = CPIAUCSL)
all_metrics_raw$date = as.Date(all_metrics_raw$date)

all_metrics = all_metrics_raw
# Fills in data if not collected each month, and normalizes each column to the most recent date
rows = nrow(all_metrics)
for (n in 2:ncol(all_metrics)){
  all_metrics[,n] = fill_quarterly(all_metrics[,n])
  all_metrics[,n] = all_metrics[,n] / all_metrics[rows,n]
}

# For datasets with less than 1979 data
# Basically multiplies the oldest known data with CPI prior to that data
# get the column names of columns that still contain NAs
col_with_na = colnames(all_metrics)[colSums(is.na(all_metrics)) > 0]
for (n in 1:length(col_with_na)){
  # get this column name to fix
  col_to_fix = col_with_na[n]
  # dataframe with only the column to fix and CPI
  df_to_fix = all_metrics %>% select(!!col_to_fix, cpi)
  # determine the range that needs to be imputed (this assumes the data has already been filled in with fill_quarterly())
  num_nas = sum(is.na(df_to_fix[,col_to_fix]))
  # subsets missing data
  df_to_fix_na = df_to_fix[1:num_nas, ]
  # normalizes CPI to the CPI at the most recent data for which we have data for the column in question
  df_to_fix_na[,2] = df_to_fix_na[,2] / df_to_fix[num_nas+1, 2]
  # multiplies the normalized CPI with the last known data for the column in question
  df_to_fix_na[,1] = df_to_fix_na[,2] * df_to_fix[num_nas+1, 1]
  # replaces NAs with imputed data 
  all_metrics[1:num_nas,col_to_fix] = df_to_fix_na[,1]
}







### Save processed data
#write.csv(all_metrics_raw, "all_metrics_raw.csv", row.names=FALSE)
write.csv(all_metrics, "all_metrics.csv", row.names=FALSE)

test = read.csv("all_metrics.csv")



