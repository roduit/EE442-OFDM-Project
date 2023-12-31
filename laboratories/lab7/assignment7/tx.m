function [txsignal conf] = tx(txbits,conf,k)
% Digital Transmitter
%
%   [txsignal conf] = tx(txbits,conf,k) implements a complete transmitter
%   consisting of:
%       - modulator
%       - pulse shaping filter
%       - up converter
%   in digital domain.
%
%   txbits  : Information bits
%   conf    : Universal configuration structure
%   k       : Frame index
%

%Create preamble and map to BPSK
preamble = lfsr_framesync(conf.npreamble);
preamble_bpsk = preamble * 2 - 1;

% Map tx into QPSK
GrayMap = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
%reshape tx
source_tx = reshape(txbits,2,conf.nbits/2)';
mappedGray = GrayMap(bi2de(source_tx, 'left-msb')+1).';

%Create signal composed of preamble and bits
signal = vertcat(preamble_bpsk, mappedGray);


symbol_up = upsample(signal,conf.os_factor);

noise = 1/sqrt(2*conf.SNR_lin)*randn(size(symbol_up));
noisy_signal = symbol_up + noise + 1j*noise ;

% base-band pulse shaping

filtered_tx_signal = matched_filter(noisy_signal,conf.os_factor,conf.tx_filterlen);

% Remove the non-information added by the convolution
%filtered_tx_signal = filtered_tx_signal(1 + conf.tx_filterlen:end - conf.tx_filterlen);

%Up conversion
time = 0:1/conf.f_s:(length(filtered_tx_signal)/conf.f_s)-1/conf.f_s;
txsignal = real(filtered_tx_signal) .* cos(2*pi*conf.f_c*time)' - imag(filtered_tx_signal) .* sin(2*pi*conf.f_c*time)';
% Calculate the RMS value
rms_value = rms(txsignal);

% Normalize the signal
txsignal = txsignal / rms_value;


