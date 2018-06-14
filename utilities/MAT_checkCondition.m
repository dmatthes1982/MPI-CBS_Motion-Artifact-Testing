function [ num ] = MAT_checkCondition( condition )
% MAT_CHECKCONDITION - This functions checks the defined conditions.
%
% Use as
%   [ num ] = MAT_checkCondition( condition )
%
% If condition is a number or a numeric vector the function checks, if the
% given numbers are part of the default values and return these numbers in
% case of confirmity. If condition is a string or cell array of some
% strings,the function returns the associated number, if the given strings
% are valid. Otherwise the function throws an error.
%
% All available condition strings and numbers are defined in
% MAT_DATASTRUCTURE
%
% SEE also MAT_DATASTRUCTURE

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/MAT_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric(condition)                                                     % if condition is already numeric
  elements = ismember(condition, generalDefinitions.condNum);
  if ~all(elements)
    error('the following condition(s): %d is (are) not a valid', condition(~elements));
  else
    num = condition;
  end
else                                                                        % if condition is specified as string
  elements = ismember(condition, generalDefinitions.condString);
  if ~all(elements)
     error('the following condition(s): %s is (are) not a valid', condition(~elements));
  else
    elements =  ismember(generalDefinitions.condString, condition);
    num = generalDefinitions.condNum(elements);
  end
end

end
