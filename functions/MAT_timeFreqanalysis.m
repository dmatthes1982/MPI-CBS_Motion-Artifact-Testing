function [ data ] = MAT_timeFreqanalysis( cfg, data )
% MAT_TIMEFREQANALYSIS performs a time frequency analysis.
%
% Use as
%   [ data ] = MAT_timeFreqanalysis(cfg, data)
%
% where the input data has to be the result from MAT_IMPORTDATASET,
% MAT_PREPROCESSING or MAT_SEGMENTATION
%
% The configuration options are
%   config.foi = frequency of interest - begin:resolution:end (default: 2:1:50)
%   config.toi = time of interest - begin:resolution:end (default: 4:0.5:176)
%   
% This function requires the fieldtrip toolbox.
%
% See also MAT_IMPORTDATASET, MAT_PREPROCESSING, MAT_SEGMENTATION, 
% MAT_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
foi       = ft_getopt(cfg, 'foi', 2:1:50);
toi       = ft_getopt(cfg, 'toi', 0:0.02:5);

% -------------------------------------------------------------------------
% TFR settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.method          = 'wavelet';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum for specified channel
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = 'maxperlen';                                          % do not use padding
cfg.taper           = 'hanning';                                            % hanning taper the segments
cfg.foi             = foi;                                                  % frequencies of interest
cfg.width           = 7;                                                    % wavlet specific parameter 1 (default value)
cfg.gwidth          = 3;                                                    % wavlet specific parameter 2 (default value) 
cfg.toi             = toi;                                                  % time of interest
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

% -------------------------------------------------------------------------
% Time-Frequency Response (Analysis)
% -------------------------------------------------------------------------
fprintf('<strong>Calc TFRs of participant 1...</strong>\n');
ft_warning off;
data.part1 = ft_freqanalysis(cfg, data.part1);
  
fprintf('<strong>Calc TFRs of participant 2...</strong>\n');
ft_warning off;
data.part2 = ft_freqanalysis(cfg, data.part2); 

ft_warning on;

end
