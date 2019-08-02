library(shiny)
library(tidyverse)
library(plotly)
library(googlesheets)


table <- "test_ddfg"

saveData <- function(data) {
    # Grab the Google Sheet
    sheet <- gs_title(table)
    # Add the data as a new row
    gs_add_row(sheet, input = data)
}

loadData <- function() {
    # Grab the Google Sheet
    sheet <- gs_title(table)
    # Read the data
    gs_read_csv(sheet)
}

# Load lookup tables
usage_by_building_type <- read_csv("data/cleaned_building_type_usage.csv")
commercial_zip_to_region_lookup <- read_csv("data/zip_to_region_lookup.csv") %>% mutate(region = tolower(Region)) %>%
    select(-Region)
emission_rates <- read_csv("data/total_output_emission_rates.csv")
zip_to_egrid_region_lookup <- read_csv("data/egrid_region_zip_lookup.csv")


# User input fields
fields <- c("zip", "building_type","ind_ele_usage", "electric_usage", "pct_pwr_replaced")

# Temp vars until data loaded from EPA
building_types <- c("Detached home or duplex", usage_by_building_type$`Principal building activity`)

# Shiny App
shinyApp(
    ui = fluidPage(
        titlePanel("Solar Panel Impact (InOurHands.love)"),
        
        sidebarLayout(
            sidebarPanel(
        textInput("zip", "Zip Code", ""),
        selectInput('building_type','Building Type', choices = building_types),
        #conditionalPanel(condition = "input.building_type == 'Detached home or duplex'",
        selectInput('ind_ele_usage', 'Do you know the average monthly electricity usage?', 
                                     choices = c('No, Use Average for Building Type', 'Yes')),
        conditionalPanel(condition = "input.ind_ele_usage == 'Yes'", 
                         numericInput('electric_usage', 'Average Monthly Electricity Usage in Kilowatt Hours', 1011)),
        sliderInput('pct_pwr_replaced', "What percent of this building's power comes from renewable energy?", 
                    min = 1, max = 100, value = 100),
        actionButton("submit", "Submit to Dataset")
        
        ),
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Carbon Savings Over Time", plotlyOutput("plot1"), plotlyOutput("plot2")),
                        tabPanel("Placeholder 2"),
                        tabPanel("Data Table", DT::dataTableOutput("responses", width = 300), tags$hr())
        ))
    )),
    server = function(input, output, session) {
        
        # Whenever a field is filled, aggregate all form data
        formData <- reactive({
            data <- sapply(fields, function(x) input[[x]])
            data
            
        })
        
        values <- reactiveValues()
        
        # func calc_carbon:
        # appends carbon savings in kWh/month
        calc_carbon <- reactive({
            
            z <- as.numeric(input$zip)
            b <- input$building_type
            i <- input$ind_ele_usage
            e <- input$electric_usage
            p <- input$pct_pwr_replaced

            if(b == 'Detached home or duplex'){
                temp <- zip_to_egrid_region_lookup %>% filter(zip == z) %>%
                    left_join(emission_rates, by = c("egrid_region" = "eGRID.subregion.acronym")) %>%
                    select(egrid_region, CO2, CH4, N2O, CO2e)

                values$carbon_savings <- temp$CO2[1]*0.001*e*p*.01
                
            } else if(i != 'Yes') {

                temp <- commercial_zip_to_region_lookup %>% filter(zip == z) %>%
                    left_join(usage_by_building_type, by = "region") %>%
                    select(`Principal building activity`, zip, region, electric_usage) %>%
                    filter(`Principal building activity` == b) %>% distinct() %>%
                    left_join(zip_to_egrid_region_lookup, by = 'zip') %>%
                    left_join(emission_rates, by = c("egrid_region" = "eGRID.subregion.acronym")) %>%
                    select(egrid_region, CO2, CH4, N2O, CO2e, electric_usage)

                values$carbon_savings <- temp$electric_usage[1]*(1/12)*1000*temp$CO2[1]*0.001*p*.01
            } else {
                temp <- commercial_zip_to_region_lookup %>% filter(zip == z) %>%
                    left_join(zip_to_egrid_region_lookup, by = 'zip') %>%
                    left_join(emission_rates, by = c("egrid_region" = "eGRID.subregion.acronym")) %>%
                    select(egrid_region, CO2, CH4, N2O, CO2e)
                
                values$carbon_savings <- e*(1/12)*1000*temp$CO2[1]*0.001*p*.01
            }
        })
        
        # When the Submit button is clicked, save the form data
        observeEvent(input$submit, {
            calc_carbon()
            dat <- c(formData(), values$carbon_savings, date())
            saveData(dat)
        })
        
        # Show the previous responses
        # (update with current response when Submit is clicked)
        output$responses <- DT::renderDataTable({
            input$submit
            loadData()
        })
        
        data <- data.frame(loadData()) %>% rowid_to_column(var = "ID")
        data <- data %>% select(carbon_savings, ID) %>% 
            mutate(month1 = 1, month2 = 2, month3 = 3, month4 = 4, month5 = 5, month6 = 6, 
                   month7 = 7, month8 = 8, month9 = 9, month10 = 10, month11 = 11, month12 = 12) %>%
            gather(key = "month_name", value = "month", -carbon_savings, -ID) %>% 
            mutate(cum_savings = month*carbon_savings) # %>% group_by(month) %>%
            #summarise(cum_savings = sum(cum_savings))
        print(data)
        
        output$plot1 <- renderPlotly({
            #ggplot(data) + geom_line(aes(x = month, y = cum_savings, color = as.factor(ID)))
            plot_ly(data, x = ~month, y = ~cum_savings, color = ~as.factor(ID), mode = 'lines+markers') %>%
                layout(xaxis = list(title = ""), 
                       yaxis = list(title = "Carbon Savings"),
                       title = "Carbon Savings by Solar Installation")
        }) 
        
        data2 <- data %>% group_by(month) %>% summarise(total_savings = sum(cum_savings))
        
        output$plot2 <- renderPlotly({
            plot_ly(data2, x = ~month, y=~total_savings, mode = 'lines+markers') %>%
                layout(xaxis = list(title = "Months Since Installation"), 
                       yaxis = list(title = "Carbon Savings"),
                       title = "Overall Carbon Savings")
        })
    }
)

