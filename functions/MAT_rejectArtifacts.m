function [ data ] = MAT_rejectArtifacts( cfg, data )
% MAT_REJECTARTIFACTS is a function which removes trials containing 
% artifacts. It returns cleaned data.
%
% Use as
%   [ data ] = MAT_rejectartifacts( cfg, data )
%
% where data can be a result of  MAT_IMPORTDATASET or MAT_PREPROCESSING
%
% The configuration options are
%   cfg.artifact  = output of MAT_manArtifact
%                   (see file MAT_pxx_03a_badtrials_yyy.mat)
%
% This function requires the fieldtrip toolbox.
%
% See also  MAT_IMPORTDATASET, MAT_PREPROCESSING, MAT_MANARTIFACT

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
artifact  = ft_getopt(cfg, 'artifact', []);

if isempty(artifact)
  error('cfg.artifact has to be defined');
end

% -------------------------------------------------------------------------
% Clean Data
% -------------------------------------------------------------------------
fprintf('\n<strong>Cleaning data of participant 1...</strong>\n');
ft_warning off;
data.part1 = ft_rejectartifact(artifact.part1, data.part1);
  
fprintf('\n<strong>Cleaning data of participant 2...</strong>\n');
ft_warning off;
data.part2 = ft_rejectartifact(artifact.part2, data.part2);
  
ft_warning on;

end
