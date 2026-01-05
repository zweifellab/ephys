function [numEvents, eventRaster, freqBinEdgeTime, freq, spikeCount] =  ...
            YS_lzlab_eventhistogram(timeWidth, timeBinSize, eventTimes, spikeTimestampArray)

  numEvents = size( find( eventTimes > 0),2);
  
  % Loop over events.
  iLastIndex = 0;
  
  % Get bin edges.
  freqBinEdgeTime=[timeWidth(1):timeBinSize:timeWidth(2)]; % back to ms.
    
  for i=1:numEvents
  
    % Get all relevent spike times for the current event.
    iStartTime = eventTimes(i) + timeWidth(1)*10; % start time in units of ms/10 
    iEndTime = eventTimes(i) + timeWidth(2)*10; % end time in units of ms/10
    eventSpikeIndices = find(spikeTimestampArray > iStartTime & spikeTimestampArray < iEndTime);
    currentEventSpikeTimes = spikeTimestampArray(eventSpikeIndices);
        
    % We really want differences in time of the spike from the event.  We do this for spikes and position (for use with radial distance).
    eventTimeDiffs(iLastIndex+1:size(currentEventSpikeTimes,2)+iLastIndex) = currentEventSpikeTimes - eventTimes(i); 
    eventRaster(i).Spikes(1:size(currentEventSpikeTimes,2)) = ( currentEventSpikeTimes - eventTimes(i) ) ./ 10.0;
    eventRaster(i).spikeCount = histc(eventRaster(i).Spikes, freqBinEdgeTime);
    eventRaster(i).freq = (eventRaster(i).spikeCount(1:end-1) / diff(freqBinEdgeTime(1:2)) ) * 1000;
    eventRaster(i).spikeIndex = eventSpikeIndices;
     
    % Lastly, we need to move the index forward so we can collect data from the next event.
    iLastIndex = size(eventTimeDiffs,2);
    
    % Probability
    prob = find(eventRaster(i).spikeCount(1:end-1) >= 1);
    eventRaster(i).probability = zeros(1, size(eventRaster(i).spikeCount, 2)-1);
    eventRaster(i).probability(prob) = 1;
        
  end;
    
  % Now we have all of the spike difference times in the eventTimeDiffs vector.  
  % Time to make histogram.
  
  % Convert timestamp to ms.
  eventTimeDiffs = eventTimeDiffs ./ 10.0; 
  
  % Get spike histogram.
  % histc throws an exception if we give it an empty array.
  if ( length( eventTimeDiffs ) > 0 )
    spikeCount = histc(eventTimeDiffs, freqBinEdgeTime);
  else
    spikeCount = zeros( 1, length(freqBinEdgeTime) );
  end;
  
  % Convert spike count to frequency.
  freq = ( spikeCount(1:end-1) ./ diff(freqBinEdgeTime) ) * ( 1000 / numEvents);
  
 