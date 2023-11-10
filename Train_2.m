clear all;close all;clc
rng(11)
load('audioFeatures.mat')



[y, settings] = mapminmax(data(:,1:end-1)');


y=y';
data(:,1:end-1) = y;
dataSize = size(data, 1);
trainRatio = 0.8; 
testRatio = 0.2; 


indices_0 = find(data(:,end) == 0);
indices_1 = find(data(:,end) == 1);


numTrain_0 = round(length(indices_0) * trainRatio);
numTrain_1 = round(length(indices_1) * trainRatio);


trainIndices_0 = indices_0(randperm(length(indices_0), numTrain_0));
trainIndices_1 = indices_1(randperm(length(indices_1), numTrain_1));

testIndices_0 = setdiff(indices_0, trainIndices_0);
testIndices_1 = setdiff(indices_1, trainIndices_1);


trainIndices = [trainIndices_0; trainIndices_1];
testIndices = [testIndices_0; testIndices_1];


trainData = data(trainIndices,:);
testData = data(testIndices,:);

randomOrderTrain = randperm(size(trainData, 1));
trainData = trainData(randomOrderTrain, :);

randomOrderTest = randperm(size(testData, 1));
testData = testData(randomOrderTest, :);

train_X = trainData(:,1:end-1);
train_Y = trainData(:,end);

test_X = testData(:,1:end-1);
test_Y = testData(:,end);



%%
nTree=500;
RF_model=TreeBagger(nTree,train_X,train_Y,'Method', 'classification');
predictl=predict(RF_model,test_X);
predict_label_1=str2num(cell2mat(predictl));
Forest_accuracy=length(find(predict_label_1 == test_Y))/length(test_Y)*100.0

%%
SVMModel = fitcsvm(train_X, train_Y);
predictedLabels = predict(SVMModel, test_X);
predict_label_2=(predictedLabels);
SVM_accuracy=length(find(predict_label_2 == (test_Y)))/length(test_Y)*100.0  

%% 
AdaboostModel = fitensemble(train_X,train_Y,'AdaBoostM1' ,100,'tree','type','classification');
predictl=predict(AdaboostModel,test_X);
predict_label_3=(predictl);
EB_accuracy=length(find(predict_label_3 == test_Y))/length(test_Y)*100

%% 
train_Y1 = categorical(train_Y);
test_Y = test_Y;
[LR_Model,dev,stats] = mnrfit(train_X,train_Y1);
scores = mnrval(LR_Model, test_X);
[~, index] = max(scores,[],2);
predict_label_4 = index - 1;
LR_accuracy = (sum(test_Y == predict_label_4) / numel(test_Y)) * 100.0

%%

train_Y1 = categorical(train_Y);
train_Y1 = onehotencode(train_Y1,2);
hiddenLayerSize = 20;
net = patternnet([hiddenLayerSize,hiddenLayerSize]);
net.trainFcn = 'traingda';
net.trainparam.epochs = 5000;
net.trainparam.goal = 0.001;
net.trainParam.lr = 0.1;
net.trainParam.max_fail = 500;
[net,tr] = train(net,train_X',train_Y1');
DNNModel = net;
outputs = net(test_X');
outputs = outputs';
[~, index] = max(outputs,[],2);
predict_label_5 = index - 1;

DNN_accuracy = (sum(test_Y == predict_label_5) / numel(test_Y)) * 100.0



%%
KNNModel = ClassificationKNN.fit(train_X,train_Y,'NumNeighbors',100);
predict_label_6 = predict(KNNModel, test_X);
accuracy_KNN = length(find(predict_label_6 == test_Y))/length(test_Y)*100
%%
nbModel = fitcnb(train_X, train_Y);
predict_label_7 = predict(nbModel, test_X);
accuracy_NaiveBayes = length(find(predict_label_7 == test_Y))/length(test_Y)*100
%%
predict_label = [predict_label_1 predict_label_2 predict_label_3 predict_label_4 predict_label_5 predict_label_6 predict_label_7];
mostFrequent = mode(predict_label,2);


save model.mat RF_model SVMModel AdaboostModel LR_Model DNNModel KNNModel nbModel settings



% 
All_accuracy = (sum(test_Y == mostFrequent) / numel(test_Y)) * 100.0