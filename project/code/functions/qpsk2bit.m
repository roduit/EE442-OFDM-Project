% qpsk2bit - Convert QPSK symbols to bitstream
%
% Syntax: bitstream = qpsk2bit(qpsk_symbols)
%
% Inputs:
%    qpsk_symbols - QPSK symbols to be converted to bitstream
%
% Output:
%    bitstream - Bitstream representing the QPSK symbols
%
% Example:
%    qpsk_symbols = [1+1i, -1-1i, 1-1i, -1+1i];
%    bitstream = qpsk2bit(qpsk_symbols);
%
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]
%
% See also: bit2qpsk
function [bitstream] = qpsk2bit(qpsk_symbols)
    
    bit1 = real(qpsk_symbols) > 0;
    bit2 = imag(qpsk_symbols) > 0;

    % b is a two colomn vector col1: real, col2: imag
    bitstream = [bit1 bit2];
    bitstream = bitstream';
    bitstream = bitstream(:);
end

