% makeFigure7b
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeFigure7b()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: perform multidimensional scaling and plot result
%
%   uses data saved by saveOriData.m 

function [] = makeFigure7b()

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
dirname = '~/data/otopy/';
totalSub=0;
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
        totalSub = totalSub+1;%counting  all subjects, across lists
        filename = [ currentList{isub} '_timecourse_v1.mat'];
        load([ dirname filename],'data');
        
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
        %remove voxels with NaNs
        allTC(isnan(mean(allTC,2)),:) = [];
        numTRs = cycleTRs;
        cycles = numTRs/cycleTRs;
        
        % average timeseries within modulator type, radial/angular
        for runType=1:2
            if runType==1
                runs = radialRuns;
            else
                runs = angularRuns;
            end
            for r=1:length(numRuns)%make a single array for this roi & run type.
                expTC{isub,runType}(:,(r-1)*numTRs+1:r*numTRs) = allTC(:,(runs(r)-1)*numTRs+1:runs(r)*numTRs);
            end
            %compute an average timecourse for each voxel, across all runs
            for timePoint = 1:numTRs
                avgTC{isub,runType}(:,timePoint) = mean(expTC{isub,runType}(:,timePoint:numTRs:end),2);
            end
        end
        %combine both modulators
        avgTCbothMods{isub} = [avgTC{isub,1} avgTC{isub,2}];%
        %create RDM for this subject
        rdm(totalSub,:) = pdist(avgTCbothMods{isub}','correlation');
        
    end
    
end
%average RDMs across subjects
groupRdm = squeeze(mean(rdm(:,:)));

%%
markerSize = 40;
maxAngle = pi;
dAngle = maxAngle/16;

lineAngles = [0:dAngle:maxAngle-0.001];


origLineAngles = repmat(lineAngles,1,2);
shiftLineAngles = [lineAngles lineAngles(9:16) lineAngles(1:8)];
lineLength = 0.1;
lineWidth = 4;
cMap = jet(256);

%% Multidimensional Scaling
mds = mdscale(squareform(groupRdm),2);
axRange = max(abs(mds(:))) + 2*lineLength;

%% PLOT
f=figure;
subplot(1,2,1)
for iline=1:size(mds,1)
    x = mds(iline,1);
    y = mds(iline,2);
    drawOriLine(x, y, origLineAngles(iline), lineLength, lineWidth, cMap(1+floor(origLineAngles(iline)*256/maxAngle),:));
    hold all
end
axis([-axRange axRange -axRange axRange]);
axis square
box on
set(gca,'XTick',[]);
set(gca,'YTick',[]);

subplot(1,2,2)
for iline=1:size(mds,1)
    x = mds(iline,1);
    y = mds(iline,2);
    drawOriLine(x, y, shiftLineAngles(iline), lineLength, lineWidth, cMap(1+floor(shiftLineAngles(iline)*256/maxAngle),:));
    hold all
end
axis([-axRange axRange -axRange axRange]);
axis square
box on
set(gca,'XTick',[]);
set(gca,'YTick',[]);


