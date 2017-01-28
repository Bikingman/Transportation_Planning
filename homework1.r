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
  
#Download travel survey data and codebook from:  
#http://www.psrc.org/data/transportation/travel-surveys/2014-household/2014-household-3/

setwd("D:/MSc Transport Planning/Transport_Planning_Lab/Homework_1/2014-hhsurvey")
hhid1 <- read.csv("2014-pr3-hhsurvey-households.csv", sep=',' ,header=T)
personID1 <- read.csv("2014-pr3-hhsurvey-persons.csv", sep=',' ,header=T)
trips <- read.csv("2014-pr3-hhsurvey-trips.csv", sep=',' ,header=T)
hhveh <- read.csv("2014-pr3-hhsurvey-vehicles.csv", sep=',' ,header=T)

"""
a)	Calculate total travel distance 
(find the distance variable from codebook) for each person 
(personID) and household (hhid) (save them as distance_person 
and distance_household, respectively; use a hhsurvey-trips file). 
Provide a summary statistics of total travel distance variable for person and 
household (Please remove all missing or unexpected data). 
"""

distance_person <- aggregate(gdist ~ personID, data =trips, FUN = sum)
head(distance_person)
nrow(distance_person)
sum(is.na(distance_person))
distance_person <- distance_person[c(distance_person$gdist > 0 & distance_person$gdist <= 300),]
nrow(distance_person)
summary(distance_person$gdist)

distance_household <- aggregate(gdist ~ hhid, data=trips, FUN=sum)
head(distance_household)
nrow(distance_household)
sum(is.na(distance_household))
distance_household <- distance_household[c(distance_household$gdist > 0 & distance_household$gdist <= 300),]
summary(distance_household$gdist)

  
""" 
b)	Create new data (household) that includes household id, 
number of vehicles, household size, number of workers in household. 
Please remove all missing values (including prefer not to answer).   
Display summary statistics of all variables in the data except id.  
Find its dimensions.
"""

household <- subset(hhid1, select = c(hhid, vehicle_count, hhsize, numworkers))
sum(is.na(household))
summary(household[, c("vehicle_count", "hhsize", "numworkers")])
dim(household)

""" 
c)	Display the data contained in the first 10 rows and 
in all columns except column 4.  
"""

household[1:10, -4]
 
""" 
d)	Merge new data (household) and total travel distance 
for household (distance_household). What is the correlation 
between total travel distance and household size?  Draw a 
histogram of log (total travel distance).  Order the data by 
total travel distance, smallest to largest. (for this problem, 
please google to find proper functions. You can also find a way to 
insert title and axis labels).  
"""

new_distance_household <- merge(household, distance_household, by = "hhid")
new_distance_household <- na.omit(new_distance_household)
with(new_distance_household, cor.test(gdist, hhsize, alternative="two.sided", method="pearson"))
hist(log(new_distance_household$gdist), main = "Total Travel Distance by Household", xlab = "distance (log scale)", ylab = "frequency")
sorted <- sort(new_distance_household$gdist, decreasing = F)
 

#would you like the data to be ordered, and then placed in to a distgram? 
