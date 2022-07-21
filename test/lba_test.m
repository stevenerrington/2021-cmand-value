close all; clear all; clc; warning off;
getColor_value;
getDirs_value;

warning off
dajo_metadata = load(fullfile(dirs.procData,'2021dajo_metadata.mat')); % 2021 dataset metadata
eux_metadata = load(fullfile(dirs.procData,'2012eux_data.mat'));
load(fullfile(dirs.procData,'valuedata_curated.mat'));

for session_i = 1:size(valuedata_master,1)
    
    %% Update user
    fprintf(['Running model comparison for session %i of %i | ' valuedata_master.session{session_i} ' \n'],session_i,size(valuedata_master,1))
    %% Setup data
    % Input RT from master table
    clear lo_rt hi_rt
    lo_rt = valuedata_master.valueRTdist(session_i).lo.nostop(:,1);
    hi_rt = valuedata_master.valueRTdist(session_i).hi.nostop(:,1);
    
    % Configure data for use with the LBA analysis
    clear data
    data.cond = [repmat(1,length(lo_rt),1);repmat(2,length(hi_rt),1)];
    data.correct = ones(length(data.cond),1);
    data.rt = [lo_rt;hi_rt];
    data.stim = ones(length(data.cond),1);
    data.response = ones(length(data.cond),1);
    
    %% Setup models (see help LBA_mle)
    clear model pArray names
    
    % Model 1: varying drift rate
    model(1).v = 2; model(1).A = 1; model(1).b = 1; model(1).t0 = 1; model(1).sv = 1;
    pArray{1} = [0.8 0.8 300 150 0.4 200];
    names{1} = ['v1 \t v2 \t A \t B \t sv \t t0'];
    
    % Model 2: varying threshold/bound
    model(2).v = 1; model(2).A = 1; model(2).b = 2; model(2).t0 = 1; model(2).sv = 1;
    pArray{2} = [0.8 300 150 150 0.4 200];
    names{2} = ['v \t A \t b1 \t b2 \t sv \t t0'];
    
    % Model 2: varying threshold/bound
    model(3).v = 1; model(3).A = 1; model(3).b = 1; model(3).t0 = 2; model(3).sv = 1;
    pArray{3} = [0.8 300 150 0.4 200 200];
    names{3} = ['v \t A \t b1 \t sv \t t0_1 \t t0_2'];
    
    %% Derive parameters for each model
    clear params LL
    
    n_models = size(model,2);
    
    for model_i = 1:n_models
        [params{model_i} LL(model_i)] = LBA_mle(data, model(model_i), pArray{model_i});
    end
    
    out_LL(session_i,:) = LL;
    
    %% Compare plots of data and model fit
    %     for model_i = 1:n_models
    %
    %         % Fit models
    %         Ncond = max(data.cond);
    %         cor = data.response == data.stim;
    %         [v A b sv t0] = LBA_parse(model(model_i), params{model_i}, Ncond);
    %
    %         % Plot data and predictions
    %         LBA_plot(data, params{model_i}, model(model_i));
    %
    %         % Print out parameters
    %         fprintf('\n\n Model %d parameters: \n\n',model_i);
    %         fprintf(['\n' names{model_i} '\n\n']);
    %         fprintf(num2str(params{model_i}));
    %         fprintf('\n\n Model %d log-likelihood: \n',model_i);
    %         fprintf(['\n' num2str(LL(model_i)) '\n\n']);
    %     end
    %
end



%% Plot

clear MLE_model
plotData=...
    [out_LL(:,1);out_LL(:,2);out_LL(:,3)];

labelData=...
    [repmat({'Model 1'},length(out_LL),1);...
    repmat({'Model 2'},length(out_LL),1);...
    repmat({'Model 3'},length(out_LL),1)];


MLE_model= gramm('x',labelData,...
    'y',plotData,'color',labelData);
MLE_model(1,1).stat_summary('type','sem','geom',{'point','errorbar'});
% MLE_model(1,1).geom_jitter('alpha',1);
MLE_model(1,1).no_legend;
MLE_model.axe_property('YLim',[-5400 -4600]);

MLE_model.draw();