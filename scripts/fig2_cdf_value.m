%% value-based inhibition function
monkeyList = {'darwin','Euler','joule','Xena'};
valueConds = {'lo','hi'}; % 'hi'
nSessions = length(valuedata_master.sessionN);

getColor_value;

for valueCondIdx = 1:2
    valueCond = valueConds{valueCondIdx};
    
    for sessionIdx = 1:nSessions

        % Get the generated weibull fitted inhibition function
        % y axis (pNC)
        rtDistCDF.(valueCond).x_noncanc{sessionIdx,1} =...
            quantile(valuedata_master.valueRTdist(sessionIdx).(valueCond).noncanc(:,1),...
            [0.1 0.3 0.5 0.7 0.9])';
        rtDistCDF.(valueCond).y_noncanc{sessionIdx,1} =...
            [0.1 0.3 0.5 0.7 0.9]';
        
        rtDistCDF.(valueCond).x_nostop{sessionIdx,1} =...
            quantile(valuedata_master.valueRTdist(sessionIdx).(valueCond).nostop(:,1),...
            [0.1 0.3 0.5 0.7 0.9])';
        rtDistCDF.(valueCond).y_nostop{sessionIdx,1} =...
            [0.1 0.3 0.5 0.7 0.9]';    
        
        rtDistCDF.(valueCond).monkeyLabel{sessionIdx,1} = valuedata_master.monkey(sessionIdx);
        
        rtDistCDF.(valueCond).valueLabel{sessionIdx,1} = valueCond;
    end
end


%%
clear valRTCDF_monkey
for monkeyIdx = 1:length(monkeyList)
    
    monkeySessionIdx = []; monkeyArrayIdx = [];
    monkeySessionIdx = find(strcmp(valuedata_master.monkey, monkeyList{monkeyIdx})==1);
    monkeyArrayIdx = find(strcmp([rtDistCDF.lo.monkeyLabel; rtDistCDF.hi.monkeyLabel],...
        monkeyList{monkeyIdx})==1);
    
    % Setup gramm parameters and data
    % Weibull averaged inhibition function
    valRTCDF_monkey(1,monkeyIdx)=...
        gramm('y',[rtDistCDF.lo.x_nostop(monkeySessionIdx);rtDistCDF.lo.x_noncanc(monkeySessionIdx)],... % Weibull fit between 1 and 600 ms
        'x',[rtDistCDF.lo.y_nostop(monkeySessionIdx);rtDistCDF.lo.y_noncanc(monkeySessionIdx)],...
        'color',[repmat({'No-stop'},length(monkeySessionIdx),1);...
        repmat({'Non-canc'},length(monkeySessionIdx),1)]);
    
    valRTCDF_monkey(2,monkeyIdx)=...
        gramm('y',[rtDistCDF.hi.x_nostop(monkeySessionIdx);rtDistCDF.hi.x_noncanc(monkeySessionIdx)],... % Weibull fit between 1 and 600 ms
        'x',[rtDistCDF.hi.y_nostop(monkeySessionIdx);rtDistCDF.hi.y_noncanc(monkeySessionIdx)],...
        'color',[repmat({'No-stop'},length(monkeySessionIdx),1);...
        repmat({'Non-canc'},length(monkeySessionIdx),1)]);
        
    
    
    valRTCDF_monkey(1,monkeyIdx).stat_summary('geom',{'point','errorbar','line'},'type','sem');
    valRTCDF_monkey(1,monkeyIdx).axe_property('YLim',[0 600]);
    valRTCDF_monkey(1,monkeyIdx).axe_property('XLim',[0 1]);
    valRTCDF_monkey(1,monkeyIdx).set_color_options('map',[colors.nostop;colors.noncanc]);
    
 
    valRTCDF_monkey(2,monkeyIdx).stat_summary('geom',{'point','errorbar','line'},'type','sem');
    valRTCDF_monkey(2,monkeyIdx).axe_property('YLim',[0 600]);
    valRTCDF_monkey(2,monkeyIdx).axe_property('XLim',[0 1]);
    valRTCDF_monkey(2,monkeyIdx).set_color_options('map',[colors.nostop;colors.noncanc]);
    
    valRTCDF_monkey(1,monkeyIdx).no_legend;
    valRTCDF_monkey(2,monkeyIdx).no_legend;
        
end

figure('Renderer', 'painters', 'Position', [100 100 1200 500]);
valRTCDF_monkey.draw();

%%



RTsummary_fig.data = [rtcomparison.nostop_lo; rtcomparison.nostop_hi; rtcomparison.noncanc_lo; rtcomparison.noncanc_hi];
RTsummary_fig.valueLabel = [repmat({'low'},nSessions,1);repmat({'high'},nSessions,1); repmat({'low'},nSessions,1); repmat({'high'},nSessions,1)];
RTsummary_fig.trialLabel = [repmat({'nostop'},nSessions*2,1);repmat({'noncanc'},nSessions*2,1)];
RTsummary_fig.monkeyLabel = repmat(rtcomparison.monkey,4,1);

clear RTsummary_fig_gramm

for monkeyIdx = 1:length(monkeyList)
    
    monkeyArrayIdx = [];
    monkeyArrayIdx = find(strcmp(RTsummary_fig.monkeyLabel, monkeyList{monkeyIdx})==1);
    
    % Setup gramm parameters and data
    % Weibull averaged inhibition function
    RTsummary_fig_gramm(1,monkeyIdx)=...
        gramm('x',RTsummary_fig.valueLabel(monkeyArrayIdx),... % Weibull fit between 1 and 600 ms
        'y',RTsummary_fig.data(monkeyArrayIdx),...
        'color',RTsummary_fig.trialLabel(monkeyArrayIdx));
    
    
    RTsummary_fig_gramm(1,monkeyIdx).geom_jitter('alpha',0.2,'dodge',0.5);
    RTsummary_fig_gramm(1,monkeyIdx).stat_summary('geom',{'point','black_errorbar','lines'},'type','sem');
%     RTsummary_fig_gramm(1,monkeyIdx).axe_property('XLim',[200 450]);
    RTsummary_fig_gramm(1,monkeyIdx).axe_property('YLim',[150 500]);
    
    RTsummary_fig_gramm(1,monkeyIdx).no_legend;
    RTsummary_fig_gramm(1,monkeyIdx).set_color_options('map',[colors.noncanc;colors.nostop]);        
end


figure('Renderer', 'painters', 'Position', [100 100 1200 250]);
RTsummary_fig_gramm.draw();