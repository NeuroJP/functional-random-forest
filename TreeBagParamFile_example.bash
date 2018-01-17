#! /bin/bash
##required inputs
group1path=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/MBM_all.mat #path and filename where group1's data is located
group1var=X_CC #the name of the variable within group1's matrix (.mat) file. This should represent a 2D matrix
use_group2_data=true #if set to true, the dataset for the second group will be specified in a separate file, if set to false, the first group's dataset will be randomly split into two groups. Set to false when doing regression
group2path=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/unrelated_MBM.mat #path and filename where group2's data is located
group2var=U_CC #the name of the variable within group2's matrix (.mat) file
fisher_z_transform=false #if set to true, the data will be fisher Z transformed before running the classification algorithm. May be useful when working with correlations as inputs (e.g. from a correlation matrix)
repopath=/group_shares/fnl/bulk/projects/FAIR_users/Feczko/code_in_dev/RFAnalysis #the full path to the repository containing the RFAnalysis code.
matlab_command=matlab #the name of the matlab command line executable, can include arguments additional options, etc. SingleCompThread is enabled by default.

##required outputs and parameters
filename=example_XCCvsUCC #the name of the output matrix (.mat) file
disable_treebag=true #if set to true, the random forests will not be saved. Setting it to false will require a lot of RAM (~20-40 GB).
proxsublimit_num=500 #an upper limit to control the size of the proximity matrices. Set when you are a) only interested in group 1, and b) the number of cases in group 2 is too large to hold in RAM.
outcome_variable=false #if set to true, the program will look for the outcome variable based on the preferences of set by the user
outcome_is_struct=true #if set to true, the input for the outcome variable will be matrix (.mat) files. If set to false, the outcome measure will be acquired from the data files themselves.
group1outcome_path='blah' #path and filename where group1's outcome measure is located
group1outcome_var='blahvar' #the name of the variable that represents group1's outcome in the matrix (.mat) file.
group2outcome_path='blah2' #path and filename where group2's outcome measure is located
group2outcome_var='blah2var' #the name of the variable that represents group2's outcome in the matrix (.mat) file.
group1outcome_num=0 #the column number in group1's data matrix to use as an outcome measure
group2outcome_num=0 #the column number in group2's data matrix to use as an outcome measure

##RF validation procedure options
cross_validate=true #if set to true, will perform cross-validation
    nfolds=10 #the number of folds to run under the cross validation procedure
holdout=false #if set to true, the data will not be split according to datasplit. Instead, a series of subject holdouts will be performed on one of the groups. Useful when trying to perform classification with families.
    holdout_data=/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Long_ADHD_OHSU/families_CC_ix_1_to_23.mat #the matrix which contains the information for what data is held per holdout iteration
    group_holdout=1 #which group (group1 or group2) has the data held?
nreps=3 #the number of iterations to run the random forest algorithm. Useful for calculating confidience intervals for accuracy and testing against the null model
nperms=0 # the number of permutation tests to run if using cross-validation, permutation is done within the runs
use_unsupervised=false #if set to true, RF algorithm will generated unstructured data instead of using group2_data, use this to validate subgroups identified using a supervised approach
group2_validate_only=false #if set to true, and regression is enabled, group2 will be used as an independent validation data set. Use the holdouts group if you want to specify an independent dataset for classification

##randomized holdout parameters (if cross_validate=false, use_unsupervised=false,group2_validate_only=false and holdout=false)
    datasplit=0.9 #the proportion of data to use for training the random forest

##RF hyper-parameter options
ntrees=1000 #the number of trees per random forest iteration; larger numbers will require more RAM and processing time
trim_features=false #if set to true, the number of features will be trimmed according to a KS test for differences between distributions
    nfeatures=0 #the number of features to use when trim_features is turned on
npredictors=false #if set to true, the number of predictors (features) per tree can be specified using num_predictors. Default is 20 features per tree. If unset, the default will be the square root of the total number of features for classification and one third for regression.
    num_predictors=0 #the number of predictors (features) per tree
regression=false # if set to true, the algorithm will model a regression forest for a selected outcome variable. When performing regression, please make sure to set outcome_variable to "true".
uniform_priors=true #if set to true, RF algorithm will assume that the number of cases per class are the same in the population (i.e. 50% of the population is group1 and 50% is group2). If set to false, RF algorithm will estimate this probability from the inputs. Only impacts classification.
matchgroups=false #if set to true, the groups will be matched when performing assessments. Use when uniform_priors still produces a biased model. Please note that the model will be constructed with less data.
surrogate=false #if set to true, missing data will be approximated using Brieman's surrogate split procedure. Simply put, an unsupervised random forest will be modeled to determine the missing data values, a subsequent random forest will then run on the real and surrogate data. WARNING missing data may lead to overfitting. Data values that are truly independent will not aid in classification, unfortunately.

##RF error estimation options
estimate_predictors=false # if set to true, the algorithm will produce out of bag estimates for variable importance and error by the number of trees (outofbag_error)
OOB_error=false #if set to true the out of bag error will be recorded per run, will increase ram and time dramatically

##Legacy options should not be used and are disabled by default
estimate_trees=false #if set to true, the random forest algorithm will attempt to estimate the number of trees to use for classification per iteration using out-of-bag classification accuracy for optimization.
weight_trees=false #if set to true, the random forest algorithm will weight each tree in the random forest by the variance of its within-sample accuracy
estimate_treepred=false # if set to true, the algorithm will estimate the number of predictors per tree

##community detection parameters
lowdensity=0.2 #used for community detection -- the lowest edge density to examine community structure
stepdensity=0.05 #used for community detection -- the increment value for each edge density examined
highdensity=1 #used for community detection -- highest edge density to examine community structure
infomapfile=/group_shares/fnl/bulk/code/external/utilities/infomap/Infomap #the full path and filename for the Infomap executable, must be installed from http://mapequation.org
