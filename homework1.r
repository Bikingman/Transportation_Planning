################### part 1

#1a) Create vector 1:12, values = ^2, call this vector x
x <- (c(1:12)^2)

#1b) Print 1st:3rd
print(x[c(1:3)])

#1c) print 3rd,7th,1st
print(x[c(3, 7, 1)])

#1d) display boolean vector, indicated elemants = 100
x==100

#1e) single command to find position of value 100 
which(x == "100")

#1f) create y as revrese order of x  
y <- rev(x)

################## part 2
  
"""
2a)	Calculate total travel distance 
(find the distance variable from codebook) for 
each person (personID) and household (hhid) 
(save them as distance_person and distance_household, respectively; 
use a hhsurvey-trips file).  Provide a summary statistics of total 
travel distance variable for person and household. 

#distance variable is = gdist

"""

setwd("D:/MSc Transport Planning/Transport_Planning_Lab/Homework_1/2014-hhsurvey")

# download data from file and use read.csv() to upload- converted in excel
require(xlsx)
personID1 <- read.csv("2014-pr3-hhsurvey-persons.csv", sep=',' ,header=T)
trips <- read.csv("2014-pr3-hhsurvey-trips.csv", sep=',' ,header=T)
hhveh <- read.csv("2014-pr3-hhsurvey-vehicles.csv", sep=',' ,header=T)

distance_person <- aggregate(gdist ~ personID, data =trips, FUN = sum)
distance_household <- aggregate(gdist ~ hhid, data=trips, FUN=sum)
  
""" 
b)	Create new data (household) that includes household id, 
number of vehicles, household size, number of workers in household. 
Please remove all missing values (including prefer not to answer).   
Display summary statistics of all variables in the data except id.  
Find its dimensions.
"""

setwd("D:/MSc Transport Planning/Transport_Planning_Lab/Homework_1/2014-hhsurvey")
hhid1 <- read.csv("2014-pr3-hhsurvey-households.csv", sep=',' ,header=T)
household <- subset(hhid1, select = c(hhid, vehicle_count, hhsize, numworkers))
household <- na.omit(household)
summary(household[, c("vehicle_count", "hhsize", "numworkers")])
dim(household)

#Questions
#accourding to PDF there was no, "perfer not to awnser" option in any selected variables, can exclude this correct? 
#by "find its dimensions" you are looking for dimesions of entire housefold object?  
# http://www.psrc.org/assets/12061/2014-Household-Survey-Dataset-Guide.pdf


""" 
c)	Display the data contained in the first 10 rows and 
in all columns except column 4.  
"""

trips[1:10, -4]
hhid1[1:10, -4]

#Quetsions 
#from which dataset? households? trips?...


 
""" 
d)	Merge new data (household) and total travel distance 
for household (distance_household). What is the correlation 
between total travel distance and household size?  Draw a 
histogram of log (total travel distance).  Order the data by 
total travel distance, smallest to largest. (for this problem, 
please google to find proper functions. You can also find a way to 
insert title and axis labels).  
"""
setwd("D:\MSc Transport Planning\Transport_Planning_Lab\Homework_1\2014-hhsurvey")

new_distance_household <- merge(household, distance_household, by = "hhid")
new_distance_household <- na.omit(new_distance_household)

with(new_distance_household, cor.test(gdist, hhsize, 
                                      alternative="two.sided", method="pearson"))

hist(log(new_distance_household$gdist), main = "Total Travel Distance by Household", 
     xlab = "log(distance)", ylab = "count")

sorted <- sort(new_distance_household$gdist, decreasing = F)
 

#would you like the data to be ordered, and then placed in to a distgram? 
