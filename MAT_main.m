% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
MAT_init;

cprintf([0,0.6,0], '<strong>---------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Motion artifact testing - data processing</strong>\n');
cprintf([0,0.6,0], '<strong>Version: 0.1</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>---------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
srcPath = '/data/pt_01826/eegData_MotionArtifactTesting/DualEEG_MAT_rawData/';
desPath = '/data/pt_01826/eegData_MotionArtifactTesting/DualEEG_MAT_processedData/';

fprintf('\nThe default paths are:\n');
fprintf('Source: %s\n',srcPath);
fprintf('Destination: %s\n',desPath);

selection = false;
while selection == false
  fprintf('\nDo you want to select the default paths?\n');
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
  srcPath = uigetdir(pwd, 'Select Source Folder...');
  desPath = uigetdir(strcat(srcPath,'/..'), ...
                      'Select Destination Folder...');
  srcPath = strcat(srcPath, '/');
  desPath = strcat(desPath, '/');
end

if ~exist(strcat(desPath, '00_settings'), 'dir')
  mkdir(strcat(desPath, '00_settings'));
end
if ~exist(strcat(desPath, '01a_raw'), 'dir')
  mkdir(strcat(desPath, '01a_raw'));
end
if ~exist(strcat(desPath, '01b_badchan'), 'dir')
  mkdir(strcat(desPath, '01b_badchan'));
end
if ~exist(strcat(desPath, '01c_repaired'), 'dir')
  mkdir(strcat(desPath, '01c_repaired'));
end
if ~exist(strcat(desPath, '02_preproc'), 'dir')
  mkdir(strcat(desPath, '02_preproc'));
end
if ~exist(strcat(desPath, '03a_badtrials'), 'dir')
  mkdir(strcat(desPath, '03a_badtrials'));
end
if ~exist(strcat(desPath, '03b_cleaned_raw'), 'dir')
  mkdir(strcat(desPath, '03b_cleaned_raw'));
end
if ~exist(strcat(desPath, '03c_cleaned_preproc'), 'dir')
  mkdir(strcat(desPath, '03c_cleaned_preproc'));
end
if ~exist(strcat(desPath, '04a_tfr_raw'), 'dir')
  mkdir(strcat(desPath, '04a_tfr_raw'));
end
if ~exist(strcat(desPath, '04b_tfr_preproc'), 'dir')
  mkdir(strcat(desPath, '04b_tfr_preproc'));
end
if ~exist(strcat(desPath, '04c_pwelch_raw'), 'dir')
  mkdir(strcat(desPath, '04c_pwelch_raw'));
end
if ~exist(strcat(desPath, '04d_pwelch_preproc'), 'dir')
  mkdir(strcat(desPath, '04d_pwelch_preproc'));
end
if ~exist(strcat(desPath, '05a_tfroc_raw'), 'dir')
  mkdir(strcat(desPath, '05a_tfroc_raw'));
end
if ~exist(strcat(desPath, '05b_tfroc_preproc'), 'dir')
  mkdir(strcat(desPath, '05b_tfroc_preproc'));
end
if ~exist(strcat(desPath, '05c_pwelchoc_raw'), 'dir')
  mkdir(strcat(desPath, '05c_pwelchoc_raw'));
end
if ~exist(strcat(desPath, '05d_pwelchoc_preproc'), 'dir')
  mkdir(strcat(desPath, '05d_pwelchoc_preproc'));
end
if ~exist(strcat(desPath, '05e_tfrop_raw'), 'dir')
  mkdir(strcat(desPath, '05e_tfrop_raw'));
end
if ~exist(strcat(desPath, '05f_tfrop_preproc'), 'dir')
  mkdir(strcat(desPath, '05f_tfrop_preproc'));
end
if ~exist(strcat(desPath, '05g_pwelchop_raw'), 'dir')
  mkdir(strcat(desPath, '05g_pwelchop_raw'));
end
if ~exist(strcat(desPath, '05h_pwelchop_preproc'), 'dir')
  mkdir(strcat(desPath, '05h_pwelchop_preproc'));
end
clear sessionStr numOfPart part newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
selection = false;

tmpPath = strcat(desPath, '01a_raw/');

sessionList     = dir([tmpPath, 'MAT_d*_01a_raw_*.mat']);
sessionList     = struct2cell(sessionList);
sessionList     = sessionList(1,:);
numOfSessions   = length(sessionList);

sessionNum      = zeros(1, numOfSessions);
sessionListCopy = sessionList;

for i=1:1:numOfSessions
  sessionListCopy{i} = strsplit(sessionList{i}, '01a_raw_');
  sessionListCopy{i} = sessionListCopy{i}{end};
  sessionNum(i) = sscanf(sessionListCopy{i}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(sessionListCopy, sprintf('%03d.mat', i)), 1, 'first');
  filePath = [tmpPath, sessionList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for i=1:1:length(userList)
    fprintf('%d - %s\n', i, userList{i});
  end
  fprintf('\n');
  fprintf('Please select one session or create a new one:\n');
  fprintf('[0] - Create new session\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      session = x;
      sessionStr = sprintf('%03d', session);
    elseif x == 0  
      selection = true;
      session = x;
      if ~isempty(max(sessionNum))
        sessionStr = sprintf('%03d', max(sessionNum) + 1);
      else
        sessionStr = sprintf('%03d', 1);
      end
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

clear tmpPath sessionListCopy userList match filePath cmdout attrib 

% -------------------------------------------------------------------------
% General selection of dyads
% -------------------------------------------------------------------------
selection = false;

while selection == false
  fprintf('\nPlease select one option:\n');
  fprintf('[1] - Process all available dyads\n');
  fprintf('[2] - Process all new dyads\n');
  fprintf('[3] - Process specific dyad\n');
  fprintf('[4] - Quit data processing\n\n');
  x = input('Option: ');
  
  switch x
    case 1
      selection = true;
      dyadsSpec = 'all';
    case 2
      selection = true;
      dyadsSpec = 'new';
    case 3
      selection = true;
      dyadsSpec = 'specific';
    case 4
      fprintf('\nData processing aborted.\n');
      clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions sessionStr
      return;
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

% -------------------------------------------------------------------------
% General selection of preprocessing option
% -------------------------------------------------------------------------
selection = false;

if session == 0
  fprintf('\nA new session always will start with part:\n');
  fprintf('[1] - Import raw data\n');
  part = 1;
else
  while selection == false
    fprintf('\nPlease select what you want to do with the selected dyads:\n');
    fprintf('[1] - Data import and repairing of bad channels\n');
    fprintf('[2] - Preprocessing, filtering, re-referencing\n');
    fprintf('[3] - Selection and rejection of bad trials\n');
    fprintf('[4] - Power analysis (TFR, pWelch)\n');
    fprintf('[5] - Averaging TFR and pWelch results\n');
    fprintf('[6] - Quit data processing\n\n');
    x = input('Option: ');
  
    switch x
      case 1
        part = 1;
        selection = true;
      case 2
        part = 2;
        selection = true;
      case 3
        part = 3;
        selection = true;
      case 4
        part = 4;
        selection = true;
      case 5
        part = 5;
        selection = true;
      case 6
        fprintf('\nData processing aborted.\n');
        clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions dyadsSpec sessionStr
        return;
      otherwise
        selection = false;
        cprintf([1,0.5,0], 'Wrong input!\n');
    end
  end
end

% -------------------------------------------------------------------------
% Specific selection of dyads
% -------------------------------------------------------------------------
sourceList    = dir([srcPath, '/*.vhdr']);
sourceList    = struct2cell(sourceList);
sourceList    = sourceList(1,:);
numOfSources  = length(sourceList);
fileNum       = zeros(1, numOfSources);

for i=1:1:numOfSources
  fileNum(i)     = sscanf(sourceList{i}, 'DualEEG_MAT_%d.vhdr');
end

switch part
  case 1
    fileNamePre = [];
    tmpPath = strcat(desPath, '01a_raw/');
    fileNamePost = strcat(tmpPath, 'MAT_d*_01a_raw_', sessionStr, '.mat');
  case 2
    tmpPath = strcat(desPath, '01c_repaired/');
    fileNamePre = strcat(tmpPath, 'MAT_d*_01c_repaired_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePost = strcat(tmpPath, 'MAT_d*_02_preproc_', sessionStr, '.mat');
  case 3
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePre = strcat(tmpPath, 'MAT_d*_02_preproc_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '03c_cleaned_preproc/');
    fileNamePost = strcat(tmpPath, 'MAT_d*_03c_cleaned_preproc_', sessionStr, '.mat');
  case 4
    tmpPath = strcat(desPath, '03c_cleaned_preproc/');
    fileNamePre = strcat(tmpPath, 'MAT_d*_03c_cleaned_preproc_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '04d_pwelch_preproc/');
    fileNamePost = strcat(tmpPath, 'MAT_d*_04d_pwelch_preproc_', sessionStr, '.mat');
  case 5
    tmpPath = strcat(desPath, '04d_pwelch_preproc/');
    fileNamePre = strcat(tmpPath, 'MAT_d*_04d_pwelch_preproc_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '05h_pwelchop_preproc/');
    fileNamePost = strcat(tmpPath, 'MAT_d*_05h_pwelchop_preproc_', sessionStr, '.mat');
  otherwise
    error('Something unexpected happend. part = %d is not defined' ...
          , part);
end

if ~isequal(fileNamePre, 0)
  if isempty(fileNamePre)
    numOfPrePart = fileNum;
  else
    fileListPre = dir(fileNamePre);
    if isempty(fileListPre)
      cprintf([1,0.5,0], ['Selected part [%d] can not be executed, no '...'
            'input data available\n Please choose a previous part.\n'], part);
      clear desPath fileNamePost fileNamePre fileNum i numOfSources ...
            selection sourceList srcPath x y dyadsSpec fileListPre ... 
            sessionList sessionNum numOfSessions session part sessionStr ...
            tmpPath
      return;
    else
      fileListPre = struct2cell(fileListPre);
      fileListPre = fileListPre(1,:);
      numOfFiles  = length(fileListPre);
      numOfPrePart = zeros(1, numOfFiles);
      for i=1:1:numOfFiles
        numOfPrePart(i) = sscanf(fileListPre{i}, strcat('MAT_d%d*', sessionStr, '.mat'));
      end
    end
  end

  if strcmp(dyadsSpec, 'all')                                               % process all participants
    numOfPart = numOfPrePart;
  elseif strcmp(dyadsSpec, 'specific')                                      % process specific participants
    y = sprintf('%d ', numOfPrePart);
    
    selection = false;
    
    while selection == false
      fprintf('\nThe following participants are available: %s\n', y);
      fprintf(['Comma-seperate your selection and put it in squared ' ...
               'brackets!\n']);
      x = input('\nPlease make your choice! (i.e. [1,2,3]): ');
      
      if ~all(ismember(x, numOfPrePart))
        cprintf([1,0.5,0], 'Wrong input!\n');
      else
        selection = true;
        numOfPart = x;
      end
    end
  elseif strcmp(dyadsSpec, 'new')                                           % process only new participants
    if session == 0
      numOfPart = numOfPrePart;
    else
      fileListPost = dir(fileNamePost);
      if isempty(fileListPost)
        numOfPostPart = [];
      else
        fileListPost = struct2cell(fileListPost);
        fileListPost = fileListPost(1,:);
        numOfFiles  = length(fileListPost);
        numOfPostPart = zeros(1, numOfFiles);
        for i=1:1:numOfFiles
          numOfPostPart(i) = sscanf(fileListPost{i}, strcat('MAT_d%d*', sessionStr, '.mat'));
        end
      end
  
      numOfPart = numOfPrePart(~ismember(numOfPrePart, numOfPostPart));
      if isempty(numOfPart)
        cprintf([1,0.5,0], 'No new dyads available!\n');
        fprintf('Data processing aborted.\n');
        clear desPath fileNamePost fileNamePre fileNum i numOfPrePart ...
              numOfSources selection sourceList srcPath x y dyadsSpec ...
              fileListPost fileListPre numOfPostPart sessionList ...
              numOfFiles sessionNum numOfSessions session numOfPart ...
              part sessionStr dyads tmpPath
        return;
      end
    end
  end

  y = sprintf('%d ', numOfPart);
  fprintf(['\nThe following participants will be processed ' ... 
         'in the selected part [%d]:\n'],  part);
  fprintf('%s\n\n', y);

  clear fileNamePost fileNamePre fileNum i numOfPrePart ...
        numOfSources selection sourceList x y dyads fileListPost ...
        fileListPre numOfPostPart sessionList sessionNum numOfSessions ...
        session dyadsSpec numOfFiles tmpPath
else
  fprintf('\n');
  clear fileNamePost fileNamePre fileNum i numOfSources selection ...
        sourceList x y dyads sessionList sessionNum numOfSessions ...
        session dyadsSpec numOfFiles tmpPath
end

% -------------------------------------------------------------------------
% Data processing main loop
% -------------------------------------------------------------------------
sessionStatus = true;
sessionPart = part;

clear part;

while sessionStatus == true
  switch sessionPart
    case 1
      MAT_main_1;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[2] - Preprocessing, filtering, re-referencing?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 2;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 2
      MAT_main_2;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[3] - Selection and rejection of bad trials?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 3;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 3
      MAT_main_3;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[4] - Power analysis (TFR, pWelch)?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 4;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 4
      MAT_main_4;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[5] - Averaging TFR and pWelch results?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 5;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 5
      MAT_main_5;
      sessionStatus = false;
    otherwise
      sessionStatus = false;
  end
  fprintf('\n');
end

fprintf('<strong>Data processing finished.</strong>\n');
fprintf('<strong>Session will be closed.</strong>\n');

clear sessionStr numOfPart srcPath desPath sessionPart sessionStatus ...
      selection x
