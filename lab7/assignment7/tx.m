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


% dummy 400Hz sinus generation
time = 1:1/conf.f_s:4;
txsignal = 0.3*sin(2*pi*400 * time.');

%Up conversion
txsignal = real(txsignal) .* cos(2*pi*conf.f_c*time)' - imag(txsignal) .* sin(2*pi*conf.f_c*time)';