% makeFigure1
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: makeFigure1()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: Demonstrates stimulus vignetting on a vertical grating
%
% create a grating, transform it to Fourier space
% vignette the grating, either by a vertical or by a horizontal edge. 
% again look at the Fourier transform.
% add two filters to demonstrate how adding an edge can change the filter's response

function[] = makeFigure1()

% broadly tuned filter (in orientation and bandwidth)
numOrientations = 4; %number of orientations in the steerable pyramid
bandwidth = 1; %spatial frequency bandwidth
dims=[256 256];
numLevels = maxLevel(dims,bandwidth);
% construct quad frequency filters
[freqRespsImag,freqRespsReal,pind]= makeQuadFRs(dims,numLevels,numOrientations,bandwidth);
% and access the filter
lev = 4;
orientation = 1;
broadResp = abs(accessSteerBand(freqRespsReal,pind,numOrientations,lev,orientation)).^2;

% narrowly tuned filter
numOrientations = 30;
bandwidth = 2.2;
numLevels = maxLevel(dims,bandwidth);
% construct quad frequency filters
[freqRespsImag,freqRespsReal,pind]= makeQuadFRs(dims,numLevels,numOrientations,bandwidth);
% access the filter
lev = 2;
narrowResp = abs(accessSteerBand(freqRespsReal,pind,numOrientations,lev,orientation)).^2;


% create grating
gratingSize = dims(1);
gratingFreq = 32;
gratingDirection = pi; %pi/4;
zoomFactor = 8;

%% Infinite boundary grating
grating = mkSine(gratingSize, gratingFreq, gratingDirection);
figure(1)
colormap(gray)
subplot(3,2,1)
imagesc(grating) %plot the grating
axis image; axis off
title('Infinite boundary')

subplot(3,2,2)
%plot the fourier transform of the grating
imagesc(1-sqrt(abs(fftshift(fft2(grating)))));
axis image;  axis off
hold on
filterThresh = 0.1;
narrowContour = contourc(1:gratingSize, 1:gratingSize, narrowResp, ones(50,1)*filterThresh);
plot(narrowContour(1,2:length(narrowContour)/2), narrowContour(2,2:length(narrowContour)/2), 'color', 'green', 'linewidth',2)
plot(narrowContour(1,2+length(narrowContour)/2:end), narrowContour(2,2+length(narrowContour)/2:end), 'color', 'green','linewidth',2)
axis off
broadContour = contourc(1:gratingSize, 1:gratingSize, broadResp,ones(50,1)*filterThresh);
plot(broadContour(1,2:length(broadContour)/2), broadContour(2,2:length(broadContour)/2), 'color', 'red','linewidth',2)
plot(broadContour(1,2+length(broadContour)/2:end), broadContour(2,2+length(broadContour)/2:end), 'color', 'red','linewidth',2)
axis off
zoom(zoomFactor)

%% Vertical aperture
subplot(3,2,3)
grating = mkSine(gratingSize, gratingFreq, gratingDirection);
grating(:, gratingSize/2:end) = 0;
imagesc(grating);
axis image; axis off
title('Vertical aperture')

subplot(3,2,4); cla
imagesc(1-sqrt(abs(fftshift(fft2(grating)))));
hold on
% narrow filter
plot(narrowContour(1,2:length(narrowContour)/2), narrowContour(2,2:length(narrowContour)/2), 'color', 'green', 'linewidth',2)
plot(narrowContour(1,2+length(narrowContour)/2:end), narrowContour(2,2+length(narrowContour)/2:end), 'color', 'green','linewidth',2)
axis off
% broad filter
plot(broadContour(1,2:length(broadContour)/2), broadContour(2,2:length(broadContour)/2), 'color', 'red','linewidth',2)
plot(broadContour(1,2+length(broadContour)/2:end), broadContour(2,2+length(broadContour)/2:end), 'color', 'red','linewidth',2)
set(gca, 'xtick', [], 'ytick', []);
axis off
axis image
zoom(zoomFactor)


%% Horizontal aperture
subplot(3,2,5)
grating = mkSine(gratingSize, gratingFreq, gratingDirection);
grating(gratingSize/2:end,:) = 0;
imagesc(flipud(grating));
axis off
title('Horizontal aperture')

subplot(3,2,6); cla
imagesc(1-sqrt(abs(fftshift(fft2(grating)))));
hold on
plot(narrowContour(1,2:length(narrowContour)/2), narrowContour(2,2:length(narrowContour)/2), 'color', 'green', 'linewidth',2)
plot(narrowContour(1,2+length(narrowContour)/2:end), narrowContour(2,2+length(narrowContour)/2:end), 'color', 'green','linewidth',2)
axis off
plot(broadContour(1,2:length(broadContour)/2), broadContour(2,2:length(broadContour)/2), 'color', 'red','linewidth',2)
plot(broadContour(1,2+length(broadContour)/2:end), broadContour(2,2+length(broadContour)/2:end), 'color', 'red','linewidth',2)
axis off
axis image
zoom(zoomFactor)

set(gcf, 'position', [100 100 510 800]);


