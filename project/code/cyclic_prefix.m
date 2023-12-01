function [cp_signal] = cyclic_prefix(signal, cp_length)
%CYCLIC_PREFIX Summary of this function goes here
%   Detailed explanation goes here
    cp_signal = vertcat(signal(end-cp_length+1:end), signal);
end

