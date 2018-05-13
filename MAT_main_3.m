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

if ~exist('numOfPart', 'var')                                               % estimate number of participants in preproc data folder
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
% Calculate TFRs an PSD (using pWelch's method) of raw and preprocessed 
% data

cprintf([0,0.6,0], '<strong>[3] - Power analysis (TFR, pWelch)</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculation of time-frequency response (TFR)
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should the time-frequency response calculated?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    tfr = true;
  elseif strcmp('n', x)
    choise = true;
    tfr = false;
  else
    choise = false;
  end
end
fprintf('\n');

if tfr == true
  for i = numOfPart
    fprintf('<strong>Dyad %d</strong>\n', i);

    cfg             = [];                                                   % load raw data
    cfg.srcFolder   = strcat(desPath, '01a_raw/');
    cfg.sessionStr  = sessionStr;
    cfg.filename    = sprintf('MAT_d%02d_01a_raw', i);

    fprintf('Load raw data...\n\n');
    MAT_loadData( cfg );

    cfg         = [];
    cfg.foi     = 2:1:100;                                                  % frequency of interest
    cfg.toi     = 0:0.1:5;                                                  % time of interest

    data_tfr_raw = MAT_timeFreqanalysis( cfg, data_raw );

    % export TFR data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '03a_tfr_raw/');
    cfg.filename    = sprintf('MAT_d%02d_03a_tfr_raw', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Time-frequency response of raw data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    MAT_saveData(cfg, 'data_tfr_raw', data_tfr_raw);
    fprintf('Data stored!\n\n');
    clear data_tfr_raw data_raw
    
    cfg             = [];                                                   % load preprocessed data
    cfg.srcFolder   = strcat(desPath, '02_preproc/');
    cfg.sessionStr  = sessionStr;
    cfg.filename    = sprintf('MAT_d%02d_02_preproc', i);

    fprintf('Load preprocessed data...\n\n');
    MAT_loadData( cfg );

    cfg         = [];
    cfg.foi     = 2:1:50;                                                   % frequency of interest
    cfg.toi     = 0:0.1:5;                                                  % time of interest

    data_tfr_preproc = MAT_timeFreqanalysis( cfg, data_preproc );

    % export TFR data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '03b_tfr_preproc/');
    cfg.filename    = sprintf('MAT_d%02d_03b_tfr_preproc', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Time-frequency response of preprocessed data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    MAT_saveData(cfg, 'data_tfr_preproc', data_tfr_preproc);
    fprintf('Data stored!\n\n');
    clear data_tfr_preproc data_preproc
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculation of power spectral density using Welch's method (pWelch)
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should the power spectral density by using Welch''s method be calculated?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    pwelch = true;
  elseif strcmp('n', x)
    choise = true;
    pwelch = false;
  else
    choise = false;
  end
end
fprintf('\n');

if pwelch == true
  for i = numOfPart
    fprintf('<strong>Dyad %d</strong>\n', i);
    
    cfg             = [];                                                   % Load raw data
    cfg.srcFolder   = strcat(desPath, '01a_raw/');
    cfg.filename    = sprintf('MAT_d%02d_01a_raw', i);
    cfg.sessionStr  = sessionStr;

    fprintf('Load raw data...\n\n');
    MAT_loadData( cfg );
    
    % Segmentation of conditions in segments of one second with 75 percent
    % overlapping
    cfg          = [];
    cfg.length   = 1;                                                       % window length: 1 sec       
    cfg.overlap  = 0.75;                                                    % 75 percent overlap
    
    fprintf('<strong>Segmentation of raw data.</strong>\n');
    trialinfoTemp = data_raw.part1.trialinfo;
    data_raw.part1.trialinfo = (1:1:length(trialinfoTemp))';
    data_raw.part2.trialinfo = (1:1:length(trialinfoTemp))';
    data_raw = MAT_segmentation( cfg, data_raw );

    fprintf('\n');
    
    % Estimation of power spectral density
    cfg         = [];
    cfg.foi     = 1:1:100;                                                  % frequency of interest
      
    data_raw = MAT_pWelch( cfg, data_raw );                                 % calculate power spectral density using Welch's method
    data_pwelch_raw = data_raw;                                             % to save need of RAM
    data_pwelch_raw.part1.trialinfo =  trialinfoTemp;
    data_pwelch_raw.part2.trialinfo =  trialinfoTemp;
    clear data_preproc
    
    % export PSD data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '03c_pwelch_raw/');
    cfg.filename    = sprintf('MAT_d%02d_03c_pwelch_raw', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Power spectral density of raw data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    MAT_saveData(cfg, 'data_pwelch_raw', data_pwelch_raw);
    fprintf('Data stored!\n\n');
    clear data_pwelch_raw
    
    cfg             = [];                                                   % Load preprocessed data
    cfg.srcFolder   = strcat(desPath, '02_preproc/');
    cfg.filename    = sprintf('MAT_d%02d_02_preproc', i);
    cfg.sessionStr  = sessionStr;

    fprintf('Load preprocessed data...\n\n');
    MAT_loadData( cfg );
    
    % Segmentation of conditions in segments of one second with 75 percent
    % overlapping
    cfg          = [];
    cfg.length   = 1;                                                       % window length: 1 sec       
    cfg.overlap  = 0.75;                                                    % 75 percent overlap
    
    fprintf('<strong>Segmentation of preprocessed data.</strong>\n');
    trialinfoTemp = data_preproc.part1.trialinfo;
    data_preproc.part1.trialinfo = (1:1:length(trialinfoTemp))';
    data_preproc.part2.trialinfo = (1:1:length(trialinfoTemp))';
    data_preproc = MAT_segmentation( cfg, data_preproc );

    fprintf('\n');
    
    % Estimation of power spectral density
    cfg         = [];
    cfg.foi     = 1:1:50;                                                   % frequency of interest
      
    data_preproc = MAT_pWelch( cfg, data_preproc );                         % calculate power spectral density using Welch's method
    data_pwelch_preproc = data_preproc;                                     % to save need of RAM
    data_pwelch_preproc.part1.trialinfo =  trialinfoTemp;
    data_pwelch_preproc.part2.trialinfo =  trialinfoTemp;
    clear data_preproc
    
    % export PSD data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '03d_pwelch_preproc/');
    cfg.filename    = sprintf('MAT_d%02d_03d_pwelch_preproc', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Power spectral density of preproc data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    MAT_saveData(cfg, 'data_pwelch_preproc', data_pwelch_preproc);
    fprintf('Data stored!\n\n');
    clear data_pwelch_preproc
  end
end

%% clear workspace
clear file_path cfg sourceList numOfSources i choise tfr pwelch T ...
      artifactRejection artifactAvailable
