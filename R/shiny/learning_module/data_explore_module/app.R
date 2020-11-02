#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

ui <- fluidPage(
    selectInput("var", "Variable", names(mtcars)),
    numericInput("bins", "bins", 10, min = 1),
    plotOutput("hist")
)
server <- function(input, output, session) {
    data <- reactive(mtcars[[input$var]])
    output$hist <- renderPlot({
        hist(data(), breaks = input$bins, main = input$var)
    }, res = 96)
}

# Run the application 
shinyApp(ui = ui, server = server)
