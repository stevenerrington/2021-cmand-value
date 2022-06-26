
if ismac
    dirs.rawData.EuX = '/Users/stevenerrington/Desktop/Projects/2021-ssrt-value/data';
    dirs.rawData.DaJo = '/Users/stevenerrington/Desktop/Projects/2021-ssrt-value/data';
    dirs.procData = '/Users/stevenerrington/Desktop/Projects/2021-ssrt-value/data';
    
    fprintf('! : Raw data is typically not stored on the laptop and may need to be re-referenced \n');
       
else
    dirs.rawData.EuX = 'D:\data\2012_Cmand_EuX\';
    dirs.rawData.DaJo = 'D:\data\2021_Cmand_DaJo\';
    dirs.procData = 'D:\projectCode\project_valueStopping\data\';
    
end