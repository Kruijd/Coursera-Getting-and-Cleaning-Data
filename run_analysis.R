######## Getting and Cleaning Data Assignment
# Load DPLYR library and download data neded for the asignment.
# Place the results in the /Data subfolder; create the folder if it is not existing yet.
# install.packages("reshape2")
library(reshape2)
zipurl<-"http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./data")){dir.create("./data")}
download.file(zipurl,"./data/wearable.zip")
unzip("./data/wearable.zip")
# reading general data
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
Feature <- read.table("./UCI HAR Dataset/features.txt")
#reading Train Data
TrainData <- read.table("./UCI HAR Dataset/train/X_train.txt")
TrainActivity <- read.table("./UCI HAR Dataset/train/y_train.txt")
TrainVolunteer <- read.table("./UCI HAR Dataset/train/Subject_train.txt")
# reading test data
TestData <- read.table("./UCI HAR Dataset/test/X_test.txt")
TestActivity <- read.table("./UCI HAR Dataset/test/y_test.txt")
TestVolunteer <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#############results:#########################################
# activity_labels:      6 activity labels
# Feature:             561 features labels
# TrainData             7352 obs. of  561 variables (rows = columns = features)
# TrainActivity         7352 obs. of  1 variable values 1-6 (6 activities)
# TrainVolunteer        7352 obs. of  1 variable values 1-30 (30 volunteers)

# TestData              2947 obs. of  561 variables (measures by feature)
# TestActivity          2947 obs. of  1 variable values 1-6 (activity)
# TestVolunteer         2947 obs. of  1 variable values 2-24 (22 volunteers)
##############################################################
# Assign Colum names to the tables
colnames(activity_labels)<-c("ActivityNumber", "ActivityName")
colnames(Feature)<-c("FeatureNumber", "FeatureName")
colnames(TrainActivity)<-"ActivityNumber"
colnames(TestActivity)<-"ActivityNumber"
colnames(TrainVolunteer)<-"Volunteer"
colnames(TestVolunteer)<-"Volunteer"
# Add activities column and volunteers column to TrainData
Train<- cbind(TrainVolunteer,TrainActivity,TrainData)
# Add activities column and volunteers column to TrainData
Test<-cbind(TestVolunteer,TestActivity,TestData)
#Combine train and test into mergeddata
MergedData <-rbind (Train,Test)
# merge the named for activity and Volunteer with the features and assign as Column names
ColumnNames<-c("Volunteer","Activity",as.vector(Feature$FeatureName))
colnames(MergedData)<-ColumnNames
#### find all features with 'mean' or 'std'in the name and store the result in 
#select feature names with 'mean' or 'std'
meanFeatures <- Feature[grep("mean",Feature$FeatureName),] 
stdFeatures <-Feature[grep("std",Feature$FeatureName),]
#Combine means and std into one data frame and order by FeatureNumber
MeanStdFeatures<-arrange(rbind(meanFeatures,stdFeatures),FeatureNumber)
#select columns from the mergeddata with name in MeanstdFeature
ColumnSelection <-c("Volunteer","Activity",as.vector(MeanStdFeatures$FeatureName))
MeanstdData<-MergedData[,ColumnSelection]
# Replace Activity ID by Activity Name
MeanstdData$Activity <- factor(MeanstdData$Activity, levels = activity_labels [,1], labels = activity_labels [,2])
## Melt the MeltMeanstdData, to a table of Volunteer, Activity and Feature, each with a value
MeltMeanstdData <-melt(MeanstdData,id=c("Volunteer","Activity"))
# Reshape MeltMeanstdData by Volunteer and Activity and Feature (the columns) and take the mean of the value
ResultTidy <- dcast(MeltMeanstdData, Volunteer + Activity ~ variable, mean)
# write the result set to disk in csv format
write.csv(ResultTidy,"ResultTidy.csv" )
