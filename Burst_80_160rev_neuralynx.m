function  [Burst] = Burst_80_160rev(SpikeTS, Window)

% EdgesISI = linspace(0,1,1001).';
% EdgesISI = EdgesISI(2:end);
% BurstISIHist = zeros(1000,1);

timeIntervalToTriggerBurst = 0.08*10000; % in ms
timeIntervalToMarkEndOfBurst = 0.16*10000; % in ms

ISIarray = diff(SpikeTS);

for i = 1:length(ISIarray)
    if ISIarray(i) <= timeIntervalToTriggerBurst
        EventKey(i,1) = 1;
    elseif ISIarray(i) >= timeIntervalToMarkEndOfBurst
        EventKey(i,1) = -1;
    else
        EventKey(i,1) = 0;
    end
end

BurstStartInd = find(EventKey == 1);
BurstEndInd = find(EventKey == -1);
BurstMidInd = find(EventKey == 0);

h = 1;
b = 1;

while h < length(SpikeTS)
    
    try
        BurstStart(b,1) = BurstStartInd(find(BurstStartInd >= h,1,'first'));
        try
            BurstEnd(b,1) = BurstEndInd(find(BurstEndInd > BurstStart(b,1),1,'first'));
            h = BurstEnd(b,1) + 1;
            b = b + 1;
        catch
            BurstEnd(b,1) = length(SpikeTS);
            h = length(SpikeTS);
        end
        
    catch
        h = length(SpikeTS);
    end
    
    try
        if (BurstEnd(b-1,1) - BurstStart(b-1,1) < 2)
            b = b - 1;
        end
    catch
        h = length(SpikeTS);
    end
    
end

if b > 2
    for i = 1:b-1        
        Burst.TS{i} = SpikeTS(BurstStart(i):BurstEnd(i));
        Burst.ISI{i} = diff(Burst.TS{i}/10); % in ms
        Burst.SpikeCount(i,1) = length(Burst.TS{i}/10); % in ms
        Burst.AvgBurstISI(i,1) = mean(Burst.ISI{i});
        Burst.Duration(i,1) = (Burst.TS{i}(end)-Burst.TS{i}(1))/10; % in ms
        Burst.FirstISIs(i,1) = Burst.ISI{i}(1);
        Burst.FirstISIs(i,2) = Burst.ISI{i}(2);        
    end
elseif b == 2
    i = 1;
    Burst.TS{i} = SpikeTS(BurstStart(i):BurstEnd(i));
    Burst.ISI{i} = diff(Burst.TS{i}/10); % in ms
    Burst.SpikeCount(i,1) = length(Burst.TS{i}/10); % in ms
    Burst.AvgBurstISI(i,1) = mean(Burst.ISI{i});
    Burst.Duration(i,1) = (Burst.TS{i}(end)-Burst.TS{i}(1))/10; % in ms
    Burst.FirstISIs(i,1) = Burst.ISI{i}(1);
    Burst.FirstISIs(i,2) = NaN;
else
    Burst.TS{1} = NaN;
    Burst.ISI{1} = NaN;
    Burst.SpikeCount(1,1) = NaN;
    Burst.AvgBurstISI(1,1) = NaN;
    Burst.Duration(1,1) = NaN;
    Burst.FirstISIs(1,1) = NaN;
    Burst.FirstISIs(1,2) = NaN;
    
end

try %SPIKETS(END) REPLACED WITH WINDOW
    %         Burst.BurstISIHist = BurstISIHist;
    Burst.AvgOverallISI = mean(ISIarray/10);
    Burst.StdOverallISI = std(ISIarray/10);
    Burst.CovOverallISI = Burst.StdOverallISI/Burst.AvgOverallISI;
    Burst.AvgDur = mean(Burst.Duration);
    Burst.StdDur = std(Burst.Duration);
    Burst.CovDur = Burst.StdDur/Burst.AvgDur;
    Burst.AvgISI = mean(Burst.AvgBurstISI);
    Burst.StdISI = std(Burst.AvgBurstISI);
    Burst.CovISI = Burst.StdISI/Burst.AvgISI;
    Burst.AvgBurstSpikes = mean(Burst.SpikeCount);
    Burst.StdBurstSpikes = std(Burst.SpikeCount);
    Burst.CovBurstSpikes = Burst.StdBurstSpikes/Burst.AvgBurstSpikes;
    Burst.BurstSetRate = (b-1)/(Window/60);
    Burst.FRnonBurst = (length(SpikeTS)-sum(Burst.SpikeCount))/Window;
    Burst.FROverall = length(SpikeTS)/Window;
    Burst.FRBurst = sum(Burst.SpikeCount)/sum(Burst.Duration);
catch
end

end

