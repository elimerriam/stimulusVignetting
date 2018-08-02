% makeStimuli
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeStimuli()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: generate and save all modulated gratings

function [] = makeStimuli()
%% Creates modulated gratings and saves them in a matrix 
%number of stimulus orientations
oris=16;
saveDir = '~/Documents/MATLAB/otopyPlus/prfSampling/';
clear stim im sumBands bandIm trigAvgBands sumBandsLev phaseAvgBands maxResponse

o=0;
%modulator types
modulatorString = {'angular','radial'};
%modulator phases
trigString = {'cos','sin'};

% number of grating phases
numPhases = 8;
f=5;
modSquare = 1;

sf = 1.4;
%%
modSqString = 'Sin';
if modSquare
    modSqString = 'Sq';
end
for modul=1:2
    for trig=1:2
        for ori=1:oris
            for phase=1:numPhases
                [im{modul,trig,ori,phase} modulator{modul,trig} grating{ori,phase}] = otopyGetStimImage('modSquare',modSquare,'whichModulator', modulatorString{modul},'modSin', trigString{trig},'whichOri',o + (ori-1)*(180-180/oris)/(oris-1),'phaseNum',phase,'angFreq',f,'numPhases',numPhases,'spatialFreq',sf);
            end
        end
    end
end

save([saveDir 'modStimuli' modSqString '.mat'],'im','modSquare','oris','sf','f','numPhases','modulatorString','trigString');

