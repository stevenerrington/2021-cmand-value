
if ismac
    dirs.rawData.EuX = '/Volumes/Alpha/data/2012_Cmand_EuX/';
    dirs.rawData.DaJo = '/Volumes/Alpha/data/2021_Cmand_DaJo/';
    dirs.root = '/Users/stevenerrington/Desktop/Projects/2021-ssrt-value/';
    dirs.procData = '/Users/stevenerrington/Desktop/Projects/2021-ssrt-value/data';
    
    fprintf('! : Raw data is stored on a network drive and speeds may be slower \n');
       
else
    dirs.rawData.EuX = 'D:\data\2012_Cmand_EuX\';
    dirs.rawData.DaJo = 'D:\data\2021_Cmand_DaJo\';
    dirs.root = 'D:\projectCode\project_valueStopping\';
    dirs.procData = 'D:\projectCode\project_valueStopping\data\';
    
end