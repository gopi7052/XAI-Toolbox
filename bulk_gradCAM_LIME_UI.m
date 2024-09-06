function bulk_gradCAM_LIME_UI
    % bulk_gradCAM_LIME_UI - GUI for performing Grad-CAM and LIME on multiple images
    %
    % Description:
    %   This function opens a GUI for performing Grad-CAM and LIME visualizations on a batch of images.
    %
    % Example:
    %   bulk_gradCAM_LIME_UI
    %
    % See also: single_gradCAM_LIME_UI, masked_LIME_UI, iou_calculation_UI

    % Create the main UI figure
    fig = uifigure('Name', 'Model Explanation Visualizer', 'Position', [100 100 800 600]);

    % Create tab group
    tg = uitabgroup(fig, 'Position', [0 50 800 550]);

    % Create tabs
    tabGradCAM = uitab(tg, 'Title', 'Grad-CAM');
    tabImageLIME = uitab(tg, 'Title', 'ImageLIME');

    % Create UI components for Grad-CAM tab
    uilabel(tabGradCAM, 'Text', 'Load Model', 'Position', [20 450 100 30]);
    btnLoadModelGC = uibutton(tabGradCAM, 'Text', 'Select Model', 'Position', [140 450 100 30], 'ButtonPushedFcn', @(btn,event) loadModel());

    uilabel(tabGradCAM, 'Text', 'Input Folder', 'Position', [20 400 100 30]);
    btnInputFolderGC = uibutton(tabGradCAM, 'Text', 'Select Folder', 'Position', [140 400 100 30], 'ButtonPushedFcn', @(btn,event) selectInputFolder());

    uilabel(tabGradCAM, 'Text', 'Output Folder', 'Position', [20 350 100 30]);
    btnOutputFolderGC = uibutton(tabGradCAM, 'Text', 'Select Folder', 'Position', [140 350 100 30], 'ButtonPushedFcn', @(btn,event) selectOutputFolder());

    btnStartGC = uibutton(tabGradCAM, 'Text', 'Start', 'Position', [20 300 100 30], 'ButtonPushedFcn', @(btn,event) startProcessing('Grad-CAM'));
    btnPauseGC = uibutton(tabGradCAM, 'Text', 'Pause', 'Position', [140 300 100 30], 'ButtonPushedFcn', @(btn,event) pauseProcessing());
    btnStopGC = uibutton(tabGradCAM, 'Text', 'Stop', 'Position', [260 300 100 30], 'ButtonPushedFcn', @(btn,event) stopProcessing());

    % Results section with scroll bar
    progressPanelGC = uipanel(tabGradCAM, 'Title', 'Results:', 'Position', [20 20 760 250]);
    progressListGC = uitextarea(progressPanelGC, 'Position', [10 10 740 200], 'Editable', 'off', 'HorizontalAlignment', 'left');

    % Create UI components for ImageLIME tab
    uilabel(tabImageLIME, 'Text', 'Load Model', 'Position', [20 450 100 30]);
    btnLoadModelIL = uibutton(tabImageLIME, 'Text', 'Select Model', 'Position', [140 450 100 30], 'ButtonPushedFcn', @(btn,event) loadModel());

    uilabel(tabImageLIME, 'Text', 'Input Folder', 'Position', [20 400 100 30]);
    btnInputFolderIL = uibutton(tabImageLIME, 'Text', 'Select Folder', 'Position', [140 400 100 30], 'ButtonPushedFcn', @(btn,event) selectInputFolder());

    uilabel(tabImageLIME, 'Text', 'Output Folder', 'Position', [20 350 100 30]);
    btnOutputFolderIL = uibutton(tabImageLIME, 'Text', 'Select Folder', 'Position', [140 350 100 30], 'ButtonPushedFcn', @(btn,event) selectOutputFolder());

    btnStartIL = uibutton(tabImageLIME, 'Text', 'Start', 'Position', [20 300 100 30], 'ButtonPushedFcn', @(btn,event) startProcessing('ImageLIME'));
    btnPauseIL = uibutton(tabImageLIME, 'Text', 'Pause', 'Position', [140 300 100 30], 'ButtonPushedFcn', @(btn,event) pauseProcessing());
    btnStopIL = uibutton(tabImageLIME, 'Text', 'Stop', 'Position', [260 300 100 30], 'ButtonPushedFcn', @(btn,event) stopProcessing());

    % Results section with scroll bar
    progressPanelIL = uipanel(tabImageLIME, 'Title', 'Results:', 'Position', [20 20 760 250]);
    progressListIL = uitextarea(progressPanelIL, 'Position', [10 10 740 200], 'Editable', 'off', 'HorizontalAlignment', 'left');

    % Variables to store loaded data and state
    net = [];
    inputFolder = '';
    outputFolder = '';
    isProcessing = false;
    isPaused = false;

    % Nested functions for button callbacks
    function loadModel()
        [modelFile, modelPath] = uigetfile({'*.mat'}, 'Select a pretrained model');
        if isequal(modelFile, 0)
            return;
        end
        modelFullPath = fullfile(modelPath, modelFile);
        loadedModel = load(modelFullPath);
        netFieldNames = fieldnames(loadedModel);
        net = loadedModel.(netFieldNames{1}); % Get the first field in the loaded .mat file
        uialert(fig, 'Model Loaded Successfully', 'Success');
    end

    function selectInputFolder()
        inputFolder = uigetdir('', 'Select Input Folder');
        if inputFolder == 0
            inputFolder = '';
        else
            uialert(fig, ['Selected Input Folder: ', inputFolder], 'Success');
        end
    end

    function selectOutputFolder()
        outputFolder = uigetdir('', 'Select Output Folder');
        if outputFolder == 0
            outputFolder = '';
        else
            uialert(fig, ['Selected Output Folder: ', outputFolder], 'Success');
        end
    end

    function startProcessing(method)
        if isempty(net) || isempty(inputFolder) || isempty(outputFolder)
            uialert(fig, 'Please load model and select input/output folders first!', 'Error');
            return;
        end
        isProcessing = true;
        isPaused = false;
        updateProgress('Processing started...', method);
        processImages(method);
    end

    function pauseProcessing()
        if isProcessing
            isPaused = true;
            updateProgress('Processing paused.', method);
        end
    end

    function stopProcessing()
        isProcessing = false;
        isPaused = false;
        updateProgress('Processing stopped.', method);
    end

    function updateProgress(message, method)
        if strcmp(method, 'Grad-CAM')
            progressListGC.Value = [progressListGC.Value; {message}];
        else
            progressListIL.Value = [progressListIL.Value; {message}];
        end
    end

    % Function to process images
    function processImages(method)
        imageFiles = dir(fullfile(inputFolder, '*.*'));
        imageFiles = imageFiles(~[imageFiles.isdir]);
        numFiles = length(imageFiles);
        
        for i = 1:numFiles
            if ~isProcessing
                break;
            end
            
            while isPaused
                pause(0.1);
            end
            
            imgPath = fullfile(inputFolder, imageFiles(i).name);
            img = imread(imgPath);
            imgResized = imresize(img, net.Layers(1).InputSize(1:2));

            [label, ~] = classify(net, imgResized);
            predClass = find(label == net.Layers(end).ClassNames);
            predClassStr = string(net.Layers(end).ClassNames(predClass)); % Convert to suitable type
            
            if strcmp(method, 'Grad-CAM')
                gradCamMap = gradCAM(net, imgResized, predClass);
                overlayMask = imresize(gradCamMap, net.Layers(1).InputSize(1:2));
                overlayMask = overlayMask / max(overlayMask(:));
                heatmapImg = ind2rgb(uint8(overlayMask * 255), jet(256));
                blendedImg = 0.6 * im2double(imgResized) + 0.4 * heatmapImg;
            else % ImageLIME
                limeMap = imageLIME(net, imgResized, predClassStr); % Use converted label
                overlayMask = imresize(limeMap, net.Layers(1).InputSize(1:2));
                overlayMask = overlayMask / max(overlayMask(:));
                heatmapImg = ind2rgb(uint8(overlayMask * 255), jet(256));
                blendedImg = 0.6 * im2double(imgResized) + 0.4 * heatmapImg;
            end
            
            blendedImgOriginalSize = imresize(blendedImg, [size(img, 1), size(img, 2)]);

            [~, name, ext] = fileparts(imageFiles(i).name);
            outputFileName = fullfile(outputFolder, [name, '_', lower(method), ext]);
            imwrite(blendedImgOriginalSize, outputFileName);

            updateProgress(['Processed and saved: ', outputFileName], method);
        end

        isProcessing = false;
        uialert(fig, 'Processing Complete', 'Success');
    end
end
