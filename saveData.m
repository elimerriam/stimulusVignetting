% saveData
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: saveData()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: Save correlation analysis (i.e. orientation preference) and pRF analysis for all subjects
%

function [] = saveData()

%% SAVE both correlation analysis and pRF analysis for all subjects
ROIs = {'v1'};

subListSq = {'mr160315','sl160201','co160316', 'id160211','rd160122','s001020170817','s002220170821','s001320170727','s000220170227','s000320170309','s000420170825','s000520170330'}; 
subListSin = {'s000520180111','s002220170818','s000120170512','s000220170316','s000320170323',  's000420170821','s001320170803'}; 
nyuDir = '/misc/data58/merriamep/data/nyuData/otopyPlus';
nihDir = '/misc/data58/merriamep/data/otopy/';
saveDir = '/Users/rothzn/data/prfSampling/';
for modSquare = 0:1%0=sine modulator, 1=square modulator
    modSqString = 'Sin';
    if modSquare
        modSqString = 'Sq';
    end
    if modSquare
        subList = subListSq;
    else
        subList = subListSin;
    end
    for isub=1:length(subList)
        subDir = nihDir;
        mrQuit
        clear corrData
        otopyGroup = 3;
        prfGroup = 4;
        if strcmp(subList{isub},'mr160315') |  strcmp(subList{isub},'co160316') | strcmp(subList{isub},'id160211') | strcmp(subList{isub},'rd160122')
            prfGroup = 5;
            subDir = nyuDir;
            eval(['cd ' subDir]);
        end
        if strcmp(subList{isub},'sl160201')
            prfGroup = 4;
            subDir = nyuDir;
        end
        eval(['cd ' subDir]);
        eval(['cd ' subList{isub}]);
        v = newView;
        v = viewSet(v, 'curGroup', otopyGroup);
        v = loadAnalysis(v, 'corAnal/corAnal.mat');
        corrData = loadROIcoranalMatching(v,ROIs,1:2,otopyGroup,1,prfGroup);%matched to prf scan
        v = viewSet(v, 'curGroup', prfGroup);
        v = loadAnalysis(v, 'pRFAnal/pRF.mat');
        prfData = loadPRFMatching(v, ROIs, 1, prfGroup, 1, prfGroup);
        deleteView(v)
        dirname = saveDir;
        filename = [ subList{isub} '.mat'];
        save([ dirname filename],'corrData','prfData');
        mrQuit;
        cd ..
    end
    save([saveDir 'subLists_' modSqString '.mat'],'subList','dirname','ROIs');
end
