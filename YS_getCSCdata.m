function cscData = YS_getCSCdata(cscFileNames, timestamps)
% Extract samples from .csc files and detrend if requested

% adjust timestamps
timestamps = timestamps*100;
nWaveform = 0;


for n = 1:size(timestamps, 2)
    % read CSC file
    [sampleTS, samples, tHeader] = Nlx2MatCSC(cscFileNames, [1 0 0 0 1], 1, 5, [timestamps(n)]);
    
    if n == 1
        samplingRate = str2double(regexpi([tHeader{:}], '(?<=-SamplingFrequency )\d+', 'match'));
        ADBitVolts = str2double(regexpi([tHeader{:}], '(?<=-ADBitVolts )\d+\.\d+', 'match'));
        ADMaxValue = str2double(regexpi([tHeader{:}], '(?<=-ADMaxValue )\d+', 'match'));
    end
        
        
    % test  
%     csc1= 'C:\Data\ChR2_HM4\M9058_03\CSC1.ncs'
%     [sampleTS, samples1, tHeader] = Nlx2MatCSC(csc1, [1 0 0 0 1], 1, 5, [timestamps(n)]);
%     csc2= 'C:\Data\ChR2_HM4\M9058_03\CSC2.ncs'
%     [sampleTS, samples2, tHeader] = Nlx2MatCSC(csc2, [1 0 0 0 1], 1, 5, [timestamps(n)]);
%     csc3= 'C:\Data\ChR2_HM4\M9058_03\CSC3.ncs'
%     [sampleTS, samples3, tHeader] = Nlx2MatCSC(csc3, [1 0 0 0 1], 1, 5, [timestamps(n)]);
%     csc4= 'C:\Data\ChR2_HM4\M9058_03\CSC4.ncs'
%     [sampleTS, samples4, tHeader] = Nlx2MatCSC(csc4, [1 0 0 0 1], 1, 5, [timestamps(n)]);
%     
%     ylim = [-20000 20000]
%     a=(sampleTS(1)) : (1/samplingRate*1e6) : (sampleTS(end))+(1/samplingRate*1e6)*(nChannels-1);
%     figure(1); plot(a, samples1); hold on;
%     plot([timestamps(n) timestamps(n)], [0 0], '*r'); hold off; set(gca, 'YLim', ylim);
%     figure(2); plot(a, samples2); hold on;
%     plot([timestamps(n) timestamps(n)], [0 0], '*r'); hold off; set(gca, 'YLim', ylim);
%     figure(3); plot(a, samples3); hold on;
%     plot([timestamps(n) timestamps(n)], [0 0], '*r'); hold off; set(gca, 'YLim', ylim);
%     figure(4); plot(a, samples4); hold on;
%     plot([timestamps(n) timestamps(n)], [0 0], '*r'); hold off; set(gca, 'YLim', ylim);
%     
%     ttFile = 'C:\Data\ChR2_HM4\M9058_03\TT1\TT1.ntt'
%     [Timestamps,Samples, ttHeader] = Nlx2MatSpike(ttFile,[1 0 0 0 1],1, 5, [timestamps(n)+600]);
%     
%     Samples/100
%     figure(5); clf;
%     subplot(2,2,[1 2]);
%     plot(1:32, Samples(:, 1)'); hold on;
%     plot(34:65, Samples(:, 2)'); plot(67:98, Samples(:, 3)');
%     plot(100:131, Samples(:, 4)'); hold off;
%     subplot(2,2,[3 4]);
%      plot(32:-1:1, Samples(:, 1)'); hold on;
%     plot(65:-1:34, Samples(:, 2)'); plot(98:-1:67, Samples(:, 3)');
%     plot(131:-1:100, Samples(:, 4)'); hold off;
    
   
        nWaveform = nWaveform + 1;
        nPoints = size(samples,1);
        samples = samples(:)';
        
        % Convert to seconds and interpolate timestamps within channel
        % sampleTS_sec = (sampleTS(1)/1e6) : (1/samplingRate) : (sampleTS(end)/1e6)+(1/samplingRate)*(nPoints-1);
        % sampleTS_sec = sampleTS/1e6;
        newTS = (sampleTS) : (1/samplingRate*1e6) : (sampleTS)+(1/samplingRate*1e6)*(nPoints-1);
        samples_microV = (samples * ADBitVolts)*1e6;
        
        % find specific waveforms
        timeIndex = newTS > timestamps(n); % adjjust sampltTS_sec
        triggeredTimes = sort(find(timeIndex == 1));
        if size(triggeredTimes, 2) == 0
            triggeredTimes = nPoints+1;
        end        
                
        if triggeredTimes(1) <= 50
            [extraTS, extraSamples, tHeader] = Nlx2MatCSC(cscFileNames, [1 0 0 0 1], 1, 5, [timestamps(n)-10000]);
            extraSamples = extraSamples(:)';
            extraNewTS = (extraTS) : (1/samplingRate*1e6) : (extraTS)+(1/samplingRate*1e6)*(nPoints-1);
            extraSamples_microV = (extraSamples * ADBitVolts)*1e6;
            samples = [extraSamples samples];
            newTS = [extraNewTS newTS];
            samples_microV = [extraSamples_microV samples_microV];
            triggeredTimes = triggeredTimes + nPoints; % adjust the triggered time point
        elseif triggeredTimes(1) >= 470
            [extraTS, extraSamples, tHeader] = Nlx2MatCSC(cscFileNames, [1 0 0 0 1], 1, 5, [timestamps(n)+10000]);
            extraSamples = extraSamples(:)';
            extraNewTS = (extraTS) : (1/samplingRate*1e6) : (extraTS)+(1/samplingRate*1e6)*(nPoints-1);
            extraSamples_microV = (extraSamples * ADBitVolts)*1e6;
            samples = [samples extraSamples];
            newTS = [newTS extraNewTS];
            samples_microV = [samples_microV extraSamples_microV];
        end
        
        % Output data
        cscData.TS(nWaveform, :) = (newTS(triggeredTimes(1)-40:triggeredTimes(1)+40)-newTS(triggeredTimes(1)))/1e3'; % ms
        cscData.waveform(nWaveform, :) = samples_microV(triggeredTimes(1)-40:triggeredTimes(1)+40);
        
        % Remove noise
        % samplesDetrended_microV = locdetrend(samples_microV, samplingRate, [1 0.5]);
        % cscData.samplesDetrended_microV = samplesDetrended_microV;
        
    
end

cscData.samplingRate = samplingRate;
cscData.fileName = cscFileNames;

end
