function postRT = getPostSlowing(Infos,ttx_history)

RT = []; RT = Infos.Decide_ - Infos.Target_;

rewardAmountTypes = {'all','hi','lo'};

    for rewardAmountIdx = 1:length(rewardAmountTypes)
        rewardAmount = rewardAmountTypes{rewardAmountIdx};
        
        postRT.(rewardAmount).noncanc = RT(ttx_history.(rewardAmount).NS_after_NC);
        postRT.(rewardAmount).canc = RT(ttx_history.(rewardAmount).NS_after_C);
        postRT.(rewardAmount).nostop = RT(ttx_history.(rewardAmount).NS_after_NS);

        % Find last no-stop trial in reward condition prior to error
        
        
        
        
        
        
    end
    

end
