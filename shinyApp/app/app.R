library(shiny)
library(plotly)
library(googlesheets)
library(readr)
library(dplyr)

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

zip_to_region_lookup <- read_csv('zip_to_region_lookup.csv')

# confirm -- these numbers are averages?
usage_by_building_type <- read_csv('Total_usage_building_type.csv') %>%
  rename(building_type = `Principal building activity`,
         Northeast = `Total_usage_Avg_usage_North_East(thousand kwh)`,
         Midwest = Total_usage_Mid_West,
         South = Total_usage_South,
         West = Total_usage_West) %>%
  mutate(building_type = ifelse(building_type == 'Health care', 'Health care (Outpatient)',
                                ifelse(building_type == 'Inpatient','Health care (Inpatient)',
                                       building_type)))

# User input fields
fields <- c("zip", "building_type","ind_sq_ft", "sq_ft", "pct_pwr_replaced")
explore_fields <- c("explore_zip", "explore_building_type", "explore_ind_sq_ft", "explore_pct_pwr_replaced")

# Temp vars until data loaded from EPA
temp_choices <- c("Education", "Home", "Apartment", "Health care (outpatient)", "Health care (inpatient)")

# Shiny App
shinyApp(
  ui = navbarPage('Solar Panel Impact (InOurHands.love)',

                  # 'Explore' page is a sandbox for users to look at potential cases and make comparisons
                  tabPanel('Explore',
                           titlePanel('Data Exploration'),

                             sidebarLayout(
                             sidebarPanel(
                               helpText(p('Enter parameters for a case to explore.'), br(), p('Given zip code, building type, and building size (if known), how much carbon can a solar panel replace?')),
                               textInput("explore_zip", "Zip Code", ""),
                               selectInput('explore_building_type','Building Type', choices = temp_choices),
                               conditionalPanel(condition = "input.explore_building_type == 'home' | input.explore_building_type == 'apartment'",
                                                selectInput('explore_ind_sq_ft', 'Do you know the square footage of this building?',
                                                            choices = c('No', 'Yes'))),
                               conditionalPanel(condition = "input.explore_ind_sq_ft == 'Yes'",
                                                numericInput('explore_sq_ft', 'Square Footage of Building', 1011)),
                               sliderInput('explore_pct_pwr_replaced', "What percent of this building's power comes from renewable energy?",
                                           min = 1, max = 100, value = 100),
                               actionButton("explore", "Display results")
                             ),
                             mainPanel(
                               tabsetPanel(type = "tabs",
                                           tabPanel("Estimated Power Saved",
                                                    titlePanel(h4("Input case:")),
                                                    DT::dataTableOutput("cases_to_explore", width = 300), tags$hr()),


                                           tabPanel("Placeholder",  titlePanel(h4('placeholder'))))
                             ) # end mainPanel
                             ) # end sidebarLayout

                  ), # end  Explore

                  # 'Data' page functionality is persistent storage-focused; save new cases to google sheet, visualize what's there
                  tabPanel('Data',
                           sidebarLayout(
                             sidebarPanel(
                               textInput("zip", "Zip Code", ""),
                               selectInput('building_type','Building Type', choices = temp_choices),
                               conditionalPanel(condition = "input.building_type == 'home' | input.building_type == 'apartment'",
                                                selectInput('ind_sq_ft', 'Do you know the square footage of this building?',
                                                            choices = c('No', 'Yes'))),
                               conditionalPanel(condition = "input.ind_sq_ft == 'Yes'",
                                                numericInput('sq_ft', 'Square Footage of Building', 1011)),
                               sliderInput('pct_pwr_replaced', "What percent of this building's power comes from renewable energy?",
                                           min = 1, max = 100, value = 100),
                               actionButton("submit", "Submit to Dataset")

                             ),
                             mainPanel(
                               tabsetPanel(type = "tabs",
                                           tabPanel("Placeholder 1", plotlyOutput("plot1")),
                                           tabPanel("Placeholder 2"),
                                           tabPanel("Data Table", DT::dataTableOutput("responses", width = 300), tags$hr()))
                             )# end mainPanel
                           ) # end sidebarLayout
                  ) # end Data

  ), # end navbarPage


  server = function(input, output, session) {

    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data
    })

    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })

    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
      loadData()
    })


    # aggregate exploration fields
    exploreData = reactive({
      if (input$explore > 0) {


        if (input$explore_zip > 0) {
          lookup <- zip_to_region_lookup %>% filter(zip == as.numeric(input$explore_zip))
          region <- zip_to_region_lookup %>% filter(zip == as.numeric(input$explore_zip)) %>% select(Region) %>% unlist %>% unname

          # variable name concats the region and building type, to label the average
          var_name <- paste('Avg_for',
                             lookup %>% select(Region) %>% unlist %>% unname,
                             input$explore_building_type,
                            'type', sep = '_')

          # from averages, get row specific to building type and select region column
          lookup_value <- usage_by_building_type %>%
            filter(building_type == input$building_type) %>%
            select(!!region) %>% unlist %>% unname

          df <- data.frame('zip' = input$explore_zip,
                           'region' = region,
                           'division' = lookup %>% select(Division) %>% unlist %>% unname,
                           'building_type' = input$explore_building_type,
                           "ind_sq_ft" = input$explore_ind_sq_ft,
                           "sq_ft" = input$explore_sq_ft,
                           "pct_pwr_replaced" = input$explore_pct_pwr_replaced,
                           'Avg_use' =  lookup_value) %>% rename(!!var_name := Avg_use)

        } else {
          # the else condition just breaks. TODO: update
          region <- 'zip not numeric'
        }


      }
    })

    # When the Explore button is clicked, format and display output
   observeEvent(input$explore, {
     explore_data <- exploreData()
   })

    output$case_to_explore <- renderText({
      exploreData()
    })

    # display input case formatted as table, with appended average energy use info
    output$cases_to_explore <- DT::renderDataTable({
      input$explore
      exploreData()
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

