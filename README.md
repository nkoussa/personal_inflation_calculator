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



   
