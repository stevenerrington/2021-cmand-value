function [ttx,ttx_value,ttx_history] = getTrials(stateFlags)
% Setup data
trialTypes = {'canceled','noncanceled','nostop','gowrong'};
targLocTypes = {'all','left','right'};
rewardAmountTypes = {'all','hi','lo'};

%% Get trial indices
clear tempttx rtTemp
tempttx.left = find(stateFlags.CurrTargIdx == 1);
tempttx.right = find(stateFlags.CurrTargIdx == 0);
tempttx.all = 1:max(stateFlags.TrialNumber);

tempttx.hi = find(stateFlags.IsHiRwrd == 1);
tempttx.lo = find(stateFlags.IsLoRwrd == 1);

tempttx.canceled = find(stateFlags.IsCancel == 1);
tempttx.noncanceled = find(stateFlags.IsNonCancelledNoBrk == 1 | stateFlags.IsNonCancelledBrk == 1);
tempttx.nostop = find(stateFlags.IsGoCorrect == 1);
tempttx.gowrong = find(stateFlags.IsGoErr == 1);

%% Find trials at each trial type, target location, and reward amount.
for trialTypeIdx = 1:length(trialTypes)
    trialType = trialTypes{trialTypeIdx};
    for targLocIdx = 1:length(targLocTypes)
        targLoc = targLocTypes{targLocIdx};
        for rewardAmountIdx = 1:length(rewardAmountTypes)
            rewardAmount = rewardAmountTypes{rewardAmountIdx};
            
            clear trialType_trialsLocation trialType_trialsReward
            trialType_trialsLocation = tempttx.(trialType)...
                (ismember(tempttx.(trialType),tempttx.(targLoc)));
            
            trialType_trialsReward = tempttx.(trialType)...
                (ismember(tempttx.(trialType),tempttx.(rewardAmount)));
            
            ttx.(trialType).(targLoc).(rewardAmount) =...
                trialType_trialsLocation(ismember...
                (trialType_trialsLocation,trialType_trialsReward));
            
        end
        
    end
end

for trialTypeIdx = 1:length(trialTypes)
    trialType = trialTypes{trialTypeIdx};
    for targLocIdx = 1:length(targLocTypes)
        targLoc = targLocTypes{targLocIdx};
        for rewardAmountIdx = 1:length(rewardAmountTypes)
            rewardAmount = rewardAmountTypes{rewardAmountIdx};
            

            ttx_value.(trialType).(targLoc).(rewardAmount) = ...
                ttx.(trialType).(targLoc).(rewardAmount)...
                (stateFlags.blockTrialNum(ttx.(trialType).(targLoc).(rewardAmount)) > 3);
            
        end
        
    end
end


%% Trial history
clear ttx_history

tempttx.nostopFiltered.all = find(stateFlags.IsGoCorrect == 1);
tempttx.nostopFiltered.hi = find(stateFlags.IsGoCorrect == 1 & stateFlags.IsHiRwrd == 1);
tempttx.nostopFiltered.lo = find(stateFlags.IsGoCorrect == 1 & stateFlags.IsLoRwrd == 1);

for rewardAmountIdx = 1:length(rewardAmountTypes)
    rewardAmount = rewardAmountTypes{rewardAmountIdx};
    
    clear pre_nostop_ttx
    pre_nostop_ttx.(rewardAmount) = tempttx.nostopFiltered.(rewardAmount) - 1;
    pre_nostop_ttx.(rewardAmount) = pre_nostop_ttx.(rewardAmount)(pre_nostop_ttx.(rewardAmount) > 0);
    
    ttx_history.(rewardAmount).C_before_NS = pre_nostop_ttx.(rewardAmount)(ismember(pre_nostop_ttx.(rewardAmount), ttx.canceled.all.(rewardAmount)));
    ttx_history.(rewardAmount).NC_before_NS = pre_nostop_ttx.(rewardAmount)(ismember(pre_nostop_ttx.(rewardAmount), ttx.noncanceled.all.(rewardAmount)));
    ttx_history.(rewardAmount).NS_before_NS = pre_nostop_ttx.(rewardAmount)(ismember(pre_nostop_ttx.(rewardAmount), ttx.nostop.all.(rewardAmount)));
    
    ttx_history.(rewardAmount).NS_after_C = ttx_history.(rewardAmount).C_before_NS + 1;
    ttx_history.(rewardAmount).NS_after_NC = ttx_history.(rewardAmount).NC_before_NS + 1;
    ttx_history.(rewardAmount).NS_after_NS = ttx_history.(rewardAmount).NS_before_NS + 1;
    
    
end


end
