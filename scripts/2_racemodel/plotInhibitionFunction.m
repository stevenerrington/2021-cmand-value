% Arrange scatter data into a plottable format for gramm. This entails
% concatenating data from the high and low contexts into one array.
scatterArray.SSD = [inhFunction.lo.ssd_pnc(:,1);inhFunction.hi.ssd_pnc(:,1)]; % Stop-signal delay
scatterArray.pNC = [inhFunction.lo.ssd_pnc(:,2);inhFunction.hi.ssd_pnc(:,2)]; % p(non-canceled | SSD)
scatterArray.color = [inhFunction.lo.valueLabel; inhFunction.hi.valueLabel];  % Value context label (high/low)

% For each monkey, we will produce a figure
for monkeyIdx = 1:length(monkeyList)
    
    % Initialise clean arrays & find the relevant sessions in the table
    monkeySessionIdx = []; monkeyArrayIdx = [];
    monkeySessionIdx = find(strcmp(valuedata_master.monkey, monkeyList{monkeyIdx})==1);
    monkeyArrayIdx = find(strcmp([inhFunction.lo.monkeyLabel; inhFunction.hi.monkeyLabel],...
        monkeyList{monkeyIdx})==1);

    % Provide the gramm toolbox with data for:
        % The session averaged Weibull-fitted inhibition functions
    valInhFunc_monkey(1,monkeyIdx)=...
        gramm('x',[1:600],...                                                          % SSD value: Weibulls were fit between 0 and 600ms
        'y',[inhFunction.lo.y(monkeySessionIdx);inhFunction.hi.y(monkeySessionIdx)],...% p(non-canc): Weibull derived inhibition function.
        'color',[repmat({'Low'},length(monkeySessionIdx),1);...
        repmat({'High'},length(monkeySessionIdx),1)]);                                 % Value context labels corresponding to the data
    
        % The session-by-session scatter points for SSD and pNC
        valInhFunc_monkey(2,monkeyIdx)=...
        gramm('x',scatterArray.SSD(monkeyArrayIdx,:),...                               % Individual stop-signal delay values
        'y',scatterArray.pNC(monkeyArrayIdx,:),...                                     % Individual pNC values
        'color',scatterArray.color(monkeyArrayIdx,:));                                 % Value context labels corresponding to the data
    
    
    % Set up figure types (& corresponding properties) in gramm
    valInhFunc_monkey(1,monkeyIdx).stat_summary();
    valInhFunc_monkey(1,monkeyIdx).axe_property('XLim',[0 600]);
    valInhFunc_monkey(1,monkeyIdx).axe_property('YLim',[0 1]);
    valInhFunc_monkey(1,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
    
    valInhFunc_monkey(2,monkeyIdx).axe_property('XLim',[0 600]);
    valInhFunc_monkey(2,monkeyIdx).axe_property('YLim',[0 1]);
    valInhFunc_monkey(2,monkeyIdx).set_color_options('map',[colors.hi;colors.lo]);
    valInhFunc_monkey(2,monkeyIdx).geom_point('alpha',0.2);
    
end

% Generate the figure!
figure('Renderer', 'painters', 'Position', [100 100 1200 500]);
valInhFunc_monkey.draw();