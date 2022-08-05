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
    
    % Model 1: null model
    model_i = 1;
    model(model_i).v = 1; model(model_i).A = 1; model(model_i).b = 1; model(model_i).t0 = 1; model(model_i).sv = 1;
    pArray{model_i} = [0.8 300 150 0.4 200];
    names{model_i} = ['v \t A \t B \t sv \t t0'];    
    
    % Model 2: varying drift rate
    model_i = 2;
    model(model_i).v = 2; model(model_i).A = 1; model(model_i).b = 1; model(model_i).t0 = 1; model(model_i).sv = 1;
    pArray{model_i} = [0.8 0.8 300 150 0.4 200];
    names{model_i} = ['v1 \t v2 \t A \t B \t sv \t t0'];
    
    % Model 3: varying threshold/bound
    model_i = 3;
    model(model_i).v = 1; model(model_i).A = 1; model(model_i).b = 2; model(model_i).t0 = 1; model(model_i).sv = 1;
    pArray{model_i} = [0.8 300 150 150 0.4 200];
    names{model_i} = ['v \t A \t b1 \t b2 \t sv \t t0'];
    
    % Model 4: varying threshold/bound
    model_i = 4;
    model(model_i).v = 1; model(model_i).A = 1; model(model_i).b = 1; model(model_i).t0 = 2; model(model_i).sv = 1;
    pArray{model_i} = [0.8 300 150 0.4 200 200];
    names{model_i} = ['v \t A \t b1 \t sv \t t0_1 \t t0_2'];

    % Model 5: varying all
    model_i = 5;
    model(model_i).v = 2; model(model_i).A = 2; model(model_i).b = 2; model(model_i).t0 = 2; model(model_i).sv = 2;
    pArray{model_i} = [0.8 0.8 300 300 150 150 0.4 0.4 200 200];
    names{model_i} = ['v1 \t v2 \t A1 \t A2 \t b1 \t b2 \t sv1 \t sv2 \t t0_1 \t t0_2'];
    
    
    
    
    
    %% Derive parameters for each model
    clear params LL
    
    n_models = size(model,2);
    
    for model_i = 1:n_models
        [params{model_i}, LL(model_i)] = LBA_mle(data, model(model_i), pArray{model_i});
        [aic(model_i), bic(model_i)] = aicbic(LL(model_i),1,length(data.cond)); 
    end
    
    out_LL(session_i,:) = LL;
    
    % Compare plots of data and model fit
        for model_i = 1:n_models
    
            % Fit models
            Ncond = max(data.cond);
            cor = data.response == data.stim;
            [v A b sv t0] = LBA_parse(model(model_i), params{model_i}, Ncond);
    
            % Plot data and predictions
            LBA_plot(data, params{model_i}, model(model_i));
    
            % Print out parameters
            fprintf('\n\n Model %d parameters: \n\n',model_i);
            fprintf(['\n' names{model_i} '\n\n']);
            fprintf(num2str(params{model_i}));
            fprintf('\n\n Model %d log-likelihood: \n',model_i);
            fprintf(['\n' num2str(LL(model_i)) '\n\n']);
        end
    
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