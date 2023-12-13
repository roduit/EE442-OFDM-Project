% cyclic_prefix - Adds a cyclic prefix to a given signal.
%
% Syntax: 
%   cp_signal = cyclic_prefix(signal, cp_length)
%
% Inputs:
%   signal - The input signal.
%   cp_length - The length of the cyclic prefix to be added.
%
% Outputs:
%   cp_signal - The signal with the cyclic prefix added.
%
% Example:
%   signal = [1 2 3 4];
%   cp_length = 2;
%   cp_signal = cyclic_prefix(signal, cp_length);
%
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function [cp_signal] = cyclic_prefix(signal, cp_length)
    cp_signal = vertcat(signal(end-cp_length+1:end), signal);
end

