function [stateFlags, Infos] = tranEuX_to_new(data_in, eux_metadata, sessionIdx)
% translate old data into new format
stateFlags.CurrTargIdx = data_in.Infos_.Target_angle == 0;

stateFlags.TrialNumber = 1:length(stateFlags.CurrTargIdx)';

stateFlags.IsCancel = ismember(stateFlags.TrialNumber,eux_metadata.executiveBeh.ttx_canc{sessionIdx})';
stateFlags.IsNonCancelledNoBrk = ismember(stateFlags.TrialNumber,eux_metadata.executiveBeh.ttx.sNC{sessionIdx})';
stateFlags.IsNonCancelledBrk = ismember(stateFlags.TrialNumber,eux_metadata.executiveBeh.ttx.NC{sessionIdx})';
stateFlags.IsGoCorrect = ismember(stateFlags.TrialNumber,eux_metadata.executiveBeh.ttx.GO{sessionIdx})';
stateFlags.IsGoErr = strcmp(data_in.Infos_.Trial_outcome,'inaccurate sacc');


[stateFlags.IsLoRwrd, stateFlags.IsHiRwrd] = getRewardTrls_EuX(data_in.Infos_);



trlN = 0;
for blk = 1:max(data_in.Infos_.Block_number)
    clear blktrls; blktrls = find(data_in.Infos_.Block_number == blk);
    count = 0;    
    blk_rwdValues = unique(data_in.Infos_.Reward_duration(blktrls));
    
    for trl = 1:length(blktrls)
        count = count + 1;
        trlN = trlN + 1; 
        stateFlags.blockTrialNum(trlN,1) = count;
    end
end

Infos.Decide_ = data_in.Decide_; Infos.Target_ = data_in.Target_;

refreshRate = 1000/70;
stateFlags.UseSsdVrCount = round(data_in.Infos_.Curr_SSD/refreshRate);

nostopTrls = isnan(data_in.StopSignal_);
stateFlags.UseSsdVrCount(nostopTrls) = NaN;



end
