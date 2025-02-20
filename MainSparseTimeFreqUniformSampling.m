%% Main code implementing 2016 paper : 
% STFT-like time frequency representations of nonstationary signal with arbitrary sampling schemes
clc; clearvars;

%% Parameters for sampling and signals constructions 
numSamples = 512;
fs = 2;
timeGrid = (0 : numSamples - 1) / fs;
sPlot = CreatePlotConfig(0, 64, 63, 512);
sConfigSignals = CreateSignalsConfig(numSamples, timeGrid, fs);

%% Generate signals
sinesDecayExp = ConstructSignal(timeGrid, 1, sConfigSignals);
sinesDiffTime = ConstructSignal(timeGrid, 2, sConfigSignals);
chirpAndFmSine = ConstructSignal(timeGrid, 3, sConfigSignals);

%% Add noise
noiseVec = sqrt(sConfigSignals.noiseVar) * randn(1, length(timeGrid));
sinesDecayExp = sinesDecayExp + noiseVec;
sinesDiffTime = sinesDiffTime + noiseVec;
chirpAndFmSine = chirpAndFmSine + noiseVec;

%% Plot generated Signals
PlotGeneratedSignals(sinesDecayExp, sinesDiffTime, chirpAndFmSine, fs, timeGrid, sPlot)

%% Apply IAA on signals
% FR - IAA
numFreqBins = numSamples * 2;
freqVec = -fs/2 : fs/numFreqBins : fs/2 - 1/numFreqBins;
A = exp( 1j*2*pi*timeGrid'*freqVec );
numIterationsIaa = 8;

[~, first_p_IAA] = IAA(sinesDecayExp', A, numIterationsIaa);
[~, second_p_IAA] = IAA(sinesDiffTime', A, numIterationsIaa);
[~, third_p_IAA] = IAA(chirpAndFmSine', A, numIterationsIaa);

% TFR - IAA
[firstSpecIAA, timeSpecIaa, freqSpecIaa] = ComputeSpecBySparseAlgo(sinesDecayExp, numIterationsIaa, fs, 64, 1, 200, [], 'IAA');
[secondSpecIAA, ~, ~] = ComputeSpecBySparseAlgo(sinesDiffTime, numIterationsIaa, fs, 64, 1, 200, [], 'IAA');
[thirdSpecIAA, ~, ~] = ComputeSpecBySparseAlgo(chirpAndFmSine, numIterationsIaa, fs, 64, 1, 200, [], 'IAA');

PlotTdrFdrTfr(sinesDecayExp, sinesDiffTime, chirpAndFmSine, timeGrid, ...
              first_p_IAA, second_p_IAA, third_p_IAA, freqVec, ...
              firstSpecIAA, secondSpecIAA, thirdSpecIAA, timeSpecIaa, freqSpecIaa);
          
%% Apply SLIM on signals
q = 0.05;
% FR - SLIM
numFreqBins = 2048;
numSamplesInFrame = 64;
stepSize = 1;
freqVec = -fs/2 : fs/numFreqBins : fs/2 - 1/numFreqBins;
A = exp( 1j*2*pi*timeGrid'*freqVec );
numIterationsSlim = 8;

[~, first_p_SLIM] = SLIM(sinesDecayExp', A, q, numIterationsSlim);
[~, second_p_SLIM] = SLIM(sinesDiffTime', A, q, numIterationsSlim);
[~, third_p_SLIM] = SLIM(chirpAndFmSine', A, q, numIterationsSlim);

% TFR - SLIM
[firstSpecSlim, timeSpecIaa, freqSpecIaa] = ComputeSpecBySparseAlgo(sinesDecayExp, numIterationsSlim, fs, numSamplesInFrame, stepSize, numFreqBins, q, 'SLIM');
[secondSpecSlim, ~, ~] = ComputeSpecBySparseAlgo(sinesDiffTime, numIterationsSlim, fs, numSamplesInFrame, stepSize, numFreqBins, q, 'SLIM');
[thirdSpecSlim, ~, ~] = ComputeSpecBySparseAlgo(chirpAndFmSine, numIterationsSlim, fs, numSamplesInFrame, stepSize, numFreqBins, q, 'SLIM');

PlotTdrFdrTfr(sinesDecayExp, sinesDiffTime, chirpAndFmSine, timeGrid, ...
              first_p_SLIM, second_p_SLIM, third_p_SLIM, freqVec, ...
              firstSpecSlim, secondSpecSlim, thirdSpecSlim, timeSpecIaa, freqSpecIaa);%% Generate Non-uniform sampling \ time vector
         
