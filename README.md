## clean up and setup work space

rm(list=ls())

library(dplyr)
library(tidyr)

## set working directory

setwd("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/")

## download, allocate and unzip data

if(!file.exists("./Data1")){dir.create("./Data1")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl,destfile="./Data1/Dataset.zip", method = "curl")

unzip(zipfile="./Data/Dataset.zip",exdir="./Data1")

## load training datasets as data.frames

strain <- read.table("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/train/subject_train.txt", header = FALSE)
xtrain <- read.table("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/train/X_train.txt", header = FALSE)
ytrain <- read.table("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/train/Y_train.txt", header = FALSE)

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

stest <- read.table("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/test/subject_test.txt", header = FALSE)
xtest <- read.table("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/test/X_test.txt", header = FALSE)
ytest <- read.table("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/test/Y_test.txt", header = FALSE)

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

features <- read.table("/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/features.txt", header = FALSE)
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

## calculate average of each variable for each activity and each subject.

ucihar.mean <- mutate(ucihar, mean = rowMeans(ucihar[,4:564]))
ucihar.mean <- select(ucihar.mean, observation, subject, activity, mean)

ucihar.select.mean <- mutate(ucihar.select, mean = rowMeans(ucihar.select[,4:86]))
ucihar.select.mean <- select(ucihar.select.mean, observation, subject, activity, mean)

## print new data tables

print(ucihar) ## merged training and test datasets
print(ucihar.mean) ## the average mean and standard deviation extracted for each measurement
print(ucihar.select.mean) ## average of each variable for each activity and each subject.

write.table(ucihar.select.mean, "/Users/Everspring/Dropbox/RWork/UCI_HAR_Dataset/tidy.dataset.txt", sep="\t", row.name=FALSE)






