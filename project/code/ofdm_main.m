% -*- file name: ofdm_main -*-
% -*- author(s) : Vincent Roduit, Filippo Quadri -*-
% -*- date : 2023-12-02 -*-
% -*- Last revision: 2023-12-13 (Vincent Roduit)-*-
% -*- Description: Main code that produces OFDM module -*-

clear;
clc
%% Upload image

rng(123);
lena_image = imread('lena.png');
gray_lena = rgb2gray(lena_image);

%% *-* Config parameters *-*

conf.original_image = size(gray_lena);

% Frame characteristics 
conf.preamble_length = 100;
conf.nb_frames = 16;                                % Number of frames to send image
conf.nb_packets = 256;                              % Number of OFDM symbols per frame 
conf.frame_gap = 10000;                             % Paddding between two frames
conf.packet_per_frame = conf.nb_packets;            % Number of packets per frame
conf.symb_per_packet = 256;                         % Number of symbols per packet (or carriers)
conf.bits_per_packet = conf.symb_per_packet * 2;    % Number of bits per paccket
conf.cp_length = conf.symb_per_packet / 2;          % [samples]

% Frequencies characteristics
conf.carrier_freq = 8e3;                            % [Hz] : Carrier frequency
conf.spacing_freq = 5;                              % [Hz] : Spacing frequency
conf.sampling_freq = 48e3;                          % [Hz] : Sampling frequency

conf.BW = conf.spacing_freq * conf.symb_per_packet; % [Hz] : Bandwidth 

conf.symbol_rate_ofdm = 1/conf.BW;                  % [s] : symbol rate OFDM
conf.symbol_rate_preamb = 1000;                     % [Hz] : symbol rate preamble

conf.ofdm_symbol_period = conf.symb_per_packet * conf.symbol_rate_ofdm; % [s]: OFDM symbol periode

% Over-sampling factors
conf.os_factor_ofdm = conf.sampling_freq / (conf.spacing_freq * conf.symb_per_packet); % Oversampling factor OFDM
conf.os_factor_preamb = conf.sampling_freq / conf.symbol_rate_preamb;                  % Oversampling factor preamble

if mod(conf.os_factor_preamb,1) ~= 0
    disp('WARNING PREAMB: Sampling rate must be a multiple of the symbol rate'); 
end

% Match filter properties
conf.rolloff_factor = 0.22;                                 % Roll-off factor (RRC)

conf.matched_filter_length_tx = conf.os_factor_preamb * 18; % Transmitter filter length
conf.matched_filter_length_rx = conf.os_factor_preamb * 6;  % Receiver filter length



%% Transmission
% Transmit
bitstream = image2bitstream(conf, gray_lena);
%bitstream = randi([0, 1], conf.bits_per_packet * conf.nb_packets, conf.nb_frames);

% RF data generation
tx_rf = tx(bitstream, conf);

% pad signal with zeros to simulate delay
tx_rf_augmented = [ zeros(conf.sampling_freq,1) ; tx_rf ;  zeros(conf.sampling_freq,1) ];

%% Reception

bitstream_rx = rx(tx_rf_augmented, conf);
bitstream_rx = logical(bitstream_rx);

ber = sum(bitstream(:) ~= bitstream_rx(:)) / length(bitstream(:))

%% Plot results

output_image = bitstream2image(bitstream_rx(:),conf.original_image);

% figure;
% plot(tx_rf)
% title('Transmitted RF Data');
% xlabel('Sample Index');
% ylabel('Amplitude');
% 
% figure;
% plot(tx_rf_augmented)
% title('Transmitted RF Data with padding');
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





