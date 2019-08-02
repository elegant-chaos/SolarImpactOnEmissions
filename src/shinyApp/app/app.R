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
commercial_zip_to_region_lookup <- read_csv("data/zip_to_region_lookup.csv")
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
                        tabPanel("Placeholder 1", plotlyOutput("plot1")),
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
            
            print("I'm in the function")
            
            z <- as.numeric(input$zip)
            b <- input$building_type
            i <- input$ind_ele_usage
            e <- input$electric_usage
            p <- input$pct_pwr_replaced

            if(b == 'Detached home or duplex'){
                temp <- zip_to_egrid_region_lookup %>% filter(zip == z) %>%
                    left_join(emission_rates, by = c("egrid_region" = "eGRID.subregion.acronym")) %>%
                    select(egrid_region, CO2, CH4, N2O, CO2e)
                print(temp)

                values$carbon_savings <- temp$CO2[1]*0.001*e*p*.01
                print("temp$CO2[1]")
                print(temp$CO2[1])
                print("e")
                print(e)
                print("p")
                print(p)
                
                print("In first if")
                print(values$carbon_savings)
                
            } else {

             temp <- commercial_zip_to_region_lookup %>% filter(zip == z) %>%
                mutate(region = tolower(Region)) %>% left_join(usage_by_building_type, by = "region") %>%
                select(`Principal building activity`, zip, region, electric_usage) %>%
                filter(`Principal building activity` == b) %>% distinct() %>%
                left_join(zip_to_egrid_region_lookup, by = 'zip') %>%
                left_join(emission_rates, by = c("egrid_region" = "eGRID.subregion.acronym")) %>%
                select(egrid_region, CO2, CH4, N2O, CO2e)


             values$carbon_savings <- temp$electric_usage*(1/12)*1000*temp$CO2*0.001*p*.01
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
        
        # The following plot is a placeholder
        # Can use a line plot of this type to show the emissions savings for 
        # all 3 emissions types listed in the eGrid data over time.
        # X axis -> month
        # Y axis -> emissions
        # color -> emission type (carbon, etc.)
        # (Above instructions just one idea. I'm sure many good ideas exist in this space.)
        
        trace_0 <- rnorm(100, mean = 5)
        trace_1 <- rnorm(100, mean = 0)
        trace_2 <- rnorm(100, mean = -5)
        x <- c(1:100)
        
        data <- data.frame(x, trace_0, trace_1, trace_2)
        
        output$plot1 <- renderPlotly({
            plot_ly(data, x = ~x, y = ~trace_0, name = 'trace 0', type = 'scatter', mode = 'lines') %>%
            add_trace(y = ~trace_1, name = 'trace 1', mode = 'lines+markers') %>%
            add_trace(y = ~trace_2, name = 'trace 2', mode = 'markers')
        })
    }
)

