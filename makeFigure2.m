% makeFigure2
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeFigure2()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: Demonstrates the vignetting effect with the original Freeman et al. (2011) grating stimuli
%
% create the vignetted gratings, provide them as input to the steerable
% pyramid, average model responses across grating phases, subtract
% horizontal from vertical to get the predicted orientation bias

function[] = makeFigure2()

% begin by creating the stimuli, gratings vignetted by annular apertures
oris=2;%number of stimulus orientations
clear stim im sumBandsLev sumBands bandIm trigAvgBands maxResponse maxResponseLev
o=0;
% number of grating phases
numPhases = 2;
sf = 0.5;

for ori=1:oris
    for phase=1:numPhases
        im{ori,phase} = otopyGetStimImage_noMod('whichOri',o + (ori-1)*(180-180/oris)/(oris-1),'phaseNum',phase,'numPhases',numPhases,'spatialFreq',sf);
    end
end

%%

% build the model, a steerable pryamid
numOrientations = 4;
bandwidth = 0.5;
dims=size(im{1,1});
numLevels = maxLevel(dims,bandwidth);
[freqRespsImag,freqRespsReal,temp]= makeQuadFRs(dims,numLevels,numOrientations,bandwidth);

%%
% build pyramid for all images
sumBands = zeros([oris numPhases size(im{1,1})]);
for ori=1:oris
    for phase=1:numPhases
        [pyr,pind]=buildQuadBands(im{ori,phase},freqRespsImag,freqRespsReal);
        for lev = 1:numLevels
            sumBandsLev{lev}(ori,phase,:,:) = zeros(size(im{1,1,1}));
            for orientation = 1:numOrientations
                % extract frequency response
                thisBand = accessSteerBand(pyr,pind,numOrientations,lev,orientation);
                bandIm{ori,phase,lev,orientation} = abs(thisBand).^2;
                sumBands(ori,phase,:,:) = squeeze(sumBands(ori,phase,:,:))+bandIm{ori,phase,lev,orientation};
                sumBandsLev{lev}(ori,phase,:,:) = squeeze(sumBandsLev{lev}(ori,phase,:,:))+bandIm{ori,phase,lev,orientation};
            end
        end
    end
end
clear thisBand phaseAvgBandsLev maxResponseLev

%average across phases
phaseAvgBands = squeeze(mean(sumBands,2));
for lev=1:numLevels
    phaseAvgBandsLev{lev} = squeeze(mean(sumBandsLev{lev},2));
end

% Get difference in response (vertical minus horizontal) for each pixel
diffResponse = squeeze(phaseAvgBands(1,:,:) - phaseAvgBands(2,:,:));
for lev=1:numLevels
    diffResponseLev{lev} = squeeze(phaseAvgBandsLev{lev}(1,:,:)-phaseAvgBandsLev{lev}(2,:,:));
    levDiff(lev) = max(diffResponseLev{lev}(:));
end

% find pyramid level with largest difference between orientations
[maxVal, maxLev] = max(levDiff);


%% PLOTS

% Plot vertical and horizontal responses
h1=figure(1);
rows = 1; cols = oris;
for ori=1:oris
    subplot(rows,cols,ori);
    imagesc(squeeze(phaseAvgBandsLev{maxLev}(ori,:,:)));
    axis image; axis off
end

%%

% Plot vertical-horizontal difference
h2=figure(2);
imagesc(diffResponseLev{maxLev});
set(gca,'xticklabel',[]); set(gca,'yticklabel',[]);
colormap gray
axis image
axis off


%% Plot the stimuli
h3=figure(3);
rows = oris;
cols = numPhases;
for ori=1:oris
    for phase=1:numPhases
        subplot(rows, cols, (phase-1)*oris + ori)
        imagesc(im{ori,phase})
        set(gca,'xticklabel',[]); set(gca,'yticklabel',[]);
        colormap gray
        axis image
        axis off
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[stim] = otopyGetStimImage_noMod(varargin)

% % evaluate the input arguments
getArgs(varargin, [], 'verbose=0');

% set default parameters
if ieNotDefined('whichOri'), whichOri = 90; end
if ieNotDefined('phaseNum'), phaseNum = 1; end
if ieNotDefined('numPhases'), numPhases = 1; end
if ieNotDefined('spatialFreq'), spatialFreq = 1.4; end

stimulus.phaseNum = phaseNum;
stimulus.numPhases = numPhases;

% open the screen
if mglGetParam('displayNumber') ~= -1,mglClose;end
mglSetParam('offscreenContext',1);
screenWidth = 1024;
screenHeight = 768;
mglOpen(0,screenWidth,screenHeight);
s.myscreen.displayDistance = 58;
s.myscreen.displaySize = [32 24.5];
mglVisualAngleCoordinates(s.myscreen.displayDistance,s.myscreen.displaySize);


% scale factor
stimulus.sFac = 1;

% spatial frequency
stimulus.sf = spatialFreq;
% stimulus.sf = 0.7;

% which phases we will have

stimulus.phases = 0:(360-0)/stimulus.numPhases:360;

% size of stimulus
s.myscreen.imageHeight = 23.7113;
stimulus.height = 0.5*floor(s.myscreen.imageHeight/0.5);
% stimulus.height = 9.5;
% stimulus.height = 23.5;
stimulus.width = stimulus.height;
stimulus.pixRes = 32.6911;

% size of annulus
stimulus.outer = 2*9.5;%stimulus.height;
stimulus.outTransition = 1;

stimulus.inner = 2*4.5;
stimulus.inTransition = 1;

% chose a sin or square
stimulus.square = 0;

% make a grating just to get the size
tmpGrating = mglMakeGrating(stimulus.width, stimulus.height, stimulus.sf, 0, stimulus.phases(1), stimulus.pixRes, stimulus.pixRes);
sz = size(tmpGrating,2);

% create mask for fixation and edge
out = stimulus.outer/stimulus.width;
in = stimulus.inner/stimulus.width;
twOut = stimulus.outTransition/stimulus.width;
twIn = stimulus.inTransition/stimulus.width;
finalmask = mkDisc(sz,(out*sz)/2,[(sz+1)/2 (sz+1)/2],twOut*sz,[1 0]);
fixationmask = mkDisc(sz,(in*sz)/2,[(sz+1)/2 (sz+1)/2],twIn*sz,[0 1]);

% rescale mask to max out at 1
mask = finalmask.*fixationmask;
mask = mask/max(mask(:));
mask(:,:,4) = (-1*(mask*255))+255;
mask(:,:,1:3) = 128;
mask = uint8(permute(mask, [3 1 2]));
stimulus.maskTex = mglCreateTexture(mask);

% make a grating again, but now scale it
tmpGrating = mglMakeGrating(stimulus.width/stimulus.sFac, stimulus.height/stimulus.sFac, stimulus.sf, 0, stimulus.phases(1), stimulus.pixRes, stimulus.pixRes);
sz = size(tmpGrating,2);


% initialize texture
r = uint8(permute(repmat(tmpGrating, [1 1 4]), [3 1 2]));
stimulus.tex = mglCreateTexture(r,[],1);

% make the grating
grating = mglMakeGrating(stimulus.width/stimulus.sFac, stimulus.height/stimulus.sFac, stimulus.sf*stimulus.sFac, ...
    whichOri, stimulus.phases(stimulus.phaseNum), stimulus.pixRes, stimulus.pixRes);

% make it a square wave
if stimulus.square==1
    grating = sign(grating);
end

% scale to range of display
grating = 255*(grating+1)/2;

% make it rgba
grating = uint8(permute(repmat(grating, [1 1 4]), [3 1 2]));
grating(4,:,:) = 256;

% update the texture
mglBindTexture(stimulus.tex, grating);

% clear the screen
mglClearScreen;
mglFillRect(0, 0, [screenHeight screenHeight],  [128 128 128]);
% draw the texture
mglBltTexture(stimulus.tex, [0 0 stimulus.height stimulus.height], 0, 0, 0);
mglBltTexture(stimulus.maskTex, [0 0 stimulus.height stimulus.height], 0, 0, 0);

% grab the screen
stim = mglFrameGrab;
stim = stim(:,:,1)';

% close screen
mglSetParam('offscreenContext',0);
mglClose;

end