% -*- mode: matlab; -*-


% Neurophysiology Analysis Toolkit http://sourceforge.net/projects/nphys/
% Authors : Chris Higginson (original author) and Josh Tasman
% Copyright (C) 2002-2005 by the authors and the Mizumori Lab 
%  (at the University of Washington, Seattle)
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA


% DISCLAIMER : The authors and the Mizumori Lab make absolutely
% no claim as to the correctness, accuracy, or reliability of this code.   
% USE AT YOUR OWN RISK. 


function extractedTimestamps = extractspiketimes(timestamp, numIntervals, intervals)
%EXTRACTSPIKETIMES   Finds all of the spike times that occur within a set of intervals.
%   Inputs:
%     timestamp -   This is a vector of ordered spike timestamps in 10^-4 seconds.
%     numIntervals - The number of intervals we are going to look for spikes within.
%     intervals - An array of size numIntervalsx2.  (i,1) is starting time of ith interval.  
%                                                   (i,2) is ending time of ith interval.
%     
%   Outputs:
%     extractedTimestamps -   A list of the spike timestamps in increasing order.  Each timestamp
%                             falls within the range of one of the
%                             intervals passed in.  Units are 10^-4
%                             seconds.
%
%

%  23 April 2002, C. Higginson, created.

% Quick check to see if being called correctly.
  if (nargin ~= 3)
    error('Should be exactly 3 input arguments.');
  elseif (nargout ~= 1)
    error('Should be exactly 1 output arguments.');
  end;

% Make sure the inputs are of the right type.
[m, n] = size(timestamp);
[p, q] = size(numIntervals);
[r, s] = size(intervals);
if (m > 1 | ~isnumeric(timestamp))
    error('timestamp argument should be 1XN numeric vector.');
elseif (p > 1 | q > 1 | ~isnumeric(numIntervals))
    error('numIntervals argument should be scalar.');
elseif (s >2 | ~isnumeric(intervals))
    error('intervals should be MX2 numeric matrix.');
end;

% Initialize returned timestamps.
extractedTimestamps = [];

if (numIntervals == 0)
    % If there are no intervals we do not need to call the mex file.  Just
    % return an empty array.
    return;
else
  [extractedTimestamps, numExtracted] = cmexExtractSpikes(timestamp, ...
                               intervals(1:numIntervals,1)', intervals(1:numIntervals,2)' ); 
                                                              
  extractedTimestamps = extractedTimestamps(1:numExtracted);
end;
    
    
            
      
