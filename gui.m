function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 06-Feb-2017 14:10:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.mainGUI);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function nextPlotButton_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'fitCounter')
    return
end
if handles.fitCounter == length(handles.fitResult)
    return
end
handles.fitCounter = handles.fitCounter+1;
guidata(hObject, handles);
plotFit(handles, handles.fitCounter, handles.fitPlotAxes, handles.mainGUI);

function prevPlotButton_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'fitCounter')
    return
end
if handles.fitCounter == 1
    return
end
handles.fitCounter = handles.fitCounter-1;
guidata(hObject, handles);
plotFit(handles, handles.fitCounter, handles.fitPlotAxes, handles.mainGUI);
adjustAxes(handles,'fit');

function runButton_Callback(hObject, eventdata, handles)
if isfield(handles, 'folder'); % Folder selected
    folder = handles.folder;
else
    warndlg('No folder selected.');
    return;
end
h = waitbar(0,'Reading Parameters.')
sett = num2str(handles.setMenu.Value);
if strcmp(sett, '6') % If no sett
    sett = '';
end
handles.sett = sett;
if handles.typeMenu.Value == 1
    suffix = 'min';
elseif handles.typeMenu.Value == 2
    suffix = 'ngperml';
end
    
startLambda = str2double(handles.startLambdaEdit.String);
endLambda = str2double(handles.endLambdaEdit.String);
nPoints = str2double(handles.avgPointsEdit.String);
wSize = str2double(handles.avgWindowEdit.String);

waitbar(0.25,h,'Reading Files.')
[header, avgPeak, fitPeak, lambdaPeak, fitResult, lambda, data] = ...
      main(folder, suffix, sett, startLambda, endLambda, wSize, nPoints);
if isempty(data)
    warndlg('No files found with current parameters. Aborting.');
    close(h);
    return;
end

% Plot the main plot (edit here Matt)
waitbar(0.5,h,'Ploting result.');
pause(0.5);
axes(handles.mainPlotAxes);
cla(gca);
plot(header, avgPeak, 'ro', 'LineWidth', 2); 
hold on;
plot(header, fitPeak, 'bx', 'LineWidth', 2);
hold off;
xlabel('Irradiation Time [min]');
ylabel('Peak Intensity [a.u.]');
grid on;
legend('Avg. Peak', 'Gaussian Peak');
adjustAxes(handles,'main');

% Output data table
handles.dataTable.Data = [header.' lambdaPeak.' avgPeak.' fitPeak.'];

handles.type = suffix; % concentration vs time
handles.fitResult = fitResult; % Cell array of fits
handles.data = data; % Data table for exporting to CSV
handles.lambda = lambda; % wavelengths
handles.header = header; % name of each experiment

% Plot fit 
waitbar(0.75,h,'Ploting fit.')
pause(0.5);
handles.fitCounter = 1;
min = lower(handles.fitPlotMinEdit.String);
max = lower(handles.fitPlotMaxEdit.String);
str = {'Auto', 'auto', 'a', 'A', 'automatic', 'Automatic'};
plotFit(handles, handles.fitCounter, handles.fitPlotAxes, handles.mainGUI);
adjustAxes(handles,'fit');

guidata(hObject, handles);
close(h)

function adjustAxes(handles, ax, hAx)
min = eval(sprintf('lower(handles.%sPlotMinEdit.String)', ax));
max = eval(sprintf('lower(handles.%sPlotMaxEdit.String)', ax));
if nargin < 3, hAx = []; end
if isempty(hAx)
    eval(sprintf('axes(handles.%sPlotAxes)', ax));
end
str = {'Auto', 'auto', 'a', 'A', 'automatic', 'Automatic'};
if ismember(min, str) || ismember(max, str)   
    xlim auto
else
    min = str2double(min);
    max = str2double(max);
    xlim([min, max]);
end
if strcmp(ax,'fit')
    min = handles.yMinEdit.String;
    max = handles.yMaxEdit.String;
    if ismember(min, str) || ismember(max, str)   
        ylim auto
    else
        min = str2double(min);
        max = str2double(max);
        ylim([min, max]);
    end
end

function plotFit(handles, i, ax, f) % Plot Fit (edit this Matt)
if strcmp(f.Tag, 'mainGUI')
    axes(ax);
end
cla(gca);

plot(handles.lambda, feval(handles.fitResult{i},handles.lambda), '-r', 'LineWidth', 2);
hold on;
plot(handles.lambda, handles.data(:, i), '-ks', 'MarkerFaceColor', 'k');
hold off;
xlabel('Wavelength (nm)');
ylabel('Intensity (a.u)');
legend('Fit', 'Experiment');
if strcmp(handles.type, 'min')
    title(['Irradiation time: ', num2str(handles.header(i)), 'min']);
elseif strcmp(handles.type, 'ngperml')
    title(['Concentration: ', num2str(handles.header(i)), 'ng/mL']);
end
grid on;

function folderButton_Callback(hObject, eventdata, handles)
folder_name = uigetdir;
if folder_name
    handles.folder = folder_name;
    [a, b] = fileparts(folder_name);
    [~, a] = fileparts(a);
    handles.dirText.String = ['Folder: ', a, '\', b];
    guidata(hObject,handles);
end

function updateButton_Callback(hObject, eventdata, handles)
adjustAxes(handles,'fit');

function updateMainPlot_Callback(hObject, eventdata, handles)
adjustAxes(handles,'main');

function exportButton_Callback(hObject, eventdata, handles)
    if ~isfield(handles, 'data')
        warndlg('No data in memory. Please run program.');
        return;
    end

    sett = handles.sett;
    if isempty(sett)
        sett = [];
    else
        sett = ['_', sett];
    end
    defaultName = fullfile(handles.folder, datestr(date, 'yyyymmdd'), sett);

    extensions = {'*.mat',...
     'MATLAB MAT file (*.mat)';
     '*.csv', 'Comma Separate Values (*.csv)';...
     '*.txt','Space-delimited TXT (*.txt)';...
     '*.*',  'All Files (*.*)'};

    [filename, pathname, index] = uiputfile(extensions, 'Save as', defaultName);

    data = [[0 handles.header]; handles.lambda handles.data];
    
    if isequal(filename,0) || isequal(pathname,0) % Canceled
       return;
    else
       fullf = fullfile(pathname, filename);
       if index == 1 % mat
           save(fullf, 'data');
       elseif index == 2 %csv
           dlmwrite(fullf,data,'delimiter',',','precision',5)
       elseif index == 3 % space-delimited txt
           dlmwrite(fullf,data,'delimiter',' ','precision',5)
       else
           error('Cant save in this extensions');
       end
    end

function undockMain_Callback(hObject, eventdata, handles)
    f = figure;
    leg = legend(handles.mainPlotAxes);
    if ~isempty(leg)
        copyobj([leg, handles.mainPlotAxes],f);
    else
        copyobj(handles.mainPlotAxes,f);
    end
    ax = gca;
    ax.Units = 'normalized';
    sett(gca, 'Position', [0.1300    0.1100    0.7750    0.8150]);

function undockFit_Callback(hObject, eventdata, handles)
    f = figure;
    leg = legend(handles.fitPlotAxes);
    if ~isempty(leg)
        copyobj([leg, handles.fitPlotAxes],f);
    else
        copyobj(handles.fitPlotAxes,f);
    end
    ax = gca;
    ax.Units = 'normalized';
    sett(gca, 'Position', [0.1300    0.1100    0.7750    0.8150]);

function mainGUI_KeyPressFcn(hObject, eventdata, handles)
switch eventdata.Key
    case 'e'
        exportButton_Callback(hObject, eventdata, handles)  
    case 'return'
        runButton_Callback(hObject, eventdata, handles)
    case 'rightarrow'
        nextPlotButton_Callback(hObject, eventdata, handles)
    case 'leftarrow'
        prevPlotButton_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in saveAllButton.
function saveAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles, 'data')
    warndlg('No data in memory. Please run program.');
    return;
end
sett = handles.sett;
if isempty(sett)
    sett = [];
else
    sett = ['_', sett];
end
format = handles.formatMenu.String{handles.formatMenu.Value};
if ~strcmp(format, 'pptx')
    folder = uigetdir(handles.folder);
else
    defaultName = fullfile(handles.folder, [datestr(date, 'yyyymmdd'), sett, '.pptx']);
    [filename, pathname] = uiputfile('.pptx', 'Save as', defaultName);
    isOpen  = exportToPPTX();
    if ~isempty(isOpen)
        % If PowerPoint already started, then close first and then open a new one
        exportToPPTX('close');
    end
    exportToPPTX('new');
end   
h = waitbar(0,'Please wait...');
n = length(handles.fitResult);
for i=1:n
    waitbar(i/n,h, ['Saving image ', num2str(i), ' of ', num2str(n)]);
    f = figure;
    ax = axes();
    ax.Visible = 'off';
    f.Visible = 'off';
    plotFit(handles, i, ax, f);
    adjustAxes(handles,'fit', ax);
    if ~strcmp(format, 'pptx')
        filename = fullfile(folder, [num2str(handles.header(i)), handles.type, handles.sett]);
        saveas(f, [filename, '.' format]);
    else
        f.Color = [1 1 1];
        exportToPPTX('addslide');
        exportToPPTX('addpicture',f);
    end   
    close(f);
end
if strcmp(format, 'pptx')
    try
        exportToPPTX('saveandclose',fullfile(pathname, filename));
    catch ME
        warndlg(ME.message);
    end
end
close(h);
