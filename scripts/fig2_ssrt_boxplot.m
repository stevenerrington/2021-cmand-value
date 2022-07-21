%% value-based inhibition function
monkeyList = {'darwin','Euler','joule','Xena'};
valueConds = {'lo','hi'}; % 'hi'
nSessions = length(valuedata_master.sessionN);

getColor_value

for valueCondIdx = 1:2
    valueCond = valueConds{valueCondIdx};
    for sessionIdx = 1:nSessions
        ssrt = valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).ssrt.integrationWeighted;
        value = {valueCond};
        monkey = valuedata_master.monkey(sessionIdx);
        raceModel_hi = rtcomparison.hiFlag(sessionIdx);
        raceModel_lo = rtcomparison.loFlag(sessionIdx);

        ssrt_comp_table.(valueCond)(sessionIdx,:) = table(ssrt, value, monkey, raceModel_hi, raceModel_lo);
    end
end

ssrt_comp_table.all = [ssrt_comp_table.lo; ssrt_comp_table.hi];



figure('Position',[100 100 1200 250]);
clear ssrt_value_boxplot
for monkeyIdx = 1:4
    monkeyName = monkeyList{monkeyIdx};
    monkeyTableIdx = []; monkeyTableIdx = find(strcmp(ssrt_comp_table.all.monkey,monkeyName) == 1 ...
        & ssrt_comp_table.all.raceModel_hi == 1 & ssrt_comp_table.all.raceModel_lo == 1 );
    
    ssrt_value_boxplot(1,monkeyIdx)= gramm('x',ssrt_comp_table.all.value(monkeyTableIdx),...
        'y',ssrt_comp_table.all.ssrt(monkeyTableIdx),'color',ssrt_comp_table.all.value(monkeyTableIdx));
    ssrt_value_boxplot(1,monkeyIdx).stat_boxplot();
    ssrt_value_boxplot(1,monkeyIdx).geom_jitter('alpha',1);
    ssrt_value_boxplot.set_color_options('map',[colors.hi;colors.lo]);
    ssrt_value_boxplot.axe_property('YLim',[0 250]);
    ssrt_value_boxplot.draw();
    
end


