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


function [timestampArray] = mzlab_findeventtimes(eventTimestampArray, eventLabelArray, eventRegExp)

  %  2002, C. Higginson, created.

  timestampArray = [];
  for iEventIndex = 1:size(eventTimestampArray,2)
    teststring = char(eventLabelArray(iEventIndex));
    if (regexp(teststring,eventRegExp,'once') == 1)
        timestampArray(end+1) = eventTimestampArray(iEventIndex);
    end;
  end;