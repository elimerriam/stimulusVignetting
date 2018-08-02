% modelOutput
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: modelOutput()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: compute and save model output for all modulated gratings
%
%%   uses stimuli created by makeStimuli.m
function [] = modelOutput()
%number of stimulus orientations
oris=16;
saveDir = '~/Documents/MATLAB/otopyPlus/prfSampling/';
clear stim im sumBands bandIm trigAvgBands sumBandsLev phaseAvgBands maxResponse

o=0;
modSquare = 1;
modSqString = 'Sin';
if modSquare
    modSqString = 'Sq';
end
load([saveDir 'modStimuli' modSqString '.mat'],'im','modSquare','oris','sf','f','numPhases','modulatorString','trigString');


%%

% build the pryamid
numOrientations = 4;
bandwidth = 0.5;
dims=size(im{1,1,1});
numLevels = maxLevel(dims,bandwidth);
% construct quad frequency filters
[freqRespsImag,freqRespsReal,temp]= makeQuadFRs(dims,numLevels,numOrientations,bandwidth);

% build pyramid for all images
pind = cell(size(im));
pyr = cell(size(im));
for modul=1:2
    sumBands{modul} = zeros([2 oris numPhases size(im{modul,1,1,1})]);
    for trig=1:2
        for ori=1:oris
            for phase=1:numPhases
                [pyr,pind]=buildQuadBands(im{modul,trig,ori,phase},freqRespsImag,freqRespsReal);
                for lev = 1:numLevels
                    sumBandsLev{modul,lev}(trig,ori,phase,:,:) = zeros(size(im{modul,1,1}));
                    for orientation = 1:numOrientations
                        % extract frequency response
                        thisBand = accessSteerBand(pyr,pind,numOrientations,lev,orientation);
                        bandIm = abs(thisBand).^2;
                        sumBands{modul}(trig,ori,phase,:,:) = squeeze(sumBands{modul}(trig,ori,phase,:,:))+bandIm;
                        sumBandsLev{modul,lev}(trig,ori,phase,:,:) = squeeze(sumBandsLev{modul,lev}(trig,ori,phase,:,:))+bandIm;
                    end
                end
            end
        end
    end
end

%%
save([saveDir 'modelOutput' modSqString '.mat'],'sumBands','sumBandsLev','modSquare','oris','sf','f','numPhases','numOrientations','bandwidth','dims','numLevels','-v7.3');

