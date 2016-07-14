#The OBJECTIVE is to create an independent tidy data set with:
# the average of each variable
# for each activity and 
# each subject.



## PART 1: DATASET No. 1 - Parts 1-4 of Question

### common id


Each of the "subject_train.txt", X_train.txt", Y_train.txt" datasets, and their counterparts in the "test" folder, need a common id.

It was decided to use the row number as the common id and name this new column 'observation'.  This would facilitate the merging of the files.

observation <- as.numeric(rownames(strain))
strain <- cbind(observation=observation, strain)

observation <- as.numeric(rownames(xtrain))
xtrain <- cbind(observation=observation, xtrain)

observation <- as.numeric(rownames(ytrain))
ytrain <- cbind(observation=observation, ytrain)

NOTE: that the "test" dataset id needed to be increased by 7352 so that the datasets could be merged.

### merge "subject_train.txt", X_train.txt", Y_train.txt" datasets

To merge the three 'training' and 'test' datasets two separate steps were needed:

1. merge the subject and ytrain/test datasets; then
2. merge these new datasets with the xtrain/test datasets

After this step we then have two data sets, train and test, with the ID column called 'observation'.


### bind train and test datasets

The train and test datasets are now ready for binding.

Once bound the new dataset, observation column of the new 'ucihar' dataset is arranged in ascending order.

### rename V1.x and V1.y colnames

Now the renaming of columns can take place.  This step is more efficient now as it only has to be done once:

Using rename column V1.x and V1.y are renamed 'subject' and 'activity' respectively.

### add activity as defined in activity.labels.txt

Now the new 'activity column is filled with descriptive information using dplyr 'mutate' and the activities as defined in the 'activity.labels.txt' file.

### load features as data.frame rto invoke column labeling

Now the 561 columns labelled V1:V561 are ready to be labelled:

1. read the 'featurs.txt. file
2. using dplyr 'mutate' update the observation column with 'V' so that it ties in 'ucihar' dataset above.
3. using dplyr 'mutate' create a 'variables' column based on V2.
4. using dplyr 'select' recreate the 'feature' dataset with two columns, 'observation' and 'variable'


### check that 'features' has 561 distinct variables which can be transmuted into column headings

It is necessary to make sure that 'features' has 561 distinct variable, otherwise it will not merge with the'ucihar'dataset.

Using the dplyr 'distinct' function we determine that there are only 477 distinf features.

### as features only has 477 distinct features, indicating that that 84 columns have the same labels, it is necessary to merge the  observation with the variable.

To solve this problem we use dplyr 'mutate' to creat a new column in feature which merges the observation and variables column, which creates 561 distinct variables.

'features' is now ready for merging with 'ucihar', this is achieved as follows:

colnames(ucihar)[4:564] <- features$variables[1:561]

which results in the columns V1:V561 being renamed with descriptive lables which reflect the task carried out and also retains the information necessary to split out the vectors of means and standard deviations.

### extract measurements for mean and standard deviation only for each measurement

We can now extract from 'ucihar' the vectors with mean and standard deviation using:

ucihar.select <- select(ucihar, matches('observation|subject|activity|mean|std', ignore.case = TRUE))

### Cleaning up variable names and then reassign the updated namesto the relevant data set

Using "gsub" the original column names of the "train" and "test" were adjusted so that they could be read easily.

This was achieved using a for loop.


## PART 2: DATASET No. 2 - Parts 5 of Question


### calculate average of each variable for each activity and each subject.

We can now calculate the mean for 'ucihar' and 'ucihar.select' datasets using:

for 'ucihar' ----->

ucihar.mean <- mutate(ucihar, mean = rowMeans(ucihar[,4:564]))
ucihar.mean <- select(ucihar.mean, observation, subject, activity, mean)

### for loop is used to extract each the mean for each activity for each subject

This is achieved using for loop and a count of 30 iterations, 1 for each subject.  

The objective is to extract the mean for each activity undertaken by each subject, each activity being "laying", sitting", "standing", "walking"	, "walking.down", and "walking.up"

THIS IS THE ESSENCE OF QUESTION 5 AND FORMS THE BASIS OF THE "tidy.dataset.txt"

### bind and write table.

Once completed the 30 individual data.tables are bound using "bind.rows".

The ""tidy.dataset.txt" file is then written.









