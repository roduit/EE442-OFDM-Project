function [parallel_symbols] = series2parallel(series_symbols, nb_carriers)
%SERIES2PARALLEL Summary of this function goes here
%   Detailed explanation goes here
    parallel_symbols = reshape(series_symbols, nb_carriers, []);
end

