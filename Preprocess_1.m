clear all; close all; clc;


rng(2121)
numFilesToSelect = 1000; 
folders = {'males', 'females'};
labels = [0, 1];




targetFreqStart = 50;
targetFreqEnd = 500;
numPoints = 200;
targetFreqs = linspace(targetFreqStart, targetFreqEnd, numPoints);


data = [];


for folderIdx = 1:length(folders)
    folderName = folders{folderIdx};
    label = labels(folderIdx);
    
    
    audioFiles = dir(fullfile(folderName, '*.m4a'));
    randomIndices = randperm(length(audioFiles));
    selectedIndices = randomIndices(1:numFilesToSelect);
    
   
    for idx = 1:length(selectedIndices)
        fileIdx = selectedIndices(idx);
        [audioData, sampleRate] = audioread(fullfile(folderName, audioFiles(fileIdx).name));
        
        maxStartPoint = length(audioData) - 2 * sampleRate;
        startPoint = randi([1, maxStartPoint]);
        extractedSegment = audioData(startPoint:startPoint + 2 * sampleRate - 1);
        
        bandpassFilter = designfilt('bandpassiir', ...
                            'FilterOrder', 4, ...
                            'HalfPowerFrequency1', 50, ...
                            'HalfPowerFrequency2', 500, ...
                            'SampleRate', sampleRate);
                        
        filteredAudio = filter(bandpassFilter, extractedSegment);
        
        
        fftResult = fft(filteredAudio);
        n = length(filteredAudio);
        
       
        fftResultHalf = fftResult(1:floor(n/2)+1);
        
        
        freqAxis = (0:floor(n/2)) * sampleRate / n;
        
        
        [~, closestIndices] = arrayfun(@(f) min(abs(freqAxis - f)), targetFreqs);
        targetAmplitudes = abs(fftResultHalf(closestIndices));
        
        
        data = [data; [targetAmplitudes' label]];
        if (mod(idx,100) == 0)
            idx
        end
    end
end


save('audioFeatures.mat', 'data');

