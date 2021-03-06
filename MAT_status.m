% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
MAT_init;

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Motion artifact testing</strong>\n');
cprintf([0,0.6,0], '<strong>Data processing status</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
path = '/data/pt_01826/eegData_MotionArtifactTesting/DualEEG_MAT_processedData/';

fprintf('\nThe default path is: %s\n', path);

selection = false;
while selection == false
  fprintf('\nDo you want to use the default path?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    newPaths = false;
  elseif strcmp('n', x)
    selection = true;
    newPaths = true;
  else
    selection = false;
  end
end

if newPaths == true
  path = uigetdir(pwd, 'Select folder...');
  path = strcat(path, '/');
end

clear newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
tmpPath = strcat(path, '01a_raw/');

fileList     = dir([tmpPath, 'MAT_d*_01a_raw_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

if numOfFiles == 0
  fprintf('\n<strong>No sessions are avialable at this path!</strong>\n');
  clear tmpPath fileList numOfFiles path selection x
  return;
end

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for i=1:1:numOfFiles
  fileListCopy{i} = strsplit(fileList{i}, '01a_raw_');
  fileListCopy{i} = fileListCopy{i}{end};
  sessionNum(i) = sscanf(fileListCopy{i}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(fileListCopy, sprintf('%03d.mat', i)), 1, 'first');
  filePath = [tmpPath, fileList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

selection = false;
while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for i=1:1:length(userList)
    fprintf('%d - %s\n', i, userList{i});
  end
  fprintf('\n');
  fprintf('Please select one session:\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      sessionStr = sprintf('%03d', x);
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

fprintf('\n');

clear fileList numOfFiles sessionNum fileListCopy x y userList ...
      match filePath cmdout attrib selection 

% -------------------------------------------------------------------------
% Determine and return session status
% -------------------------------------------------------------------------  
parts = {...
          '[1] - Data import and repairing of bad channels:', ...
          '[2] - Preprocessing, filtering, re-referencing:', ...
          '[3] - Power analysis (TFR, pWelch):', ...
          '[4] - Averaging TFR and pWelch results:' ...
};

folders = {...
            '01c_repaired', ...
            '02_preproc', ...
            '03d_pwelch_preproc', ...
            '04d_pwelch_preprocop' ...
};

fprintf('<strong>Status of the data processing:</strong>\n');

for i = 1:1:length(parts)
  fprintf('\n%s\n', parts{i});
  tmpPath = strcat(path, folders{i}, '/');
  
  fileList    = dir([tmpPath, ['MAT_d*' sessionStr '.mat']]);
  fileList    = struct2cell(fileList);
  fileList    = fileList(1,:);
  numOfFiles  = length(fileList);
  numOfPart   = zeros(1, numOfFiles);
  for j = 1:1:numOfFiles
    numOfPart(j) = sscanf(fileList{j}, strcat('MAT_d%d*', sessionStr, '.mat'));
  end
  
  numOfPart = unique(numOfPart);
  y = sprintf('%d ', numOfPart);
  
  fprintf('%s\n', y);
end

clear fileList folders parts numOfFiles numOfPart i j y tmpPath ...
      path sessionStr
    