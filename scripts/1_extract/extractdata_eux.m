parfor sessionIdx = 1:length(eux_metadata.executiveBeh.filenames)
    % Let the user know where the script is at
    fprintf('Analysing session %i of %i | %s.          \n',...
        sessionIdx,length(eux_metadata.executiveBeh.filenames),...
        eux_metadata.executiveBeh.filenames{sessionIdx});
    
    data_in = load([eux_matDir ...
        eux_metadata.executiveBeh.filenames{sessionIdx}]);
    
    [stateFlags, Infos] = tranEuX_to_new(data_in, eux_metadata, sessionIdx);
    
    % Extract trial indices for all relevant conditions
    [ttx, ttx_value,ttx_history] = getTrials(stateFlags);
    
    % Get value behavior
    [valueBeh] = getValueBeh(Infos, ttx_value);
    
    % Get stopping behavior (i.e. response times, stop-signal delays, p(error))
    % across all value levels.
    [stopSignalBeh, RTdist] = getStoppingBeh_eux(stateFlags,Infos,ttx_value);
    
    % Get stopping behavior split by value levels (i.e. in high & low reward blocks)
    [valueStopSignalBeh, valueRTdist] = getValueStopping_eux(stateFlags,Infos,ttx_value);
    
    % Get post-error/post-stop/post-go RT's
    [postRT] = getPostSlowing(Infos,ttx_history);
    
    % Collate relevant data into one table for future analyses
    valuedata_eux(sessionIdx,:) = ...
        table(sessionIdx,{eux_metadata.executiveBeh.filenames{sessionIdx}},...
        {eux_metadata.executiveBeh.nhpSessions.monkeyNameLabel{sessionIdx}},...
        valueBeh, stopSignalBeh,RTdist,valueStopSignalBeh,valueRTdist,postRT,...
        'VariableNames',{'sessionN','session','monkey','valueBeh','stopSignalBeh',...
        'RTdist','valueStopSignalBeh','valueRTdist','postRT'});
    
end