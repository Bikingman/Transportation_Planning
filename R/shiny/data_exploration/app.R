#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
    dashboardHeader(title = "Basic dashboard to explore data"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("Load Data", tabName = "loader", icon = icon("th"))
        )
    ),
    dashboardBody(
        tabItems(
            # First tab content
            tabItem(tabName = "dashboard",
                    fluidRow(
                        box(plotOutput("plot1", height = 250)),

                        box(
                            title = "Controls",
                            sliderInput("slider", "Number of observations:", 1, 100, 50)
                        )
                    )
            ),

            # Second tab content
            tabItem(tabName = "loader",
                    radioButtons("datatype", h3("Choose the data type, 300MB max"), 
                                 c(".csv" = "csv",
                                   ".shp" = "shp",
                                   ".xslx" = "xlsx",
                                   ".json" = "json",
                                   ".geojson" = "geojson")),

                    conditionalPanel(condition = "input.datatype == 'csv'",
                        fileInput(inputId="csv", label="Upload a .csv file")),
                    conditionalPanel(condition = "input.datatype == 'shp'",
                        fileInput(inputId="shp", label="Upload a .shp file")),
                    conditionalPanel(condition = "input.datatype == 'xlsx'",
                        fileInput(inputId="xlsx", label="Upload a .xlsx file"),
                        textInput(inputId="xlsx_sheet", label="Which sheet would you like to load?", value = "Sheet1", width = NULL, placeholder = NULL)),
                    conditionalPanel(condition = "input.datatype == 'json'",
                        fileInput(inputId="json", label="Upload a .json file")),
                    conditionalPanel(condition = "input.datatype == 'geojson'",
                        fileInput(inputId="geojson", label="Upload a .geojson file")),
                        
                    )
                    
            
            )
        )
    )


server <- function(input, output) {
    options(shiny.maxRequestSize=300*1024^2) 
    set.seed(122)
    histdata <- rnorm(500)

    output$plot1 <- renderPlot({
        data <- histdata[seq_len(input$slider)]
        hist(data)
    })
    
}

shinyApp(ui, server)
