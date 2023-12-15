% % Set the audio recording parameters
% fs = 48e3; % Sampling rate (Hz)
% bitsPerSample = 16; % Bits per sample
% numberOfChannels = 1; % Number of audio channels (1 for mono, 2 for stereo)
% 
% % Create an audio recorder object
% recObj = audiorecorder(fs, bitsPerSample, numberOfChannels);
% 
% % Record audio for a specified duration (e.g., 5 seconds)
% durationInSeconds = 5;
% disp('Recording...');
% recordblocking(recObj, durationInSeconds);
% disp('Finished recording');
% 
% % Get the recorded audio data
% audioData = getaudiodata(recObj);
% 
% % Plot the recorded audio waveform
% time = (0:length(audioData)-1) / fs;
% figure;
% plot(time, audioData);
% title('Recorded Audio');
% xlabel('Time (seconds)');
% ylabel('Amplitude');
% 
% figure;
% plot(abs(fftshift(fft(audioData))))
% 
% % Save the recorded audio to a file (optional)
% audiowrite('recorded_audio.wav', audioData, fs);

% Specify the path to your WAV file
filePath = 'impulse_cuisine.wav';

% Read the audio file
[audioData, sampleRate] = audioread(filePath);

% Display the sample rate
disp(['Sample Rate: ' num2str(sampleRate) ' Hz']);

% Plot the audio waveform
time = (0:length(audioData)-1) / sampleRate;
figure;
plot(time, audioData);
title('Audio Waveform');
xlabel('Time (seconds)');
ylabel('Amplitude');

