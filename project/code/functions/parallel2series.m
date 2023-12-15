% parallel2series converts parallel symbols to series symbols.
%   series_symbols = parallel2series(parallel_symbols) takes a matrix of parallel symbols 
% and converts it into a column vector of series symbols.
%
%   Input:
%   - parallel_symbols: Matrix of parallel symbols.
%
%   Output:
%   - series_symbols: Column vector of series symbols.
%
%   Example:
%   parallel_symbols = [1 2 3; 4 5 6];
%   series_symbols = parallel2series(parallel_symbols);
%
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function [series_symbols] = parallel2series(parallel_symbols)
    series_symbols = reshape(parallel_symbols, numel(parallel_symbols), 1);
 end

