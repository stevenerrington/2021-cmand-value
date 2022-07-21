parfor sessionN = 1:length(dajo_metadata.dajo_datamap.sessionN)
    % Let the user know where the script is at
    fprintf('Analysing session %i of %i | %s.          \n',...
        sessionN,length(dajo_metadata.dajo_datamap.sessionN),dajo_metadata.dajo_datamap.session{sessionN});
    
    % Load in behavioral data (i.e. events and timestamps)
    data_in = load([dajo_matDir dajo_metadata.dajo_datamap.behInfo(sessionN).dataFile]);
    
    % Extract trial indices for all relevant conditions
    [ttx, ttx_value, ttx_history] = getTrials (data_in.events.stateFlags_);
    
    % Get value behavior
    [valueBeh] = getValueBeh(data_in.events.Infos_, ttx_value);
    
    % Get stopping behavior (i.e. response times, stop-signal delays, p(error))
    % across all value levels.
    [stopSignalBeh, RTdist] = getStoppingBeh(data_in.events.stateFlags_,data_in.events.Infos_,ttx_value);
    
    % Get stopping behavior split by value levels (i.e. in high & low reward blocks)
    [valueStopSignalBeh, valueRTdist] = getValueStopping(data_in.events.stateFlags_,data_in.events.Infos_,ttx_value);
    
    % Get post-error/post-stop/post-go RT's
    [postRT] = getPostSlowing(data_in.events.Infos_,ttx_history);
    
    % Collate relevant data into one table for future analyses
    valuedata_dajo(sessionN,:) = ...
        table(sessionN,dajo_metadata.dajo_datamap.session(sessionN),{dajo_metadata.dajo_datamap.animalInfo(sessionN).monkey},...
        valueBeh,stopSignalBeh,RTdist,valueStopSignalBeh,valueRTdist,postRT,...
        'VariableNames',{'sessionN','session','monkey','valueBeh','stopSignalBeh',...
        'RTdist','valueStopSignalBeh','valueRTdist','postRT'});
end