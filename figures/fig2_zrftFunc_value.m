
%% value-based inhibition function
monkeyList = {'darwin','Euler','joule','Xena'};
valueConds = {'lo','hi'}; % 'hi'
nSessions = length(valuedata_master.sessionN);

getColor_value

clear zrftFunction
for valueCondIdx = 1:2
    valueCond = valueConds{valueCondIdx};
    
    zrftFunction.(valueCond).zrft_pnc = [];
    zrftFunction.(valueCond).monkeyLabel = [];
    zrftFunction.(valueCond).valueLabel = [];
    
    for sessionIdx = 1:nSessions
        
        % Get the generated weibull fitted inhibition function
        % y axis (pNC)
        [zrftFunction.(valueCond).params{sessionIdx,1},...
            ~,~,zrftFunction.(valueCond).y{sessionIdx,1}] =...
            fitWeibull_zrft(...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_zrft+100,...
            1-valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_pnc,...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_nTr);
        
        zrftFunction.(valueCond).zrft_pnc =...
            [zrftFunction.(valueCond).zrft_pnc;...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_zrft',...
            1-valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_pnc'];
        
        zrftFunction.(valueCond).monkeyLabel = ...
            [zrftFunction.(valueCond).monkeyLabel ;...
            repmat(valuedata_master.monkey(sessionIdx),...
            length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD),1)];
        
        zrftFunction.(valueCond).valueLabel = ...
            [zrftFunction.(valueCond).valueLabel ;...
            repmat({valueCond},...
            length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD),1)];
        
        zrftFunction.(valueCond).slope(sessionIdx,1) = zrftFunction.(valueCond).params{sessionIdx,1}(2);
        
    end
end

% Arrange scatter data into a plottable format for gramm.
scatterArray.ZRFT = [zrftFunction.lo.zrft_pnc(:,1);zrftFunction.hi.zrft_pnc(:,1)];
scatterArray.pNC = [zrftFunction.lo.zrft_pnc(:,2);zrftFunction.hi.zrft_pnc(:,2)];
scatterArray.color = [zrftFunction.lo.valueLabel; zrftFunction.hi.valueLabel];

clear valInhFunc_monkey
for monkeyIdx = 1:length(monkeyList)
    
    monkeySessionIdx = []; monkeyArrayIdx = [];
    monkeySessionIdx = find(strcmp(valuedata_master.monkey, monkeyList{monkeyIdx})==1);
    monkeyArrayIdx = find(strcmp([zrftFunction.lo.monkeyLabel; zrftFunction.hi.monkeyLabel],...
        monkeyList{monkeyIdx})==1);
    
    % Setup gramm parameters and data
    % Weibull averaged inhibition function
    valInhFunc_monkey(1,monkeyIdx)=...
        gramm('x',[-5:0.1:5],... % Weibull fit between 1 and 600 ms
        'y',[zrftFunction.lo.y(monkeySessionIdx);zrftFunction.hi.y(monkeySessionIdx)],...
        'color',[repmat({'Low'},length(monkeySessionIdx),1);...
        repmat({'High'},length(monkeySessionIdx),1)]);
    
    % Plot scatter points for inhibition function
    valInhFunc_monkey(2,monkeyIdx)=...
        gramm('x',scatterArray.ZRFT(monkeyArrayIdx,:),...
        'y',scatterArray.pNC(monkeyArrayIdx,:),...
        'color',scatterArray.color(monkeyArrayIdx,:));
    
    
    valInhFunc_monkey(3,monkeyIdx)=...
        gramm('x',[zrftFunction.lo.slope(monkeySessionIdx);...
        zrftFunction.hi.slope(monkeySessionIdx)],'color',[repmat({'Low'},length(monkeySessionIdx),1);...
        repmat({'High'},length(monkeySessionIdx),1)]);
    
    valInhFunc_monkey(1,monkeyIdx).stat_summary();
    valInhFunc_monkey(1,monkeyIdx).axe_property('XLim',[-5 5]);
    valInhFunc_monkey(1,monkeyIdx).axe_property('YLim',[0 1]);
    valInhFunc_monkey(1,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
    valInhFunc_monkey(1,monkeyIdx).no_legend();

    valInhFunc_monkey(2,monkeyIdx).geom_point('alpha',0.2);
    valInhFunc_monkey(2,monkeyIdx).axe_property('XLim',[-5 5]);
    valInhFunc_monkey(2,monkeyIdx).axe_property('YLim',[0 1]);
    valInhFunc_monkey(2,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
    valInhFunc_monkey(2,monkeyIdx).no_legend();
    
    valInhFunc_monkey(3,monkeyIdx).stat_density('bandwidth',20);
    valInhFunc_monkey(3,monkeyIdx).axe_property('XLim',[50 350]);
    valInhFunc_monkey(3,monkeyIdx).axe_property('YLim',[0 0.02]);
    valInhFunc_monkey(3,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
    valInhFunc_monkey(3,monkeyIdx).no_legend();

end

figure('Renderer', 'painters', 'Position', [100 100 1200 750]);
valInhFunc_monkey.draw();

%%
jasp_zrft_slope...
    = table(...
     valuedata_master.sessionN,... % Session number
     valuedata_master.monkey,...   % Monkey name
     zrftFunction.lo.slope,...  % Mid value (low condition)
     zrftFunction.hi.slope,...  % Mid value (high condition)
     'VariableNames',{'sessionN','monkey','low_ZFRTslope','high_ZFRTslope'});
 
 writetable(jasp_zrft_slope,...
     'D:\projectCode\project_valueStopping\data\jasp\jasp_zrft_slope.csv',...
     'WriteRowNames',true) 