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
library(psych)
library(DT)
library(ggplot2)

source("reload_dashboard.R")
source("observe_file.R")

ui <- dashboardPage(
    dashboardHeader(title = "Basic dashboard to explore data"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Load Data", tabName = "loader", icon = icon("database")),
            menuItem("Explore Data", tabName = "dashboard", icon = icon("dashboard"))
                        
        )
    ),
    dashboardBody(
        tabItems(
            # First tab content
            tabItem(tabName = "dashboard",
                    fluidRow(
                      box(title = "Data Selector",
                      div(style = "padding-left: 10px;",
                          selectInput(inputId = "data_selected",
                                      label = 'Load your data and select the dataset to review below.',
                                      choices = c("Upload your data")),
                      ),
                      width = 12
                      )
                    ),
                    fluidRow(
                      column(
                        box(title = "Selected Data Dimensions",
                            div(style = "padding-left: 10px; display: inline-block; vertical-align: middle;",
                                htmlOutput("data_dimensions")
                            ),
                        ),
                        width = 12
                        
                      ),
                    column(
                      box(title = "Null/NA/Empty Counts Per Column",
                          div(style = "padding-left: 10px; display: inline-block; vertical-align: middle;",
                              DT::dataTableOutput("null_counts")
                          ),
                      ),
                      width = 12
                    ),
                    width = 12
                    ),
                    fluidRow(
                      
                        box(title = "Numeric Data",
                            selectInput(inputId = "variables_selected",
                                        label = 'Select a variable',
                                        choices = c("header2")),
                            plotOutput("plot1", height = 250)),
                        box(
                            title = "Overall Summary",
                            div(style = 'overflow-x: scroll', dataTableOutput('overall_summary'))
                           ),
                        box(
                            title = "Raw Data",
                            div(style = 'overflow-x: scroll', DT::dataTableOutput('raw_data'))
                            ),
                           

            )
            ),    

            # Second tab content
            tabItem(tabName = "loader",
                    radioButtons("datatype", h3("Choose the data type, 300MB max"), 
                                 c(".csv" = "csv"
  #                                 ".shp" = "shp",
  #                                 ".xslx" = "xlsx",
  #                                 ".json" = "json",
  #                                 ".geojson" = "geojson"
                                   )
                                 ),

                    conditionalPanel(condition = "input.datatype == 'csv'",
                        fileInput(inputId="csv", label="Upload a .csv file", multiple=TRUE, accept=".csv", placeholder = 'Select one or multiple .csv files')),
#                    conditionalPanel(condition = "input.datatype == 'shp'",
#                        fileInput(inputId="shp", label="Upload a .shp file")),
#                    conditionalPanel(condition = "input.datatype == 'xlsx'",
#                        fileInput(inputId="xlsx", label="Upload a .xlsx file"),
#                        textInput(inputId="xlsx_sheet", label="Which sheet?", value = "Sheet1", width = NULL, placeholder = NULL)),
#                    conditionalPanel(condition = "input.datatype == 'json'",
#                        fileInput(inputId="json", label="Upload a .json file')),
#                    conditionalPanel(condition = "input.datatype == 'geojson'",
#                        fileInput(inputId="geojson", label="Upload a .geojson file")),
                    actionButton("load_data", "Load Data In App"),

                    )
            )
        )
    )

    


server <- function(input, output, session) {
    options(shiny.maxRequestSize = 300*1024^2) 
  
    #prep input data, i.e. load data 
    observeEvent(input$load_data, {
        which_data <- input$datatype
        if (which_data == 'csv') {
          observe_file(session, input, output, file_type = which_data, input_type = input$csv)
        }
    })
    

    observeEvent(input$variables_selected, {
        output$plot1 <- renderPlot({
            hist(as.numeric(unlist(upload[[input$data_selected]][input$variables_selected])))
            })
    })
    
    #update data selector 
    observeEvent(req(input$data_selected != 'Upload your data'), {
      reload_dashboard(session, upload, loaded_names, input, output)
      output$plot1 <- renderPlot({
        hist(as.numeric(unlist(upload[[input$data_selected]][input$variables_selected])))
      })
    })


}
shinyApp(ui, server)
