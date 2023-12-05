conf.preamble_length = 100;

conf.matched_filter_length_tx = 100;
conf.matched_filter_length_rx = 50;

conf.nb_frames = 1000;
conf.nb_packets = 2;
if mod(conf.nb_packets,2) ~= 0
    disp('WARNING nb_packets: Number of packets should be a multiple of 2'); 
end
conf.packet_per_frame = 10;                 % Number of packets per frame
conf.bit_per_packet = 256;                  % Number of bits per packet (or carriers)
conf.cp_length = conf.nb_carriers / 2;      % [samples]

conf.symbol_rate = 100;                      % [Hz]

conf.ofdm_symbol_period = conf.bit_per_packet / conf.symbol_rate; % [s]

conf.carrier_freq = 8e3;                    % [Hz]
conf.spacing_freq = 5;                      % [Hz]
conf.sampling_freq = 48e3;                  % [Hz]

conf.os_factor_ofdm = conf.sampling_freq / (conf.spacing_freq * conf.bit_per_packet); % Oversampling factor OFDM
conf.os_factor_preamb = conf.sampling_freq / conf.symbol_rate;                        % Oversampling factor preamble

if mod(conf.os_factor_preamb,1) ~= 0
    disp('WARNING PREAMB: Sampling rate must be a multiple of the symbol rate'); 
end

if mod(conf.os_factor_ofdm,1) ~= 0
    disp('WARNING OFDM: Sampling rate must be a multiple of the symbol rate'); 
end

conf.rolloff_factor = 0.22;                 % Roll-off factor (RRC)