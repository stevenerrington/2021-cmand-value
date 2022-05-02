% Load in data map
load('C:\Users\Steven\Desktop\2021-tdt2mat\2021-dajo-datamap.mat')

% Define data directories
dirs.rawData = 'S:\Users\Current Lab Members\Steven Errington\2021_DaJo\mat\';
dirs.procData = 'S:\Users\Current Lab Members\Steven Errington\temp\dajo_sdf\';

nSessions = size(dajo_datamap,1);

% Looping through sessions
parfor sessionIdx = 1:nSessions
    fprintf('Analysing session %i of %i  |  %s    \n',...
        sessionIdx,size(dajo_datamap,1),dajo_datamap(sessionIdx,:).behInfo.dataFile)
    
    % Behaviour %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load behaviour file
    beh_data = load(fullfile(dirs.rawData, dajo_datamap.behInfo(sessionIdx).dataFile));
    
    % Get event timings
    ttx = [];
    [ttx, ~, ~] = processSessionTrials...
        (beh_data.events.stateFlags_, beh_data.events.Infos_);
    
    % Neural %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spk_file_prefix = dajo_datamap.session{sessionIdx}(1:end-9);
    spk_file_suffix = dajo_datamap.session{sessionIdx}(end-7:end);
    fileList = [];
    fileList = dir([dirs.procData spk_file_prefix '-*-' spk_file_suffix '*']);
    
    nNeurons_session = length(fileList);
    
    for neuronIdx = 1:nNeurons_session
        for trlIdx = 1:length(ttx.nostop.all.hi)
            
            
        end
        for trlIdx = 1:length(ttx.nostop.all.lo)
            
        end
        
        spkdata = load([dirs.procData fileList(neuronIdx).name]);
        
        datamapIdx = find(strcmp(...
            dajo_datamap.neurophysInfo{sessionIdx}.dataFilename,...
            fileList(neuronIdx).name(1:end-11)));
        
        area{sessionIdx,1}{neuronIdx,1} = dajo_datamap.neurophysInfo{sessionIdx}.area{datamapIdx};
        a{sessionIdx,1}(neuronIdx,:) = nanmean(spkdata.SDF.target(ttx.nostop.all.hi,:));
        b{sessionIdx,1}(neuronIdx,:) = nanmean(spkdata.SDF.target(ttx.nostop.all.lo,:));
        
    end
    
end


