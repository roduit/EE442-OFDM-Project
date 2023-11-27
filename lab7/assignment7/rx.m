function [rxbits conf] = rx(rxsignal,conf,k)
% Digital Receiver
%
%   [txsignal conf] = tx(txbits,conf,k) implements a complete causal
%   receiver in digital domain.
%
%   rxsignal    : received signal
%   conf        : configuration structure
%   k           : frame index
%
%   Outputs%
%
%   rxbits      : received bits
%   conf        : configuration structure
%

% dummy 
% rxbits = zeros(conf.nbits,1);%

% Base-band shaping
time = 0:1/conf.f_s:(length(rxsignal)/conf.f_s)-1/conf.f_s;

r_dc = rxsignal .* exp(-j*2*pi*conf.f_c*time');

r_bb = 2 * lowpass(r_dc,conf);

filtered_rx_signal = matched_filter(r_bb, conf.os_factor, conf.rx_filterlen);
%filtered_rx_signal = filtered_rx_signal(1 + conf.rx_filterlen + conf.f_s : end - conf.rx_filterlen - conf.f_s);

%Frame sync
[data_idx theta magnitude] = frame_sync(conf,filtered_rx_signal, conf.os_factor); % Index of the first data symbol

% downsampling
sampled_signal = filtered_rx_signal(1+conf.rx_filterlen+conf.tx_filterlen + data_idx:conf.os_factor:end-conf.rx_filterlen - conf.tx_filterlen);
%

%Demap 
demapped_bits = demapper(sampled_signal);
rxbits = demapped_bits(1:conf.nbits);



