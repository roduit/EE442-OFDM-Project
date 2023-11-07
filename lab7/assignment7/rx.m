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
rxbits = zeros(conf.nbits,1);%

%Down-conversion
time = 0:1/conf.f_s:(length(rxsignal)/conf.f_s)-1/conf.f_s;

r_dc = 0.5 * rxsignal + 0.5 * (real(rxsignal)-imag(rxsignal)) .* exp(-4*pi*conf.f_c*time');

r_bb = 2 * lowpass(r_dc,conf);
