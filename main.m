function [header, avgPeak, fitPeak, fitResult, lambda, data] = main(folder, suffix, set, startLambda, endLambda, wSize, nPoints)

% folder = 'D:\Dropbox\Research\Rentzepis\UmangProgram\'; % Path with data
% startLambda = 300;       % First wavelength in region of interest
% endLambda = 400;         % Second wavelength in region of interest
% wSize = 5;               % Number of points to take on each side of center
% nPoints = 4;             % Number of points to average peak over

data = loadData(folder, suffix, set); % Load data in the folder
if isempty(data)
    header = []; avgPeak = []; fitPeak = []; fitResult = []; lambda = [];
    return
end
header = data(1,2:end);  % file header with concentration/exposure time
nExp = size(data,2)-1;   % Number of experiments
lambda = data(2:end, 1); % Wavelengths


iS = find(lambda == startLambda); % Start intex of ROI
iE = find(lambda == endLambda);   % End index of ROI

lambda = lambda(iS:iE);           % Wavelengths in ROI
data = data(iS+1:iE+1, 2:end);    % All N spectra in ROI

center = zeros(1,nExp); fitPeak = zeros(1,nExp); avgPeak = zeros(1,nExp);

% Start fitting experiments
for i=1:nExp
    spectrum = data(:,i); % Experimental data
    fitResult{i} = createFit(lambda, spectrum); % Fit to gaussian
    coeff = coeffvalues(fitResult{i}); center = coeff(2); % Peak wavelength
    fit = feval(fitResult{i},lambda); % Gaussian data
    ci = find(lambda == round(center)); % Find location of peak in array
    if isempty(ci)
        uiwait(warndlg(['Poor fit for: ', num2str(header(i)), ' ', suffix '. Excluding data point.']));
        fitPeak(i) = nan;
        avgPeak(i) = nan;
        continue;
    end
    window = [ci-wSize:ci+wSize]; % Window for picking 4 points
    dist = zeros(size(window));
    
    % Extract all points within window and find abs. distance
    for j=1:length(window)
        y1 = spectrum(window(j)); % Experimental point
        y2 = fit(window(j));      % Fit point
        dist(j) = abs(y1-y2); % Distance between data and fit;
    end
    [~,id]=sort(dist);
    avgPeak(i) = sum(spectrum(ci+id(1:nPoints)-wSize-1))/nPoints;
    fitPeak(i) = coeff(1);
end

%plot(header, avgPeak, 'o', header, fitPeak, 'x');
%disp(table(avgPeak.', fitPeak.', 'VariableNames',{'AveragePeak', 'FitPeak'}));
end