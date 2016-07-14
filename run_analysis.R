## ANALYSIS OBJECTIVES AND DESCRIPTION

## run_analysis.R will do the following:

## 1. merges the training and the test sets to create one data set.
## 2. extracts the measurements on the mean and standard deviation for each measurement.
## 3. apply descriptive activity names to the data set
## 4. labels the data set with descriptive variable names.
## 5. create a second, independent data set with the average of each variable for each activity and each subject.

## clean up and setup work space

rm(list=ls())

library(dplyr)
library(tidyr)

## set working directory

setwd("/Users/Everspring/Dropbox/RWork/UCI_HAR_Assignment/")

## download, allocate and unzip data

if(!file.exists("./Data1")){dir.create("./Data1")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl,destfile="./Data1/Dataset.zip", method = "curl")

unzip(zipfile="./Data1/Dataset.zip",exdir="./Data1")

###### DATASET No. 1 - Parts 1-4 of Question ######

## load training datasets as data.frames

strain <- read.table("./Data1/UCI HAR Dataset/train/subject_train.txt", header = FALSE)
xtrain <- read.table("./Data1/UCI HAR Dataset/train/X_train.txt", header = FALSE)
ytrain <- read.table("./Data1/UCI HAR Dataset/train/Y_train.txt", header = FALSE)

## add common id to each training dataset

observation <- as.numeric(rownames(strain))
strain <- cbind(observation=observation, strain)
observation <- as.numeric(rownames(xtrain))
xtrain <- cbind(observation=observation, xtrain)
observation <- as.numeric(rownames(ytrain))
ytrain <- cbind(observation=observation, ytrain)

## merge s, x, and y train datasets

mergesy <- merge(strain, ytrain, by.x = "observation", by.y = "observation")
train <- merge(mergesy, xtrain, by.x = "observation", by.y = "observation")

## remove surplus data

rm(strain)
rm(xtrain)
rm(ytrain)
rm(mergesy)

## load test datasets as data.frames

stest <- read.table("./Data1/UCI HAR Dataset/test/subject_test.txt", header = FALSE)
xtest <- read.table("./Data1/UCI HAR Dataset/test/X_test.txt", header = FALSE)
ytest <- read.table("./Data1/UCI HAR Dataset/test/Y_test.txt", header = FALSE)

## add common id to each test dataset

obs <- as.numeric(rownames(stest))
stest <- cbind(obs=obs, stest)
stest <- mutate(stest, observation = obs + 7352)
stest <- select(stest, observation, V1)
obs <- as.numeric(rownames(xtest))
xtest <- cbind(obs=obs, xtest)
xtest <- mutate(xtest, observation = obs + 7352)
xtest <- select(xtest, observation, V1:V561)
obs <- as.numeric(rownames(ytest))
ytest <- cbind(obs=obs, ytest)
ytest <- mutate(ytest, observation = obs + 7352)
ytest <- select(ytest, observation, V1)

## merge s, x, and y test datasets

mergesy <- merge(stest, ytest, by.x = "observation", by.y = "observation")
test <- merge(mergesy, xtest, by.x = "observation", by.y = "observation")

## remove surplus data

rm(stest)
rm(xtest)
rm(ytest)
rm(mergesy)

## bind train and test datasets

ucihar <- bind_rows(test, train)
ucihar <- arrange(ucihar, observation)

## remove surplus data

rm(test)
rm(train)

## rename V1.x and V1.y colnames

ucihar <- rename(ucihar, subject = V1.x)
ucihar <- rename(ucihar, activity = V1.y)

## add activity as defined in activity.labels.txt

ucihar <- mutate(ucihar, activity = ifelse(activity == 1, "walking", ifelse(activity == 2, "walking.up", ifelse(activity == 3, "walking.down", ifelse(activity == 4, "sitting", ifelse(activity == 5, "standing", ifelse(activity == 6, "laying", NA)))))))

## load features as data.frame rto invoke column labeling

features <- read.table("./Data1/UCI HAR Dataset/features.txt", header = FALSE)
features <- mutate(features, observation = paste("V", V1, sep = ''))
features <- mutate(features, variables = V2)
features <- select(features, observation, variables)

## check that 'features' has 561 distinct variables which can be transmuted into column headings

check = features %>% distinct(variables)
print(check)

## as features only has 477 distinct features, indicating that that 84 columns have the same labels, it is necessary to merge the  observation with the variable.

features <- mutate(features, variables = paste(observation, variables, sep = '_'))
colnames(ucihar)[4:564] <- features$variables[1:561]

## remove surplus data

rm(features)

## extract measurements for mean and standard deviation only for each measurement

ucihar.select <- select(ucihar, matches('observation|subject|activity|mean|std', ignore.case = TRUE))
ucihar.select <- select(ucihar.select, -contains('freq', ignore.case = TRUE))

## Cleaning up variable names and then reassign the updated namesto the relevant data set

col.names  = colnames(ucihar.select); 

for (i in 1:length(col.names)) 
{
  col.names[i] = gsub("\\()","",col.names[i])
  col.names[i] = gsub("-std"," S.Dev ",col.names[i])
  col.names[i] = gsub("_t"," time ",col.names[i])
  col.names[i] = gsub("_f"," freq ",col.names[i])
  col.names[i] = gsub("-mean"," Mean ",col.names[i])
  col.names[i] = gsub("([Gg]ravity)","Gravity",col.names[i])
  col.names[i] = gsub("[Gg]yro","Gyro",col.names[i])
  col.names[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMag",col.names[i])
  };
  
colnames(ucihar.select) = col.names;

dataset1 = ucihar.select

###### DATASET No. 2 - Part 5 of Question ######

## calculate average of each variable for each activity and each subject.

ucihar.mean <- mutate(ucihar.select, mean = rowMeans(ucihar[,4:564]))
ucihar.mean <- select(ucihar.mean, observation, subject, activity, mean)

count <- c(1:30)
 
for (i in count) {
 	
 	a <- ucihar.mean %>% filter(subject == i) %>% group_by(activity) %>% mutate(mean = mean(mean)) %>% select(subject, activity, mean) %>% distinct(subject) %>% arrange(subject)
 	
 	assign(paste("a", i, sep = ""), a)

}

tidy.dataset <- bind_rows(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30)

write.table(tidy.dataset, "./Data1/tidy.dataset.txt", sep="\t", row.name=FALSE)

rm(count)

