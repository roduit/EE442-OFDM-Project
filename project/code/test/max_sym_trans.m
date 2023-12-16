% % % % %
% Wireless Receivers: algorithms and architectures
% Ecole Polytechnique Federale de Lausanne
% Professor : Andreas Burg
% Semester : Fall 2023
% Project : OFDM transmission and reception
% Authors : Vincent Roduit, Filippo Quadri
% Maximum SYMBOLS transmission
% % % % %

clear;
clc
%% Upload image

rng(123);
image = imread('lena_256.png');
gray_image = im2gray(image);

%% Config parameters

% Audio transmission characteristics
%   3 operating modes:
%   - 'matlab' : generic MATLAB audio routines (unreliable under Linux)
%   - 'native' : OS native audio system
%       - ALSA audio tools, most Linux distrubtions
%       - builtin WAV tools on Windows 
%   - 'bypass' : no audio transmission, takes txsignal as received signal
conf.audiosystem = 'matlab'; % Values: 'matlab','native','bypass'
conf.bitsps     = 16;

% Image characteristics
conf.original_image = size(gray_image);

% Frame characteristics 
conf.preamble_length = 100;
conf.nb_frames = 1;                                 % Number of frames to send image
conf.ofdm_sym_per_frame = 1;                        % Number of OFDM symbols per frame 
conf.frame_gap = 1000;                              % Paddding between two frames
conf.nb_carriers = 256;                             % Number of symbols per packet (or carriers)
conf.bits_per_ofdm_sym = conf.nb_carriers * 2;      % Number of bits per paccket
conf.cp_length = conf.nb_carriers / 2;              % [samples]

% Frequencies characteristics
conf.carrier_freq = 8e3;                            % [Hz] : Carrier frequency
conf.spacing_freq = 20;                             % [Hz] : Spacing frequency
conf.sampling_freq = 48e3;                          % [Hz] : Sampling frequency

conf.BW = conf.spacing_freq * conf.nb_carriers; % [Hz] : Bandwidth 

%conf.symbol_rate_ofdm = 1/conf.BW;                 % [s] : symbol rate OFDM
conf.symbol_rate_preamb = 1000;                     % [Hz] : symbol rate preamble

%conf.ofdm_symbol_period = conf.nb_carriers * conf.symbol_rate_ofdm; % [s]: OFDM symbol period

% Over-sampling factors
conf.os_factor_ofdm = conf.sampling_freq / (conf.spacing_freq * conf.nb_carriers); % Oversampling factor OFDM
conf.os_factor_preamb = conf.sampling_freq / conf.symbol_rate_preamb;                  % Oversampling factor preamble

if mod(conf.os_factor_preamb,1) ~= 0
    disp('WARNING PREAMB: Sampling rate must be a multiple of the symbol rate'); 
end

% Match filter properties
conf.rolloff_factor = 0.22;                                 % Roll-off factor (RRC)

conf.matched_filter_length_tx = conf.os_factor_preamb * 18; % Transmitter filter length
conf.matched_filter_length_rx = conf.os_factor_preamb * 6;  % Receiver filter length

tab_sym_per_frame = 10:10:80;
ber = zeros(1, length(tab_sym_per_frame));

for ii=1:numel(tab_sym_per_frame)
    
    conf.ofdm_sym_per_frame = tab_sym_per_frame(ii);
    disp(conf.ofdm_sym_per_frame)

    % Transmission
    % Transmit
    %bitstream = image2bitstream(conf, gray_image);
    bitstream = randi([0, 1], conf.bits_per_ofdm_sym * conf.ofdm_sym_per_frame, conf.nb_frames);
    
    % RF data generation
    tx_rf = tx(bitstream, conf);
    
    % pad signal with zeros to simulate delay
    rawtxsignal = [ zeros(conf.sampling_freq,1) ; tx_rf ;  zeros(conf.sampling_freq,1) ];
    
    txdur = length(rawtxsignal)/conf.sampling_freq; % calculate length of transmitted signal
    audiowrite('out.wav',rawtxsignal,conf.sampling_freq)
    
    % Platform native audio mode 
    if strcmp(conf.audiosystem,'native')
        
        % Windows WAV mode 
        if ispc()
            disp('Windows WAV');
            wavplay(rawtxsignal,conf.sampling_freq,'async');
            disp('Recording in Progress');
            rawrxsignal = wavrecord((txdur+1)*conf.sampling_freq,conf.sampling_freq);
            disp('Recording complete')
            rxsignal = rawrxsignal(1:end,1);
    
        % ALSA WAV mode 
        elseif isunix()
            disp('Linux ALSA');
            cmd = sprintf('arecord -c 2 -r %d -f s16_le  -d %d in.wav &',conf.sampling_freq,ceil(txdur)+1);
            system(cmd); 
            disp('Recording in Progress');
            system('aplay  out.wav')
            pause(2);
            disp('Recording complete')
            rawrxsignal = audioread('in.wav');
            rxsignal    = rawrxsignal(1:end,1);
        end
        
    % MATLAB audio mode
    elseif strcmp(conf.audiosystem,'matlab')
        disp('MATLAB generic');
        playobj = audioplayer(rawtxsignal,conf.sampling_freq,conf.bitsps);
        recobj  = audiorecorder(conf.sampling_freq,conf.bitsps,1);
        record(recobj);
        disp('Recording in Progress');
        playblocking(playobj)
        pause(0.5);
        stop(recobj);
        disp('Recording complete')
        rawrxsignal  = getaudiodata(recobj,'int16');
        rxsignal     = double(rawrxsignal(1:end))/double(intmax('int16')) ;
        
    elseif strcmp(conf.audiosystem,'bypass')
        rawrxsignal = rawtxsignal(:,1);
        rxsignal    = rawrxsignal;
    end
    
    % Reception
    
    bitstream_rx = rx(rxsignal, conf);
    bitstream_rx = logical(bitstream_rx);
    
    ber_temp = sum(bitstream(:) ~= bitstream_rx(:)) / length(bitstream(:))

    ber(1, ii) = sum(bitstream(:) ~= bitstream_rx(:)) / length(bitstream(:));
end

figure;
semilogy(tab_sym_per_frame, ber);
xlabel("Number of OFDM symbols per frame")
ylabel("BER")
title("BER vs Number of OFDM symbols per frame")

% Plot results

% output_image = bitstream2image(bitstream_rx(:),conf.original_image);
% 
% figure;
% plot(tx_rf)
% title('Transmitted RF Data');
% xlabel('Sample Index');
% ylabel('Amplitude');
% 
% figure;
% plot(rxsignal)
% title('Received RF Data with padding');
% xlabel('Sample Index');
% ylabel('Amplitude');


%{
 % Plot RF data
figure;
plot(tx_rf);
title('Transmitted RF Data');
xlabel('Sample Index');
ylabel('Amplitude');

% Plot range from 1 to 5280 with green color
x1 = tx_rf(1:5280);

% Plot range from 5281 to 15008 with red color
x2 = tx_rf(5281:15008);

% Plot range from 15009 to the end with magenta color
x3 = tx_rf(15009:end);

% Create a plot with different colors for each range
figure;
plot(1:5280, x1, 'g', 'LineWidth', 2);
hold on;
plot(5281:15008, x2, 'r', 'LineWidth', 2);
plot(15009:length(tx_rf), x3, 'm', 'LineWidth', 2);
hold off;

title('Samples from tx\_rf with Colors');
xlabel('Sample Index');
ylabel('Value');
legend('Preamble (Green)', 'Training (Red)', 'Packet 1 (Magenta)'); 
%}




