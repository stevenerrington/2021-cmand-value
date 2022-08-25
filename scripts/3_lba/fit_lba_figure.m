
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
end