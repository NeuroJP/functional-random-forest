function [accuracy,treebag,outofbag_error] = TestTreeBags(learning_groups, learning_data, testing_groups, testing_data,ntrees,type,treebag,treeweights,categorical_vector,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if exist('type','var') == 0
    type = 'validationPlusOOB';
end
if exist('treeweights','var') == 0
    treeweights = 0;
end
if exist('treebag','var') == 0
    treebag = 0;
end
numpredictors = 0;
surrogate = 'off';
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        switch(varargin{i})
            case('npredictors')
                numpredictors = varargin{i+1};
            case('Surrogate')
                surrogate = varargin{i+1};
        end
    end
end
if numpredictors == 0
    numpredictors = round(sqrt(size(learning_data,2)));
end
switch(type)
    case('estimate_trees')
        initial_trees = 50; %%change if you want to examine smaller numbers, generally at least 50 trees will be needed for most weak classifiers
        tree_step = 10; %%change if you want to examine finer numbers -- lower numbers will slow the function
        treebag = TreeBagger(initial_trees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate);
        optimize = 0;
        outofbag_error_first = oobError(treebag);
        outofbag_error_first = outofbag_error_first(end);
        final_trees = initial_trees + tree_step;
        while final_trees <= ntrees && optimize == 0
            treebag = growTrees(treebag,tree_step);
            outofbag_error_second = oobError(treebag);
            outofbag_error_second = outofbag_error_second(end);
            if abs(outofbag_error_second - outofbag_error_first) < 0.001
                optimize = 1;
                accuracy = final_trees - tree_step;
            else
                final_trees = final_trees + tree_step;
                outofbag_error_first = outofbag_error_second;
            end
        end
        if optimize == 0
            accuracy = ntrees;
            sprintf('%s',strcat('Optimization algorithm exceeded tree limit. Number of trees: #',num2str(accuracy)))
        else
            sprintf('%s',strcat('Optimization found! Number of trees: #',num2str(accuracy))) 
        end
    case('weight_trees')
        treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate);
        accuracy = zeros(ntrees,1);
        for i = 1:ntrees
            prediction_classes = str2num(cell2mat(predict(treebag,treebag.X,'Trees',i)));
            accurate_classes = learning_groups == prediction_classes;
            accuracy(i,1) = var(fitdist(double(accurate_classes),'Binomial'));
        end
    case('validation')
        ngroups = size(unique(testing_groups),1);
        treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','off','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate);
        outofbag_error = NaN;
        if strcmp(varargin{1},'regression')
            predicted_classes = predict(treebag,testing_data);
            accuracy = zeros(3,1);
            predicted_classes_new = zeros(max(max(size(predicted_classes))),1);
            for blah = 1:max(max(size(predicted_classes)))
                predicted_classes_new(blah) = str2num(predicted_classes{blah});
            end
            accuracy_prediction = abs(predicted_classes_new.' - testing_groups);
            accuracy(1,1) = mean(accuracy_prediction);
            accuracy(2,1) = corr(predicted_classes_new.',testing_groups);
            N = max(max(size(testing_groups)));
            mean_all = (accuracy(1,1)+mean(testing_groups))/2;
            for i = 1:N
                nx1=nx1+(testing_groups(i) - mean_all)^2;
                nx2=nx2+(predicted_classes_new(i) - mean_all)^2;
                nxpooled = nxpooled + ((predicted_classes_new(i) - mean_all)*(testing_groups(i) - mean_all));
            end
            s_squared = (nx1+nx2)/((2*N)-1);
            accuracy(3,1) = nxpooled/(N*s_squared);
        else
            predicted_classes = str2num(cell2mat(predict(treebag,testing_data)));
            accuracy_prediction = predicted_classes == testing_groups;
            accuracy = zeros(ngroups+1,1);
            accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
            for n = 1:ngroups
                accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
            end
        end
    case('validation_weighted')
        ngroups = size(unique(testing_groups),1);
        outofbag_error = NaN;
        predicted_classes = str2num(cell2mat(predict(treebag,testing_data,'TreeWeights',treeweights)));
        accuracy_prediction = predicted_classes == testing_groups;
        accuracy = zeros(ngroups+1,1);
        accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
        for n = 1:ngroups
            accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
        end
    case('validationPlusOOB')
        ngroups = size(unique(testing_groups),1);
        treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',numpredictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate);
        outofbag_error = oobError(treebag);
        if strcmp(varargin{1},'regression')
            predicted_classes = predict(treebag,testing_data);
            accuracy = zeros(3,1);
            predicted_classes_new = zeros(max(max(size(predicted_classes))),1);
            for blah = 1:max(max(size(predicted_classes)))
                predicted_classes_new(blah) = str2num(predicted_classes{blah});
            end
            accuracy_prediction = abs(predicted_classes_new.' - testing_groups);
            accuracy(1,1) = mean(accuracy_prediction);
            accuracy(2,1) = corr(predicted_class_new,testing_groups);
            N = max(max(size(testing_groups)));
            mean_all = (accuracy(1,1)+mean(testing_groups))/2;
            for i = 1:N
                nx1=nx1+(testing_groups(i) - mean_all)^2;
                nx2=nx2+(predicted_classes_new(i) - mean_all)^2;
                nxpooled = nxpooled + ((predicted_classes_new(i) - mean_all)*(testing_groups(i) - mean_all));
            end
            s_squared = (nx1+nx2)/((2*N)-1);
            accuracy(3,1) = nxpooled/(N*s_squared);
        else
            predicted_classes = str2num(cell2mat(predict(treebag,testing_data)));
            accuracy_prediction = predicted_classes == testing_groups;
            accuracy = zeros(ngroups+1,1);
            accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
            for n = 1:ngroups
                accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
            end
        end
    case('validationPlusOOB_weighted')
        ngroups = size(unique(testing_groups),1);
        predicted_classes = str2num(cell2mat(predict(treebag,testing_data,'TreeWeights',treeweights,'Surrogate',surrogate)));
        accuracy_prediction = predicted_classes == testing_groups;
        accuracy = zeros(ngroups+1,1);
        accuracy(1,1) = size(find(accuracy_prediction == 1),1)/size(testing_groups,1);
        for n = 1:ngroups
            accuracy(n+1,1) = size(find(accuracy_prediction(testing_groups == n-1) == 1),1)/size(find(testing_groups == n-1),1);
        end
    case('EstimatePredictorsToSample')
        initial_predictors = numpredictors; %%change if you want to examine smaller numbers, can be used as an input to the function itself
        predictor_step = 20; %%change if you want to examine finer numbers -- lower numbers will slow the function
        limit_nodice = 5;
        treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',initial_predictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate);
        nvars = size(learning_data,2);
        outofbag_error_first = oobError(treebag);
        outofbag_error_first = outofbag_error_first(end);
        optimal_predictors = numpredictors;
        optimal_prediction = outofbag_error_first;
        final_predictors = initial_predictors + predictor_step;
        count = 0;
        while final_predictors <= nvars && count < limit_nodice
            treebag = TreeBagger(ntrees,learning_data,learning_groups,'OOBVarImp','off','OOBPred','on','NVarToSample',final_predictors,'CategoricalPredictors',categorical_vector,'Surrogate',surrogate);
            outofbag_error_second = oobError(treebag);
            outofbag_error_second = outofbag_error_second(end);
            if outofbag_error_second < optimal_prediction
                sprintf('%s',strcat('Accuracy improved by: %',num2str(100*(optimal_prediction - outofbag_error_second))))
                sprintf('%s',strcat('Accuracy is now : %',num2str(100*(1 - outofbag_error_second))))
                optimal_prediction = outofbag_error_second;
                optimal_predictors = final_predictors;
                sprintf('%s',strcat('Number of predictors is: #',num2str(optimal_predictors)))
                count = 0;
            end
            final_predictors = final_predictors + predictor_step;
            count = count + 1;
        end
        accuracy = optimal_predictors;
        sprintf('%s',strcat('Optimization found! Number of predictors: #',num2str(accuracy))) 
end
end

