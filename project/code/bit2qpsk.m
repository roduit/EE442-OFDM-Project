%   bit2qpsk converts a bitstream into QPSK symbols using Gray mapping.
%
%   Inputs:
%       bitstream - Input bitstream to be converted into QPSK symbols.
%
%   Output:
%       qpsk_symbols - Output QPSK symbols.
%
%   Example:
%       bitstream = [1 0 1 1 0 1 0 0];
%       qpsk_symbols = bit2qpsk(bitstream);
%
%   Reference:
%       Gray mapping: https://en.wikipedia.org/wiki/Gray_code
%
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function [qpsk_symbols] = bit2qpsk(bitstream)

    % Gray mapping
    GrayMap = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];

    % Reshape bitstream into 2 bits per symbol
    reshaped_bitstream = reshape(bitstream, 2, length(bitstream)/2)';

    % Convert bitstream into QPSK symbols
    qpsk_symbols = GrayMap(bi2de(reshaped_bitstream, 'left-msb')+1).';
end

