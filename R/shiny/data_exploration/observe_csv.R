#TODO abstract this so it can handle any datatype
observe_csv <- function(session, input, output){
  #create helper function
  getExtension <- function(input) {
    ex <- strsplit(basename(input), split = "\\.")[[1]]
    return(ex[-1])
  }
  #if the data is empty 
  loaded_extensions <- list()
   for (e in 1:length(input$csv[, 1])) {
     loaded_extensions[[e]] <- getExtension(input$csv[[e, 'datapath']])
   }
  
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
    print("Incorrect file format")
    showModal(modalDialog(
      title = "Incorrect file format.",
      paste0("Either the file(s) you selected are not CSV format, or the CSV file(s) are incorrectly formatted. Additionally, this app requires no '.' exist in your CSV file name other than for the file type extension.", input$userid,'.'),
      easyClose = TRUE,
      footer = NULL
    ))
  }
  # else load the csv 
  else if ( isTRUE(length(which(loaded_extensions == 'csv')) == length(loaded_extensions)) == TRUE ) {
    #create empty list
    loaded_names <- list()
    upload <- list()
    #load csv files 
    tryCatch({ # setup catch for error
      for (nr in 1:length(input$csv[, 1])) {
        loaded_names[[nr]] <- sub(".csv$", "", basename(input$csv$name[[nr]]))
        upload[[nr]] <- read.csv(
          file = input$csv[[nr, 'datapath']], 
          header = T, 
          sep = ',',
        )
        names(upload)[nr] <- loaded_names[[nr]]
        }
      }, 
      error = function(e) {
        showModal(modalDialog(
          title = "Incorrect file format.",
          paste0("Something about your CSV is not correct."),
          easyClose = TRUE,
          footer = NULL
        ))
      }
    )
  } else {
    print("Something's not correct")
    showModal(modalDialog(
      title = "Incorrect file format.",
      paste0("Check your file format. Note, this app requires no '.' exist in your CSV file name other than for the file type extension."),
      easyClose = TRUE,
      footer = NULL
    ))
  }
  
    
    upload <<- upload
    loaded_names <<- loaded_names
    updateSelectInput(session, "data_selected",
                      label = paste("Select the dataset to review below."),
                      choices = loaded_names,
                      selected = loaded_names[1]
    )
} 
