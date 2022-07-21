% Setup table structure for the forthcoming data
rtcomparison = table();

% For each session within our data table
for session = 1:length(valuedata_master.sessionN)
    
    % Get session information (i.e number, session name, monkey). This will
    % be useful for splitting the data in future
    rtcomparison.sessionN(session) = valuedata_master.sessionN(session);
    rtcomparison.session(session) = valuedata_master.session(session);
    rtcomparison.monkey(session) = valuedata_master.monkey(session);
    
    
    % Get average values for each condition
    rtcomparison.noncanc_hi(session) = valuedata_master.valueBeh(session).summaryData.noncanc_hi;
    rtcomparison.noncanc_lo(session) = valuedata_master.valueBeh(session).summaryData.noncanc_lo;
    rtcomparison.nostop_hi(session) = valuedata_master.valueBeh(session).summaryData.nostop_hi;
    rtcomparison.nostop_lo(session) = valuedata_master.valueBeh(session).summaryData.nostop_lo;
    
    % We will begin by determining whether the NC RT < GO RT assumption is met in high and low
    % reward contexts.
    % (1) Compare mean RT between non-canceled and no-stop trials for high reward
    rtcomparison.hiFlag(session) = valuedata_master.valueBeh(session).summaryData.noncanc_hi <...
        valuedata_master.valueBeh(session).summaryData.nostop_hi;   % Get flag (1 = NC < GO (Valid); 2 = NC > GO (Invalid)
    rtcomparison.hiDiff(session) = valuedata_master.valueBeh(session).summaryData.noncanc_hi -...
        valuedata_master.valueBeh(session).summaryData.nostop_hi;   % Get magnitude of RT difference between NC & GO
    
    % (2) Compare mean RT between non-canceled and no-stop trials for low reward
    rtcomparison.loFlag(session) = valuedata_master.valueBeh(session).summaryData.noncanc_lo <...
        valuedata_master.valueBeh(session).summaryData.nostop_lo;   % Get flag (1 = NC < GO (Valid); 2 = NC > GO (Invalid)
    rtcomparison.loDiff(session) = valuedata_master.valueBeh(session).summaryData.noncanc_lo -...
        valuedata_master.valueBeh(session).summaryData.nostop_lo;    % Get magnitude of RT difference between NC & GO
    
    % We will then look to see if both value conditions met the RT assumptions of the independent race model.
    rtcomparison.both(session) = sum([rtcomparison.hiFlag(session), rtcomparison.loFlag(session)]) == 2;
    
    % After this initial race model validation, we then wanted to quantify
    % the effect of value context on changes in RT overall. As such, we
    % first compared RT on no-stop trials with high and low reward...
    rtcomparison.nostop_val(session,1) = ...
        valuedata_master.valueBeh(session).summaryData.nostop_hi-...
        valuedata_master.valueBeh(session).summaryData.nostop_lo;
    
    % ... and  repeated this with non-canceled trials
    rtcomparison.noncanc_val(session,1) = ...
        valuedata_master.valueBeh(session).summaryData.noncanc_hi-...
        valuedata_master.valueBeh(session).summaryData.noncanc_lo;  
        
    % Finally, after determining what the effect of value context on response time
    % is, we will then turn to see what the effect on stop-signal reaction
    % time is.
    rtcomparison.ssrtDiff(session,1) = ...
        valuedata_master.valueStopSignalBeh(session).hi.ssrt.integrationWeighted-...
        valuedata_master.valueStopSignalBeh(session).lo.ssrt.integrationWeighted;
    
    rtcomparison.ssrtHigh(session,1) = ...
        valuedata_master.valueStopSignalBeh(session).hi.ssrt.integrationWeighted;  
    rtcomparison.ssrtLow(session,1) = ...
        valuedata_master.valueStopSignalBeh(session).lo.ssrt.integrationWeighted;  

end