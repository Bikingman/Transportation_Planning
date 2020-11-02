#TODO abstract this so it can handle any datatype
observe_file <- function(session, input, output, file_type='None', input_type=NA){
  #create helper function
  getExtension <- function(input) {
    ex <- strsplit(basename(input), split = "\\.")[[1]]
    return(ex[-1])
  }
  Add_Modal <- function(title='None', body='None'){
    showModal(modalDialog(
      title = title,
      paste0(body),
      easyClose = TRUE,
      footer = NULL
    ))
  }
  print(input_type)
  #if the data is empty 
  loaded_extensions <- list()
   for (e in 1:length(input_type[, 1])) {
     loaded_extensions[[e]] <- getExtension(input_type[[e, 'datapath']])
   }
  
  #### try loading data 
  # test if field is null
  if (is.null(input_type)) {
    Add_Modal(title = 'No Data', 
              body = 'No data selected.')

  } 
  
  # else if the selected data is not the correct data type 
  else if (isTRUE(length(which(loaded_extensions == file_type)) == length(loaded_extensions)) != TRUE) {
    Add_Modal(title = 'Not correct file format', 
              body = 'Either the file(s) you selected are not the desired file type. or the file(s) are incorrectly formatted. Additionally, this app requires no \'.\' exist in your file name other than for the file type extension.')
  }
  
  # else load the file 
  else if ( isTRUE(length(which(loaded_extensions == file_type)) == length(loaded_extensions)) == TRUE ) {
    #create empty list
    loaded_names <- list()
    upload <- list()
    #load files 
    tryCatch({ # setup catch for error

      for (nr in 1:length(input_type[, 1])) {
        loaded_names[[nr]] <- sub(sprintf(".%s$", file_type), "", basename(input_type$name[[nr]]))
        if (file_type == 'csv') {
          upload[[nr]] <- read.csv(
            file = input_type[[nr, 'datapath']], 
            header = T, 
            sep = ',',
          )
        }
        names(upload)[nr] <- loaded_names[[nr]]
        }
      }, 
      error = function(e) {
        Add_Modal(title = 'Incorrect file format.', 
                  body = 'Something about your file is not correct.')
      }
    )
  } 
  
  # else catchall 
  else {
    Add_Modal(title='Incorrect file format.', 
              body='Check your file format. Note, this app requires no \'.\' exist in your file name other than for the file type extension.')
    }
  
  ###### end of validation and laoad
  
  #TODO modularize the upload and loaded names (refactor them so they're easier to read)
  upload <<- upload
  loaded_names <<- loaded_names
  updateSelectInput(session, "data_selected",
                    label = paste("Select the dataset to review below."),
                    choices = loaded_names,
                    selected = loaded_names[1]
  )
} 
