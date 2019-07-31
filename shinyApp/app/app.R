library(shiny)
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

# User input fields
fields <- c("zip", "building_type","ind_sq_ft", "sq_ft", "pct_pwr_replaced")

# Temp vars until data loaded from EPA
temp_choices <- c("school", "home", "apartment", "medical (in-patient)", "medical (out-patient)")

# Shiny App
shinyApp(
    ui = fluidPage(
        titlePanel("Solar Panel Impact (InOurHands.love)"),
        
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
                        tabPanel("Data Table", DT::dataTableOutput("responses", width = 300), tags$hr())
        ))
    )),
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

