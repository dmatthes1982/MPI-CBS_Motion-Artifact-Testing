function MAT_createTbl( cfg )
% MAT_CREATETBL generates '*.xls' files for the documentation of the data 
% processing process. Currently three different types of doc files are
% supported.
%
% Use as
%   MAT_createTbl( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01826/eegData_MotionArtifactTesting/DualEEG_MAT_processedData/00_settings/')
%   cfg.type        = type of documentation file (option: 'settings')
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% Explanation:
%   type settings - holds information about the selectable values: fsample, reference and ICAcorrVal
%   
% This function requires the fieldtrip toolbox.

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', ...
          '/data/pt_01826/eegData_MotionArtifactTesting/DualEEG_MAT_processedData/00_settings/');
type        = ft_getopt(cfg, 'type', []);
sessionStr  = ft_getopt(cfg, 'sessionStr', []);

if isempty(type)
  error('cfg.type has to be specified. It could be only ''settings''');
end

if isempty(sessionStr)
  error('cfg.sessionStr has to be specified');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/MAT_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Create table
% -------------------------------------------------------------------------
switch type
  case 'settings'
    T = table(1,{'unknown'},{'unknown'},0,{'unknown'});
    T.Properties.VariableNames = ...
        {'dyad', 'badChanPart1', 'badChanPart2', 'fsample', 'reference'};
    filepath = [desFolder type '_' sessionStr '.xls'];
    writetable(T, filepath);
  otherwise
    error('cfg.type is not valid. Please use ''settings''!');
end

end

