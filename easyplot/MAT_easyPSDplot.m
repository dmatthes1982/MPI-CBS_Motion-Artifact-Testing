function MAT_easyPSDplot(cfg, data)
% MAT_EASYPSDPLOT is a function, which makes it easier to plot the power
% spectral density within a specific condition of the MAT_DATASTRUCTURE
%
% Use as
%   MAT_easyPSDplot(cfg, data)
%
% where the input data have to be a result from MAT_PWELCH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2   
%   cfg.condition   = condition (default: 100 or 'No movement', see MAT_DATASTRUCTURE)
%   cfg.trial       = number of trial (default: 1)   
%   cfg.electrode   = number of electrodes (default: {'Cz'} repsectively [8])
%                     examples: {'Cz'}, {'F3', 'Fz', 'F4'}, [8] or [2, 1, 28]
%
% This function requires the fieldtrip toolbox
%
% See also MAT_PWELCH, MAT_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 100);
trl     = ft_getopt(cfg, 'trial', 1);
elec    = ft_getopt(cfg, 'electrode', {'Cz'});

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

if ~ismember(part, [0,1,2])                                                 % check cfg.part definition
  error('cfg.part has to either 0, 1 or 2');
end

switch part                                                                 % check validity of cfg.part
  case 0
    if isfield(data, 'part1')
      warning backtrace off;
      warning('You are using dyad-specific data. Please specify either cfg.part = 1 or cfg.part = 2');
      warning backtrace on;
      return;
    end
  case 1
    if ~isfield(data, 'part1')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part1;
  case 2
    if ~isfield(data, 'part2')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part2;
end

trialinfo = data.trialinfo;                                                 % get trialinfo
label     = data.label;                                                     % get labels 

cond = MAT_checkCondition( cond );                                          % check cfg.condition definition    
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

if isnumeric(elec)                                                          % check cfg.electrode
  for i=1:length(elec)
    if elec(i) < 1 || elec(i) > 32
      error('cfg.elec has to be a numbers between 1 and 32 or a existing labels like {''Cz''}.');
    end
  end
else
  tmpElec = zeros(1, length(elec));
  for i=1:length(elec)
    tmpElec(i) = find(strcmp(label, elec{i}));
    if isempty(tmpElec(i))
      error('cfg.elec has to be a cell array of existing labels like ''Cz''or a vector of numbers between 1 and 32.');
    end
  end
  elec = tmpElec;
end

% -------------------------------------------------------------------------
% Plot power spectral density (PSD)
% -------------------------------------------------------------------------
plot(data.freq, log(squeeze(data.powspctrm(trl, elec,:))));
labelString = strjoin(data.label(elec), ',');
if part == 0                                                                % set figure title
  title(sprintf('PSD - Cond.: %d - Trial: %d - Elec.: %s', cond, ...
                trlInCond, labelString));
else
  title(sprintf('PSD - Part.: %d - Cond.: %d - Trial: %d - Elec.: %s', ...
        part, cond, trlInCond, labelString));
end

xlabel('frequency in Hz');                                                  % set xlabel
ylabel('PSD');                                                              % set ylabel

end
