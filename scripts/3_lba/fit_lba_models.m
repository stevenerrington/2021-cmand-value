
%% Setup workspace
% Clear workspace and console.
close all; clear all; clc; warning off;

% Define data directories
getDirs_value;
dajo_metadata = load(fullfile(dirs.procData,'2021dajo_metadata.mat')); % 2021 dataset metadata
eux_metadata = load(fullfile(dirs.procData,'2012eux_data.mat'));

% Load in pre-processed data
load(fullfile(dirs.procData,'valuedata_curated.mat'));

% Define global model parameters
nModel_iter = 10; % Number of times to run model fit
nSim_iter = 2000; % Number of trials in simulation of model fit parameters
getColor_value

% Set seed for (hopeful) reproducability
rng(1) 

%% Setup data
session_i = 10;
fprintf(['Running model comparison for session %i of %i | ' valuedata_master.session{session_i} ' \n'],session_i,size(valuedata_master,1))

% Input RT from master table and configure data for use with the LBA analysis
clear model_input

% Define RT values for high and low value contexts
model_input.rt_obs.lo = valuedata_master.valueRTdist(session_i).lo.nostop(:,1);
model_input.rt_obs.hi = valuedata_master.valueRTdist(session_i).hi.nostop(:,1);
% Concatenate them into one array
model_input.data.rt = [model_input.rt_obs.lo;model_input.rt_obs.hi];
% Give labels for low and high context, respectively
model_input.data.cond = [ones(length(model_input.rt_obs.lo),1);ones(length(model_input.rt_obs.hi),1)*2];
% ...and provide other labels, irrelevant to this study.
model_input.data.correct = ones(length(model_input.data.cond),1);
model_input.data.stim = ones(length(model_input.data.cond),1);
model_input.data.response = ones(length(model_input.data.cond),1);

%% Setup models (see help LBA_mle)

%{
###############################################################
LBA parameter defintions
    v: Drift rate
    A: Start point (upper end)
    b: Response threshold
    t0: Non-decision time
    sv: Standard deviation of drift rate samples

###############################################################
*** Model combinations

1) Null model: all factors fixed
2) Threshold model: all but threshold fixed
3) Rate model: all but rate fixed
4) Onset model: all but onset fixed
5) Start model: all but start point fixed
7) Rate SD model: all but standard deviation of the drift rate fixed

As of today (2022-08-05, 12h54) I am just playing about to get one model to
work, and then I will adjust accordingly.
###############################################################
*** Info
Parameters must be inputted into LBA scripts in the following order:
[v, A, b, t0, sv]. If allowing the parameter to vary between conditions,
then an  additional parameter is added to this array. For example, allowing
drift rate to vary would result in the following array: [v, v, A, b, t0, sv]

###############################################################
%}

% Create a clean environment for defining the model
clear model model_in init_params param_def

% Define the default parameters
param_def.v(1) = 0.6; param_def.v(2) = 0.8;
param_def.A(1) = 40; param_def.A(2) = 40;
param_def.b(1) = 300; param_def.b(2) = 200;
param_def.t0(1) = 100; param_def.t0(2) = 100;
param_def.sv(1) = 0.2; param_def.sv(2) = 0.2;

% Define the model to run
% Model 1 (Null model - all but drift rate variance) %%%%%%%%%%%%%%%%%%%%%

model_i = 1; model_label = 'null';
model(model_i).v = 2; 
model(model_i).A = 2; 
model(model_i).b = 2; 
model(model_i).t0 = 2; 
model(model_i).sv = 1;

% Place all model parameters into a cell array for future calls.
param_labels = {'v','A','b','t0','sv'};
init_params{model_i} = [];

for param_i = 1:length(param_labels)
    for nparam_i = 1:model(model_i).(param_labels{param_i})
        model_in.(param_labels{param_i})(nparam_i) = param_def.(param_labels{param_i})(nparam_i);
    end
    
    init_params{model_i} = [init_params{model_i}, model_in.(param_labels{param_i})];
end


%% Run model
% Model 1: null model
model_i = 1; 

% Create a clean environment for running the model
clear params logLikelihood model_standard_params param_rand_start

% Run each model 20 times, each with a different starting point. With this,
% it allows for reliability - we start the optimization in different spots
% based within 5 x +/- the defined starting parameters.
for model_iter_i = 1:nModel_iter
    fprintf(['Running model iteration %i of %i | \n'],model_iter_i,nModel_iter)
    
    % Get the initial defined parameters (as done above)
    model_standard_params = init_params{model_i};

        % For each parameter
    for param_i = 1:length(model_standard_params)
        clear lower_bound upper_bound
        % Define a boundary - starting point must be with 20% of
        % the defined boundary set above.
        scale = 0.1;
        lower_bound =  model_standard_params(param_i) .* (1-scale);
        upper_bound =  model_standard_params(param_i) .* (1+scale);
        
        % We then choose a random point between these two bounds as our
        % start point.
        param_rand_start(model_iter_i,param_i) =...
            lower_bound + (upper_bound-lower_bound) .* rand(1,1);        
    end

    % We then run the optimization script, getting the fit parameters
    % (params) and log Likelihood (logLikelihood) for the current iteration.
    [params(model_iter_i,:), logLikelihood(model_iter_i,:)] =....
        LBA_mle(model_input.data, model(model_i), param_rand_start(model_iter_i,:));
end




%% Simulated data based on model parameters
%{
Once we have these fitted parameters, we can then simulate data using a
LBA. Once we have the simulated data, we can then compare this to the
observed data to make sure it looks correct.
%}

figure('Renderer', 'painters', 'Position', [100 100 1500 300]);

% For each iteration of the model that we run
for model_iter_i = 1:nModel_iter
    
    % Get the extracted parameters
    clear v A b sv t0
    [v, A, b, sv, t0] = LBA_parse(model(model_i), params(model_iter_i,:), 2);
    
    % Then use these parameters in a simulation to get trial by trial RT's
    % for low (column 1) and high (column 2) reward contexts
    clear  model_sim
    for trl_iter_i = 1:nSim_iter
        model_sim.sim_RT(trl_iter_i,:) = LBA_trial_RT(A, b, v, t0, sv, 2);
    end
    
    % Once we've extracted these RT's, we can then work out the CDF for
    % each condition, for observed and simulated data
    clear cdf_plot
    cdf_plot.lo.obs = cumulDist(model_input.rt_obs.lo); % Low, observed
    cdf_plot.lo.sim = cumulDist(model_sim.sim_RT(:,1)); % Low, simulated
    cdf_plot.hi.obs = cumulDist(model_input.rt_obs.hi); % High, observed
    cdf_plot.hi.sim = cumulDist(model_sim.sim_RT(:,2)); % High, simulated
    
    % For each iteration, we generate a figure, and plot the CDF.
    % In these figures, dashed lines are the simulated data and thicker
    % solid lines are the observed. Blue represents low value context,
    % magenta represents high value context.
    subplot(2,nModel_iter,model_iter_i); hold on
    plot(cdf_plot.lo.obs(:,1),cdf_plot.lo.obs(:,2),'-','color',colors.lo,'LineWidth',1.5)
    plot(cdf_plot.lo.sim(:,1),cdf_plot.lo.sim(:,2),'--','color',colors.lo,'LineWidth',0.5)
    xlim([0 600]); ylabel('CDF')
    
    subplot(2,nModel_iter,model_iter_i+nModel_iter); hold on
    plot(cdf_plot.hi.obs(:,1),cdf_plot.hi.obs(:,2),'-','color',colors.hi,'LineWidth',1.5)
    plot(cdf_plot.hi.sim(:,1),cdf_plot.hi.sim(:,2),'--','color',colors.hi,'LineWidth',0.5)
    xlim([0 600]); xlabel('Response Latency (ms)'); ylabel('CDF')

end




