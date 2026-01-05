optoBurst.m
Description

optoBurst.m is a MATLAB function for peri-event analysis and optogenetic tagging of in vivo tetrode electrophysiology data. The script aligns single-unit spike activity to behavioral and optogenetic events, computes baseline firing and burst statistics, and extracts spike waveforms and continuous signal (CSC) snippets to evaluate light-evoked neuronal responses.

Features

Peri-event time histograms (PETHs) and spike rasters aligned to user-defined events

Baseline firing rate and burst analysis

Extraction and visualization of baseline and light-evoked spike waveforms across tetrode channels

Continuous signal (CSC) extraction aligned to spike and stimulation times

Export of figures and structured analysis outputs for downstream analysis

Requirements

MATLAB (recent versions recommended)

Plexon MATLAB SDK (for plx_waves)

MClust-formatted spike files (.t)

Custom helper functions used by this pipeline:

lzlab_readmclusttfile

lzlab_eventhistogram

mzlab_findeventtimes

extractspiketimes

Burst_80_160rev_neuralynx

YS_getCSCdata / getCSCdata

Function Usage
optoBurst(eventFileName, cellFileNames, cscFileNames, analysisOptions)

Inputs

eventFileName
Excel file containing event timestamps and labels (sheet name: eventTimes).

cellFileNames
Cell array of MClust .t files corresponding to isolated units.

cscFileNames
Cell array of continuous signal (CSC) files corresponding to each unit.

analysisOptions (struct)
User-defined analysis parameters, including:

event labels to analyze

peri-event time windows

histogram bin sizes

figure and data saving options

Output

Figures (.jpg, optional)
Peri-event histograms, spike rasters, baseline and light-evoked waveforms, and CSC traces.

MAT file (.mat, optional)
A structured results variable containing:

baseline firing and burst metrics

peri-event histogram and raster data

baseline and light-evoked spike waveforms

CSC waveforms aligned to spikes and optogenetic events

Optogenetic Tagging

Optogenetic tagging is assessed by identifying short-latency spikes following optogenetic stimulation and comparing their waveforms to baseline spikes. This provides a qualitative assessment of light-evoked unit activation.

Notes

Event definitions, binning, and alignment windows are fully controlled by user-supplied parameters.

This script is intended for visualization and exploratory analysis and does not perform automated statistical classification of opto-tagged units.

License

GPL-2.0-or-later

This software is distributed under the GNU General Public License, version 2 or (at your option) any later version.

Copyright © Larry Zweifel and members of the Zweifel Lab, University of Washington.

This program is provided “as is”, without warranty of any kind. Use at your own risk.

Citation

If you use this code, please cite the associated publication and this repository.
