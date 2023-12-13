% matched_filter applies a root-raised cosine filter to the input signal.
% The filter is designed based on the oversampling factor, rolloff factor, and filter length provided in the configuration structure.
% The filtered signal is obtained by convolving the input signal with the filter coefficients.
%
% Inputs:
%   - signal: Input signal to be filtered.
%   - os_factor: Oversampling factor (e.g., 4).
%   - mf_length: One-sided filter length. The total number of filter coefficients is 2*mf_length + 1.
%   - conf: Configuration structure containing the rolloff factor for the filter design.
%
% Output:
%   - filtered_signal: Signal filtered using the root-raised cosine filter.
% Author(s): [Vincent Roduit, Filippo Quadri]
% Date: [2023-12-05]
% Version: [1.0]

function filtered_signal = matched_filter(signal, os_factor, mf_length, conf)
    rolloff_factor = conf.rolloff_factor;
    
    h = rrc(os_factor, rolloff_factor, mf_length);
    filtered_signal = conv(signal, h, "same");