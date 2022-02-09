function [BlocksRange, number_of_blocks] = getBlocksRange(Infos_)

Block_count = sort(unique(Infos_.Block_number));
number_of_blocks = length(Block_count);

for currentBlock = Block_count(1):Block_count(end)
    CurrBlock_TrialIndex = find(Infos_.Block_number == currentBlock);
    BlocksRange(currentBlock,:) = [CurrBlock_TrialIndex(1) CurrBlock_TrialIndex(end) ];
end

