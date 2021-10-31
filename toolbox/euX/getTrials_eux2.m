function [ttx,ttx_value] = getTrials_eux2(stateFlags)
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
