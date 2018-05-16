function [ cfgAllArt ] = MAT_manArtifact( cfg, data )
% MAT_MANARTIFACT - this function can be use to select bad trials.
%
% Use as
%   [ cfgAllArt ] = MAT_manArtifact(cfg, data)
%
% where data can be a result of MAT_IMPORTDATASET or MAT_PREPROCESSING
%
% The configuration options are
%   cfg.dyad      = number of dyad (only necessary for adding markers to databrowser view) (default: []) 
%
% This function requires the fieldtrip toolbox.
%
% See also MAT_IMPORTDATASET, MAT_PREPROCESSING, MAT_DATABROWSER

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad      = ft_getopt(cfg, 'dyad', []);

% -------------------------------------------------------------------------
% Initialize settings, build output structure
% -------------------------------------------------------------------------
cfg             = [];
cfg.dyad        = dyad;
cfg.channel     = {'all', '-V1', '-V2'};
cfg.ylim        = [-100 100];
cfgAllArt.part1 = [];                                       
cfgAllArt.part2 = [];

% -------------------------------------------------------------------------
% Check Data
% -------------------------------------------------------------------------

fprintf('<strong>Search for bad trials in data of participant 1...</strong>\n');
cfg.part = 1;
ft_warning off;
cfgAllArt.part1 = MAT_databrowser(cfg, data);
cfgAllArt.part1 = keepfields(cfgAllArt.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('\n<strong>Search for bad trials in  data of participant 2...</strong>\n');
cfg.part = 2;
ft_warning off;
cfgAllArt.part2 = MAT_databrowser(cfg, data);
cfgAllArt.part2 = keepfields(cfgAllArt.part2, {'artfctdef', 'showcallinfo'});
  
ft_warning on;

end