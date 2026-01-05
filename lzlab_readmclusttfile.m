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


function [timestamp, numSpikes] = readmclusttfile(sFilePath)
%READMCLUSTTFILE   Reads a cluster t-file produced by MClust.
%   Inputs:
%     sFilePath -   This is the full path to the t-file.
%     
%   Outputs:
%     timestamp:        A list of the timestamps of the spikes in increasing 
%                       order in units of 10^-4 seconds.  
%     numSpikes:        Number of spikes in the cluster.  
%

%  23 April 2002, C. Higginson, created.

  % Quick check to see if being called correctly.
  if (nargin ~= 1)
    error('There should be exactly 1 input argument.');
  elseif (nargout ~= 2)
    error('There should be exactly 2 output arguments.');
  end;

  % Open for binary read access     
  iClusterFileID = fopen(sFilePath, 'r', 'b');
  
  % Throw an error if there is a problem reading the file.
  if (iClusterFileID == -1)
    error(['Error opening cluster file:' sFilePath]);
  end;
      
  % Find the end of the header.
  fseek(iClusterFileID, 0, 'bof');
  beginheader = '%%BEGINHEADER';
  endheader = '%%ENDHEADER';
  iH = 1; H = {};
  curfpos = ftell(iClusterFileID);
  headerLine = fgetl(iClusterFileID);
  if strcmp(headerLine, beginheader)
    H{1} = headerLine;
    while ~feof(iClusterFileID) & ~strcmp(headerLine, endheader)     
      headerLine = fgetl(iClusterFileID);
      iH = iH+1;
      H{iH} = headerLine;
      if strcmp(headerLine, endheader)
        break;
      end;
    end;
  end;     
  
  % Read all of the timestamps.
%   [timestamp, numSpikes] = fread(iClusterFileID, inf, 'uint32');
  [timestamp, numSpikes] = fread(iClusterFileID, inf, 'uint64');
  timestamp = timestamp';
  
  % It is important that the timestamps are sequential for later analysis.
%   delta = diff(timestamp);
%   if (min(delta) < 0)
%     error(['Spike timestamps in cluster file must be non-decreasing. ' sFilePath]);
%   end;
  
  % Give a warning if the cell has no spikes.
  if (numSpikes == 0)
    warning(['There are no spikes in the cluster file:' sFilePath]);
  end;
  
  % Free memory.
  delta = [];

  fclose(iClusterFileID);
  
  return;
