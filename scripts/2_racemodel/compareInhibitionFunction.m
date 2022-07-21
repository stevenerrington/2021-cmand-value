% For each value context (high and low)
for valueCondIdx = 1:2
    
    % Get the relevant context name string
    valueCond = valueConds{valueCondIdx};
    
    % Create a blank structure to concatenate into
    inhFunction.(valueCond).ssd_pnc = [];
    inhFunction.(valueCond).monkeyLabel = [];
    inhFunction.(valueCond).valueLabel = [];
    
    
    for sessionIdx = 1:nSessions
        
        % Get the generated weibull fitted inhibition function
        % y axis (pNC)
        inhFunction.(valueCond).y{sessionIdx,1} =...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_weibull.y;
        
        % Extract the SSD and pNC for the given session, segregated by high and
        % low reward
        inhFunction.(valueCond).ssd_pnc =...
            [inhFunction.(valueCond).ssd_pnc;...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD,...
            valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_pnc'];
        
        % For future extraction, generate a label for the monkey...
        inhFunction.(valueCond).monkeyLabel = ...
            [inhFunction.(valueCond).monkeyLabel ;...
            repmat(valuedata_master.monkey(sessionIdx),...
            length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD),1)];
        % ... and the value condition for which the data was extracted
        
        inhFunction.(valueCond).valueLabel = ...
            [inhFunction.(valueCond).valueLabel ;...
            repmat({valueCond},...
            length(valuedata_master.valueStopSignalBeh(sessionIdx).(valueCond).inh_SSD),1)];
        
        [ ~, inhFunction.(valueCond).weiMidSSD(sessionIdx,1) ] =...
            min(abs(inhFunction.(valueCond).y{sessionIdx}-0.5 ) );

        
    end
end