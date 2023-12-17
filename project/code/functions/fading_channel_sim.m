function [fading_channel_response] = fading_channel_sim()
    fading_channel_response = zeros(1000, 1);
    fading_channel_response(1) = 1;
    fading_channel_response(280) = 0.55;
    %fading_channel_response(280) = 0.9;
    %fading_channel_response(900) = 0.4; 
end