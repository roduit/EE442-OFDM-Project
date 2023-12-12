function [series_symbols] = parallel2series(parallel_symbols)
%PARALLEL2SERIES Summary of this function goes here
%   Detailed explanation goes here
    % Reshape the input vector into a vector of size (M*D, 1)
    series_symbols = reshape(parallel_symbols, numel(parallel_symbols), 1);
 end

