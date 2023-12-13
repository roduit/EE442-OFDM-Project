% series2parallel - Converts a series of symbols into parallel symbols.
%
%   parallel_symbols = series2parallel(series_symbols, nb_carriers)
%
%   Input:
%       - series_symbols: A vector of symbols in series.
%       - nb_carriers: The number of parallel carriers.
%
%   Output:
%       - parallel_symbols: A matrix of symbols arranged in parallel.
%
%   Example:
%       series_symbols = [1 2 3 4 5 6];
%       nb_carriers = 2;
%       parallel_symbols = series2parallel(series_symbols, nb_carriers);
%
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function [parallel_symbols] = series2parallel(series_symbols, nb_carriers)
    parallel_symbols = reshape(series_symbols, nb_carriers, []);
end

