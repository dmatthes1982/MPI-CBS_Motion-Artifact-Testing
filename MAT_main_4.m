%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '03c_cleaned_preproc';
  cfg.filename  = 'MAT_d01_03c_cleaned_preproc';
  sessionStr    = sprintf('%03d', MAT_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = ['/data/pt_01826/eegData_MotionArtifactTesting/'                % destination path for processed data 
              'DualEEG_MAT_processedData/']; 
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in preproc data folder
  sourceList    = dir([strcat(desPath, '03c_cleaned_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('MAT_d%d_03c_cleaned_preproc_', sessionStr, '.mat'));
  end
end

%% part 4
% Calculate TFRs an PSD (using pWelch's method) of raw and preprocessed 
% data

cprintf([0,0.6,0], '<strong>[4] - Power analysis (TFR, pWelch)</strong>\n');
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

    cfg             = [];                                                   % load cleaned raw data
    cfg.srcFolder   = strcat(desPath, '03b_cleaned_raw/');
    cfg.sessionStr  = sessionStr;
    cfg.filename    = sprintf('MAT_d%02d_03b_cleaned_raw', i);

    fprintf('Load cleaned raw data...\n\n');
    MAT_loadData( cfg );

    cfg         = [];
    cfg.foi     = 2:1:100;                                                  % frequency of interest
    cfg.toi     = 0:0.1:5;                                                  % time of interest

    data_tfr_raw = MAT_timeFreqanalysis( cfg, data_cleaned_raw );

    % export TFR data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '04a_tfr_raw/');
    cfg.filename    = sprintf('MAT_d%02d_04a_tfr_raw', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Time-frequency response of raw data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    MAT_saveData(cfg, 'data_tfr_raw', data_tfr_raw);
    fprintf('Data stored!\n\n');
    clear data_tfr_raw data_cleaned_raw
    
    cfg             = [];                                                   % load cleaned preprocessed data
    cfg.srcFolder   = strcat(desPath, '03c_cleaned_preproc/');
    cfg.sessionStr  = sessionStr;
    cfg.filename    = sprintf('MAT_d%02d_03c_cleaned_preproc', i);

    fprintf('Load cleaned preprocessed data...\n\n');
    MAT_loadData( cfg );

    cfg         = [];
    cfg.foi     = 2:1:50;                                                   % frequency of interest
    cfg.toi     = 0:0.1:5;                                                  % time of interest

    data_tfr_preproc = MAT_timeFreqanalysis( cfg, data_cleaned_preproc );

    % export TFR data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '04b_tfr_preproc/');
    cfg.filename    = sprintf('MAT_d%02d_04b_tfr_preproc', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Time-frequency response of preprocessed data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    MAT_saveData(cfg, 'data_tfr_preproc', data_tfr_preproc);
    fprintf('Data stored!\n\n');
    clear data_tfr_preproc data_cleaned_preproc
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
    
    cfg             = [];                                                   % Load cleaned raw data
    cfg.srcFolder   = strcat(desPath, '03b_cleaned_raw/');
    cfg.filename    = sprintf('MAT_d%02d_03b_cleaned_raw', i);
    cfg.sessionStr  = sessionStr;

    fprintf('Load cleaned raw data...\n\n');
    MAT_loadData( cfg );
    
    % Segmentation of conditions in segments of one second with 75 percent
    % overlapping
    cfg          = [];
    cfg.length   = 1;                                                       % window length: 1 sec       
    cfg.overlap  = 0.75;                                                    % 75 percent overlap
    
    fprintf('<strong>Segmentation of raw data.</strong>\n');
    trialinfoTemp1 = data_cleaned_raw.part1.trialinfo;
    trialinfoTemp2 = data_cleaned_raw.part2.trialinfo;
    data_cleaned_raw.part1.trialinfo = (1:1:length(trialinfoTemp1))';
    data_cleaned_raw.part2.trialinfo = (1:1:length(trialinfoTemp2))';
    data_cleaned_raw = MAT_segmentation( cfg, data_cleaned_raw );

    fprintf('\n');
    
    % Estimation of power spectral density
    cfg         = [];
    cfg.foi     = 1:1:100;                                                  % frequency of interest
      
    data_cleaned_raw = MAT_pWelch( cfg, data_cleaned_raw );                 % calculate power spectral density using Welch's method
    data_pwelch_raw = data_cleaned_raw;                                     % to save need of RAM
    data_pwelch_raw.part1.trialinfo =  trialinfoTemp1;
    data_pwelch_raw.part2.trialinfo =  trialinfoTemp2;
    clear data_cleaned_raw
    
    % export PSD data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '04c_pwelch_raw/');
    cfg.filename    = sprintf('MAT_d%02d_04c_pwelch_raw', i);
    cfg.sessionStr  = sessionStr;

    file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                       '.mat');

    fprintf('Power spectral density of raw data of dyad %d will be saved in:\n', i); 
    fprintf('%s ...\n', file_path);
    MAT_saveData(cfg, 'data_pwelch_raw', data_pwelch_raw);
    fprintf('Data stored!\n\n');
    clear data_pwelch_raw
    
    cfg             = [];                                                   % Load cleaned preprocessed data
    cfg.srcFolder   = strcat(desPath, '03c_cleaned_preproc/');
    cfg.filename    = sprintf('MAT_d%02d_03c_cleaned_preproc', i);
    cfg.sessionStr  = sessionStr;

    fprintf('Load cleaned preprocessed data...\n\n');
    MAT_loadData( cfg );
    
    % Segmentation of conditions in segments of one second with 75 percent
    % overlapping
    cfg          = [];
    cfg.length   = 1;                                                       % window length: 1 sec       
    cfg.overlap  = 0.75;                                                    % 75 percent overlap
    
    fprintf('<strong>Segmentation of preprocessed data.</strong>\n');
    trialinfoTemp1 = data_cleaned_preproc.part1.trialinfo;
    trialinfoTemp2 = data_cleaned_preproc.part2.trialinfo;
    data_cleaned_preproc.part1.trialinfo = (1:1:length(trialinfoTemp1))';
    data_cleaned_preproc.part2.trialinfo = (1:1:length(trialinfoTemp2))';
    data_cleaned_preproc = MAT_segmentation( cfg, data_cleaned_preproc );

    fprintf('\n');
    
    % Estimation of power spectral density
    cfg         = [];
    cfg.foi     = 1:1:50;                                                   % frequency of interest
      
    data_cleaned_preproc = MAT_pWelch( cfg, data_cleaned_preproc );                         % calculate power spectral density using Welch's method
    data_pwelch_preproc = data_cleaned_preproc;                                     % to save need of RAM
    data_pwelch_preproc.part1.trialinfo =  trialinfoTemp1;
    data_pwelch_preproc.part2.trialinfo =  trialinfoTemp2;
    clear data_cleaned_preproc trialinfoTemp1 trialinfoTemp2
    
    % export PSD data into a *.mat file
    cfg             = [];
    cfg.desFolder   = strcat(desPath, '04d_pwelch_preproc/');
    cfg.filename    = sprintf('MAT_d%02d_04d_pwelch_preproc', i);
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
