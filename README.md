# Personal Inflation Calculator

This repo contains the files to create an R shiny app that takes your current income and spending, calculates what your income and spending would have been in previous years, and calculates your personal inflation rate based on your [basket of goods](https://www.bls.gov/cpi/factsheets/averages-and-individual-experiences-differ.htm).

## How to use the Personal Inflation Calculator

### Online
You can go to ADD LINK WHEN PERMANENT

### View app locally
Requirements:
- RStudio
- Packages: shiny, ggplot2, dplyr, tidyr

1. Install RStudio and the required packages, if necessary.
2. Open `app.R` in RStudio and click "Run App" at the top.

## Building static site with shinylive 

1. Clone repo locally and set working directory (and make any edits you wish to make).
2. Install and load packages required to run shinylive:
   ```
   install.packages("shinylive")
   install.packages("httpuv")
   library(shinylive)
   library(httpuv)
   ```
3. Create a new folder within this working directory (here we call it docs by convention, but you can name it whatever you want).
4. Export app with shinylive:
   ```
   shinylive::export(appdir = ".", destdir = "docs")
   ```
5. View the app locally to make sure it's working:
   ```
   httpuv::runStaticServer("docs/")
   ```

## Sources

Data was obtained from [FRED](https://fred.stlouisfed.org/).

| Category       | FRED ID          | FRED Dataset Name |
| -------------- | ---------------- | ----------------- |
| income         | LEU0252918500A   | Employed full time: Median usual weekly nominal earnings (second quartile): Wage and salary workers: Bachelor's degree and higher: 25 years and over
| housing        | CUUR0000SEHA     | Consumer Price Index for All Urban Consumers: Rent of Primary Residence in U.S. City Average
| food           | CPIUFDNS         | Consumer Price Index for All Urban Consumers: Food in U.S. City Average
| childcare      | CUUR0000SEEB     | Consumer Price Index for All Urban Consumers: Tuition, Other School Fees, and Childcare in U.S. City Average
| gas            | APU000074714     | Average Price: Gasoline, Unleaded Regular (Cost per Gallon/3.785 Liters) in U.S. City Average
| apparel        | CPIAPPSL         | Consumer Price Index for All Urban Consumers: Apparel in U.S. City Average
| insurance_home | PCU9241269241262 | Producer Price Index by Industry: Premiums for Property and Casualty Insurance: Premiums for Homeowner's Insurance
| insurance_car  | PCU9241269241261 | Producer Price Index by Industry: Premiums for Property and Casualty Insurance: Premiums for Private Passenger Auto Insurance
| car_new        | CUUR0000SETA01   | Consumer Price Index for All Urban Consumers: New Vehicles in U.S. City Average
| car_used       | CUSR0000SETA02   | Consumer Price Index for All Urban Consumers: Used Cars and Trucks in U.S. City Average
| cpi            | CPIAUCSL         | Consumer Price Index for All Urban Consumers: All Items in U.S. City Average

   
