library(shiny)
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

# Define the fields we want to save from the form
fields <- c("zip", "building_type","ind_sq_ft", "sq_ft", "pct_pwr_replaced")

# Shiny app with 3 fields that the user can submit data for
shinyApp(
    ui = fluidPage(
        titlePanel("Solar Panel Impact (InOurHands.love)"),
        
        sidebarLayout(
            sidebarPanel(
        textInput("zip", "Zip Code", "")
        #YOU ARE HERE, MAKE THE INPUTS MATCH THE FIELDS LISTED ABOVE 
        #checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
        #sliderInput("r_num_years", "Number of years using R",
        #            0, 25, 2, ticks = FALSE),
        #actionButton("submit", "Submit")
        ),
        mainPanel(
            DT::dataTableOutput("responses", width = 300), tags$hr()
        ))
    ),
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
    }
)

