conf.preamble_length = 100;

conf.nb_frames = 1000;
conf.packet_per_frame = 10;                 % Number of packets per frame
conf.bit_per_packet = 256;                  % Number of bits per packet (or carriers)
conf.cp_length = conf.nb_carriers / 2;      % [samples]

conf.symbol_rate = 8;                      % [Hz]

conf.ofdm_symbol_period = conf.bit_per_packet / conf.symbol_rate; % [s]

conf.carrier_freq = 8e3;                    % [Hz]
conf.spacing_freq = 5;                      % [Hz]
conf.sampling_freq = 48e3;                  % [Hz]
conf.os_factor = conf.sampling_freq / (conf.spacing_freq * conf.bit_per_packet); % Oversampling factor

% dans tx on gère que un frame à la fois