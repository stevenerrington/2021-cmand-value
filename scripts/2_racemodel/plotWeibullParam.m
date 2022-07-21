for monkeyIdx = 1:length(monkeyList)
    
    % Initialise clean arrays & find the relevant sessions in the table
    monkeySessionIdx = []; monkeyArrayIdx = [];
    monkeySessionIdx = find(strcmp(valuedata_master.monkey, monkeyList{monkeyIdx})==1);
    monkeyArrayIdx = find(strcmp([inhFunction.lo.monkeyLabel; inhFunction.hi.monkeyLabel],...
        monkeyList{monkeyIdx})==1);
    
    weibullSSDfig(1,monkeyIdx)=gramm('x',[inhFunction.lo.weiMidSSD(monkeySessionIdx);...
        inhFunction.hi.weiMidSSD(monkeySessionIdx)],'color',[repmat({'Low'},length(monkeySessionIdx),1);...
        repmat({'High'},length(monkeySessionIdx),1)]);
    weibullSSDfig(1,monkeyIdx).stat_density('bandwidth',20);
    weibullSSDfig(1,monkeyIdx).axe_property('XLim',[50 400]);
    weibullSSDfig(1,monkeyIdx).axe_property('YLim',[0 0.02]);
end

figure('Renderer', 'painters', 'Position', [100 100 1200 250]);
weibullSSDfig.draw();