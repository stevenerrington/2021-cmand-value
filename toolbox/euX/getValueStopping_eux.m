function [valueStopSignalBeh, valueRTdist] = getValueStopping_eux(stateFlags,Infos,ttx)

% Parameters
monitorRefresh = 1000/70;
rewardLabels = {'lo','hi'};

for rewardIdx = 1:length(rewardLabels)
    rewardLabel = rewardLabels{rewardIdx};
    
    % RT distribution
    valueRTdist.(rewardLabel).all = Infos.Decide_ - Infos.Target_;
    valueRTdist.(rewardLabel).nostop = cumulDist(valueRTdist.(rewardLabel).all(ttx.nostop.all.(rewardLabel)));
    valueRTdist.(rewardLabel).noncanc = cumulDist(valueRTdist.(rewardLabel).all(ttx.noncanceled.all.(rewardLabel)));
    
    % Stop-signal delay
    inh_SSD = unique(stateFlags.UseSsdVrCount);
    ssdVRvalues = inh_SSD(~isnan(inh_SSD));
    inh_SSD = round(ssdVRvalues*monitorRefresh);
    
    clear inh_nTr inh_pnc
    for ssdIdx = 1:length(inh_SSD)
        clear stopTrialIdx
        stopTrialIdx = find(stateFlags.UseSsdVrCount == ssdVRvalues(ssdIdx));
        
        valueStopSignalBeh.(rewardLabel).ssd_ttx.NC{ssdIdx} =...
            stopTrialIdx(ismember(stopTrialIdx, ttx.noncanceled.all.(rewardLabel)));
        
        valueStopSignalBeh.(rewardLabel).ssd_ttx.NS_before_NC{ssdIdx} =...
            ttx.nostop.all.(rewardLabel)(...
            ismember(ttx.nostop.all.(rewardLabel), ...
            valueStopSignalBeh.(rewardLabel).ssd_ttx.NC{ssdIdx}-1));        
        
        valueStopSignalBeh.(rewardLabel).ssd_ttx.C{ssdIdx} =...
            stopTrialIdx(ismember(stopTrialIdx, ttx.canceled.all.(rewardLabel)));
        
        clear n_NC n_C
        n_NC = length(valueStopSignalBeh.(rewardLabel).ssd_ttx.NC{ssdIdx});
        n_C  = length(valueStopSignalBeh.(rewardLabel).ssd_ttx.C{ssdIdx});
        
        inh_nTr(ssdIdx) = n_NC+n_C;
        inh_pnc(ssdIdx) = n_NC/(inh_nTr(ssdIdx));
    end
    
    valueStopSignalBeh.(rewardLabel).inh_SSD = inh_SSD;
    valueStopSignalBeh.(rewardLabel).inh_pnc = inh_pnc;
    valueStopSignalBeh.(rewardLabel).inh_nTr = inh_nTr;
    
    [valueStopSignalBeh.(rewardLabel).inh_weibull.parameters,~,...
        valueStopSignalBeh.(rewardLabel).inh_weibull.x,...
        valueStopSignalBeh.(rewardLabel).inh_weibull.y] =...
        fitWeibull(valueStopSignalBeh.(rewardLabel).inh_SSD,...
        valueStopSignalBeh.(rewardLabel).inh_pnc,...
        valueStopSignalBeh.(rewardLabel).inh_nTr);
    
    valueStopSignalBeh.(rewardLabel).ssrt = getSSRT(valueStopSignalBeh.(rewardLabel).inh_SSD,...
        valueStopSignalBeh.(rewardLabel).inh_pnc,valueStopSignalBeh.(rewardLabel).inh_nTr,...
        valueRTdist.(rewardLabel).nostop(:,1),...
        valueStopSignalBeh.(rewardLabel).inh_weibull.parameters);
    
    
    for ssdIdx = 1:length(inh_SSD)
        
        inh_zrft(ssdIdx) = (mean(valueRTdist.(rewardLabel).nostop(:,1)) -...
            valueStopSignalBeh.(rewardLabel).inh_SSD(ssdIdx) - valueStopSignalBeh.(rewardLabel).ssrt.integrationWeighted)...
            ./(std(valueRTdist.(rewardLabel).nostop(:,1)));
    end
    
    valueStopSignalBeh.(rewardLabel).inh_zrft = inh_zrft;
    
    
%     [valueStopSignalBeh.(rewardLabel).inh_weibull_zfrt.parameters,~,...
%         valueStopSignalBeh.(rewardLabel).inh_weibull_zfrt.x,...
%         valueStopSignalBeh.(rewardLabel).inh_weibull_zfrt.y] =...
%         fitWeibull_zrft(valueStopSignalBeh.(rewardLabel).inh_zrft,...
%         valueStopSignalBeh.(rewardLabel).inh_pnc,...
%         valueStopSignalBeh.(rewardLabel).inh_nTr);
    
end
end

