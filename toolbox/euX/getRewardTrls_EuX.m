function [LowRew_Index, HighRew_Index] = getRewardTrls_EuX(Infos_)


%% INHERITED CODE.

TrialNum = length(Infos_.Target_angle);
[BlocksRange, NBlocks] = getBlocksRange(Infos_);
RIGHT = (Infos_.Target_angle == 0);
LEFT = (Infos_.Target_angle == 180);

%% LowRew_index calculation:
    LowRew_Index = zeros(TrialNum,1);
    HighRew_Index = zeros(TrialNum,1);
    LowRewMat = [];
    HighRewMat = [];
  
 for block = 1:NBlocks    % for each block do:
     CorrectTrials = (strcmp(Infos_.Trial_outcome(BlocksRange(block,1):BlocksRange(block,2)) , 'go correct') == 1 | strcmp(Infos_.Trial_outcome(BlocksRange(block,1):BlocksRange(block,2)) , 'nogo correct') );   % This gives the correct trials in that block;
     rewardAmount_all = Infos_.Reward_duration(BlocksRange(block,1):BlocksRange(block,2));  % This tells us all the reward amounts for correct trials
     % note that correct trials are the reliable ones for detecting which
     % side is associated with what reward amount.
     corrRewardAmount = rewardAmount_all(CorrectTrials);
     rewardsInBlock = unique(corrRewardAmount);         % this gives the unique reward amounts in the block! 
     rewardsInBlock = reshape(rewardsInBlock,1,length(rewardsInBlock));  
     
     % The logic is: we take the mean of the reward values. Low reward will
     % be lower than the mean, while High reward will be higher than the
     % mean. 
     lowcount = 0;
     highcount = 0;
         for i = 1:length(rewardsInBlock);                       % for all the reward amounts in the block:
             if rewardsInBlock(i) < mean(rewardsInBlock)         % assuming that low reward in a block is always lower than the mean of reward amounts! This is reasonable unless something awfully weird happened in the block!
                 lowcount = lowcount + 1;
                 % LowRewMat = [LowRewMat  rewardsInBlock(i)];     % These are the LowRewMat  
                 LowRewMat(lowcount) = rewardsInBlock(i);                    % This is out low reward amount!! 
                 % LowBlockIndex = [LowBlockIndex block];
             else
                 highcount = highcount + 1;
%                  HighRewMat = [HighRewMat  rewardsInBlock(i)];  % this marks all the "high rewards"
%                  HighBlockIndex = [HighBlockIndex block];
                 HighRewMat(highcount) = rewardsInBlock(i);                    % This is out high reward amount!! 
             end
         end

         % Now let's match the reward amounts for LEFT side with High vs.
         % LOW. 
         
        leftTrials = LEFT(BlocksRange(block,1):BlocksRange(block,2));    % Let's look at the left-side trials. This is ALL Left-ward trials, irrespective of whether correct or not! 
        rewardedLeftTrials = (CorrectTrials .* leftTrials);             % These are the REWARDED, LEFT side trials.
        rew_LeftTrials = rewardAmount_all(rewardedLeftTrials==1);            % let's get the reward amount only for those trials. Specific to the block!

        rightTrials = RIGHT(BlocksRange(block,1):BlocksRange(block,2));   % This is all right-ward trials, irrespective of whether correct or not! 
        rewardedRightTrials = (CorrectTrials .* rightTrials);
        rew_RightTrials = rewardAmount_all(rewardedRightTrials==1);
        
%         rewards4ThisBlock_Low = unique( LowRewMat( LowBlockIndex == block));
%         rewards4ThisBlock_High = unique( HighRewMat( HighBlockIndex == block));

        if sum(ismember(rew_LeftTrials, LowRewMat )) == length(rew_LeftTrials)      % if the reward amount for correct LEFT trials = Low reward:  
           % Then for this block ... (range defined by BlocksRange)
           % LEFT trials are LOW ...
           % RIGHT trials are HIGH
                     
           LowRew_Index(  BlocksRange(block,1):BlocksRange(block,2) ,1) =  leftTrials;    % Low reward trials = left trials (which are only specific to that block)
           HighRew_Index( BlocksRange(block,1):BlocksRange(block,2) ,1) = rightTrials;    % High reward trials = right trials (specific to that block only)
           
        elseif   sum(ismember(rew_RightTrials, LowRewMat )) == length(rew_RightTrials)     % if the reward amount for correct LEFT trials = High reward:
           % Then for this block ... (range defined by BlocksRange)
           % RIGHT trials are LOW ...
           % LEFT trials are HIGH
           LowRew_Index(  BlocksRange(block,1):BlocksRange(block,2) ,1) =  rightTrials;   % 
           HighRew_Index( BlocksRange(block,1):BlocksRange(block,2) ,1) =   leftTrials;
        end
        
        
        
 end
  