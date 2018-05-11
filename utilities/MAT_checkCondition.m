function [ num ] = MAT_checkCondition( condition )
% MAT_CHECKCONDITION - This functions checks the defined condition. 
%
% Use as
%   [ num ] = MAT_checkCondition( condition )
%
% If condition is a number the function checks, if this number is equal to 
% one of the default values and return this number in case of confirmity. 
% If condition is a string, the function returns the associated number, if
% the given string is valid. Otherwise the function throws an error.
%
% All available condition strings and numbers are defined in
% MAT_DATASTRUCTURE
%
% SEE also MAT_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

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
  if ~any(generalDefinitions.condNum == condition)
    error('%d is not a valid condition', condition);
  else
    num = condition;
  end
else                                                                        % if condition is specified as string
  elements = strcmp(generalDefinitions.condString, condition);
  if ~any(elements)
     error('%s is not a valid condition', condition);
  else
    num = generalDefinitions.condNum(elements);
  end
end

end
