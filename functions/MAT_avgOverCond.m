function [ data ] = MAT_avgOverCond( data )
% MAT_AVGOVERCOND estimates the averaged power spectral desitiny over all
% conditions with the same condition marker.
%
% Use as
%   [ data ] = MAT_avgOverCond( data )
%
% where the input data hast to be the result from MAT_PWELCH
%
% This function requires the fieldtrip toolbox.
%
% See also MAT_PWELCH

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Calculate averaged power spectral density
% -------------------------------------------------------------------------
fprintf('<strong>Averaging over equal conditions for participant 1...</strong>\n');
data.part1 = average(data.part1);

fprintf('<strong>Averaging over equal conditions for participant 2...</strong>\n');
data.part2 = average(data.part2);

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_avg ] = average(data_org)
trialinfo = unique(data_org.trialinfo);
if size(data_org.powspctrm, 4) > 1
  powspctrm = zeros(length(trialinfo), length(data_org.label), ...
                    length(data_org.freq), length(data_org.time));
else
  powspctrm = zeros(length(trialinfo), length(data_org.label), ...
                    length(data_org.freq));
end

for i = 1:1:length(trialinfo)
  val       = ismember(data_org.trialinfo, trialinfo(i));
  if size(data_org.powspctrm, 4) > 1
    tmpspctrm = data_org.powspctrm(val,:,:,:);
    powspctrm(i,:,:,:) = median(tmpspctrm, 1);
  else
    tmpspctrm = data_org.powspctrm(val,:,:);
    powspctrm(i,:,:) = median(tmpspctrm, 1);
  end
end

data_avg.label = data_org.label;
data_avg.dimord = data_org.dimord;
data_avg.freq = data_org.freq;
if size(data_org.powspctrm, 4) > 1
  data_avg.time = data_org.time;
end
data_avg.powspctrm = powspctrm;
if size(data_org.powspctrm, 4) > 1
  data_avg.cumtapcnt = ones(length(trialinfo), length(data_avg.freq));
end
data_avg.trialinfo = trialinfo;
data_avg.cfg.previous = data_org.cfg;
data_avg.cfg.avgOverCond = 'yes';

end
