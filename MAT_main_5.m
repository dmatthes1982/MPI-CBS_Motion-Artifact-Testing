%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '04d_pwelch_preproc';
  cfg.filename  = 'MAT_d01_04d_pwelch_preproc';
  sessionStr    = sprintf('%03d', MAT_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = ['/data/pt_01826/eegData_MotionArtifactTesting/'                % destination path for processed data 
              'DualEEG_MAT_processedData/']; 
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in pwelch_preproc folder
  sourceList    = dir([strcat(desPath, '04d_pwelch_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('MAT_d%d_04d_pwelch_preproc_', sessionStr, '.mat'));
  end
end

%% part 5
% Averaging TFR and pWelch results
% a) averaging over repetitions
% b) averaging over participants

cprintf([0,0.6,0], '<strong>[5] - Averaging TFR and pWelch results</strong>\n');
fprintf('\n');

% averaging over repetitions
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  cfg             = [];                                                     % load tfr of raw data
  cfg.srcFolder   = strcat(desPath, '04a_tfr_raw/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_04a_tfr_raw', i);

  fprintf('Load time frequency responses of raw data...\n\n');
  MAT_loadData( cfg );
  
  data_tfroc_raw = MAT_avgOverCond(data_tfr_raw);                           % average tfr of raw data over condition
  
  % export TFR data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05a_tfroc_raw/');
  cfg.filename    = sprintf('MAT_d%02d_05a_tfroc_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response of raw data averaged over condition of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_tfroc_raw', data_tfroc_raw);
  fprintf('Data stored!\n\n');
  clear data_tfroc_raw data_tfr_raw
  
  cfg             = [];                                                     % load tfr of preproc data
  cfg.srcFolder   = strcat(desPath, '04b_tfr_preproc/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_04b_tfr_preproc', i);

  fprintf('Load time frequency responses of preproc data...\n\n');
  MAT_loadData( cfg );
  
  data_tfroc_preproc = MAT_avgOverCond(data_tfr_preproc);                   % average tfr of preproc data over condition
  
  % export TFR data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05b_tfroc_preproc/');
  cfg.filename    = sprintf('MAT_d%02d_05b_tfroc_preproc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response of preproc data averaged over condition of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_tfroc_preproc', data_tfroc_preproc);
  fprintf('Data stored!\n\n');
  clear data_tfroc_preproc data_tfr_preproc
  
  cfg             = [];                                                     % load psd of raw data
  cfg.srcFolder   = strcat(desPath, '04c_pwelch_raw/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_04c_pwelch_raw', i);

  fprintf('Load power spectral density of raw data...\n\n');
  MAT_loadData( cfg );
  
  data_pwelchoc_raw = MAT_avgOverCond(data_pwelch_raw);                     % average psd of raw data over condition
  
  % export PSD data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05c_pwelchoc_raw/');
  cfg.filename    = sprintf('MAT_d%02d_05c_pwelchoc_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Power spectral density of raw data averaged over condition of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_pwelchoc_raw', data_pwelchoc_raw);
  fprintf('Data stored!\n\n');
  clear data_pwelchoc_raw data_pwelch_raw
  
  cfg             = [];                                                     % load psd of preproc data
  cfg.srcFolder   = strcat(desPath, '04d_pwelch_preproc/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_04d_pwelch_preproc', i);

  fprintf('Load power spectral density of preproc data...\n\n');
  MAT_loadData( cfg );
  
  data_pwelchoc_preproc = MAT_avgOverCond(data_pwelch_preproc);             % average psd of preproc data over condition
  
  % export PSD data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05d_pwelchoc_preproc/');
  cfg.filename    = sprintf('MAT_d%02d_05d_pwelchoc_preproc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Power spectral density of preproc data averaged over condition of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_pwelchoc_preproc', data_pwelchoc_preproc);
  fprintf('Data stored!\n\n');
  clear data_pwelchoc_preproc data_pwelch_preproc
end

% averaging over participants
for i = numOfPart
    fprintf('<strong>Dyad %d</strong>\n', i);
  
  cfg             = [];                                                     % load averaged tfr of raw data
  cfg.srcFolder   = strcat(desPath, '05a_tfroc_raw/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_05a_tfroc_raw', i);

  fprintf('Load averaged time frequency responses of raw data...\n\n');
  MAT_loadData( cfg );
  
  data_tfrop_raw = MAT_avgOverPart(data_tfroc_raw);                         % average tfr of raw data over participants
  
  % export TFR data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05e_tfrop_raw/');
  cfg.filename    = sprintf('MAT_d%02d_05e_tfrop_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response of raw data averaged over participants of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_tfrop_raw', data_tfrop_raw);
  fprintf('Data stored!\n\n');
  clear data_tfrop_raw data_tfroc_raw
  
  cfg             = [];                                                     % load averaged tfr of preproc data
  cfg.srcFolder   = strcat(desPath, '05b_tfroc_preproc/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_05b_tfroc_preproc', i);

  fprintf('Load averaged time frequency responses of preproc data...\n\n');
  MAT_loadData( cfg );
  
  data_tfrop_preproc = MAT_avgOverPart(data_tfroc_preproc);                 % average tfr of preproc data over participants
  
  % export TFR data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05f_tfrop_preproc/');
  cfg.filename    = sprintf('MAT_d%02d_05f_tfrop_preproc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response of preproc data averaged over participants of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_tfrop_preproc', data_tfrop_preproc);
  fprintf('Data stored!\n\n');
  clear data_tfrop_preproc data_tfroc_preproc
  
  cfg             = [];                                                     % load averaged psd of raw data
  cfg.srcFolder   = strcat(desPath, '05c_pwelchoc_raw/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_05c_pwelchoc_raw', i);

  fprintf('Load averaged power spectral density of raw data...\n\n');
  MAT_loadData( cfg );
  
  data_pwelchop_raw = MAT_avgOverPart(data_pwelchoc_raw);                   % average psd of raw data over participants
  
  % export PSD data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05g_pwelchop_raw/');
  cfg.filename    = sprintf('MAT_d%02d_05g_pwelchop_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Power spectral density of raw data averaged over participants of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_pwelchop_raw', data_pwelchop_raw);
  fprintf('Data stored!\n\n');
  clear data_pwelchop_raw data_pwelchoc_raw
  
  cfg             = [];                                                     % load averaged psd of preproc data
  cfg.srcFolder   = strcat(desPath, '05d_pwelchoc_preproc/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('MAT_d%02d_05d_pwelchoc_preproc', i);

  fprintf('Load averaged power spectral density of preproc data...\n\n');
  MAT_loadData( cfg );
  
  
  data_pwelchop_preproc = MAT_avgOverPart(data_pwelchoc_preproc);           % average psd of preproc data over participants
  
  % export PSD data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05h_pwelchop_preproc/');
  cfg.filename    = sprintf('MAT_d%02d_05h_pwelchop_preproc', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Power spectral density of preproc data averaged over participants of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  MAT_saveData(cfg, 'data_pwelchop_preproc', data_pwelchop_preproc);
  fprintf('Data stored!\n');
  clear data_pwelchop_preproc data_pwelchoc_preproc
end

%% clear workspace
clear file_path cfg sourceList numOfSources i
