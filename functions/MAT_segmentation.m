function [ data ] = MAT_segmentation(cfg, data )
% MAT_SEGMENTATION segments the data of each condition into segments with a
% certain length
%
% Use as
%   [ data ] = MAT_segmentation( cfg, data )
%
% where the input data can be the result from MAT_IMPORTDATASET or
% MAT_PREPROCESSING
%
% The configuration options are
%   cfg.length    = length of segments (excepted values: 0.2, 1, 5, 10 seconds, default: 1)
%   cfg.overlap   = percentage of overlapping (range: 0 ... 1, default: 0)
%
% This function requires the fieldtrip toolbox.
%
% See also MAT_IMPORTDATASET, MAT_PREPROCESSING, FT_REDEFINETRIAL,
% MAT_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
segLength = ft_getopt(cfg, 'length', 1);
overlap   = ft_getopt(cfg, 'overlap', 0);

possibleLengths = [0.2, 1, 5, 10];

if ~any(ismember(possibleLengths, segLength))
  error('Excepted cfg.length values are only 0.2, 1, 5 and 10 seconds');
end

% -------------------------------------------------------------------------
% Segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';
cfg.trials          = 'all';                                                  
cfg.length          = segLength;
cfg.overlap         = overlap;

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fprintf('<strong>Segment data of participant 1 in segments of %d sec...</strong>\n', ...
        segLength);
ft_info off;
ft_warning off;
data.part1 = ft_redefinetrial(cfg, data.part1);
    
fprintf('<strong>Segment data of participant 2 in segments of %d sec...</strong>\n', ...
        segLength);
ft_info off;
ft_warning off;
data.part2 = ft_redefinetrial(cfg, data.part2);
    
ft_info on;
ft_warning on;
