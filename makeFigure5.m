% makeFigure5
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeFigure5()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: Plots preferred orientation for each voxel, for angular vs
%   radial modulators
%


function [] = makeFigure5()


%% Need to first run saveCorrData.m
% load list of subjects
load('/Users/rothzn/data/otopy/subLists_corr.mat','subjListNYU_sq', 'subjListNIH_sq','subjListNIH_sin','ROIs');
dirname = '/Users/rothzn/data/otopy/';

%initiate subject index
s=0;
clear ROIs phases corrs minCorrs
for ilist = 1:3
    switch ilist
        case 1
            currentList = subjListNYU_sq;
        case 2
            currentList = subjListNIH_sq;
        case 3
            currentList = subjListNIH_sin;
    end
    for isub=1:length(currentList)
        filename = [ currentList{isub} '_corr_v1.mat'];
        load([dirname filename],'corrData');
        s=s+1;
        for i=1:2% just 2 scans for the first ROI
            ROIs{i} = corrData{i}.name;
            phases{s}(i,:) = corrData{i}.ph;%preferred phase for each voxel
            corrs{s}(i,:) = corrData{i}.co;%coherence value for each voxel
        end
        minCorrs{s} = min(corrs{s}(1,:),corrs{s}(2,:));%minimum coherence per voxel
    end
end

%% pool voxel values across subjects
subs=s;
allMinCorrs = [];
allPhases = [];
figure(1)
for s=1:subs
    [sortedVals sortedVox] = sort(minCorrs{s});
    minCorrsSort{s} = minCorrs{s}(sortedVox);% list of minimum coherence
    phasesSort{s} = phases{s}(:,sortedVox);% list of preferred phase
    allMinCorrs = [allMinCorrs minCorrsSort{s}];% list of minimum coherence, pooled across subjects
    allPhases = [allPhases phasesSort{s}];% list of preferred phase, pooled across subjects
end

%% plot
%only plot voxels with coherence above threshold
corrThresh = 0.0;
f=figure(2);
plot(0:359,0:359,'k','linewidth',2);%main diagonal
plot(0:179, 180:359,'k','linewidth',2);%secondary diagonal, 90 degree shift
plot(180:359, 0:179,'k','linewidth',2);%secondary diagonal, 90 degree shift
%sort voxels by coherence
[allMinCorrsSort allSortedVox] = sort(allMinCorrs);
allPhasesSort = allPhases(:,allSortedVox);
goodVox = allMinCorrsSort>corrThresh;
dotplot(allPhasesSort(1,goodVox),allPhasesSort(2,goodVox),allMinCorrsSort(goodVox),allMinCorrsSort(goodVox).^2,3*(pi/180));
axis square
axis off
caxis([corrThresh 1]);
xlim([0 2*pi]);
ylim([0 2*pi]);
colormap jet

set(gcf,'position',[100 100 700 700])
