function MAT_easyTFRplot(cfg, data)
% MAT_EASYTFRPLOT is a function, which makes it easier to plot a
% time-frequency-spectrum of a specific condition and trial from the 
% MAT_DATASTRUCTURE.
%
% Use as
%   MAT_easyTFRPlot(cfg, data)
%
% where the input data is a results from MAT_TIMEFREQANALYSIS.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%   cfg.condition   = condition (default: 100 or 'No movement', see MAT_DATASTRUCTURE)
%   cfg.electrode   = number of electrode (default: 'Cz')
%   cfg.trial       = number of trial (default: 1)
%   cfg.freqlimits  = [begin end] (default: [2 100])
%   cfg.timelimits  = [begin end] (default: [0 5])
%
% This function requires the fieldtrip toolbox
%
% See also FT_SINGLEPLOTTFR, MAT_TIMEFREQANALYSIS, MAT_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 100);
elec    = ft_getopt(cfg, 'electrode', 'Cz');
trl     = ft_getopt(cfg, 'trial', 1);
freqlim = ft_getopt(cfg, 'freqlimits', [2 100]);
timelim = ft_getopt(cfg, 'timelimits', [0 5]);

if ~ismember(part, [1,2])                                                   % check cfg.part definition
  error('cfg.part has to either 1 or 2');
end

switch part
  case 1
    data = data.part1;
  case 2
    data = data.part2;
end

trialinfo = data.trialinfo;                                                 % get trialinfo
label     = data.label;                                                     % get labels

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));

cond    = MAT_checkCondition( cond );                                       % check cfg.condition definition    
trials  = find(trialinfo == cond);
if isempty(trials)
  error('The selected dataset contains no condition %d.', cond);
else
  numTrials = length(trials);
  if numTrials < trl                                                        % check cfg.trial definition
    error('The selected dataset contains only %d trials.', numTrials);
  else
    trlInCond = trl;
    trl = trl-1 + trials(1);
  end
end

if isnumeric(elec)
  if ~ismember(elec,  1:1:32)
    error('cfg.elec hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elec = find(strcmp(label, elec));
  if isempty(elec)
    error('cfg.elec hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

% -------------------------------------------------------------------------
% Plot time frequency spectrum
% -------------------------------------------------------------------------

ft_warning off;

cfg                 = [];                                                       
cfg.maskstyle       = 'saturation';
cfg.xlim            = timelim;
cfg.ylim            = freqlim;
cfg.zlim            = 'maxmin';
cfg.trials          = trl;                                                  % select trial (or 'all' trials)
cfg.channel         = elec;
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

colormap jet;                                                               % use the older and more common colormap

ft_singleplotTFR(cfg, data);
title(sprintf('Part.: %d - Cond.: %d - Elec.: %s - Trial: %d', ...
      part, cond, strrep(data.label{elec}, '_', '\_'), trlInCond));      

xlabel('time in sec');                                                      % set xlabel
ylabel('frequency in Hz');                                                  % set ylabel

ft_warning on;

end