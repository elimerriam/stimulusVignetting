% otopyGetStimImage
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: img = otopyGetStimImage('modSquare=1','whichModulator=radial', 'modSin=cos', 'whichOri=90','phaseNum=1','angFreq=5','numPhases=2','spatialFreq=0.5');
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: creates a modulated grating
%
% used by: makeFigure3.m, makeStimuli.m

function[stim modulator origGrating] = otopyGetStimImage(varargin)

% % evaluate the input arguments
getArgs(varargin, [], 'verbose=0');

% set default parameters
if ieNotDefined('whichModulator'), whichModulator = 'radial'; end
if ieNotDefined('modSin'), modSin = 'cos'; end
if ieNotDefined('whichOri'), whichOri = 90; end
if ieNotDefined('modSquare'), modSquare = 1; end
if ieNotDefined('phaseNum'), phaseNum = 1; end
if ieNotDefined('angFreq'), angFreq = 4; end
if ieNotDefined('numPhases'),numPhases=1; end
if ieNotDefined('spatialFreq'), spatialFreq = 1.4; end
if ieNotDefined('outerEdge'), outerEdge = 2; end
if ieNotDefined('innerEdge'), innerEdge = 0.75; end

stimulus.whichModulator = whichModulator;
stimulus.modSin = modSin;
stimulus.modSquare = modSquare;
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
% stimulus.sf = 1.4;%1.4

stimulus.phases = 0:(360-0)/stimulus.numPhases:360;

% size of stimulus
s.myscreen.imageHeight = 23.7113;
stimulus.height = 0.5*floor(s.myscreen.imageHeight/0.5);
% stimulus.height = 23.5;
stimulus.width = stimulus.height;
stimulus.pixRes = 32.6911;

% size of annulus
stimulus.outer = stimulus.height- outerEdge;%stimulus.height-2
stimulus.outTransition = 0;

stimulus.inner = innerEdge;%0.75;
stimulus.inTransition = 0;

% chose a sin or square grating
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

% create the modulator
visualspace = linspace(-stimulus.width, stimulus.width, sz);
[x,y] = meshgrid(visualspace);
[th,rad] = cart2pol(x,y);


f=angFreq;
a = ((4*f+pi)/(4*f-pi))^(2/pi);
if strcmp(stimulus.whichModulator, 'angular')
    disp(sprintf('Angular modulator'));
    modulator = angFreq .* th;
elseif strcmp(stimulus.whichModulator, 'radial')
    disp(sprintf('Radial modulator'));
    modulator = log(rad)/log(a);
end

% sin or cos
if strcmp(stimulus.modSin, 'cos')
    modulator = cos(modulator);
else
    modulator = sin(modulator);
end

% square wave modulator or not
if stimulus.modSquare==1
    modulator(abs(modulator)<sin(pi/4)) = 0;
    modulator = sign(modulator);
end

% done
stimulus.modulator = modulator;

% initialize texture
r = uint8(permute(repmat(tmpGrating, [1 1 4]), [3 1 2]));
stimulus.tex = mglCreateTexture(r,[],1);


% make the grating
grating = mglMakeGrating(stimulus.width/stimulus.sFac, stimulus.height/stimulus.sFac, stimulus.sf*stimulus.sFac, ...
    whichOri, stimulus.phases(stimulus.phaseNum), stimulus.pixRes, stimulus.pixRes);

% make it a square wave grating
if stimulus.square==1
    grating = sign(grating);
end


origGrating = grating;
% scale to range of display
origGrating = 255*(origGrating+1)/2;
% make it rgba
origGrating = uint8(permute(repmat(origGrating, [1 1 4]), [3 1 2]));
origGrating(4,:,:) = 256;

% multiple by the modulator
grating = grating .* stimulus.modulator;

% scale to range of display
grating = 255*(grating+1)/2;

% make it rgba
grating = uint8(permute(repmat(grating, [1 1 4]), [3 1 2]));
grating(4,:,:) = 256;

% update the texture
mglBindTexture(stimulus.tex, grating);

%% DISPLAY MODULATED GRATING

% clear the screen
mglClearScreen;
mglFillRect(0, 0, [screenWidth screenHeight],  [128 128 128]);
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
