#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(munsell)

inflation_data = read.csv("all_metrics.csv")

format_price = function(num, decimals=2){
  num = round(num, digits=decimals)
  formatted_num = paste0("$", num)
  return(formatted_num)
}

format_percent = function(num, decimals=2, isFrac=TRUE){
  if (isFrac){
    num = num*100
  }
  num = round(num, digits=decimals)
  formatted_num = paste0(num, "%")
  return(formatted_num)
}

calculate_YoY = function(basket){
  this_year = basket
  last_year = c(rep(NA, 12), this_year[1:(length(this_year)-12)])
  diff = this_year-last_year
  yoy = (diff/last_year)*100
}

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Personal Inflation"),
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        numericInput("input_income", "Income:", 0, min = 0),
        hr(style = "border-top: 1px solid #000000;"),
        numericInput("input_housing", "Housing:", 0, min = 0),
        numericInput("input_food", "Food:", 0, min = 0),
        numericInput("input_childcare", "Childcare:", 0, min = 0),
        numericInput("input_gas", "Gas:", 0, min = 0),
        numericInput("input_apparel", "Apparel:", 0, min = 0),
        numericInput("input_insurance_home", "Home Insurance:", 0, min = 0),
        numericInput("input_insurance_car", "Car Insurance:", 0, min = 0),
        fluidRow(
          column(width = 7, numericInput("input_car", "Auto:", 0, min = 0)),
          column(width = 5, radioButtons("input_car_type", "Auto Type:", choices = list("New" = 1, "Used" = 2), selected = 1)),
        ),
        numericInput("input_misc", "Misc:", 0, min = 0),
        hr(style = "border-top: 1px solid #000000;"),
        fluidRow(
          column(width = 6, selectInput("month", "Month:", c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"))),
          column(width = 6, selectInput("year", "Year:", 1979:2025))
        )
      ),

        # Show a plot of the generated distribution
        mainPanel(
          tableOutput("table_income"),
          tableOutput("table"),
          tags$br(),
          textOutput("code"),
          tags$br(),
          plotOutput("distPlot"),
          tags$br(),
          p("*Historical data for insurance is only available from June 1998 onward, previous data is extrapolated using CPI."),
          p("**Misc uses CPI."),
        )
    )
)

# Define server logic
server <- function(input, output) {
  
    date = reactive(paste0(input$year, "-", input$month, "-01"))
    
    previous_income = reactive({
      income = output_by_date()
      inc = income %>% filter(date == date()) %>% pull(income)
      inc
    })
    
    output_by_date = reactive({
      df = inflation_data
      df$income = df$income * input$input_income
      df$food = df$food * input$input_food
      df$housing = df$housing * input$input_housing
      df$childcare = df$childcare * input$input_childcare
      df$gas = df$gas * input$input_gas
      df$apparel = df$apparel * input$input_apparel
      df$insurance_home = df$insurance_home * input$input_insurance_home
      df$insurance_car = df$insurance_car * input$input_insurance_car
      if (input$input_car_type == 1){ # new
        df = transform(df, car = df$car_new * input$input_car)
      } else if (input$input_car_type == 2){ # used
        df = transform(df, car = df$car_used * input$input_car)
      }
      df = transform(df, misc = df$cpi * input$input_misc)
      df = df %>% select(-c(car_new, car_used))
      df
    })
    
    expenses = reactive({
      df = output_by_date() %>% mutate(Expenses = select(., !c(income, date)) %>% rowSums(na.rm = TRUE))
      df$personal_cpi_yoy = calculate_YoY(df$Expenses)
      df$fred_cpi_yoy = calculate_YoY(df$cpi)
      df$date = as.Date(df$date)
      df      
    })
    
    output$code <- renderText({ 
      expense_df = expenses()
      income_increase_total = format_percent(input$input_income/previous_income(), decimals=0)
      input_expenses = expense_df %>% filter(date == '2025-01-01') %>% pull(Expenses)
      output_expenses = expense_df %>% filter(date == date()) %>% pull(Expenses)
      expense_increase_total = format_percent(input_expenses/output_expenses, decimals=0)
      cpi_past_date = expense_df %>% filter(date >= date())
      average_your_cpi = mean(cpi_past_date$personal_cpi_yoy, na.rm = T)
      average_fred_cpi = mean(cpi_past_date$fred_cpi_yoy, na.rm = T)
      out_text = paste0("Since ", month.abb[as.numeric(input$month)], " ", input$year, " your income has increased ", income_increase_total, 
                        " and your expenses have increased ", expense_increase_total, ".", "\n", "During this time period, your average CPI year-over-year is ", 
                        format_percent(average_your_cpi, isFrac=FALSE), " whereas the official average CPI year-over-year is ", format_percent(average_fred_cpi, isFrac=FALSE))
      out_text
    })
    
    output$table_income <- renderTable({
      df = data.frame(Category = "Income", 
                      previous_dollar = previous_income(), 
                      current_dollar = input$input_income,
                      previous_percent = "-", 
                      current_percent = "-")
      df = df %>% mutate_at(c(2, 3), ~ format_price(.))
      colnames(df) = c("Category", paste(month.abb[as.numeric(input$month)], input$year, "<br>Dollars"), "Jan 2025<br>Dollars", paste(month.abb[as.numeric(input$month)], input$year, "<br>% of Income"), "Jan 2025<br>% of Income")
      df
    }, align='r', sanitize.text.function=identity)

    output$table <- renderTable({
      names = c("Housing", "Food", "Childcare", "Gas", "Apparel", "Home Insur*", "Car Insur*", "Car", "Misc**")
      df = output_by_date()
      previous_current = df[df$date %in% c(date(), '2025-01-01'), ]
      previous_current = previous_current %>% select(housing, food, childcare, gas, apparel, insurance_home, insurance_car, car, misc)
      #previous = t(previous_current[1,])
      #current = t(previous_current[2,])
      df = data.frame(names = names)
      df$previous = t(previous_current[1,])
      df$current = t(previous_current[2,])
      df = transform(df, previous_percent = df$previous / previous_income())
      df = transform(df, current_percent = df$current / input$input_income)
      df = df %>% mutate_at(c(2, 3), ~ format_price(.))
      df = df %>% mutate_at(c(4, 5), ~ format_percent(.))
      colnames(df) = c("Category", paste(month.abb[as.numeric(input$month)], input$year, "<br>Dollars"), "Jan 2025<br>Dollars", paste(month.abb[as.numeric(input$month)], input$year, "<br>% of Income"), "Jan 2025<br>% of Income")
      df
      }, align='r', sanitize.text.function=identity)

    output$distPlot <- renderPlot({
      df_plot = expenses() %>% select(date, personal_cpi_yoy, fred_cpi_yoy) %>%
        pivot_longer(!date, names_to="metric", values_to="value")
      ggplot(data = df_plot, aes(x=date, y=value)) + 
        geom_line(aes(color=metric)) + 
        geom_vline(xintercept = as.Date(date()), linetype="dotted") +
        theme(text=element_text(size=15), plot.title = element_text(hjust = 0.5)) +
        labs(title="Year-Over-Year CPI", x="Year", y="CPI", color="") + 
        scale_color_hue(labels=c("personal_cpi_yoy" = "Personal", "fred_cpi_yoy"="Official"))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
