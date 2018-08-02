% makeFigure3
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeFigure3()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: Demonstrates the vignetting effect with angular and radial modulated gratings
%
% create the modulated gratings, provide them as input to the steerable
% pyramid, average model responses across grating phases, subtract
% horizontal from vertical to get the predicted orientation bias for each
% modulator

function[] = makeFigure3()
%% Plots modulated gratings and the model output

%number of stimulus orientations
oris=2;

clear stim im sumBands bandIm trigAvgBands sumBandsLev phaseAvgBands maxResponse diffResponse

%modulator types
modulatorString = {'angular','radial'};
%modulator phases
trigString = {'cos','sin'};
% number of grating phases
numPhases = 2;
f=5;
modSquare = 0;
sf = 0.5;
for modul=1:2
    for trig=1:2
        for ori=1:oris
            for phase=1:numPhases
                [im{modul,trig,ori,phase} modulator{modul,trig} grating{ori,phase}] = otopyGetStimImage('modSquare',modSquare,'whichModulator', modulatorString{modul},'modSin', trigString{trig},'whichOri',(ori-1)*(180-180/oris)/(oris-1),'phaseNum',phase,'angFreq',f,'numPhases',numPhases,'spatialFreq',sf);
            end
        end
    end
end

%%

% build the pryamid
numOrientations = 4;
bandwidth = 0.5;
dims=size(im{1,1,1});
numLevels = maxLevel(dims,bandwidth);
% construct quad frequency filters
[freqRespsImag,freqRespsReal,temp]= makeQuadFRs(dims,numLevels,numOrientations,bandwidth);
%%
% build pyramid for all images
for modul=1:2
    sumBands{modul} = zeros([2 oris numPhases size(im{modul,1,1})]);
    for trig=1:2
        for ori=1:oris
            for phase=1:numPhases
                [pyr,pind]=buildQuadBands(im{modul,trig,ori,phase},freqRespsImag,freqRespsReal);
                for lev = 1:numLevels
                    sumBandsLev{modul,lev}(trig,ori,phase,:,:) = zeros(size(im{modul,1,1}));
                    for orientation = 1:numOrientations
                        % extract frequency response
                        thisBand = accessSteerBand(pyr,pind,numOrientations,lev,orientation);
                        bandIm{modul,trig,ori,phase,lev,orientation} = abs(thisBand).^2;
                        sumBands{modul}(trig,ori,phase,:,:) = squeeze(sumBands{modul}(trig,ori,phase,:,:))+bandIm{modul,trig,ori,phase,lev,orientation};
                        sumBandsLev{modul,lev}(trig,ori,phase,:,:) = squeeze(sumBandsLev{modul,lev}(trig,ori,phase,:,:))+bandIm{modul,trig,ori,phase,lev,orientation};
                    end
                end
            end
        end
    end
end

%%

temp = cell2mat(sumBands); m1 = max(temp(:));
% average the responses across sin/cos
for modul=1:2
    for ori=1:oris
        for phase=1:numPhases
            trigAvgBands{modul}(ori,phase,:,:) = squeeze(mean(sumBands{modul}(:,ori,phase,:,:)));
            for lev=1:numLevels
                trigAvgBandsLev{modul,lev}(ori,phase,:,:) = squeeze(mean(sumBandsLev{modul,lev}(:,ori,phase,:,:)));
            end
        end
    end
end
%average across phases
for modul=1:2
    for ori=1:oris
        phaseAvgBands{modul} = squeeze(mean(trigAvgBands{modul},2));
        for lev=1:numLevels
            phaseAvgBandsLev{modul,lev} = squeeze(mean(trigAvgBandsLev{modul,lev},2));
        end
    end
end

% Get difference in response (vertical minus horizontal) for each modulator
for modul=1:2
    diffResponse{modul} = squeeze(phaseAvgBands{modul}(1,:,:) - phaseAvgBands{modul}(2,:,:));
    for lev=1:numLevels
        diffResponseLev{modul,lev} = squeeze(phaseAvgBandsLev{modul,lev}(1,:,:)-phaseAvgBandsLev{modul,lev}(2,:,:));
    end
end

%% difference between modulators for each level
for lev=1:numLevels
    levDiff(lev) = max(diffResponseLev{1,lev}(:) - diffResponseLev{2,lev}(:));
end
% find pyramid level with largest difference between modulators
[maxVal, maxLev] = max(levDiff);

%% Modul vertcial and horizontal output for each stimulus
h1 = figure(1);
phase=1;
rows=2;
cols=4;
for modul=1:2
    for trig=1:2
        phase=1;
        for ori=1:oris
            subplot(rows,cols,(ori-1)*cols + (modul-1)*2 + trig)
            imagesc(squeeze(sumBandsLev{modul,maxLev}(trig,ori,phase,:,:)))
            set(gca,'xticklabel',[]); set(gca,'yticklabel',[]);
            colormap gray
            axis image
            axis off
        end
    end
end

%% Vertical minus Horizontal per modulator
h2=figure(2);
for modul=1:2
    subplot(1,2,modul)
    imagesc(diffResponseLev{modul,maxLev});
    colormap gray
    axis image
    axis off
end
%% Stimuli
h3=figure(3);
rows=2;
cols=4;
for modul=1:2
    for trig=1:2
        phase=1;
        for ori=1:oris
            subplot(rows,cols,(ori-1)*cols + (modul-1)*2 + trig)
            imagesc(im{modul,trig,ori,phase})
            set(gca,'xticklabel',[]); set(gca,'yticklabel',[]);
            colormap gray
            axis image
            axis off
        end
    end
end
set(gcf,'position',[200 200 1300 500])

end

