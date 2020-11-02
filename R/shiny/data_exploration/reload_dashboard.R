reload_dashboard <- function(session, upload, loaded_names, input, output){
  if (input$data_selected != 'Upload your data') {
    
    #get headers 
    headers <- names(upload[[input$data_selected]])
    
    # get and parse headers
    numeric_columns <- vector()
    non_numeric_columns <- vector()
    for (i in headers) {
      if (all(grepl("^-?[0-9.]+$", unlist(upload[[input$data_selected]][i]))) == 'TRUE') {
        numeric_columns[i] <-  upload[[input$data_selected]][i]
        print(upload[[input$data_selected]][i])
      } else if (all(grepl("^[A-Za-z0-9]+$", unlist(upload[[input$data_selected]][i]))) == 'TRUE' ) {
        non_numeric_columns[i] <- i
      }
    }
    
    #update histogram input
    updateSelectInput(session, "variables_selected",
                      label = paste("Select a variable"),
                      choices = names(numeric_columns),
                      selected = tail(names(numeric_columns)[1], 1)
    )
    
    #update summary table
    output$overall_summary <- DT::renderDataTable(describe(upload[[input$data_selected]][,names(numeric_columns)]))
    
    #update raw table 
    output$raw_data <- renderDataTable(as.data.frame(upload[[input$data_selected]]))
    
    #update dimention data 
    output$data_dimensions <- renderUI({
      str1 <- paste("Total Number of Columns: ", length(upload[[input$data_selected]]))
      str2 <- paste("Total Number of Rows: ", nrow(upload[[input$data_selected]]))
      HTML(paste(str1, str2, sep = '<br/>'))
    })
    #update na counts
    na_count <- sapply(upload[[input$data_selected]], function(y) sum(length(which(is.na(y)))) + sum(length(which(y == ''))))
    na_count <- data.frame(na_count)
    print(na_count)
    output$null_counts <- renderDataTable((
      na_count
    ))
  }
}