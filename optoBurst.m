function lzlab_DAfear(eventFileName, cellFileNames, cscFileNames, analysisOptions)

% Read events
[eventTimestampArray, eventLabelArray] = xlsread(eventFileName, 'eventTimes');
eventTimestampArray = eventTimestampArray'/100;
eventLabelArray = eventLabelArray(:,2)';

nEventTypes = size(analysisOptions.histogramevents, 2);

emptyCells = cellfun(@isempty, cellFileNames);
realCellFiles = find(emptyCells == 0);

for n = realCellFiles;
    % Read the cell file.
    [spikeTimestampArray, nSpikes] = lzlab_readmclusttfile(cellFileNames{n});
    
    numEventPlots = 0;
    numFigures = 0;
    fighandles = []; % this will be used to print figures later.
    histhandles = []; % this will be a list of handles to the individual plots.  We use this to go back and scale the plots later.
    yMaxScale = 0;
    yMinScale = 0;
    results = struct([]);
    
    % Read the plx file
    nWaveform = 0; lightWaveform = []; lightTimestamps = []; % this will be used to find waveforms evoked by light
    plxFilePoint = cell2mat(strfind(cellFileNames(n), 'cell'));
    plxFileName = cellFileNames{n}(1:(plxFilePoint-2));
    cellNum = regexp(cellFileNames{n}, 'cell(\d*).t', 'tokens');
    currentUnit = [];
    for k = 1:4 % tetrode
        [currentUnit(k).n, currentUnit(k).npw, currentUnit(k).ts, currentUnit(k).wave] = plx_waves(plxFileName, k, str2double(cellNum{1}));
        currentUnit(k).ts = currentUnit(k).ts*10000; % adjust the length of timestemps from the plx file
    end
    clear mexPlex 
    
    % analyze baseline activity
    baseDuration = 600; % 10 min = 600 sec
    baseEvent = mzlab_findeventtimes(eventTimestampArray, eventLabelArray, 'baseline');
    baseSpikeTimes = extractspiketimes(spikeTimestampArray, 1, [baseEvent-baseDuration*1000*10 baseEvent]);
    
    WF.spikeTimes = baseSpikeTimes;
    WF.firingRate = size(WF.spikeTimes, 2)/baseDuration;
    if size(baseSpikeTimes, 2) > 1
        [Burst] = Burst_80_160rev_neuralynx(baseSpikeTimes, baseDuration);
        
        for i=1:length(Burst.Duration)
            WF.firstBurstTime(i,1) = Burst.TS{1,i}(1,1);
            WF.lastBurstTime(i,1) = Burst.TS{1,i}(end,1);
        end
        
        WF.SpikesInBurst = Burst.SpikeCount;
        WF.BurstDuration = Burst.Duration;
        WF.AvgBurstRate = length(Burst.Duration)/baseDuration;
        WF.PercSpikesInBurst = sum(WF.SpikesInBurst)/length(WF.spikeTimes)*100;
        WF.BurstRatio = sum(WF.SpikesInBurst)/length(WF.spikeTimes);
        WF.AvgSpikesInBurst = mean(WF.SpikesInBurst);
        WF.AvgDurationBurst = mean(WF.BurstDuration);
        WF.FRnonBurst = Burst.FRnonBurst;
        WF.FROverall = Burst.FROverall;
        WF.FRBurst = Burst.FRBurst;
        WF.BurstSetRate = Burst.BurstSetRate;
    end
    results(1).WF = WF;
    
    % Open a new figure
    numFigures = numFigures + 1;
    fighandles(numFigures) = figure('Name','Histogram analysis', 'PaperOrientation', 'landscape', 'Position', [50, 50, 720, 541], ...
        'PaperUnits', 'inches', 'PaperPosition', [0, 0, 11.0, 8.5]);
    
    %-------------------Figure title--------------------------
    h = axes('Tag', 'SummaryTitle', 'Units', 'normalized', 'Box', 'on', 'YTickMode', 'manual', 'Position',[0.0 .875  .99 0.125], 'Color', 'w', 'XLimMode', 'manual', 'YLimMode', 'manual', 'XLim', [1 100], 'YLim', [1 3], 'YDir', 'reverse', 'Visible','off');
    toptitle = [date, '  Cell: ', cellFileNames{n}];
    text(20, 2, toptitle,'FontSize',8, 'Interpreter', 'none');
    
    
    for i = 1:nEventTypes
        numEventPlots = numEventPlots + 1;
        % Find the histogramevent
        eventTimes = mzlab_findeventtimes(eventTimestampArray, eventLabelArray, analysisOptions.histogramevents{i});
        
        switch i
            case 1
                subplot('Position', [0.05, .5, .3, .35]);
            case 2
                subplot('Position', [0.4, .5, .3, .35]);
            case 3
                subplot('Position', [0.05, .05, .43, .35]);
            case 4
                subplot('Position', [0.54, .05, .43, .35]);              
        end;
        
        % Define the analysis window around events
        if i == 1;
            windowWidth=analysisOptions.windowWidth(1,:);
            binWidth=analysisOptions.binWidth(1);
            lightTimesCSC = eventTimes;
        elseif i == 2;
            windowWidth=analysisOptions.windowWidth(2,:);
            binWidth=analysisOptions.binWidth(2);
        elseif i == 3;
            windowWidth=analysisOptions.windowWidth(3,:);
            binWidth=analysisOptions.binWidth(3);
        elseif i == 4;
            windowWidth=analysisOptions.windowWidth(4,:);
            binWidth=analysisOptions.binWidth(4);
        end
        
        [numEvents, eventRaster, freqBinEdgeTime, freq, spikeCount] = lzlab_eventhistogram(windowWidth, binWidth, eventTimes, spikeTimestampArray);
        
        % Find the peak firing rate
        [peakRate, peakRateIndex] = max(freq);
        
        % Find the center of the peak firing rate bin
        if peakRateIndex == size(freqBinEdgeTime, 2)
            peakRateIndex = peakRateIndex -1;
        end
        peakTime = (freqBinEdgeTime(peakRateIndex + 1) + freqBinEdgeTime(peakRateIndex)) / 2;
        
        % Find the peak firing rate
        [minRate, minRateIndex] = min(freq);
        
        % Find the center of the peak firing rate bin
        if minRateIndex == size(freqBinEdgeTime, 2)
            minRateIndex = minRateIndex -1;
        end
        minTime = (freqBinEdgeTime(minRateIndex + 1) + freqBinEdgeTime(minRateIndex)) / 2;
        
        if i == 1 || i == 2;
            % Plot histogram
            bar(freqBinEdgeTime(1:end-1) + diff(freqBinEdgeTime)/2.0, sum(cat(1, eventRaster.probability))/size(eventRaster, 2), 1, 'k'); % spike probability
            % Find the waveform in reponse to light stimulation
            firstLight = find(freqBinEdgeTime == 0);
            for m = 1:size(eventRaster,2)
                if eventRaster(m).probability(41) == 1;
                    nWaveform = nWaveform+1;
                    fisrtWaveform = find(eventRaster(m).Spikes > 0 & eventRaster(m).Spikes <= binWidth);
                    lightWaveform(nWaveform,:) = [currentUnit(1).wave(eventRaster(m).spikeIndex(fisrtWaveform(1)),:), currentUnit(2).wave(eventRaster(m).spikeIndex(fisrtWaveform(1)),:),...
                        currentUnit(3).wave(eventRaster(m).spikeIndex(fisrtWaveform(1)),:), currentUnit(4).wave(eventRaster(m).spikeIndex(fisrtWaveform(1)),:)];
                    lightTimestamps(nWaveform) = currentUnit(1).ts(eventRaster(m).spikeIndex(fisrtWaveform(1)));
                end
            end
        else
            bar(freqBinEdgeTime(1:end-1) + diff(freqBinEdgeTime)/2.0, freq, 1, 'k'); % firing rate
        end
        
        hFreqAxes = gca;
        set(hFreqAxes, 'YAxisLocation','left', 'Box', 'on' );
        totalPos = get(hFreqAxes,'Position');
        percentRaster = 0.3;
        freqPos = [totalPos(1) totalPos(2)+totalPos(4)*percentRaster totalPos(3) totalPos(4)*(1-percentRaster)];
        set(hFreqAxes, 'Position', freqPos);
        title(analysisOptions.histogramevents{i}, 'Interpreter', 'none');
        set(hFreqAxes, 'XLim', [min(freqBinEdgeTime), max(freqBinEdgeTime)]);
        
        % Plot spike raster
        set(hFreqAxes,'XTick', []);
        hSpikeRasterAxes = axes('Position', [totalPos(1) totalPos(2) totalPos(3) totalPos(4)*percentRaster]);
        set(hSpikeRasterAxes,'YTick', []);     
        hold on;
        set(hSpikeRasterAxes, 'XLim', get(hFreqAxes,'XLim'));
        if i == 3 || i == 4
            set(hSpikeRasterAxes, 'XLim', get(hFreqAxes,'XLim'), 'XTick', analysisOptions.CStick);
        end
        set(hSpikeRasterAxes, 'YLim', [1 2*numEvents+8]);
        for j=1:numEvents
            yval = [];
            yval(1:size(eventRaster(j).Spikes,2)) = 6 + (numEvents-j)*2;
            line([eventRaster(j).Spikes; eventRaster(j).Spikes] , [yval + 0.9; yval - 0.9], 'Color', [0 0 0]);
        end;
        XLimit = get(hSpikeRasterAxes, 'XLim');
        YLimit = get(hSpikeRasterAxes, 'YLim');
        hold off;
        
        % Get the scale of the y axis for the histogram
        histhandles(i) = hFreqAxes;
        histYLim = get(histhandles(i), 'YLim');
        
        if (histYLim(2) > yMaxScale)
            yMaxScale = histYLim(2);
        end;
        
        if (histYLim(1) < yMinScale)
            yMinScale = histYLim(1);
        end;
        
        % Output data
        results(i).time = freqBinEdgeTime;
        results(i).freq = freq;
        results(i).probability = sum(cat(1, eventRaster.probability))/size(eventRaster, 2);
        [results(i).trial(1:numel(eventRaster)).freq] = deal(eventRaster.freq);
        [results(i).trial(1:numel(eventRaster)).spikeCount] = deal(eventRaster.spikeCount);
        [results(i).trial(1:numel(eventRaster)).spikes] = deal(eventRaster.Spikes);

    end
    
    % Plot plx waveforms
    nBaseWaveform = 2:602;
    if size(currentUnit(1).wave, 1) < size(nBaseWaveform, 2)
        nBaseWaveform = 1:size(currentUnit(1).wave, 1);
    end
    lowY = [min(min(currentUnit(1).wave(nBaseWaveform, 1:32))), min(min(currentUnit(2).wave(nBaseWaveform, 1:32))), min(min(currentUnit(3).wave(nBaseWaveform, 1:32))), min(min(currentUnit(4).wave(nBaseWaveform, 1:32))), min(min(lightWaveform))]; 
    highY = [max(max(currentUnit(1).wave(nBaseWaveform, 1:32))), max(max(currentUnit(2).wave(nBaseWaveform, 1:32))), max(max(currentUnit(3).wave(nBaseWaveform, 1:32))), max(max(currentUnit(4).wave(nBaseWaveform, 1:32))), max(max(lightWaveform))];
    ylim = [max([abs(lowY), highY])*-1.05 max([abs(lowY), highY])*1.05];
    subplot('Position', [0.75, .7, .15, .14]);
    plot(1:32, currentUnit(1).wave(nBaseWaveform, 1:32)); hold on;
    plot(34:65, currentUnit(2).wave(nBaseWaveform, 1:32)); plot(67:98, currentUnit(3).wave(nBaseWaveform, 1:32));
    plot(100:131, currentUnit(4).wave(nBaseWaveform, 1:32)); hold off;
    set(gca,'XLim', [0 132], 'XTickMode', 'Manual', 'XTickLabel', [],'YLim', ylim, 'YTickMode', 'Manual','YTickLabel', []); title('Baseline waveforms');
    % save results
    results(1).baseWaveform = [currentUnit(1).wave(nBaseWaveform, 1:32), currentUnit(2).wave(nBaseWaveform, 1:32), currentUnit(3).wave(nBaseWaveform, 1:32), currentUnit(4).wave(nBaseWaveform, 1:32)];
    
    if size(lightWaveform, 1) < 1
        subplot('Position', [0.75, .5, .15, .14]);
        set(gca,'XLim', [0 132], 'XTickMode', 'Manual', 'XTickLabel', [],'YLim', ylim, 'YTickMode', 'Manual','YTickLabel', []); title('No light-evoked waveforms');
    else
        subplot('Position', [0.75, .5, .15, .14]);
        plot(1:32, lightWaveform(:, 1:32)); hold on;
        plot(34:65, lightWaveform(:, 33:64)); plot(67:98, lightWaveform(:, 65:96));
        plot(100:131, lightWaveform(:, 97:128)); hold off;
        set(gca,'XLim', [0 132], 'XTickMode', 'Manual', 'XTickLabel', [],'YLim', ylim, 'YTickMode', 'Manual','YTickLabel', []); title('Light-evoked waveforms');
        results(1).lightWaveform = lightWaveform;     
    end
    
    % Plot CSC waveforms
    % read the EEG data 
    baseTimestamps = currentUnit(1).ts(nBaseWaveform)';
    baseCSCdata = YS_getCSCdata(cscFileNames{n}, baseTimestamps);
    nWavePoints = size(baseCSCdata.waveform,2);
    subplot('Position', [0.91, .7, .08, .14]);
    plot(1:nWavePoints, baseCSCdata.waveform(:, 1:nWavePoints));
    ylim = [max(abs(baseCSCdata.waveform(:)))*-1.05 max(abs(baseCSCdata.waveform(:)))*1.05];
    set(gca,'XLim', [0 nWavePoints], 'XTickMode', 'Manual', 'XTickLabel', [],'YLim', ylim, 'YTickMode', 'Manual','YTickLabel', []); title('CSC');
    % Outputs
    results(1).CSCtimestamps = baseCSCdata.TS(1,:);
    results(1).baseWaveformCSC = baseCSCdata.waveform;
    
    lightCSCdata = getCSCdata(cscFileNames{n}, lightTimesCSC);
    subplot('Position', [0.91, .5, .08, .14]);
    plot(1:nWavePoints, lightCSCdata.waveform(:, 1:nWavePoints));
    set(gca,'XLim', [0 nWavePoints], 'XTickMode', 'Manual', 'XTickLabel', [],'YLim', ylim, 'YTickMode', 'Manual','YTickLabel', []); title('CSC');
    results(1).lightWaveformCSC = lightCSCdata.waveform;
    
    % Go back and rescale the histograms
    if i>2
        for l = 1:2
            set(histhandles(l), 'YLim', [0 1]);
        end
        
        for l = 3:i
            set(histhandles(l), 'YLim', [yMinScale yMaxScale]);
        end
    else
        for l = 1:i
            set(histhandles(l), 'YLim', [0 1]);
        end
    end
    
    % Save figures as a jpeg format
    if analysisOptions.saveFigures == 1
        figureName = [cellFileNames{n} '_' analysisOptions.saveName '.jpg'];
        for l = 1:numFigures
            orient portrait;
            saveas(fighandles(l), figureName, 'jpg');
        end
    end
    
    % Save neural data as a mat format
    if analysisOptions.saveMat == 1
        outputFileName = [cellFileNames{n} '_' analysisOptions.saveName '.mat'];
        save(outputFileName, 'results');
    end
    
end

end