observe_csv <- function(session, input, output){
  #if the data is empty 
  loaded_extensions <- list()
   for (e in 1:length(input$csv[, 1])) {
     loaded_extensions[[e]] <- getExtension(input$csv[[e, 'datapath']])
   }
  print(isTRUE(length(which(loaded_extensions == 'csv')) == length(loaded_extensions)))
  if (is.null(input$csv)) {
    print("You selected nothing")
    showModal(modalDialog(
      title = "Select your data.",
      paste0("You didn't select any files. This app can handle multiple files at once.", input$userid,'.'),
      easyClose = TRUE,
      footer = NULL
      ))
  } 
  # else if the data select is not a csv 
  else if (isTRUE(length(which(loaded_extensions == 'csv')) == length(loaded_extensions)) != TRUE) {
    #TODO relace with modal 
    print("Incorrect file format")
    showModal(modalDialog(
      title = "Incorrect file format.",
      paste0("Either the file(s) you selected are not CSV format, or the CSV file(s) are incorrectly formatted. Additionally, this app requires no '.' exist in your CSV file name other than for the file type extension.", input$userid,'.'),
      easyClose = TRUE,
      footer = NULL
    ))
  }
  
  # else load the csv 
  else {
    #create empty list
    loaded_names <- list()
    upload <- list()
    #load csv files 
    for (nr in 1:length(input$csv[, 1])) {
      loaded_names[[nr]] <- sub(".csv$", "", basename(input$csv$name[[nr]]))
      upload[[nr]] <- read.csv(
        file = input$csv[[nr, 'datapath']], 
        header = T, 
        sep = ',',
      )
      names(upload)[nr] <- loaded_names[[nr]]
    }
    
    
    upload <<- upload
    loaded_names <<- loaded_names
    updateSelectInput(session, "data_selected",
                      label = paste("Select the dataset to review below."),
                      choices = loaded_names,
                      selected = loaded_names[1]
    )
} 
}
