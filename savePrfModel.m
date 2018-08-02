% savePrfModel
% 
% associated with the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). 
% Stimulus vignetting and orientation selectivity in human visual cortex. 
% DOI: 10.7554/eLife.37241
%
%   usage: savePrfModel()
%   by: zvi roth and eli merriam
%   date: 7/25/2018
%   purpose: Use each voxel's pRF as a mask to sample model output, and
%   get a predicted orientation tuning curve and preferred orientation
%
%% uses data saved by avgModelOutput.m and by saveData.m

function [] = savePrfModel()
%%
saveDir = '~/Documents/MATLAB/otopyPlus/prfSampling/';
dataDir = '/Users/rothzn/data/prfSampling/';

for modSquare=0:1%0=sine modulator, 1=square modulator
    clear dataPh dataCo dataMinCo prfR2 prfPolar prfEccen prfSize rfResp rfRespLev rfPhase rfAmp rfPhaseLev rfAmpLev
    modSqString = 'Sin';
    if modSquare
        modSqString = 'Sq';
    end
    %load data saved by avgModelOutput.m
    load([saveDir 'avgPhaseModelOutput' modSqString '.mat'],'phaseAvgBands','phaseAvgBandsLev','modSquare','oris','sf','f','numPhases');
    keyboard
    numLevels = size(phaseAvgBandsLev,2);
    %% Find level with maximal difference between modulators
    for lev=1:numLevels
        for modul=1:2
            ver = squeeze(phaseAvgBandsLev{modul,lev}(1,:,:));
            hor = squeeze(phaseAvgBandsLev{modul,lev}(1+oris/2,:,:));
            oriDiff{modul} = ver-hor;
        end
        temp = oriDiff{1}-oriDiff{2};
        modulDiff(lev,:,:) = temp;
        maxModulDiff(lev) = max(temp(:));
    end
    [tmp, maxLev] = max(maxModulDiff);
    
    %% Grids for defining a Gaussian pRF function
    pix2deg = 50;
    imSize = size(squeeze(phaseAvgBands{1}(1,:,:)));
    [Y X] = meshgrid(1:imSize(1),1:imSize(2));
    centerX = (max(X(:))-min(X(:)))/2;
    centerY = (max(Y(:))-min(Y(:)))/2;
    %convert X Y pixel values to degrees
    X = (X-centerX)./pix2deg;
    Y = (Y-centerY)./pix2deg;
    
    %% change model outputs to vectors
    for modul=1:2
        for ori=1:oris
            vecBands{modul}(:,ori) = reshape(phaseAvgBands{modul}(ori,:,:),1,imSize(1)*imSize(2));
            for lev=1:numLevels
                vecBandsLev{modul}(:, ori, lev) = reshape(phaseAvgBandsLev{modul,lev}(ori,:,:),1,imSize(1)*imSize(2));
            end
        end
    end
    
    
    %% Load fMRI data saved by saveData.m
    load([dataDir 'subLists_' modSqString '.mat'],'subList','dirname','ROIs');%created by saveData.m
    for isub=1:length(subList)
        filename = [ subList{isub} '.mat'];
        load([ dirname filename],'corrData','prfData');
        for roi=1:length(ROIs)
            for modul=1:2
                dataPh{isub,roi}(:,modul) = corrData{(roi-1)*2 + modul}.ph;
                dataCo{isub,roi}(:,modul) = corrData{(roi-1)*2 + modul}.co;
            end
            dataMinCo{isub,roi} = min(dataCo{isub,roi},[],2);
            prfR2{isub,roi} = prfData{roi}.r2;
            prfPolar{isub,roi} = prfData{roi}.polar;
            prfEccen{isub,roi} = prfData{roi}.eccen;
            prfSize{isub,roi} = prfData{roi}.rfsize;
            voxels= length(prfSize{isub,roi});
            
            %calculate model's tuning curve for each voxel pRF
            rfMaskVec = zeros(voxels,imSize(1)*imSize(2),'single');
            for vox=1:voxels
                [rfX, rfY] = pol2cart(prfPolar{isub,roi}(vox),prfEccen{isub,roi}(vox));%pRF center
                rfS = prfSize{isub,roi}(vox);%pRF size
                rfMask = single(exp(-((X-rfX).^2 + (Y-rfY).^2)/(2*rfS^2))');%2D Gaussian
                rfMaskVec(vox,:) = reshape(rfMask,1,imSize(1)*imSize(2));
            end
            rfResp{isub,roi} = zeros(2,oris,voxels);
            rfRespLev{isub,roi} = zeros(2,oris,numLevels,voxels);
            for modul=1:2
                rfResp{isub,roi}(modul,:,:) = (rfMaskVec*vecBands{modul})';
                for lev=1:numLevels
                    rfRespLev{isub,roi}(modul,:,lev,:) = (rfMaskVec*vecBandsLev{modul}(:, :, lev))';
                end
            end

            for modul=1:2
                % Get phase and amplitude of tuning curve
                f = fft(squeeze(rfResp{isub,roi}(modul,:,:)));
                rfPhase{isub,roi}(modul,:) = angle(f(2,:));
                rfAmp{isub,roi}(modul,:) = abs(f(2,:));
                
                f = fft(squeeze(rfRespLev{isub,roi}(modul,:,:,:)));
                rfPhaseLev{isub,roi}(modul,:,:) = angle(f(2,:,:));%modul,lev,voxel
                rfAmpLev{isub,roi}(modul,:,:) = abs(f(2,:,:));
            end
            %adjust the phase so that it corresponds to that computed by
            %computeCoranal. run 'type computeCoranal' in MATLAB. Last
            %paragraph. case 'Sine' is the default.
            rfPhaseLev{isub,roi} = - pi/2 - rfPhaseLev{isub,roi};
            %but the direction in which orientation is changing is flipped, so:
            rfPhaseLev{isub,roi} = - rfPhaseLev{isub,roi};
            rfPhaseLev{isub,roi}(rfPhaseLev{isub,roi}<0) = rfPhaseLev{isub,roi}(rfPhaseLev{isub,roi}<0)+pi*2;
            
            rfPhase{isub,roi} = - pi/2 - rfPhase{isub,roi};
            rfPhase{isub,roi} = -rfPhase{isub,roi};
            rfPhase{isub,roi}(rfPhase{isub,roi}<0) = rfPhase{isub,roi}(rfPhase{isub,roi}<0)+pi*2;
        end
    end
    %% SAVE
    save([dataDir 'prfModel_' modSqString '.mat'],'subList','dirname','ROIs','rfPhaseLev','rfAmpLev','rfPhase','rfAmp','rfResp','rfRespLev',...
        'dataPh','dataCo','dataMinCo','prfR2','prfPolar','prfEccen','prfSize','maxLev');
    %data used by makeFigure6.m
end
