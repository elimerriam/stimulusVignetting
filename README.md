# Stimulus vignetting code

The code in this repository contains all the MATLAB software used to analyze the data and generate the figures for the following publication: Roth, ZN, Heeger, DJ, and Merriam, EP (2018). Stimulus vignetting and orientation selectivity in human visual cortex. [DOI: 10.7554/eLife.37241](https://osf.io/tbjrf/).

This code depends heavily on three other software packages: mrTools, mgl, and the steerable pyramid. mrTools and mgl are forked from their own repositories on gitHub. We have included a version of the steerable pyramid, which differs slightly from the version on Eero Simoncelli’s LVC gitHub repository.

To generate the figures in the paper, download the data from OSF (DOI: 10.17605/OSF.IO/TBJRF) and run the following functions. If things don’t work out, please contact us

Order in which to run scripts:

* makeFigure1.m
* makeFigure2.m
* makeFigure3.m
* saveCorrData.m
* makeFigure5.m
* saveData.m
* makeStimuli.m
* modelOutput.m
* avgModelOutput.m
* savePrfModel.m
* makeFigure6.m
* saveOriData.m
* makeFigure7a.m
* makeFigure7b.m
