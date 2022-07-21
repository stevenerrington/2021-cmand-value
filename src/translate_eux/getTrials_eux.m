function [ttx,ttx_value] = getTrials_eux(data_in)
% Setup data
trialTypes = {'canceled','noncanceled','nostop','gowrong'};
targLocTypes = {'all','left','right'};
rewardAmountTypes = {'all','hi','lo'};

%% Get trial indices
clear tempttx rtTemp
tempttx.left = find(data_in.Infos_.Target_angle == 180);
tempttx.right = find(data_in.Infos_.Target_angle == 0);
tempttx.all = 1:length(data_in.Infos_.Target_angle);

tempttx.hi = find(data_in.Infos_.Reward_duration > 99);
tempttx.lo = find(data_in.Infos_.Reward_duration < 99);

tempttx.canceled = find(strcmp(data_in.Infos_.Trial_outcome,'nogo correct'));
tempttx.noncanceled = find(strcmp(data_in.Infos_.Trial_outcome,'nogo correct'));
tempttx.nostop = find(strcmp(data_in.Infos_.Trial_outcome,'nogo correct'));
tempttx.gowrong = find(strcmp(data_in.Infos_.Trial_outcome,'nogo correct'));

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
