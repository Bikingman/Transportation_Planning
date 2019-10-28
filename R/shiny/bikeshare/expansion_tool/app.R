library(shiny)
library(leaflet)
library(sp)
library(RCurl)
library(rsconnect)
library(plyr)
library(jsonlite)

# Define UI ----
ui <- fluidPage(
  
  # Application title
  titlePanel("Bike Expansion Tool"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      h2(strong("Parameters")),
      br(), 
      br(),
#for future data
#      fluidRow(
#        column(12,
#               radioButtons("city", 
#                            h4("Where are we expanding?"),
#                            choices = list(
#                              "New York City"  = "NYC",
#                              "Boston" = "Boston",
#                              "Philadelphia" = "Philadelphia",
#                              "Minneapolis" = "Minneapolis",
#                              "San Francisco" = "San Francisco",
#                              "Columbus" = "Columbus"),
#                            selected = "NYC")
#        )
#      ),

      fluidRow(
        column(12,
               radioButtons("radio", 
                            h4("Will the distribution take place in the day or overnight?"),
                            choices = list(
                              "Day"  = 6,
                              "Night" = 10),
                            selected = 6),
               helpText("This helps calculate where bikes go and assumes less time available for distribution during the day than at night.")
                            )
        ),
       fluidRow(
        column(12,
               numericInput("addbikes", 
                            h4("How many bikes are we adding?"), 
                            value =100)
               )
        ),
      fluidRow(
        column(12,
               numericInput("vans", 
                            h4("How many vans will be available to distribute new bikes?"), 
                            value = 4)
        )
      ),

      fluidRow(
        column(12,
               numericInput("stations", 
                            h4("How many stations will get new bikes?"), 
                            value = 40)
        )
      ),


p("This tool is designed to create a bike distribution plan for field operations to,  a) reintroduce fixed bikes, b) replace missing/worn-out bicycles, or c) expanding the total number of available steeds." ),
p("Plans are created by, first identifying the most popular stations using historical data (weekday, April 2018), then assigning new bikes based on three elements: 1) total incoming bikes, 2) total stations, and 3) each station's relative popularity. The tool takes the most popular stations and assigns bikes based on their relative popularity. The assignment accounts for morning or evening activity as bike share users tend to act differently depending on the time of day. Total available docks are included in the table to improve the distribution planning. Hope you enjoy!"),




        fluidRow(
          column(12,
                 helpText("Developed by Dan Patterson, more of his work can be found on", a(href = "http://www.urbandatacyclist.com", "his webpage.")
                 )
          )
        )
    ),
       
    mainPanel(
      h2(strong("Expansion Plan")),
      br(),
      strong(textOutput("Statement")),
      br(),
      textOutput("Statement2"),
      br(),
      fluidRow(
        column(12,
               leafletOutput("map"
               )
        )
      ),
      br(),
      p("This plan includes the most popular stations and calculates how many bikes should be added given the information you provided on the left."),

 #     fluidRow(
  #      column(12, 
  #             downloadButton("downloadDataFromTable", 
 #                             "Download Bike Expansion List", 
  #                            style="display: block; margin: 0 auto; width: 230px;color: black;"))
#      ),
  
      fluidRow(
        column(12,
               dataTableOutput("table"
               )
        )
      ),
      
      br(),
p("If during the expansion there aren't enough spaces for additional bikes, continue with the expansion and disperse the bikes as you would if they were part of the daily grind.",
  em("Keep up the good work!")

        )
  )
)
)

  
  
  
# Define server logic ----
server <- function(input, output) {
  
  
  output$Statement <- renderText({
    A <- input$stations
    B <- as.numeric(input$radio)
    C <- input$vans
    D <- input$addbikes
    E <- ceiling(A/B)
    F <- ceiling(E/C)
    G <- ceiling(D/B)
    paste("During this shift, each van will be expected to reach approximately,", F,"stations and deliver", G, "bikes per hour. Is this managable?")
  })
  
  output$table <- renderDataTable({
  
    if ( (input$radio==6)
    ) {
         #morning data
         h <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/MH.csv")
         morning_hires <- read.csv(text = h)
         dd <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/data.csv")
         data <- read.csv(text = dd)
         json <- getURL("https://gbfs.citibikenyc.com/gbfs/fr/station_status.json")
         j <- fromJSON(json, flatten = T)
         jj <- ldply(j, data.frame)
         

         #get unique id names to merge with morning hires
         morning_hires2 <- merge(morning_hires, data, by = "start.station.id", all.x = T, all.y = F)
         morning_hires2 <- merge(morning_hires2, jj, by.x = "start.station.id", by.y = "stations.station_id", all.x = T, all.y = F)
         morning_hires2 <- morning_hires2[order(-morning_hires2$hire),] 
         distribution_list <- morning_hires2[1:input$stations,]
         distribution_list$perc <- distribution_list$hire/sum(distribution_list$hire)
         distribution_list$bike_count <- round(distribution_list$perc*input$addbikes,0)
         distribution_list <- subset(distribution_list, bike_count > 0)
         distribution_list <- distribution_list[order(-distribution_list$bike_count),] 
         final_list <- subset(distribution_list, select = c("start.station.name", "bike_count", "stations.num_docks_available"))
         colnames(final_list) <- c("Station Name", "New Bikes", "Available Docks")
         final_list
         
         
    } else {
      #evening data
      EH <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/EH.csv")
      evening_hires <- read.csv(text = EH)
      dd <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/data.csv")
      data <- read.csv(text = dd)
      json <- getURL("https://gbfs.citibikenyc.com/gbfs/fr/station_status.json")
      j <- fromJSON(json, flatten = T)
      jj <- ldply(j, data.frame)
      
      evening_hires2 <- merge(evening_hires, data, by = "start.station.id", all.x = T, all.y = F)
      evening_hires2 <- merge(evening_hires2, jj, by.x = "start.station.id", by.y = "stations.station_id", all.x = T, all.y = F)
      
      evening_hires2 <- evening_hires2[order(-evening_hires2$hire),] 
      evening_distribution_list <- evening_hires2[1:input$stations,]
      evening_distribution_list$perc <- evening_distribution_list$hire/sum(evening_distribution_list$hire)
      evening_distribution_list$bike_count <- round(evening_distribution_list$perc*input$addbikes,0)
      evening_distribution_list <- subset(evening_distribution_list, bike_count > 0)
      evening_distribution_list <- evening_distribution_list[order(-evening_distribution_list$bike_count),] 
      final_evening_list <- subset(evening_distribution_list, select = c("start.station.name", "bike_count", "stations.num_docks_available"))
      colnames(final_evening_list) <- c("Station Name", "New Bikes", "Available Docks")
      

       final_evening_list 
   
    }
  }
  )
  
  
  
  output$map <- renderLeaflet({
    
    if ( (input$radio==6)
    ) {
      #morning data
      h <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/MH.csv")
      morning_hires <- read.csv(text = h)
      dd <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/data.csv")
      data <- read.csv(text = dd)
      json <- getURL("https://gbfs.citibikenyc.com/gbfs/fr/station_status.json")
      j <- fromJSON(json, flatten = T)
      jj <- ldply(j, data.frame)
      #get unique id names to merge with morning hires
      morning_hires2 <- merge(morning_hires, data, by = "start.station.id", all.x = T, all.y = F)
      morning_hires2 <- morning_hires2[order(-morning_hires2$hire),] 
      distribution_list <- morning_hires2[1:input$stations,]
      distribution_list$perc <- distribution_list$hire/sum(distribution_list$hire)
      distribution_list$bike_count <- round(distribution_list$perc*input$addbikes,0)
      distribution_list <- subset(distribution_list, bike_count > 0)
      distribution_list <- distribution_list[order(-distribution_list$bike_count),] 
      final_list <- subset(distribution_list, select = c("start.station.name", "bike_count"))
      
      pts1 <- subset(distribution_list, select = c(start.station.longitude, start.station.latitude))
      distribution_spatial <- SpatialPointsDataFrame(pts1, data = distribution_list,
                                                     proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
      
      leaflet() %>%
        addProviderTiles(providers$Stamen.TonerLite,
                         options = providerTileOptions(noWrap = TRUE)
        ) %>%
        addCircleMarkers(data = distribution_spatial, 
                         radius = 4,
                         fillOpacity = 1,
                         color = "Green",
                         label = paste("Station Name:", distribution_spatial$start.station.name,"&",
                                       "Bikes:", distribution_spatial$bike_count)
                                        

        )
      
      
    } else {
      #evening data
      dd <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/data.csv")
      data <- read.csv(text = dd)
      EH <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/EH.csv")
      evening_hires <- read.csv(text = EH)
      json <- getURL("https://gbfs.citibikenyc.com/gbfs/fr/station_status.json")
      j <- fromJSON(json, flatten = T)
      jj <- ldply(j, data.frame)
      
      evening_hires2 <- merge(evening_hires, data, by = "start.station.id", all.x = T, all.y = F)
      evening_hires2 <- evening_hires2[order(-evening_hires2$hire),] 
      evening_distribution_list <- evening_hires2[1:input$stations,]
      evening_distribution_list$perc <- evening_distribution_list$hire/sum(evening_distribution_list$hire)
      evening_distribution_list$bike_count <- round(evening_distribution_list$perc*input$addbikes,0)
      evening_distribution_list <- subset(evening_distribution_list, bike_count > 0)
      evening_distribution_list <- evening_distribution_list[order(-evening_distribution_list$bike_count),] 
      final_evening_list <- subset(evening_distribution_list, select = c("start.station.name", "bike_count"))
      
      pts2 <- subset(evening_distribution_list, select = c(start.station.longitude, start.station.latitude))
      evening_distribution_spatial <- SpatialPointsDataFrame(pts2, data = evening_distribution_list,
                                                     proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
      
      pal <- colorFactor(
        palette = 'Blues',
        domain = evening_distribution_spatial$bike_count
      )
      
      leaflet() %>%
        addProviderTiles(providers$Stamen.TonerLite,
                         options = providerTileOptions(noWrap = TRUE)
        ) %>%
        
        addCircleMarkers(data = evening_distribution_spatial, 
                         lng = as.numeric(evening_distribution_spatial$start.station.longitude), 
                         lat = as.numeric(evening_distribution_spatial$start.station.latitude),
                         radius = 4,
                         fillOpacity = 1,
                         color = "Blue",
                         label = paste("Station Name:", evening_distribution_spatial$start.station.name,"&",
                         "Bikes:", evening_distribution_spatial$bike_count)
        )
                  
    }
  }
  )
  

}
    

    
# Run the app ----
shinyApp(ui = ui, server = server)
