
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
% Input RT from master table and configure data for use with the LBA analysis
clear sim_param_def sim_data_rt

% Set simulated data
sim_param_def.v(1) = 0.6; sim_param_def.v(2) = 0.8;
sim_param_def.A(1) = 40; sim_param_def.A(2) = 40;
sim_param_def.b(1) = 300; sim_param_def.b(2) = 200;
sim_param_def.t0(1) = 100; sim_param_def.t0(2) = 100;
sim_param_def.sv(1) = 0.2; sim_param_def.sv(2) = 0.2;


for trl_iter_i = 1:nSim_iter
    sim_data_rt(trl_iter_i,:) = LBA_trial_RT...
        (sim_param_def.A, sim_param_def.b, sim_param_def.v, sim_param_def.t0, sim_param_def.sv, 2);
end

clear model_input
% Define RT values for high and low value contexts
model_input.data.rt = [sim_data_rt(:,1);sim_data_rt(:,2)];
% Give labels for low and high context, respectively
model_input.data.cond = [ones(length(sim_data_rt(:,1)),1);ones(length(sim_data_rt(:,1)),1)*2];
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

! description needed here.

###############################################################
*** Info
Parameters must be inputted into LBA scripts in the following order:
[v, A, b, t0, sv]. If allowing the parameter to vary between conditions,
then an  additional parameter is added to this array. For example, allowing
drift rate to vary would result in the following array: [v, v, A, b, t0, sv]

###############################################################
%}

% Create a clean environment for defining the model
clear param_def model init_params 

% Define the default parameters
param_labels = {'v','A','b','t0','sv'};

param_def.v(1) = 0.6; param_def.v(2) = 0.8;
param_def.A(1) = 40; param_def.A(2) = 40;
param_def.b(1) = 300; param_def.b(2) = 200;
param_def.t0(1) = 100; param_def.t0(2) = 100;
param_def.sv(1) = 0.2; param_def.sv(2) = 0.2;

% Define the model to run
model_i = 0 ;
for v_i = 1:2
    for A_i = 1:2
        for b_i = 1:2
            for t0_i = 1:2
                for sv_i = 1
                    model_i =  model_i + 1;
                    
                    model(model_i).v = v_i;
                    model(model_i).A = A_i;
                    model(model_i).b = b_i;
                    model(model_i).t0 = t0_i;
                    model(model_i).sv = sv_i;
                    
                    model_label{1,model_i} = ...
                        [repmat('v',1,v_i), '_', repmat('A',1,A_i), '_',...
                        repmat('b',1,b_i), '_', repmat('t0',1,t0_i),'_',...
                        repmat('sv',1,sv_i)];
                    model_label{2,model_i} = ...
                        char(model_i + 64);                    
                end
            end
        end
    end
end

% Set initial starting parameters into arrays.
n_models = size(model,2);

clear model_in init_params
for model_i = 1:n_models
    
    % Place all model parameters into a cell array for future calls.
    init_params{model_i} = []; model_in = struct();
    
    for param_i = 1:length(param_labels)
        for nparam_i = 1:model(model_i).(param_labels{param_i})
            model_in.(param_labels{param_i})(nparam_i) = param_def.(param_labels{param_i})(nparam_i);
        end
        
        init_params{model_i} = [init_params{model_i}, model_in.(param_labels{param_i})];
    end
end

%% Run model
% Model 1: null model
for model_i = 1:n_models
    
    % Create a clean environment for running the model
    clear params logLikelihood model_standard_params param_rand_start
    
    % Run each model 20 times, each with a different starting point. With this,
    % it allows for reliability - we start the optimization in different spots
    % based within 5 x +/- the defined starting parameters.
    for model_iter_i = 1:nModel_iter
        fprintf(['Running model %i of %i; iteration %i of %i | \n'],model_i,n_models,model_iter_i,nModel_iter)
        
        % Get the initial defined parameters (as done above)
        model_standard_params = init_params{model_i};
        
        % For each parameter
        for param_i = 1:length(model_standard_params)
            clear lower_bound upper_bound
            % Define a boundary - starting point must be with 20% of
            % the defined boundary set above.
            scale = 0.25;
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
    
    model_fit_out.params{model_i} = params;
    model_fit_out.logLikelihood{model_i} = logLikelihood;
    
end

%% Simulated data based on model parameters
%{
Once we have these fitted parameters, we can then simulate data using a
LBA. Once we have the simulated data, we can then compare this to the
observed data to make sure it looks correct.
%}

clear  model_sim

for model_i = 1:n_models       
    % For each iteration of the model that we run
    for model_iter_i = 1:nModel_iter 
        fprintf(['Comparing RTs for model %i of %i; iteration %i of %i | \n'],model_i,n_models,model_iter_i,nModel_iter)

        % Get the extracted parameters
        clear v A b sv t0
        [v, A, b, sv, t0] = LBA_parse(model(model_i), model_fit_out.params{model_i}(model_iter_i,:), 2);
        
        % Then use these parameters in a simulation to get trial by trial RT's
        % for low (column 1) and high (column 2) reward contexts
        for trl_iter_i = 1:nSim_iter
            model_sim{model_i,model_iter_i}.sim_RT(trl_iter_i,:) = LBA_trial_RT(A, b, v, t0, sv, 2);
        end
        
        % Run a two-sample Kolmogorov-Smirnov test comparing the simulated
        % and observed RT's for low value contexts
        [ks_test.lo.h(model_i,model_iter_i),...
            ks_test.lo.p(model_i,model_iter_i),...
            ks_test.lo.stats{model_i,model_iter_i}] =...
            kstest2(model_sim{model_i,model_iter_i}.sim_RT(:,1),sim_data_rt(:,1));
        
        %... and high value contexts
        [ks_test.hi.h(model_i,model_iter_i),...
            ks_test.hi.p(model_i,model_iter_i),...
            ks_test.hi.stats{model_i,model_iter_i}] =...
            kstest2(model_sim{model_i,model_iter_i}.sim_RT(:,2),sim_data_rt(:,2));        
        
    end
end




%% Compare log likelihood across models

for model_i = 1:n_models
        fprintf(['Comparing RTs for model %i of %i | \n'],model_i,n_models)
    for model_iter_i = 1:nModel_iter
              
        % Transform the log likelihood into AIC and BIC values
        [aic(model_i,model_iter_i),bic(model_i,model_iter_i)] =...
            aicbic(model_fit_out.logLikelihood{model_i}(model_iter_i),...
            length(init_params{model_i}),length(model_input.data.rt));
    end
end

%% Estimate delta BIC
% To accurately determine which model is best, we will use delta BIC. This
% allows for us to compare how other models compare to the best.

% For each iteration of the model
for model_iter_i = 1:nModel_iter
    % Find the minimum BIC value and subtract this from the other BIC
    % within the given model iteration
    delta_bic(:,model_iter_i) = bic(:,model_iter_i)-min(bic(:,model_iter_i));
end


%% Figure: Plot BIC x Model
bic_count_i = 0;
clear figure_bic_*
for model_i = 1:n_models
    fprintf(['Comparing RTs for model %i of %i | \n'],model_i,n_models)
    
    for model_iter_i = 1:nModel_iter
        bic_count_i = bic_count_i + 1;
        figure_bic_data(bic_count_i)  = delta_bic(model_i,model_iter_i);
        figure_bic_label{bic_count_i} = char(model_i + 64);
    end
end

clear figure_bic_gramm
figure_bic_gramm(1,1)=...
    gramm('x',figure_bic_label',...
    'y',figure_bic_data');

figure_bic_gramm(1,1).stat_boxplot();
figure_bic_gramm(1,1).geom_jitter('alpha',0.2,'dodge',0.5);

figure_bic_gramm(1,1).no_legend;
figure_bic_gramm(1,1).set_names('x','Model','y','BIC');
figure_bic_gramm(1,1).axe_property('YLim',[0 10]);

figure('Position',[100 100 1200 250]);
figure_bic_gramm.draw();


%% Simulated data based on model parameters
%{
Once we have these fitted parameters, we can then simulate data using a
LBA. Once we have the simulated data, we can then compare this to the
observed data to make sure it looks correct.
%}

for model_i = 1:n_models
    
    figure('Renderer', 'painters', 'Position', [100 100 1500 300]);
    
    % For each iteration of the model that we run
    for model_iter_i = 1:nModel_iter
        
        % Get the extracted parameters
        clear v A b sv t0
        [v, A, b, sv, t0] = LBA_parse(model(model_i), model_fit_out.params{model_i}(model_iter_i,:), 2);
        
        % Then use these parameters in a simulation to get trial by trial RT's
        % for low (column 1) and high (column 2) reward contexts
        clear  model_sim
        for trl_iter_i = 1:nSim_iter
            model_sim.sim_RT(trl_iter_i,:) = LBA_trial_RT(A, b, v, t0, sv, 2);
        end
        
        % Once we've extracted these RT's, we can then work out the CDF for
        % each condition, for observed and simulated data
        clear cdf_plot
        cdf_plot.lo.obs = cumulDist(sim_data_rt(:,1)); % Low, observed
        cdf_plot.lo.sim = cumulDist(model_sim.sim_RT(:,1)); % Low, simulated
        cdf_plot.hi.obs = cumulDist(sim_data_rt(:,2)); % High, observed
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
end