function [fading_channel_response] = fading_channel_sim()
    fading_channel_response = zeros(1000, 1);
    fading_channel_response(1) = 1;
    fading_channel_response(150) = 0.2557;
    fading_channel_response(338) = 0.082;
    %fading_channel_response(900) = 0.4; 
end