%% Test LBA parameters from previous manuscripts
SAT_params.medium.A = 30; SAT_params.medium.B = 144;
SAT_params.medium.v = 30; SAT_params.medium.t0 = 30;
SAT_params.medium.sv = 0.1;

clear lba_test

for trl_iter_i = 1:nSim_iter
    lba_test(trl_iter_i,:) = LBA_trial_RT(30, 144, 0.55, 81, 0.1, 1);
end

clear cdf_plot
cdf_plot.test = cumulDist(lba_test(:,1));

% For each iteration, we generate a figure, and plot the CDF.
% In these figures, dashed lines are the simulated data and thicker
% solid lines are the observed. Blue represents low value context,
% magenta represents high value context.
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
subplot(1,1,1); hold on
plot(cdf_plot.test(:,1),cdf_plot.test(:,2),'-','color','k','LineWidth',2)
xlim([0 600]); ylabel('CDF'); 
vline(median(cdf_plot.test(:,1)))


%{
This seems to produce reasonable distributions.
%}
