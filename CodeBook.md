
## common id


Each of the "subject_train.txt", X_train.txt", Y_train.txt" datasets, and their counterparts in the "test" folder, need a common id.

It was decided to use the row number as the common id and name this new column 'observation'.  This would facilitate the merging of the files.

observation <- as.numeric(rownames(strain))
strain <- cbind(observation=observation, strain)

observation <- as.numeric(rownames(xtrain))
xtrain <- cbind(observation=observation, xtrain)

observation <- as.numeric(rownames(ytrain))
ytrain <- cbind(observation=observation, ytrain)

## merge "subject_train.txt", X_train.txt", Y_train.txt" datasets

To merge the three 'training' and 'test' datasets two separate steps were needed:

1. merge the subject and ytrain/test datasets; then
2. merge these new datasets with the xtrain/test datasets

After this step we then have two data sets, train and test, with the ID column called 'observation'.


## bind train and test datasets

The train and test datasets are now ready for binding.

Once bound the new dataset, observation column of the new 'ucihar' dataset is arranged in ascending order.

## rename V1.x and V1.y colnames

Now the renaming of columns can take place.  This step is more efficient now as it only has to be done once:

Using rename column V1.x and V1.y are renamed 'subject' and 'activity' respectively.

## add activity as defined in activity.labels.txt

Now the new 'activity column is filled with descriptive information using dplyr 'mutate' and the activities as defined in the 'activity.labels.txt' file.

## load features as data.frame rto invoke column labeling

Now the 561 columns labelled V1:V561 are ready to be labelled:

1. read the 'featurs.txt. file
2. using dplyr 'mutate' update the observation column with 'V' so that it ties in 'ucihar' dataset above.
3. using dplyr 'mutate' create a 'variables' column based on V2.
4. using dplyr 'select' recreate the 'feature' dataset with two columns, 'observation' and 'variable'


## check that 'features' has 561 distinct variables which can be transmuted into column headings

It is necessary to make sure that 'features' has 561 distinct variable, otherwise it will not merge with the'ucihar'dataset.

Using the dplyr 'distinct' function we determine that there are only 477 distinf features.

## as features only has 477 distinct features, indicating that that 84 columns have the same labels, it is necessary to merge the  observation with the variable.

To solve this problem we use dplyr 'mutate' to creat a new column in feature which merges the observation and variables column, which creates 561 distinct variables.

'features' is now ready for merging with 'ucihar', this is achieved as follows:

colnames(ucihar)[4:564] <- features$variables[1:561]

which results in the columns V1:V561 being renamed with descriptive lables which reflect the task carried out and also retains the information necessary to split out the vectors of means and standard deviations.

## extract measurements for mean and standard deviation only for each measurement

We can now extract from 'ucihar' the vectors with mean and standard deviation using:

ucihar.select <- select(ucihar, matches('observation|subject|activity|mean|std', ignore.case = TRUE))

## calculate average of each variable for each activity and each subject.

We can now calculate the mean for 'ucihar' and 'ucihar.select' datasets using:

for 'ucihar' ----->

ucihar.mean <- mutate(ucihar, mean = rowMeans(ucihar[,4:564]))
ucihar.mean <- select(ucihar.mean, observation, subject, activity, mean)

and for 'ucihar.select' ----->

ucihar.select.mean <- mutate(ucihar.select, mean = rowMeans(ucihar.select[,4:86]))
ucihar.select.mean <- select(ucihar.select.mean, observation, subject, activity, mean)

## print new data tables

print(ucihar) ## merged training and test datasets
print(ucihar.mean) ## the average mean and standard deviation extracted for each measurement
print(ucihar.select.mean) ## average of each variable for each activity and each subject.








