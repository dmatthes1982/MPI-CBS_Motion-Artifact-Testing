function [ data ] = MAT_preprocessing( cfg, data )
% MAT_PREPROCESSING does the preprocessing of the raw data. 
%
% Use as
%   [ data ] = MAT_preprocessing(cfg, data)
%
% where the input data have to be the result from MAT_IMPORTATASET
%
% The configuration options are
%   cfg.bpfreq            = passband range [begin end] (default: [0.1 48])
%   cfg.bpfilttype        = bandpass filter type, 'but' or 'fir' (default: fir')
%   cfg.bpinstabilityfix  = deal with filter instability, 'no' or 'split' (default: 'no')
%   cfg.reref             = re-referencing: 'yes' or 'no' (default: 'yes')
%   cfg.refchannel        = re-reference channel (default: 'TP10')
%   cfg.samplingRate      = sampling rate in Hz (default: 500)
%
% This function requires the fieldtrip toolbox.
%
% See also MAT_IMPORTDATASET, FT_PREPROCESSING, MAT_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
bpfreq            = ft_getopt(cfg, 'bpfreq', [0.1 48]);
bpfilttype        = ft_getopt(cfg, 'bpfilttype', 'fir');
bpinstabilityfix  = ft_getopt(cfg, 'bpinstabilityfix', 'no');
reref             = ft_getopt(cfg, 'reref', 'yes');
refchannel        = ft_getopt(cfg, 'refchannel', 'TP10');
samplingRate      = ft_getopt(cfg, 'samplingRate', 500);

if ~(samplingRate == 500 || samplingRate == 250 || samplingRate == 125)     
  error('Only the following sampling rates are permitted: 500, 250 or 125 Hz');
end  

% -------------------------------------------------------------------------
% Preprocessing settings
% -------------------------------------------------------------------------

% general filtering
cfgBP                   = [];
cfgBP.bpfilter          = 'yes';                                            % use bandpass filter
cfgBP.bpfreq            = bpfreq;                                           % bandpass range  
cfgBP.bpfilttype        = bpfilttype;                                       % bandpass filter type = fir      
cfgBP.bpinstabilityfix  = bpinstabilityfix;                                 % deal with filter instability
cfgBP.channel           = 'all';                                            % use all channels
cfgBP.trials            = 'all';                                            % use all trials
cfgBP.feedback          = 'no';                                             % feedback should not be presented
cfgBP.showcallinfo      = 'no';                                             % prevent printing the time and memory after each function call

% re-referencing
cfgReref               = [];
cfgReref.reref         = reref;                                             % enable re-referencing
if ~iscell(refchannel)
  cfgReref.refchannel    = {refchannel, 'REF'};                             % specify new reference
else
  cfgReref.refchannel    = [refchannel, {'REF'}];
end
cfgReref.implicitref   = 'REF';                                             % add implicit channel 'REF' to the channels
cfgReref.refmethod     = 'avg';                                             % average over selected electrodes
cfgReref.channel       = 'all';                                             % use all channels
cfgReref.trials        = 'all';                                             % use all trials
cfgReref.feedback      = 'no';                                              % feedback should not be presented
cfgReref.showcallinfo  = 'no';                                              % prevent printing the time and memory after each function call
cfgReref.calceogcomp   = 'yes';                                             % calculate eogh and eogv 

% downsampling
cfgDS                  = [];
cfgDS.resamplefs       = samplingRate;
cfgDS.feedback         = 'no';                                              % feedback should not be presented
cfgDS.showcallinfo     = 'no';                                              % prevent printing the time and memory after each function call

% -------------------------------------------------------------------------
% Preprocessing
% -------------------------------------------------------------------------
fprintf('<strong>Preproc participant 1...</strong>\n');
orgFs       = data.part1.fsample;
data.part1  = bpfilter(cfgBP, data.part1);
data.part1  = rereference(cfgReref, data.part1);
if orgFs ~= samplingRate
  data.part1  = downsampling(cfgDS, data.part1);
else
  data.part1.fsample = orgFs;
end
  
fprintf('<strong>Preproc participant 2...</strong>\n');
orgFs       = data.part2.fsample;
data.part2  = bpfilter(cfgBP, data.part2);
data.part2  = rereference(cfgReref, data.part2);
if orgFs ~= samplingRate
  data.part2  = downsampling(cfgDS, data.part2);
else
  data.part2.fsample = orgFs;
end  

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_out ] = bpfilter( cfgB, data_in )
  
data_out = ft_preprocessing(cfgB, data_in);
  
end

function [ data_out ] = downsampling( cfgD, data_in )

ft_info off;
data_out = ft_resampledata(cfgD, data_in);
ft_info on;

end

function [ data_out ] = rereference( cfgR, data_in )

calcceogcomp = cfgR.calceogcomp;

if strcmp(calcceogcomp, 'yes')
  cfgtmp              = [];
  cfgtmp.channel      = {'F9', 'F10'};
  cfgtmp.reref        = 'yes';
  cfgtmp.refchannel   = 'F10';
  cfgtmp.showcallinfo = 'no';
  cfgtmp.feedback     = 'no';
  
  eogh                = ft_preprocessing(cfgtmp, data_in);
  eogh.label{1}       = 'EOGH';
  
  cfgtmp              = [];
  cfgtmp.channel      = 'EOGH';
  cfgtmp.showcallinfo = 'no';
  
  eogh                = ft_selectdata(cfgtmp, eogh); 
  
  cfgtmp              = [];
  cfgtmp.channel      = {'V1', 'V2'};
  cfgtmp.reref        = 'yes';
  cfgtmp.refchannel   = 'V2';
  cfgtmp.showcallinfo = 'no';
  cfgtmp.feedback     = 'no';
  
  eogv                = ft_preprocessing(cfgtmp, data_in);
  eogv.label{1}       = 'EOGV';
  
  cfgtmp              = [];
  cfgtmp.channel      = 'EOGV';
  cfgtmp.showcallinfo = 'no';
  
  eogv                = ft_selectdata(cfgtmp, eogv);
end

cfgR = removefields(cfgR, {'calcceogcomp'});
data_out = ft_preprocessing(cfgR, data_in);

if strcmp(calcceogcomp, 'yes')
  cfgtmp              = [];
  cfgtmp.showcallinfo = 'no';
  ft_info off;
  data_out            = ft_appenddata(cfgtmp, data_out, eogv, eogh);
  ft_info on;
end

end
