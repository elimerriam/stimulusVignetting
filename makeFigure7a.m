% makeFigure7a
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeFigure7a()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: decode orientation
%
%   uses data saved by saveOriData.m 

function [] = makeFigure7a()

dirname = '/Users/rothzn/data/otopy/';
load([dirname 'subLists.mat'],'subjListNYU_sq','subjListNIH_sq','subjListNIH_sin','subjDir','ROIs');%saved by saveOriData.m

%Numbering radial and angular runs
angularRuns = [1:4 9:12];% spokes
radialRuns = [5:8 13:16];% rings
%total number of runs (both modulators)
numRuns=16;
numROIs=length(ROIs);
%number of TRs in a cycle
cycleTRs=16;
currentSub=0;

for ilist = 1:3
    switch ilist
        case 1
            currentList = subjListNYU_sq;
        case 2
            currentList = subjListNIH_sq;
        case 3
            currentList = subjListNIH_sin;
    end
    clear expTC avgTC projCoef projTC projCoef2 projTC2
    for isub=1:length(currentList)
        currentSub = currentSub+1
        filename = [ currentList{isub} '_timecourse_v1.mat'];
        load([ dirname filename],'data','corrData');
        
        %transform the data into one array per ROI
        for i=1:length(data)
            if i==1
                [numVoxels numTRs] = size(data{i}.percenttSeries);
                allTC = zeros(numVoxels,numRuns*numTRs);
            end
            if mod(i,2)==1 %& runNum~=7 & runNum~=15 %counterclockwise, invert and shift the timecourse
                data{i}.percenttSeries = data{i}.percenttSeries(:,end:-1:1);
                data{i}.percenttSeries = circshift(data{i}.percenttSeries,[0 6]);
            end
            data{i}.percenttSeries = zscore(data{i}.percenttSeries,0,2);
            %combine all runs together
            cycleTS = reshape(data{i}.percenttSeries,numVoxels,cycleTRs,numTRs/cycleTRs);
            %average over cycles within a run
            allTC(:,(i-1)*cycleTRs+1:i*cycleTRs) = mean(cycleTS,3);
        end
        %since we averaged over cycles
        numTRs = cycleTRs;
        cycles = numTRs/cycleTRs;
        %remove voxels with NaNs
        allTC(isnan(mean(allTC,2)),:) = [];
        
        %% decode within modulator type, radial/angular
        for runType=1:2
            if runType==1
                runs = radialRuns;
            else
                runs = angularRuns;
            end
            testLabels = repmat(1:cycleTRs,1,cycles)';
            trainLabels = repmat(1:cycleTRs,1,cycles*(length(runs)-1))';
            for r=1:length(runs)%make a single array for this roi & run type.
                expTC{isub,runType}(:,(r-1)*numTRs+1:r*numTRs) = allTC(:,(runs(r)-1)*numTRs+1:runs(r)*numTRs);
            end
            %compute an average timecourse for each voxel, across all runs
            for timePoint = 1:numTRs
                avgTC{isub,runType}(:,timePoint) = mean(expTC{isub,runType}(:,timePoint:numTRs:end),2);
            end
            for r=1:length(runs)
                testData = expTC{isub,runType}(:,(r-1)*numTRs+1:r*numTRs);
                trainData = expTC{isub,runType}(:,[1:(r-1)*numTRs r*numTRs+1:end]);
                
                class = classify(testData',trainData',trainLabels,'diaglinear');
                accuracy = sum(class == testLabels)/length(class);
                score(runType,r) = accuracy*100;
            end
        end
        radialScore = squeeze(score(1,:));
        angularScore = squeeze(score(2,:));
        for runType=1:2
            if runType==1
                runs = radialRuns;
            else
                runs = angularRuns;
            end
            [numVoxels ~] = size(expTC{isub,runType});
        end
        %% Cross-decoding between run types
        for runType=1:2%runtype 1: train on radial, test on angular
            clear runs
            runs{runType} = radialRuns;
            runs{3-runType} = angularRuns;
            testLabels = repmat(1:cycleTRs,1,cycles*(length(runs{1})))';
            trainLabels = testLabels;
            %shifting one run type by half a cycle
            shiftedTestLabels = circshift(testLabels,cycleTRs/2);
            
            clear trainTC testTC
            for r=1:length(runs{1})%make a single array for this run type.
                trainTC(:,(r-1)*numTRs+1:r*numTRs) = allTC(:,(runs{1}(r)-1)*numTRs+1:runs{1}(r)*numTRs);
                testTC(:,(r-1)*numTRs+1:r*numTRs) = allTC(:,(runs{2}(r)-1)*numTRs+1:runs{2}(r)*numTRs);
            end
            class = classify(testTC',trainTC',trainLabels,'diaglinear');
            accuracy = sum(class == testLabels)/length(class);
            betweenScore(runType) = accuracy*100;
            accuracy = sum(class == shiftedTestLabels)/length(class);
            shiftBetweenScore(runType) = accuracy*100;
        end
        listScore{ilist}(isub,1) = mean(squeeze(score(1,:)));
        listScore{ilist}(isub,2) = mean(squeeze(score(2,:)));
        listScore{ilist}(isub,3) = squeeze(betweenScore(1));
        listScore{ilist}(isub,4) = squeeze(betweenScore(2));
        listScore{ilist}(isub,5) = squeeze(shiftBetweenScore(1));
        listScore{ilist}(isub,6) = squeeze(shiftBetweenScore(2));
        allScore(currentSub,:) = listScore{ilist}(isub,:);
    end
end
%% dot plot - combine across subjects and average across modulators
clear smallScore
for analysis=1:3
    smallScore(:,analysis) = mean(allScore(:,(analysis-1)*2+1:analysis*2),2);
end
subs = size(allScore,1);
anals = size(smallScore,2);
[analNum, subNum] = meshgrid(1:anals, 1:subs);

f=figure;
scatter(analNum(:),smallScore(:), 40, subNum(:));
hold on
lineLength = 0.3;
lineWidth = 3;
for i=1:anals
    line([i-lineLength/2 i+lineLength/2], [mean(smallScore(:,i)) mean(smallScore(:,i))], 'color','k','linewidth',lineWidth);
end
line([0 7],[ 100/16 100/16],'color','k','linestyle','--');
axis([0.5 3.5 0 60]);
set(gcf, 'position', [100 100 400 400]);
set(gca,'XTick',[]);
ylabel('Accuracy %');
set(gca,'FontSize',18');
colormap 'jet'

