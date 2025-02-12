%% Split data into training and testing sets
all = readtable('all_data.csv'); % all data
ratio = 0.2; % fraction of data used for validation
data_size = size(all);
num_val = round(ratio*data_size(1), 0);
i_val = randsample(data_size(1), num_val);
testing = all(i_val, :);
training = setdiff(all, testing);

% If want to save/read data
writetable(testing, 'testing.csv');
writetable(training, 'training.csv');

training = readtable('training.csv');
testing = readtable('testing.csv');

%% Fit regression models
Xtrain = [training.Q_inf, training.Q_air_1, training.Q_air_2, training.Q_air_3, training.Q_air_4, training.Q_air_5, training.Temp];
Ytrain = training.NH4; % can also select DO_1, DO_2, DO_3, or NO3

% Regression models in MATLAB: https://www.mathworks.com/discovery/machine-learning-models.html
f_lm = @() fitlm(Xtrain,Ytrain); % linear regression
t_lm = timeit(f_lm);
mdl_lm = f_lm();

f_glm = @() fitglm(Xtrain,Ytrain); % generalized linear regression
t_glm = timeit(f_glm);
mdl_glm = f_glm();

f_gpr = @() fitrgp(Xtrain,Ytrain); % Gaussian process regression
t_gpr = timeit(f_gpr);
mdl_gpr = f_gpr();

f_svm = @() fitrsvm(Xtrain,Ytrain); % support vector machine
t_svm = timeit(f_svm);
mdl_svm = f_svm();

f_tree = @() fitrtree(Xtrain,Ytrain); % decision tree
t_tree = timeit(f_tree);
mdl_tree = f_tree();

f_ensemble = @() fitrensemble(Xtrain,Ytrain); % ensemble of learners
t_ensemble = timeit(f_ensemble);
mdl_ensemble = f_ensemble();

f_gam = @() fitrgam(Xtrain,Ytrain); % generalized additive model
t_gam = timeit(f_gam);
mdl_gam = f_gam();

%% Test regression models
Xtest = [testing.Q_inf, testing.Q_air_1, testing.Q_air_2, testing.Q_air_3, testing.Q_air_4, testing.Q_air_5, testing.Temp];
Ytest = testing.NH4;

pred_lm = predict(mdl_lm, Xtest);
pred_glm = predict(mdl_glm, Xtest);
pred_gpr = predict(mdl_gpr, Xtest);
pred_svm = predict(mdl_svm, Xtest);
pred_tree = predict(mdl_tree, Xtest);
pred_ensemble = predict(mdl_ensemble, Xtest);
pred_gam = predict(mdl_gam, Xtest);

RMSElm = rmse(Ytest, pred_lm);
RMSEglm = rmse(Ytest, pred_glm);
RMSEgpr = rmse(Ytest, pred_gpr);
RMSEsvm = rmse(Ytest, pred_svm);
RMSEtree = rmse(Ytest, pred_tree);
RMSEensemble = rmse(Ytest, pred_ensemble);
RMSEgam = rmse(Ytest, pred_gam);

%% Print results

fprintf('Results \n');
fprintf('------- \n');

fprintf('Linear regression: \n');
fprintf('RMSE: %.4f \n', RMSElm);
fprintf('Time: %.4f \n \n', t_lm);

fprintf('Generalized linear regression: \n');
fprintf('RMSE: %.4f \n', RMSEglm);
fprintf('Time: %.4f \n \n', t_glm);

fprintf('Gaussian process regression: \n');
fprintf('RMSE: %.4f \n', RMSEgpr);
fprintf('Time: %.4f \n \n', t_gpr);

fprintf('Support vector machine: \n');
fprintf('RMSE: %.4f \n', RMSEsvm);
fprintf('Time: %.4f \n \n', t_svm);

fprintf('Decision tree: \n');
fprintf('RMSE: %.4f \n', RMSEtree);
fprintf('Time: %.4f \n \n', t_tree);

fprintf('Emsemble of learners: \n');
fprintf('RMSE: %.4f \n', RMSEensemble);
fprintf('Time: %.4f \n \n', t_ensemble);

fprintf('Generalized additive model: \n');
fprintf('RMSE: %.4f \n', RMSEgam);
fprintf('Time: %.4f \n \n', t_gam);