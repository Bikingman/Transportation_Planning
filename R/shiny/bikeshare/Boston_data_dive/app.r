library(shiny)
library(rgdal)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(plyr)
library(dplyr)
library(rsconnect)
library(jsonlite)
library(sp)
library(maptools)
library(scales)
library(ggplot2)
library(RColorBrewer)
library(RCurl)
library(tidyr)


points_to_line <- function(data, long, lat, id_field = NULL, sort_field = NULL) {
  
  # Convert to SpatialPointsDataFrame
  coordinates(data) <- c(long, lat)
  
  # If there is a sort field...
  if (!is.null(sort_field)) {
    if (!is.null(id_field)) {
      data <- data[order(data[[id_field]], data[[sort_field]]), ]
    } else {
      data <- data[order(data[[sort_field]]), ]
    }
  }
  
  # If there is only one path...
  if (is.null(id_field)) {
    
    lines <- SpatialLines(list(Lines(list(Line(data)), "id")))
    
    return(lines)
    
    # Now, if we have multiple lines...
  } else if (!is.null(id_field)) {  
    
    # Split into a list by ID field
    paths <- sp::split(data, data[[id_field]])
    
    sp_lines <- SpatialLines(list(Lines(list(Line(paths[[1]])), "line1")))
    
    # I like for loops, what can I say...
    for (p in 2:length(paths)) {
      id <- paste0("line", as.character(p))
      l <- SpatialLines(list(Lines(list(Line(paths[[p]])), id)))
      sp_lines <- spRbind(sp_lines, l)
    }
    
    return(sp_lines)
  }
}



URL <- "https://s3.amazonaws.com/hubway-data/index.html"

####### GLOBAL DATA SETUP 
fileName <- "C:\\Users\\Daniel I. Patterson\\Desktop\\Shiney\\shiny_boston_data_dive\\201810-bluebikes-tripdata\\201810-bluebikes-tripdata.csv"
data <- read.csv(fileName, sep = ',', header = T)

json <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/Boston_data_dive/data/station_geojson.geojson")
j <- fromJSON(json, flatten = T)
jj <- ldply(j, data.frame)
jj <- jj[4:nrow(jj),]

data <- data %>%
  filter(data$start.station.name
         %in% jj$properties.Station) 
data <- data %>%
  filter(data$end.station.name
         %in% jj$properties.Station)

data$hire <- 1

data$age <- 2018 - data$birth.year
data$agerange <- ifelse(data$age <= 14, "0 to 14", 
                        ifelse(data$age >= 15 & data$age <= 24, "15 to 24",
                               ifelse(data$age >= 25 & data$age <= 34, "25 to 34", 
                                      ifelse(data$age >= 35 & data$age <= 44, "35 to 44", 
                                             ifelse(data$age >= 45 & data$age <= 54, "45 to 54", 
                                                    ifelse(data$age >= 55 & data$age <= 64, "55 to 64",
                                                           ifelse(data$age >= 65, "65+", 999
                                                           )))))))
data$genderword <- ifelse(data$gender == 0, "No data",
                          ifelse(data$gender == 1, "Male",
                                 ifelse(data$gender == 2, "Female", 999)))
data$starttime <- strptime(data$starttime, "%Y-%m-%d %H:%M:%S")
data$hour <- as.POSIXlt(data$starttime)$hour
data$dow <- as.POSIXlt(data$starttime)$wday
data$dow <- factor(data$dow, levels = c(0:6), 
                   labels = c("Sunday", "Monday", "Tuesday", "Wednesday", 
                              "Thursday", "Friday", "Saturday"))


data$start_time_stripped <- strptime(data$starttime, format = "%Y-%m-%d")
data$start_time_stripped <- as.character(data$start_time_stripped)



hour <- aggregate(hire ~ hour + dow, data = data, FUN = sum)


whiskerdata <- aggregate(hire ~ hour + dow + genderword, data = data, FUN = sum)
whiskerdataf <- subset(whiskerdata, genderword == "Female")
whiskerdatam <- subset(whiskerdata, genderword == "Male")
whiskerdatacom <- aggregate(hire ~ hour + dow, data = whiskerdata, FUN = sum)

line_data <- aggregate(hire ~ start_time_stripped, data = data, FUN = sum)
line_data$start_time_stripped <- as.Date(line_data$start_time_stripped)

station_unique <- unique(data$start.station.name)

data$starttime <- as.Date(data$starttime)
nroute <- data %>%  
  group_by(start.station.id, end.station.id) %>% 
  summarise(nroute=n()) %>% 
  arrange(desc(nroute)) 

temp <- distinct(select(data,start.station.id,start.station.latitude,start.station.longitude,start.station.name))
temp2 <- distinct(select(data,end.station.id,end.station.latitude,end.station.longitude,end.station.name))

#join lat,lng for start and end stations
nroute$route_id <- rownames(nroute)
routes <- left_join(nroute,temp,by = c("start.station.id"="start.station.id")) 
routes2 <- left_join(routes,temp2,by = c("end.station.id"="end.station.id")) 

#take top 0.4% popular routes
top_route <- head(routes2,n=dim(nroute)[1]*0.01)
top_route <- top_route %>%  
  select(-c(start.station.name,end.station.name))


z <- gather(top_route, measure, val, -route_id) %>% 
  group_by(route_id) %>%
  do(data.frame(   lat=c(.[["val"]][.[["measure"]]=="start.station.latitude"],
                         .[["val"]][.[["measure"]]=="end.station.latitude"]),
                   long = c(.[["val"]][.[["measure"]]=="start.station.longitude"],
                            .[["val"]][.[["measure"]]=="end.station.longitude"])))
z <- as.data.frame(z)
y <- points_to_line(z, "long", "lat", "route_id") 

  
###leaflet data
#h <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/MH.csv")
#morning_hires <- read.csv(text = h)
#dd <- getURL("https://raw.githubusercontent.com/Bikingman/SHINY/master/bikeshare/expansion_tool/data/data.csv")
#data <- read.csv(text = dd)

totalhires <- aggregate(hire ~ start.station.name, data = data, FUN = sum)
stations <- merge(jj, totalhires, by.x = "properties.Station", by.y = "start.station.name", all.x = T, all.y = T)
stations$hire[is.na(stations$hire)] <- 0
pts <- subset(stations, select = c(properties.Longitude, properties.Latitude))
distribution_spatial <- SpatialPointsDataFrame(pts, data = stations,
                                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))


  

starts <- subset(data, select = c("start.station.id", "start.station.latitude", "start.station.longitude", "hire"))
ends <- subset(data, select = c("end.station.id", "end.station.latitude", "end.station.longitude", "hire"))
departures <- aggregate(hire ~ start.station.id + start.station.latitude + start.station.longitude, data = starts, FUN = sum)
arrivals <- aggregate(hire ~ end.station.id + end.station.latitude + end.station.longitude, data = ends, FUN = sum)


# Define UI for application that draws a histogram
ui <- navbarPage("Boston's Blue Bikes Data Dive",
                 id = "nav", 
                 position = "fixed-top",
                 collapsible = TRUE,
                 inverse = T,
                 
 
                 
#######################FIRST PANEL

tabPanel("Interactive Map", 
         div(class="outer",
             
             #this is where css styling will go 
             leafletOutput("map", width="100%", height="100%"),
             
             absolutePanel(
               id = "controls",
               fixed = "TRUE",
               draggable = "TRUE",
               top = 60, 
               left = "auto", 
               right = 20, 
               bottom = "auto",
               width = 330, 
               height = "auto",
               h3("Parameters"), 
               
               checkboxInput("routes", "Show Most Popular Routes", value = FALSE),
               
               radioButtons("radio", 
                            h4("Cumulative or Sperate Bars?"),
                            choices = list(
                              "Cumulative"  = 6,
                              "Seperate" = 10),
                            selected = 6)
             )
         )
),
                                 
              
##################SECOND PANEL                 
                 
                 tabPanel("Temporal Use Patterns", 
                          div(class="outer",
                              style="overflow-y: scroll",
                              tags$head(
                                # Include our custom CSS
                                includeCSS("styles.css")
                              ),
                              
                              #this is where css styling will go 

                              
                         
                          h3("How was the system used over time?"),
                          h4("Use the selection options to your right to dive deeper into the Boston Blue Bikes bikeshare system. There's a lot of infomration to see!"),
                          br(),
                          fluidRow(
                            column(6,
                                   plotOutput("temp_map", height = 700, width = 1200))
                          ),
                          
                 # Sidebar with a slider input for number of bins 
                 absolutePanel(
                   id = "controls",
                   fixed = "TRUE",
                   draggable = "TRUE",
                   top = 60, 
                   left = "auto", 
                   right = 20, 
                   bottom = "auto",
                   width = 330, 
                   height = "auto",
      
                   radioButtons("radio2", 
                                h4("Heatmap or Line Graph"),
                                choices = list(
                                  "Heatmap"  = 8,
                                  "Line Graph" = 9),
                                selected = 8),
                   
                   radioButtons("radio3", 
                                h4("Timescale"),
                                choices = list(
                                  "Day of Week"  = 28,
                                  "Day of Month" = 29),
                                selected = 28),
                   
                   radioButtons("radio4",
                                h4("All Stations or Single Station"),
                                choices = list(
                                  "All Stations" = "all",
                                  "Single Station" = "single"),
                                selected = "all"),
                                
                   
                   conditionalPanel(
                     condition = ("input.radio4 == 'single'"),
                       selectInput("station_selection1",
                               h3("Station Selection"),
                               station_unique)),
                   
                   conditionalPanel(
                     condition = ("input.radio3 == 29"),
                       sliderInput("slider1", 
                                   label = h3("Date Range"), 
                                   as.Date("2018-10-01","%Y-%m-%d"), 
                                   as.Date("2018-10-31", "%Y-%m-%d"), 
                                   value = c(as.Date("2018-10-1"), as.Date("2018-10-31"))))
                   
                   
                   
                 )  
                 )
                 ),
                 

#########################THIRD PANEL

                 tabPanel("Gender Stats",
                          div(class="outer",
                              style="overflow-y: scroll",
                              tags$head(
                                # Include our custom CSS
                                includeCSS("styles.css")
                              ),
                              
                              
                              br(),
                              h3("Combined data"),
                              h4("This section dives into the bike share data made by all users."),
                              fluidRow(
                                column(4,plotOutput("barplot", height = 400, width = 500)),
                                column(4,plotOutput("comwhisker", height = 400, width = 500))
                              ),
                              br(),
                              hr(),
                              h3("Male"),
                              h4("This section dives into data produced by men."),
                              fluidRow(
                                column(4,plotOutput("male", height = 400, width = 500))
                              ),
                              br(),
                              hr(),
                              h3("Female"),
                              fluidRow(
                                column(4,
                                       plotOutput("female", height = 400, width = 500))
                              ),
                              
                              
                              absolutePanel(
                                id = "controls",
                                #class = "model-body",
                                fixed = "TRUE",
                                draggable = "TRUE",
                                top = 60, 
                                left = "auto", 
                                right = 20, 
                                bottom = "auto",
                                width = 330, 
                                height = "auto",
                                h3("Parameters"),
                                radioButtons("radio",
                                             h4("Cumulative or Seperate Bars?"),
                                             choices = list(
                                               "Cumulative"  = 6,
                                               "Seperate" = 10),
                                             selected = 6)
                              )
                          )
                 )
                 
                 
###################close UI

)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  output$map <- renderLeaflet({
  

    
      if (input$routes==TRUE) {
        leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron,
                           options = providerTileOptions(noWrap = TRUE)
          ) %>%
          addCircleMarkers(data = distribution_spatial$hire*.004, 
                           radius = 2,
                           fillOpacity = .9,
                           color = "#33CCFF",
                           label = paste( 
                             "Hires:", distribution_spatial$hire)
          )%>% 
          addPolylines(data = y,
                       color="#ffa500",
                       weight =2, 
                       opacity = 0.3)
        }
    
    else {  leaflet() %>%
        addProviderTiles(providers$CartoDB.Positron,
                         options = providerTileOptions(noWrap = TRUE)
        ) %>%
        addCircleMarkers(data = distribution_spatial, 
                         radius = distribution_spatial$hire*.004,
                         fillOpacity = .9,
                         color = "#33CCFF",
                         label = paste( 
                           "Hires:", distribution_spatial$hire)
        )}
    
    
  }
  
  )
  
 
  output$comwhisker <- renderPlot({
    
    boxplot(whiskerdatacom$hire ~ whiskerdatacom$dow)
    
  }
  )
  
  
  
  
  output$barplot <- renderPlot({
    
    
    
    if ( (input$radio==6)
    ) {
      f <- ggplot(data = data, aes(x = data$agerange)) +
        geom_bar(colour = "black", aes(fill = as.factor(data$genderword))) +
        scale_x_discrete(drop = FALSE) + 
        scale_fill_brewer(palette = "Dark2") +
        labs(title = "Blue Bike Hires By Age and Gender, October 2018", y = "Total Hires", x = "Age Range", fill = "data$genderword") + 
        guides(fill = guide_legend("Legend")) + 
        theme_bw()
      
      f
      
      
    } else {
      h <- ggplot(data = data, aes(x = data$agerange)) +
        geom_bar(position = "dodge", colour = "black", aes(fill = as.factor(data$genderword))) +
        scale_x_discrete(drop = FALSE) + 
        scale_fill_brewer(palette = "Dark2") +
        labs(title = "Blue Bike Hires By Age and Gender, October 2018", y = "Total Hires", x = "Age Range", fill = "data$genderword") + 
        guides(fill = guide_legend("Legend")) + 
        theme_bw()
      
      h
      
    }
  }
  )
  
  
  
  
  
  output$male <- renderPlot({
   
    boxplot(whiskerdatam$hire ~ whiskerdatam$dow)
    
  }
  )
  
  
  
  output$female <- renderPlot({
    
    
    fbp <- ggplot(whiskerdataf, aes(dow, hire)) + 
      geom_boxplot(aes(fill=whiskerdataf$dow)) + 
      guides(fill=FALSE,color=FALSE)+
      labs(title="Female Hires by Day of Week",
           x="Day of Week",
           y="Hires") + 
      theme_classic()
    fbp
  
      }
  )
  
  
  output$temp_map <- renderPlot({
    
    
    
    if ( (input$radio2==8)
    ) {
      p <- ggplot(hour, aes(hour, dow)) + 
        geom_tile(aes(fill = hire),     
                  colour = "white") + 
        scale_fill_gradient(low = "paleturquoise",
                            high = "midnightblue") + 
        labs(title = "Popularity of Hires by Day and Hour", y = "Day of Week", x = "Hour of Day") + 
        guides(fill = guide_legend("Hires")) + 
        theme_classic()
      
      
      p
      
      
    } else {
      l <- ggplot(line_data, aes(as.Date(start_time_stripped), hire)) + 
        geom_line(aes(),     
                  colour = "red") + 
        scale_x_date(limits = as.Date(c(input$slider1[1],input$slider1[2]))) +
        labs(title = "Popularity over Time", y = "Hires", x = "Time") + 
        guides(fill = guide_legend("Hires")) + 
        theme_bw()
      l
      
    }
    
   
    
    
    
  })
  }

# Run the application 
shinyApp(ui = ui, server = server)

