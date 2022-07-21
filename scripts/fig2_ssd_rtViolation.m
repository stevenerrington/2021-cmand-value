monkeyList = {'darwin','Euler','joule','Xena'};
valueConds = {'lo','hi'}; % 'hi'
nSessions = length(valuedata_master.sessionN);

for valueCondIdx = 1:2
    
    % Get the relevant context name string
    valueCond = valueConds{valueCondIdx};
    
    for sessionIdx = 1:nSessions
        RT = []; RT = valuedata_master.RTdist(sessionIdx).all;
        nSSD = length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD);
        
        for ssdIdx = 1:nSSD
            
            % For each SSD, RTnc - RTns
            assumptionRT.(valueCond).deltaRT{sessionIdx}(1,ssdIdx) = ...
                nanmean(RT(valuedata_master.valueStopSignalBeh(sessionIdx)...
                .(valueCond).ssd_ttx.NC{ssdIdx})) -...
                nanmean(RT(valuedata_master.valueStopSignalBeh(sessionIdx)...
                .(valueCond).ssd_ttx.NS_before_NC{ssdIdx}));
            
            assumptionRT.(valueCond).SSD{sessionIdx}(1,ssdIdx) = ...
                valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD(ssdIdx);            
        end
        
        
    end
end


%%

assumptionRT.plot.x_y = [];
assumptionRT.plot.valueLabel = [];
assumptionRT.plot.monkeyLabel = [];

for valueCondIdx = 1:2
    valueCond = valueConds{valueCondIdx};
    
    for sessionIdx = 1:nSessions
        nSSD = length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD);

        assumptionRT.plot.x_y = ...
            [assumptionRT.plot.x_y; ...
            assumptionRT.(valueCond).SSD{sessionIdx}',...
            assumptionRT.(valueCond).deltaRT{sessionIdx}'];
        
        assumptionRT.plot.valueLabel = ...
            [assumptionRT.plot.valueLabel; repmat({valueCond},nSSD,1)];
        
        assumptionRT.plot.monkeyLabel = ...
            [assumptionRT.plot.monkeyLabel; ...
            repmat(valuedata_master.monkey(sessionIdx),nSSD,1)];
    end
end


%%

clear rtViolationPlot
for monkeyIdx = 1:4
    monkeyName = monkeyList{monkeyIdx};
    monkeyTableIdx = []; monkeyTableIdx = find(strcmp(assumptionRT.plot.monkeyLabel,monkeyName) == 1);
    
    
    
    rtViolationPlot(1,monkeyIdx)= gramm(...
        'x',assumptionRT.plot.x_y(monkeyTableIdx,1),...
        'y',assumptionRT.plot.x_y(monkeyTableIdx,2),...
        'color',assumptionRT.plot.valueLabel(monkeyTableIdx));
    rtViolationPlot(1,monkeyIdx).no_legend;
    rtViolationPlot(1,monkeyIdx).stat_smooth();
    rtViolationPlot(1,monkeyIdx).geom_jitter('alpha',0.2);
    rtViolationPlot(1,monkeyIdx).geom_hline('yintercept',0)
    rtViolationPlot.set_color_options('map',[colors.lo;colors.hi]);
    rtViolationPlot.axe_property('XLim',[0 500]);
    rtViolationPlot.axe_property('YLim',[-250 250]);
    
end

figure('Position',[100 100 1200 250]);
rtViolationPlot.draw();
