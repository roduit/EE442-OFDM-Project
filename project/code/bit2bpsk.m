% bit2bpsk converts a bitstream into BPSK symbols.
%
% Inputs:
%   - bitstream: a vector of binary values representing the input bitstream
%
% Output:
%   - bpsk_symbols: a vector of BPSK symbols generated from the input bitstream
%
% Example:
%   bitstream = [0 1 1 0 1];
%   bpsk_symbols = bit2bpsk(bitstream);
%
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function [bpsk_symbols] = bit2bpsk(bitstream)
    bpsk_symbols = bitstream .* 2 - 1;
end

