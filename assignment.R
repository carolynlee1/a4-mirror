# a4-data-wrangling

################################### Set up ###################################

# Install (if not installed) + load dplyr package 
install.packages("dplyr")
library("dplyr")
# Set your working directory to the appropriate project folder
getwd()
setwd("~/info201/a4-data-wrangling-carolynlee1/")
# Read in `any_drinking.csv` data using a relative path
any.drinking <- read.csv("./data/any_drinking.csv", stringsAsFactors = FALSE)
# Read in `binge.drinking.csv` data using a relative path
binge.drinking <- read.csv("./data/binge_drinking.csv", stringsAsFactors = FALSE)
# Create a directory (using R) called "output" in your project directory
# Make sure to suppress any warnings, in case the directory already exists
dir.create("output", showWarnings = FALSE)

################################### Any drinking in 2012 ###################################

# For this first section, you will work only with the *any drinking* dataset.
# In particular, we'll focus on data from 2012, keeping track of the `state` and `location` variables

# Create a data.frame that has the `state` and `location` columns, and all columns with data from 2012
View(any.drinking)
data.2012 <- select(any.drinking, state, location, both_sexes_2012, males_2012, females_2012)
View(data.2012)
# Using the 2012 data, create a column that has the difference in male and female drinking patterns
data.2012 <- mutate(data.2012, diff = males_2012 - females_2012)
View(data.2012)
# Write your 2012 data to a .csv file in your `output/` directory with an expressive filename
# Make sure to exclude rownames
getwd()
write.csv(data.2012, file = "output/2012 data.csv", row.names = FALSE)
# Are there any locations where females drink more than males?
# Your answer should be a *dataframe* of the locations, states, and differences for all locations (no extra columns)
females.more <- data.2012 %>%
  filter(diff < 0) %>%
  select(location, state, diff)
View(females.more)
# What is the location in which male and female drinking rates are most similar (*absolute* difference is smallest)?
# Your answer should be a *dataframe* of the location, state, and value of interest (no extra columns)
most.similar <- data.2012 %>%
  filter(diff == min(abs(diff))) %>%
  select(location, state, diff)
View(most.similar)


       # As you've (hopefully) noticed, the `location` column includes national, state, and county level estimates. 
# However, many audiences may only be interested in the *state* level data. Given that, you should do the following:
# Create a new variable that is only the state level observations in 2012
# For the sake of this analysis, you should treat Washington D.C. as a *state*
View(data.2012)
only.state <- filter(data.2012, location == state)
# Which state had the **highest** drinking rate for both sexes combined? 
# Your answer should be a *dataframe* of the state and value of interest (no extra columns)
highest.data <- only.state %>%
  filter(both_sexes_2012 == max(both_sexes_2012)) %>%
  select(state, both_sexes_2012)

# Which state had the **lowest** drinking rate for both sexes combined?
# Your answer should be a *dataframe* of the state and value of interest (no extra columns)
lowest.data <- only.state %>%
  filter(both_sexes_2012 == min(both_sexes_2012)) %>%
  select(state, both_sexes_2012)
# What was the difference in (any-drinking) prevalence between the state with the highest level of consumption, 
# and the state with the lowest level of consumption?
# Your answer should be a single value (a dataframe storing one value is fine)
select(highest.data, 2) - select(lowest.data, 2)
  
# Write your 2012 state data to an appropriately named file in your `output/` directory
# Make sure to exclude rownames
write.csv(only.state, file = "output/2012 state data.csv", row.names = FALSE)

# Write a function that allows you to specify a state, then saves a .csv file with only observations from that state
# This includes data about the state itself, as well as the counties within the state
# You should use the entire any.drinking dataset for this function
# The file you save in the `output` directory indicates the state name
# Make sure to exclude rownames
GetState <- function(state.name) {
 state.selected.data <- any.drinking %>%
      filter(state == state.name) 
 write.csv(state.selected.data, file = paste0("output/", state.name, " data from 2012.csv" ), row.names = FALSE)
}
# Demonstrate your fun8ction works by passing 3 states of your choice to the function
GetState("Alaska")
GetState("California")
GetState("New York")
################################### Binge drinking Dataset ###################################
# In this section, we'll ask a variety of questions regarding our binge.drinking dataset
# Moreover, we'll be looking at a subset of the observations which is just the counties 
# (i.e., exclude state/national estimates)
# In order to ask these questions, you'll need to first prepare a subset of the data for this section:

# Create a dataframe with only the county level observations from the binge_driking dataset 
# You should (again) think of Washington D.C. as a state, and therefore *exclude it here*
# This does include "county-like" areas such as parishes and boroughs
only.county <- as.data.frame(binge.drinking %>%
  filter(state != location, state != "National"))

View(only.county)
# What is the average level of binge drinking in 2012 for both sexes (across the counties)?
only.county %>%
  summarise(
    mean = mean(both_sexes_2012)
  )

# What is the *minimum* level of binge drinking in each state in 2012 for both sexes (across the counties)? 
# Your answer should contain roughly 50 values (one for each state), unless there are two counties in a state with the same value
# Your answer should be a *dataframe* with the 2012 binge drinking rate, location, and state
state.min <- only.county %>%
  group_by(state) %>%
  filter(both_sexes_2012 == min(both_sexes_2012)) %>% 
  select(both_sexes_2012, location, state)
 
View(state.min)
# What is the *maximum* level of binge drinking in each state in 2012 for both sexes (across the counties)? 
# Your answer should be a *dataframe* with the value of interest, location, and state
state.max <- only.county %>%
  group_by(state) %>%
  filter(both_sexes_2012 == max(both_sexes_2012)) %>% 
  select(both_sexes_2012, location, state)
View(state.max)
# What is the county with the largest increase in male binge drinking between 2002 and 2012?
# Your answer should include the county, state, and value of interest
binge.drinking %>%
  mutate(males.diff = males_2002 - males_2012) %>%
  filter(males.diff == max(males.diff)) %>%
  select(location, state, males.diff)

View(binge.drinking)
  
# How many counties experienced an increase in male binge drinking between 2002 and 2012?
# Your answer should be an integer (a dataframe with only one value is fine)

increased.males.data <- binge.drinking %>%
  filter(males.diff > 0) %>%
  count()
 
View(increased.males.data)
# What percentage of counties experienced an increase in male binge drinking between 2002 and 2012?
# Your answer should be a fraction or percent (we're not picky)
round(increased.males.data / count(binge.drinking) * 100, digits = 1)
                    
# How many counties observed an increase in female binge drinking in this time period?
# Your answer should be an integer (a dataframe with only one value is fine)

increased.females.data <- binge.drinking %>%
  mutate(females.diff = females_2012 - females_2002) %>%
  filter(females.diff > 0) %>%
  count()

View(increased.females.data)
# What percentage of counties experienced an increase in female binge drinking between 2002 and 2012?
# Your answer should be a fraction or percent (we're not picky)
round(increased.females.data / count(binge.drinking) * 100, digits = 1)

# How many counties experienced a rise in female binge drinking *and* a decline in male binge drinking?
# Your answer should be an integer (a dataframe with only one value is fine)
female.rise.male.decline <- binge.drinking %>%
  filter(females.diff > 0 & males.diff < 0) %>%
  count()


################################### Joining Data ###################################
# You'll often have to join different datasets together in order to ask more involved questions of your dataset. 
# In order to join our datasets together, you'll have to rename their columns to differentiate them

# First, rename all prevalence columns in the any.drinking dataset to the have prefix "any."
# Hint: you can get (and set!) column names using the colnames function. This may take multiple lines of code.
colnames(any.drinking)[3:length(any.drinking)] <- paste0("any.", colnames(any.drinking)[3:length(any.drinking)])
View(any.drinking)
 # Then, rename all prevalence columns in the binge.drinking dataset to the have prefix "binge."
# Hint: you can get (and set!) column names using the colnames function. This may take multiple lines of code.
colnames(binge.drinking)[3:length(binge.drinking)] <- paste("binge.", colnames(binge.drinking)[3:length(binge.drinking)])
View(binge.drinking)
# Then, create a dataframe with all of the columns from both datasets. 
# Think carefully about the *type* of join you want to do, and what the *identifying columns* are
both.drinking <- full_join(any.drinking, binge.drinking)
View(both.drinking)
# Create a column of difference between `any` and `binge` drinking for both sexes in 2012
any.binge.diff <- both.drinking %>% 
  select(contains("both_sexes_2012")) %>%
  mutate(diff = any.binge.diff[, 1] - any.binge.diff[, 2])
  
both.drinking <- mutate(both.drinking, diff.any.binge = any.binge.diff$diff)

View(any.binge.diff)
View(both.drinking)

# Which location has the greatest *absolute* difference between `any` and `binge` drinking?
# Your answer should be a one row data frame with the state, location, and value of interest (difference)
both.drinking %>%
  filter(diff.any.binge == abs(max(diff.any.binge))) %>%
  select(state, location, diff.any.binge)

# Which location has the smallest *absolute* difference between `any` and `binge` drinking?
# Your answer should be a one row data frame with the state, location, and value of interest (difference)
both.drinking %>%
  filter(diff.any.binge == min(abs(diff.any.binge))) %>%
  select(state, location, diff.any.binge)

################################### Write a function to ask your own question(s) ###################################
# Even in an entry level data analyst role, people are expected to come up with their own questions of interest
# (not just answer the questions that other people have). For this section, you should *write a function*
# that allows you to ask the same question on different subsets of data. 
# For example, you may want to ask about the highest/lowest drinking level given a state or year. 
# The purpose of your function should be evident given the input parameters and function name. 
# After writing your function, *demonstrate* that the function works by passing in different parameters to your function.
GetAverages <- function(year) {
  any.drinking %>%
    select(contains(year)) %>%
    summarise_all(funs(mean))
}
GetAverages("2005")
GetAverages("2008")
GetAverages("2012")
################################### Challenge ###################################

# Using your function from part 1 (that wrote a .csv file given a state name), write a separate file 
# for each of the 51 states (including Washington D.C.)
# The challenge is to do this in a *single line of (concise) code*

lapply(only.state$state, GetState)



# Using a dataframe of your choice from above, write a function that allows you to specify a *year* and *state* of interest, 
# that saves a .csv file with observations from that state's counties (and the state itself) 
# It should only write the columns `state`, `location`, and data from the specified year. 
# Before writing the .csv file, you should *sort* the data.frame in descending order
# by the both_sexes drinking rate in the specified year. 
# Again, make sure the file you save in the output directory indicates the year and state. 
# Note, this will force you to confront how dplyr uses *non-standard evaluation*
# Hint: https://cran.r-project.org/web/packages/dplyr/vignettes/nse.html
# Make sure to exclude rownames
GetCounties <- function(what.year, what.state) {
county.data  <- any.drinking %>%
    filter(state == what.state) %>%
    select(state, location, contains(what.year)) 

    arrange(county.data, desc(county.data[, 3]))
    
    write.csv(county.data, file = paste0("output/", what.year, " data from ", what.state, ".csv" ), row.names = FALSE)
    
}


# Demonstrate that your function works by passing a year and state of your interest to the function
GetCounties("2012", "Alaska")
