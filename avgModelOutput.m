% avgModelOutput
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: avgModelOutput()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: average model output across modulator phase (sin/cos) and carrier phase
%

%% uses data saved by modelOutput.m

function [] = avgModelOutput()

%number of stimulus orientations
oris=16;
saveDir = '~/Documents/MATLAB/otopyPlus/prfSampling/';
o=0;
modSquare=1;
modSqString = 'Sin';
if modSquare
    modSqString = 'Sq';
end
load([saveDir 'modelOutput' modSqString '.mat'],'sumBands','sumBandsLev','modSquare','oris','sf','f','numPhases','numOrientations','bandwidth','dims','numLevels');%from modelOutput.m

%%
% average the responses across sin/cos
image=0;
trigAvgBands = cell(2,1);
trigAvgBandsLev = cell(2,numLevels);
temp = size(squeeze(sumBands{2}(1,:,:,:,:)));
for modul=1:2
    %pre-allocating matrices
    trigAvgBands{modul} = zeros(temp);
    for lev=1:numLevels
        trigAvgBandsLev{modul,lev}= zeros(temp);
    end
    
    for ori=1:oris
        for phase=1:numPhases
            image=image+1
            trigAvgBands{modul}(ori,phase,:,:) = squeeze(mean(sumBands{modul}(:,ori,phase,:,:)));
            for lev=1:numLevels
                trigAvgBandsLev{modul,lev}(ori,phase,:,:) = squeeze(mean(sumBandsLev{modul,lev}(:,ori,phase,:,:)));
            end
            sumBands{modul}(:,ori,phase,:,:) = zeros;%free up memory
            trigAvgBandsLev{modul,lev}(ori,phase,:,:) = zeros;%free up memory
        end
    end
    sumBands{modul} = [];%free up memory
    for lev=1:numLevels
        sumBandsLev{modul,lev} = [];%free up memory
    end
end
save([saveDir 'avgCosModelOutput' modSqString '.mat'],'trigAvgBands','trigAvgBandsLev','modSquare','oris','sf','f','numPhases','-v7.3');
clear sumBands sumBandsLev

%average across phases
for modul=1:2
    for ori=1:oris
        phaseAvgBands{modul} = squeeze(mean(trigAvgBands{modul},2));
        for lev=1:numLevels
            phaseAvgBandsLev{modul,lev} = squeeze(mean(trigAvgBandsLev{modul,lev},2));
        end
    end
end
%%
save([saveDir 'avgPhaseModelOutput' modSqString '.mat'],'phaseAvgBands','phaseAvgBandsLev','modSquare','oris','sf','f','numPhases','-v7.3');


