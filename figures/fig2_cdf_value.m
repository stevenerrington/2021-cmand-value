%% value-based inhibition function
monkeyList = {'darwin','Euler','joule','Xena'};
valueConds = {'lo','hi'}; % 'hi'
nSessions = length(valuedata_master.sessionN);

getColor_value

for valueCondIdx = 1:2
    valueCond = valueConds{valueCondIdx};
    
    inhFunction.(valueCond).ssd_pnc = [];
    inhFunction.(valueCond).monkeyLabel = [];
    inhFunction.(valueCond).valueLabel = [];
    
    for sessionIdx = 1:nSessions
        
        % Get the generated weibull fitted inhibition function
        % y axis (pNC)
        inhFunction.(valueCond).y{sessionIdx,1} =...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_weibull.y;
        
        inhFunction.(valueCond).ssd_pnc =...
            [inhFunction.(valueCond).ssd_pnc;...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD,...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_pnc'];
        
        inhFunction.(valueCond).monkeyLabel = ...
            [inhFunction.(valueCond).monkeyLabel ;...
            repmat(valuedata_master.monkey(sessionIdx),...
            length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD),1)];
        
        inhFunction.(valueCond).valueLabel = ...
            [inhFunction.(valueCond).valueLabel ;...
            repmat({valueCond},...
            length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD),1)];
        
    end
end

% Arrange scatter data into a plottable format for gramm.
scatterArray.SSD = [inhFunction.lo.ssd_pnc(:,1);inhFunction.hi.ssd_pnc(:,1)];
scatterArray.pNC = [inhFunction.lo.ssd_pnc(:,2);inhFunction.hi.ssd_pnc(:,2)];
scatterArray.color = [inhFunction.lo.valueLabel; inhFunction.hi.valueLabel];

for monkeyIdx = 1:length(monkeyList)
    
    monkeySessionIdx = []; monkeyArrayIdx = [];
    monkeySessionIdx = find(strcmp(valuedata_master.monkey, monkeyList{monkeyIdx})==1);
    monkeyArrayIdx = find(strcmp([inhFunction.lo.monkeyLabel; inhFunction.hi.monkeyLabel],...
        monkeyList{monkeyIdx})==1);

    % Setup gramm parameters and data
    % Weibull averaged inhibition function
    valInhFunc_monkey(1,monkeyIdx)=...
        gramm('x',[1:600],... % Weibull fit between 1 and 600 ms
        'y',[inhFunction.lo.y(monkeySessionIdx);inhFunction.hi.y(monkeySessionIdx)],...
        'color',[repmat({'Low'},length(monkeySessionIdx),1);...
        repmat({'High'},length(monkeySessionIdx),1)]);
    
    
    % Plot scatter points for inhibition function
    valInhFunc_monkey(2,monkeyIdx)=...
        gramm('x',scatterArray.SSD(monkeyArrayIdx,:),...
        'y',scatterArray.pNC(monkeyArrayIdx,:),...
        'color',scatterArray.color(monkeyArrayIdx,:));
    
    
    valInhFunc_monkey(1,monkeyIdx).stat_summary();
    valInhFunc_monkey(1,monkeyIdx).axe_property('XLim',[0 600]);
    valInhFunc_monkey(1,monkeyIdx).axe_property('YLim',[0 1]);
    valInhFunc_monkey(1,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
    
    valInhFunc_monkey(2,monkeyIdx).axe_property('XLim',[0 600]);
    valInhFunc_monkey(2,monkeyIdx).axe_property('YLim',[0 1]);
    valInhFunc_monkey(2,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
    valInhFunc_monkey(2,monkeyIdx).geom_point('alpha',0.2);
    
end

figure('Renderer', 'painters', 'Position', [100 100 1200 500]);
valInhFunc_monkey.draw();

