% makeFigure6
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeFigure6()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: Plots predicted orientation preference vs measured orientation
%   preference, for all V1 voxels. Prediction is made by sampling the model
%   output with the voxel's population receptive field (pRF).
%
%   before running this script, need to 
%   run: saveData.m, makeStimuli.m, modelOutput.m, avgModelOutput.m, and savePrfModel.m, 
%   in that order.

%% uses data saved by savePrfModel.m
function [] = makeFigure6()
%%
allMinCo=[]; allPh=[]; allCo=[]; allRFphase=[]; allR2=[]; allRFphaseLev=[];
for modSquare=0:1
    modSqString = 'Sin';
    if modSquare
        modSqString = 'Sq';
    end
    %% LOAD data saved by savePrfModel.m
    load(['/Users/rothzn/data/prfSampling/prfModel_' modSqString '.mat'],'subList','dirname','ROIs','rfPhaseLev','rfAmpLev','rfPhase','rfAmp','rfResp','rfRespLev',...
        'dataPh','dataCo','dataMinCo','prfR2','prfPolar','prfEccen','prfSize','maxLev');
    %% Correlate actual sinusoidal fit vs. model sinusoidal fit, for each voxel pRF
    clear dataMinCoSort dataPhSort dataCoSort prfR2Sort rfPhaseLevSort rfPhaseSort
    for isub=1:length(subList)
        for roi=1:1%length(ROIs)
            %sort voxels according to correlation value
            [sortedVals sortedVox] = sort(dataMinCo{isub,roi});
            dataMinCoSort{isub,roi} = dataMinCo{isub,roi}(sortedVox);%=sortedVals;
            dataPhSort{isub,roi} = dataPh{isub,roi}(sortedVox,:);
            dataCoSort{isub,roi} = dataCo{isub,roi}(sortedVox,:);
            prfR2Sort{isub,roi} = prfR2{isub,roi}(sortedVox,:);

            rfPhaseLevSort{isub,roi}(:,maxLev,:) = rfPhaseLev{isub,roi}(:,maxLev,sortedVox);
            
            allMinCo = [allMinCo; dataMinCoSort{isub,roi}];
            allPh = [allPh; dataPhSort{isub,roi}];
            allCo = [allCo; dataCoSort{isub,roi}];
            allRFphaseLev = [allRFphaseLev; squeeze(rfPhaseLevSort{isub,roi}(:,maxLev,:))'];
            allR2 = [ allR2; prfR2Sort{isub,roi}];
        end
    end
end

%% Plot all subjects pooled together 
[sortedVals sortedVox] = sort(allMinCo);
allMinCoSort = allMinCo(sortedVox);%=sortedVals;
allPhSort=allPh(sortedVox,:);
allCoSort=allCo(sortedVox,:);
allRFphaseSort=allRFphaseLev(sortedVox,:);
allR2Sort = allR2(sortedVox,:);
modulator = {'angular','radial'};
corrThresh = 0.0;
goodVox = allMinCoSort>corrThresh & ~isnan(sum(allRFphaseSort,2));

for modul=1:2
    f=figure;
    dotplot(allRFphaseSort(goodVox,modul),allPhSort(goodVox,modul),allMinCoSort(goodVox),allMinCoSort(goodVox).^2,0.05);
    axis square
    axis off
    xlabel('Model'); ylabel('Data');
    title(modulator{modul});
    colormap 'jet'
    set(gcf,'position',[100 100 700 700])
end

f=figure;
dotplot(allRFphaseSort(goodVox,2),allRFphaseSort(goodVox,1),allMinCoSort(goodVox),allMinCoSort(goodVox).^2,0.05);
axis square
axis off
xlabel('Model - radial')
ylabel('Model - angular')
set(gcf,'position',[120 120 700 700])
