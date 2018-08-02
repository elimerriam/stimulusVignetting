% saveOriData
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: saveOriData()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: save timecourses for orientation decoding
%
% saves data that is used by: makeFigure7a.m, makeFigure7b.m

function [] = saveOriData()
dirname = '/Users/rothzn/data/otopy/';
ROIs = {'v1'};
subjListNYU_sq = {'co160316','rd160122','id160211','mr160315','sl160201'};%NYU subjects
subjListNIH_sq = {'s001020170817','s002220170821','s001320170727','s000220170227','s000320170309','s000420170825','s000520170330'}; 
subjListNIH_sin = {'s000520180111','s002220170818','s000120170512','s000220170316','s000320170323',  's000420170821','s001320170803'}; 

subjDir{1} = '/misc/data58/merriamep/data/nyuData/otopyPlus/';
subjDir{2} = '/misc/data58/merriamep/data/otopy/';
subjDir{3} = subjDir{2};

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
        
        %get orientation timeseries
        numRuns=16;
        data = loadROITSeries(v,ROIs,1:16,2,'matchScanNum=1','matchGroupNum=1','keepNAN',true);
        filename = [ currentList{isub} '_timecourse_v1.mat'];
        
        junkFrames = 8;% junkFrames = viewGet(getMLRView, 'junkFrames', 1, 1)
        nFrames = 160;%nFrames = viewGet(getMLRView, 'nFrames', 1, 1)
        
        for i=1:length(data)
            data{i}.shorttSeries = data{i}.tSeries(:,junkFrames+1:junkFrames+nFrames);
            data{i}.percenttSeries = percentTSeries(data{i}.shorttSeries');
            data{i}.percenttSeries = data{i}.percenttSeries';
        end
        clear corrData
        corrData = loadROIcoranalMatching(v,ROIs,1:2,3,1,1);
        save([ dirname filename],'data','corrData');
        deleteView(v)
        cd ..
    end
end
keyboard
save('/Users/rothzn/data/otopy/subLists.mat','subjListNYU_sq' ,'subjListNIH_sq','subjListNIH_sin','subjDir','ROIs');

    