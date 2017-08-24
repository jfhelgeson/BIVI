#install packages if not already installed
if (!require(rgdal))
  install.packages("rgdal")
if (!require(dplyr))
  install.packages("dplyr")
if (!require(readr))
  install.packages("readr")
if (!require(geojsonio))
  install.packages("geojsonio")
if (!require(shiny))
  install.packages("shiny")
if (!require(leaflet))
  install.packages("leaflet")
if (!require(RColorBrewer))
  install.packages("RColorBrewer")
if (!require(scales))
  install.packages("scales")
if (!require(ggplot2))
  install.packages("ggplot2")
if (!require(colorRamps))
  install.packages("colorRamps")
if (!require(DT))
  install.packages("DT")


#### Packages #####################
library(rgdal)
library(dplyr)
library(readr)
library(geojsonio)
library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(ggplot2)
library(colorRamps)


#data file for spatial polygons data frame
counties <- geojson_read("counties.geojson",
                         what = "sp")

#data for the indices at the county level
countydata <- read.csv("countydata.csv")
countydata$GEO_ID <- as.character(countydata$GEO_ID)

#subset to match up to the data to make map labels
countydatamatch <- countydata[,-c(1,3:7)]

#matching the data with a left join so the counties have the appropriate labels
counties@data$GEO_ID <- as.character(counties@data$GEO_ID)
counties@data <- left_join(counties@data,countydatamatch,by = "GEO_ID")

#data in same order as the map data
countydatamap <- counties@data

#data table for table tab
countydatatable <- countydatamap %>% 
  select(
    FIPS = FIPS,
    State = ST,
    County = CNTY,
    Location = Location,
    "SVI Theme 1 Score" = SVITheme1Score,
    "SVI Theme 2 Score" = SVITheme2Score,
    "SVI Theme 3 Score" = SVITheme3Score,
    "SVI Theme 4 Score" = SVITheme4Score,
    "SVI Themes Score" = SVIThemesScore,
    "SVI Score" = SVIOverallScore,
    "BIVI Theme 1 Score" = BIVITheme1Score,
    "BIVI Theme 2 Score" = BIVITheme2Score,
    "BIVI Theme 3 Score" = BIVITheme3Score,
    "BIVI Theme 4 Score" = BIVITheme4Score,
    "BIVI Themes Score" = BIVIThemesScore,
    "BIVI Score" = BIVIOverallScore,
    "Presidential Disaster Declarations Score" = PDDscore,
    "Latitude" = latitude,
    "Longitude" = longitude
  )
countydatatable$County <- as.character(countydatatable$County)

#selecting only unique county names for table selection
cnty <- as.character(countydata$CNTY) %>%
  unique()
  
  
#vector of differences between indices
diffvect <- (as.vector(c(as.numeric(countydatamap$BIVIOverallScore - countydatamap$SVIOverallScore))))
diffdf <- data.frame(diffdf = diffvect)

#mutating the diffvect onto the spdf data
counties@data <- bind_cols(counties@data, diffdf)

