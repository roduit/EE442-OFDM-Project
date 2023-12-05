clear;
clc

% Config file
conf.preamble_length = 100;

conf.nb_frames = 1000;
conf.nb_packets = 2;
if mod(conf.nb_packets,2) ~= 0
    disp('WARNING nb_packets: Number of packets should be a multiple of 2'); 
end
conf.packet_per_frame = 10;                 % Number of packets per frame
conf.bit_per_packet = 256;                  % Number of bits per packet (or carriers)
conf.cp_length = conf.bit_per_packet / 2;      % [samples]

conf.carrier_freq = 8e3;                    % [Hz]
conf.spacing_freq = 5;                      % [Hz]
conf.sampling_freq = 48e3;                  % [Hz]

conf.BW = conf.spacing_freq * conf.bit_per_packet; % Bandwidth [Hz]

conf.symbol_rate_ofdm = 1/conf.BW;                      % [s]
conf.symbol_rate_preamb = 1000;                         % [Hz]

conf.ofdm_symbol_period = conf.bit_per_packet * conf.symbol_rate_ofdm; % [s]


conf.os_factor_ofdm = conf.sampling_freq / (conf.spacing_freq * conf.bit_per_packet); % Oversampling factor OFDM
conf.os_factor_preamb = conf.sampling_freq / conf.symbol_rate_preamb;                        % Oversampling factor preamble

if mod(conf.os_factor_preamb,1) ~= 0
    disp('WARNING PREAMB: Sampling rate must be a multiple of the symbol rate'); 
end

conf.rolloff_factor = 0.22;                 % Roll-off factor (RRC)

conf.matched_filter_length_tx = conf.os_factor_preamb * 5;
conf.matched_filter_length_rx = conf.os_factor_preamb * 3;




% Transmit
bitstream = randi([0, 1], conf.bit_per_packet * conf.nb_packets, 1);

% RF data generation
tx_rf = tx(bitstream, conf);

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




