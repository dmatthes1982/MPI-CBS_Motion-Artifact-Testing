function [ data ] = MAT_avgOverPart( data )
% MAT_AVGOVERPART estimates the averaged power spectral desitiny over all
% participants of one dyad.
%
% Use as
%   [ data ] = MAT_avgOverCond( data )
%
% where the input data hast to be the result from MAT_AVGOVERCOND
%
% This function requires the fieldtrip toolbox.
%
% See also MAT_AVGOVERCOND

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Calculate averaged power spectral density
% -------------------------------------------------------------------------
fprintf('<strong>Averaging over participants...</strong>\n');
data = average(data);

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_avg ] = average(data_avg)
if size(data_avg.part1.powspctrm, 4) > 1
  powspctrm = squeeze(mean(cat(5, data_avg.part1.powspctrm, ...
                data_avg.part2.powspctrm),5));
else
  powspctrm = squeeze(mean(cat(4, data_avg.part1.powspctrm, ...
                data_avg.part2.powspctrm),4));
end

  cfg1 = data_avg.part1.cfg;
  cfg2 = data_avg.part2.cfg;
  data_avg = data_avg.part1;
  data_avg.powspctrm = powspctrm;
  data_avg.cfg.avgOverPart =  'yes';
  data_avg.cfg = removefields(data_avg.cfg, 'avgOverCond');
  data_avg.cfg = removefields(data_avg.cfg, 'previous');
  data_avg.cfg.previous{1,1} = cfg1;
  data_avg.cfg.previous{1,2} = cfg2;

end
