%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '02_preproc';
  cfg.filename  = 'MAT_d01_02_preproc';
  sessionStr    = sprintf('%03d', MAT_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = ['/data/pt_01826/eegData_MotionArtifactTesting/'                % destination path for processed data 
              'DualEEG_MAT_processedData/']; 
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in pwelch_preproc folder
  sourceList    = dir([strcat(desPath, '02_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('MAT_d%d_02_preproc_', sessionStr, '.mat'));
  end
end

%% part 3
% Selection and rejection of bad trials

cprintf([0,0.6,0], '<strong>[3] - Selection and rejection of bad trials</strong>\n');
fprintf('\n');

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);

  cfg             = [];                                                     % load raw data                                                     
  cfg.srcFolder   = strcat(desPath, '01a_raw/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_01a_raw', i);

  fprintf('Load raw data...\n\n');
  MAT_loadData( cfg );
  
  cfg           = [];                                                       % selection of bad trials
  cfg.dyad      = i;
  
  cfg_badtrials = MAT_manArtifact(cfg, data_raw);
  
  % export the selection into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03a_badtrials/');
  cfg.filename    = sprintf('MAT_d%02d_03a_badtrials', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('\nThe selection of bad trials of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'cfg_badtrials', cfg_badtrials);
  fprintf('Data stored!\n\n');
  
  fprintf('<strong>Cleaning raw data</strong>\n');
  cfg           = [];                                                       % rejection of bad trials in raw data
  cfg.artifact  = cfg_badtrials;
  cfg.reject    = 'complete';
  cfg.target    = 'single';
  
  data_cleaned_raw = MAT_rejectArtifacts(cfg, data_raw);
  fprintf('\n');
  
  % export the selection into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03b_cleaned_raw/');
  cfg.filename    = sprintf('MAT_d%02d_03b_cleaned_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The cleaned raw data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_cleaned_raw', data_cleaned_raw);
  fprintf('Data stored!\n\n');
  clear data_raw data_cleaned_raw
  
  cfg             = [];                                                     % load preprocessed data                                                     
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_02_preproc', i);

  fprintf('Load preprocessed data...\n\n');
  MAT_loadData( cfg );
  
  fprintf('<strong>Cleaning preprocessed data</strong>\n');
  cfg           = [];                                                       % rejection of bad trials in preprocessed data
  cfg.artifact  = cfg_badtrials;
  cfg.reject    = 'complete';
  cfg.target    = 'single';
  
  data_cleaned_preproc = MAT_rejectArtifacts(cfg, data_preproc);
  fprintf('\n');
  
  % export the selection into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03c_cleaned_preproc/');
  cfg.filename    = sprintf('MAT_d%02d_03c_cleaned_preproc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The cleaned preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_cleaned_preproc', data_cleaned_preproc);
  fprintf('Data stored!\n\n');
  clear data_preproc data_cleaned_preproc cfg_badtrials
end

%% clear workspace
clear file_path cfg sourceList numOfSources i
