function varargout = Interface(varargin)
% INTERFACE MATLAB code for Interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Interface

% Last Modified by GUIDE v2.5 01-Nov-2023 02:06:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Interface_OpeningFcn, ...
                   'gui_OutputFcn',  @Interface_OutputFcn, ...
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


% --- Executes just before Interface is made visible.
function Interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Interface (see VARARGIN)

% Choose default command line output for Interface
handles.output = hObject;
set(handles.radiobutton1,'value',1);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        cla(handles.axes1,'reset')
        load('model.mat')
        load('audioFeatures.mat')
        [~, settings] = mapminmax(data(:,1:end-1)');
        [file,path,~] = uigetfile('*.m4a');
        targetFreqStart = 50;
        targetFreqEnd = 500;
        numPoints = 200;
        targetFreqs = linspace(targetFreqStart, targetFreqEnd, numPoints);
        [audioData, sampleRate] = audioread(fullfile(path,file));
        maxStartPoint = length(audioData) - 2 * sampleRate;
        startPoint = randi([1, maxStartPoint]);
        extractedSegment = audioData(startPoint:startPoint + 2 * sampleRate - 1);
        
        bandpassFilter = designfilt('bandpassiir', ...
                            'FilterOrder', 4, ...
                            'HalfPowerFrequency1', 50, ...
                            'HalfPowerFrequency2', 500, ...
                            'SampleRate', sampleRate);
                        
        filteredAudio = filter(bandpassFilter, extractedSegment);
        
        
        fftResult = fft(filteredAudio);
        n = length(filteredAudio);
        
       
        fftResultHalf = fftResult(1:floor(n/2)+1);
        
     
        freqAxis = (0:floor(n/2)) * sampleRate / n;
        
        
        [~, closestIndices] = arrayfun(@(f) min(abs(freqAxis - f)), targetFreqs);
        targetAmplitudes = abs(fftResultHalf(closestIndices));
        targetAmplitudes = mapminmax('apply', targetAmplitudes, settings);
        
        %%
        predictl_RF=predict(RF_model,targetAmplitudes');
        predict_label_1=str2num(cell2mat(predictl_RF));
        
        predictedLabels = predict(SVMModel, targetAmplitudes');
        predict_label_2=(predictedLabels);
        
        predictl=predict(AdaboostModel,targetAmplitudes');
        predict_label_3=(predictl);
        
        scores = mnrval(LR_Model, targetAmplitudes');
       [~, predict_label_4] = max(scores,[],2);
       
       
       outputs = DNNModel(targetAmplitudes);
       outputs = outputs';
       [~, predict_label_5] = max(outputs,[],2);
       
       predict_label_6 = predict(KNNModel, targetAmplitudes');
       
       predict_label_7 = predict(nbModel, targetAmplitudes');
       
       if (predict_label_1 == 0)
          set(handles.edit1,'String','Male');
       else
          set(handles.edit1,'String','Female');
       end
       
       if (predict_label_2 == 0)
          set(handles.edit2,'String','Male');
       else
          set(handles.edit2,'String','Female');
       end
       
       if (predict_label_3 == 0)
          set(handles.edit3,'String','Male');
       else
          set(handles.edit3,'String','Female');
       end
       
       if (predict_label_4 == 0)
          set(handles.edit4,'String','Male');
       else
          set(handles.edit4,'String','Female');
       end
       
       if (predict_label_5 == 0)
          set(handles.edit9,'String','Male');
       else
          set(handles.edit9,'String','Female');
       end
       
       if (predict_label_6 == 0)
          set(handles.edit6,'String','Male');
       else
          set(handles.edit6,'String','Female');
       end
       
       if (predict_label_7 == 0)
          set(handles.edit7,'String','Male');
       else
          set(handles.edit7,'String','Female');
       end
       
       predict_label = [predict_label_1 predict_label_2 predict_label_3 predict_label_4 predict_label_5 predict_label_6 predict_label_7];
       mostFrequent = mode(predict_label);
       
       if (mostFrequent == 0)
          set(handles.edit8,'String','Male');
       else
          set(handles.edit8,'String','Female');
       end
     
       freqAxis = linspace(0, sampleRate/2, length(fftResult)); 

        
        axes(handles.axes1)   
        %figure
        plot(freqAxis, abs(fftResult));
        title('FFT (50-500 Hz)');
        xlabel('Freq (Hz)');
        ylabel('Amp');
        xlim([50 500]);

%      im = imread('task2.png');
%      axes(handles.axes1)    
%      imshow(im)
       
       sound(audioData, sampleRate);

       
       
       
       
        
        
        
        
        
        
        







function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
% function radiobutton1_Callback(hObject, eventdata, handles)
% % hObject    handle to radiobutton1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)function radiobutton1_Callback(hObject, eventdata, handles)
% set(handles.radiobutton1,'value',1);
% set(handles.radiobutton2,'value',0);
% set(handles.radiobutton3,'value',0);
% set(handles.radiobutton4,'value',0);
% 
% 
% % Hint: get(hObject,'Value') returns toggle state of radiobutton1
% 
% 
% % --- Executes on button press in radiobutton2.
% function radiobutton2_Callback(hObject, eventdata, handles)
% % hObject    handle to radiobutton2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% set(handles.radiobutton1,'value',0);
% set(handles.radiobutton2,'value',1);
% set(handles.radiobutton3,'value',0);
% set(handles.radiobutton4,'value',0);
% 
% % Hint: get(hObject,'Value') returns toggle state of radiobutton2
% 
% 
% % --- Executes on button press in radiobutton3.
% function radiobutton3_Callback(hObject, eventdata, handles)
% % hObject    handle to radiobutton3 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% set(handles.radiobutton1,'value',0);
% set(handles.radiobutton2,'value',0);
% set(handles.radiobutton3,'value',1);
% set(handles.radiobutton4,'value',0);
% 
% % Hint: get(hObject,'Value') returns toggle state of radiobutton3
% 
% 
% % --- Executes on button press in radiobutton4.
% function radiobutton4_Callback(hObject, eventdata, handles)
% % hObject    handle to radiobutton4 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% set(handles.radiobutton1,'value',0);
% set(handles.radiobutton2,'value',0);
% set(handles.radiobutton3,'value',0);
% set(handles.radiobutton4,'value',1);

% Hint: get(hObject,'Value') returns toggle state of radiobutton4



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
