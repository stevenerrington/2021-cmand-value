%% value-based inhibition function
monkeyList = {'darwin','Euler','joule','Xena'};
valueConds = {'lo','hi'}; % 'hi'
nSessions = length(valuedata_master.sessionN);

getColor_value


figure('Position',[100 100 1200 250]);
clear ssrt_rt_value_boxplot
for monkeyIdx = 1:4
    monkeyName = monkeyList{monkeyIdx};
    monkeyTableIdx = []; monkeyTableIdx = find(strcmp(rtcomparison.monkey,monkeyName) == 1 ...
        & rtcomparison.both == 1 );
    
    plotData = []; labelData = [];
    
    plotData=...
        [rtcomparison.ssrtDiff(monkeyTableIdx);...
        rtcomparison.nostop_val(monkeyTableIdx);...
        rtcomparison.noncanc_val(monkeyTableIdx)];
        
    labelData=...
        [repmat({'ssrt'},length(monkeyTableIdx),1);...
        repmat({'nostop'},length(monkeyTableIdx),1);...
        repmat({'noncanc'},length(monkeyTableIdx),1)];
    
    
    ssrt_rt_value_boxplot(1,monkeyIdx)= gramm('x',labelData,...
        'y',plotData,'color',labelData);
    ssrt_rt_value_boxplot(1,monkeyIdx).stat_boxplot('width',2);
    ssrt_rt_value_boxplot(1,monkeyIdx).geom_jitter('alpha',1);
    ssrt_rt_value_boxplot.set_color_options('map',[colors.noncanc;colors.nostop;colors.canceled]);
    ssrt_rt_value_boxplot.axe_property('YLim',[-150 150]);
    ssrt_rt_value_boxplot(1,monkeyIdx).no_legend;
    ssrt_rt_value_boxplot.draw();
    
end

