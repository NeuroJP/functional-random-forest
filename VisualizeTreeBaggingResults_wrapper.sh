#! /bin/bash
#VisualizeTreeBaggingResults_wrapper.sh requires a ParamFile as an input (e.g. VisualizeTreeBaggingResults_wrapper.sh VisualizeTreeBagResults_example.bash). See the VisualizeTreeBagResults_example.bash for more information on available parameters.
source $1
#parameters set from the VisualizeTreeBagResultsParamFile
if $use_group2_data; then group2_data="struct('path','"${group2path}"','variable','"${group2var}"')"; else group2_data=0; fi
if $regression; then regression='Regression'; else regression='classification'; fi
#If missing parameters, set defaults
filename=${filename:-'thenamelessone'}
regression=${regression:-'Classification'}
infomap_command_file=${infomap_command_file:-'/group_shares/PSYCH/code/release/utilities/simple_infomap/simple_infomap.py'}
#Construct the model, which will save outputs to a filename.mat file
matlab14b -nodisplay -nosplash -singleCompThread -r "addpath('/group_shares/FAIR_LAB2/Projects/FAIR_users/Feczko/projects/Analysis') ; VisualizeTreeBaggingResults('"$results_matfile"','"$filename"','"$regression"',struct('path','"${group1path}"','variable','"${group1var}"'),"$group2_data",'"$infomap_command_file"'); exit"
