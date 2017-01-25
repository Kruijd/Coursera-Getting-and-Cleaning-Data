Code Book

This document explains the code inside run_analysis.R.

the main sections are:
0. Preparation
1. Download the data
2. Prepare the data
3: select the required features
4: create a tidy result set
5: write the result set to disk in csv format

1. Download the data
after the zip file is downloaded, extracted and loaded these are the result sets:

activity_labels:      6 activity labels
Feature             561 features labels
TrainData             7352 obs. of  561 variables columns = features)
TrainActivity         7352 obs. of  1 variable values 1-6 (6 activities)
TrainVolunteer        7352 obs. of  1 variable values 1-30 (30 volunteers)
TestData              2947 obs. of  561 variables (measures by feature)
TestActivity          2947 obs. of  1 variable values 1-6 (activity)
TestVolunteer         2947 obs. of  1 variable values 2-24 (22 volunteers)

2. Prepare the data
In this section the column names are assigned.
for TrainData and TestData these are found in 'Feature'
TrainData and testData are combined with Rbind into MergedData.
MergedData now contains the combined data from trainind and test exercises.
Finally the Column names are assigned. Since the activity and the Volunteer are two additional columns in Mergeddata, 
both names are added to the list of FeatureNames:
    ColumnNames<-c("Volunteer","Activity",as.vector(Feature$FeatureName))
    colnames(MergedData)<-ColumnNames

str(MergedData)
'data.frame':	10299 obs. of  563 variables:
 $ Volunteer                           : int  1 1 1 1 1 1 1 1 1 1 ...
 $ Activity                            : int  5 5 5 5 5 5 5 5 5 5 ...
 $ tBodyAcc-mean()-X                   : num  0.289 0.278 0.28 0.279 0.277 ...
 $ tBodyAcc-mean()-Y                   : num  -0.0203 -0.0164 -0.0...............


3. select the required features
the fratures with 'mean'or 'std in it's name have to be selected.
The  geep command is used for this:
      meanFeatures <- Feature[grep("mean",Feature$FeatureName),] 
      stdFeatures <-Feature[grep("std",Feature$FeatureName),]
 Allthough 'Mean' with capital 'M' is also found in the features, this was not considered as neededin the selection 
 because it repersented a name in stead of the function that was aimend.
 Both features are combined into one set and sorted by FeatureNumber.
        str(MeanStdFeatures):
        data.frame':	79 obs. of  2 variables:
        $ FeatureNumber: int  1 2 3 4 5 6 41 42 43 44 ...
        $ FeatureName  : Factor w/ 477 levels "angle(tBod....

Now the Columns have to be selected in the MergedData file that are part of MeanStdFeatures.
"Volunteer" and "Activity" should be selected too, to not loose them.
ColumnSelection <-c("Volunteer","Activity",as.vector(MeanStdFeatures$FeatureName))
    MeanstdData<-MergedData[,ColumnSelection]
    
Finally the Activity has to be replaced by the description as found in the 'activity_labels' data frame.
    MeanstdData$Activity <- factor(MeanstdData$Activity, levels = activity_labels [,1], labels = activity_labels [,2])
 The result set is now limited from initially 563 columns to 81 columns.
 
 str(MeanstdData)
'data.frame':	10299 obs. of  81 variables:

4: create a tidy result set
First step is to 'melt' the data by "Volunteer","Activity" and store it into MeltMeanstdData .
        MeltMeanstdData <-melt(MeanstdData,id=c("Volunteer","Activity"))
 
 str(MeltMeanstdData)
  data.frame':	813621 obs. of  4 variables:
 $ Volunteer: int  1 1 1 1 1 1 1 1 1 1 ...
 $ Activity : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 5 5 5 5 5 5 5 5 5 5 ...
 $ variable : Factor w/ 79 levels "tBodyAcc-mean()-X",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ value    : num  0.289 0.278 0.28 0.279 0.277 ...
    
 Next the data is reshaped.
 For each volunteer, and each activity, the # Reshape MeltMeanstdData by Volunteer and Activity 
 and Feature (the columns) and take the mean of the value.
 
ResultTidy <- dcast(MeltMeanstdData, Volunteer + Activity ~ variable, mean)

The result will be a data frame, again with 81 columns, but the amount of rows is now reduced to 180. 
Each value is nor aggregated to a mean value.
        str(ResultTidy)
        'data.frame':	180 obs. of  81 variables:
        $ Volunteer                      : int  1 1 1 1 1 1 2 2 2 2 ...
        $ Activity                       : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 1 2 3 4 5 6 1 2 3 4 ...
        $ tBodyAcc-mean()-X              : num  0.277 0.255 0.289 0.261 
        .................
        
5: write the result set to disk in csv format
In the last step the results arestored on disk.
The choice is made to store it in csv format.

write.csv(ResultTidy,"ResultTidy.csv" ) 
 
