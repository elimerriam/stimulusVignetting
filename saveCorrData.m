% saveCorrData
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: saveCorrData()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: save result of correlation analysis 
%
% saves data that is used by: makeFigure5

function [] = saveCorrData()

%% Go through all subjects, saving correlation analysis data for both modulators
ROIs = {'v1'};
subjListNYU_sq = {'co160316','rd160122','id160211','mr160315','sl160201'};%NYU subjects
subjListNIH_sq = {'s001020170817','s002220170821','s001320170727','s000220170227','s000320170309','s000420170825','s000520170330'}; 
subjListNIH_sin = {'s000520180111','s002220170818','s000120170512','s000220170316','s000320170323',  's000420170821','s001320170803'}; 

subjDir{1} = '/misc/data58/merriamep/data/nyuData/otopyPlus/';
subjDir{2} = '/misc/data58/merriamep/data/otopy/';
subjDir{3} = subjDir{2};
averageGroup = 3;

for ilist = 1:length(subjDir)
    eval(['cd ' subjDir{ilist}]);
    switch ilist
        case 1
            currentList = subjListNYU_sq;
        case 2
            currentList = subjListNIH_sq;
        case 3
            currentList = subjListNIH_sin;
    end
    for isub=1:length(currentList)
        mrQuit
        eval(['cd ' currentList{isub}]);
        v = getMLRView;
        clear corrData
        
        %extract correlation analysis results
        corrData = loadROIcoranalMatching(v,ROIs,1:2,averageGroup,1,1);
        
        %save the data
        dirname = '/Users/rothzn/data/otopy/';
        filename = [ currentList{isub} '_corr_v1.mat'];
        save([ dirname filename],'corrData');
        deleteView
        cd ..
    end
end
%save lists of all subjects
save('/Users/rothzn/data/otopy/subLists_corr.mat','subjListNYU_sq' ,'subjListNIH_sq','subjListNIH_sin','subjDir','ROIs');

    