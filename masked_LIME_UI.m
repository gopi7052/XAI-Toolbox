function masked_LIME_UI

    % masked_LIME_UI - GUI for performing masked LIME visualization on an image
    %
    % Description:
    %   This function opens a GUI for performing masked LIME visualization on an image.
    %
    % Example:
    %   masked_LIME_UI
    %
    % See also: bulk_gradCAM_LIME_UI, single_gradCAM_LIME_UI, iou_calculation_UI


    % Create the main UI figure in full screen
    fig = uifigure('Name', 'Model Explanation Visualizer', 'WindowState', 'maximized');
    movegui(fig, 'center');
    
    % Add title to main UI figure
    titlePosition = [fig.Position(3)/2 - 150, fig.Position(4) - 50, 300, 30];
    uilabel(fig, 'Text', 'Model Explanation - LIME', 'FontSize', 18, 'FontWeight', 'bold', 'Position', titlePosition, 'FontColor', 'red');

    % Create UI components for main UI figure
    btnLoadModelIL = uibutton(fig, 'Text', 'Load Model', 'Position', [20 fig.Position(4) - 100 100 30], 'ButtonPushedFcn', @(btn,event) loadModel());
    btnSingleImageIL = uibutton(fig, 'Text', 'Select Image', 'Position', [20 fig.Position(4) - 150 100 30], 'ButtonPushedFcn', @(btn,event) selectSingleImage('ImageLIME'));
    btnOutputFolderIL = uibutton(fig, 'Text', 'Output Folder', 'Position', [20 fig.Position(4) - 200 100 30], 'ButtonPushedFcn', @(btn,event) selectOutputFolder());
    btnStartIL = uibutton(fig, 'Text', 'Start', 'Position', [20 fig.Position(4) - 300 100 30], 'ButtonPushedFcn', @(btn,event) startProcessing('ImageLIME', 'single'));
    btnPauseIL = uibutton(fig, 'Text', 'Pause', 'Position', [140 fig.Position(4) - 300 100 30], 'ButtonPushedFcn', @(btn,event) pauseProcessing());
    btnStopIL = uibutton(fig, 'Text', 'Stop', 'Position', [260 fig.Position(4) - 300 100 30], 'ButtonPushedFcn', @(btn,event) stopProcessing());
    uilabel(fig, 'Text', 'Results', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 fig.Position(4) - 350 100 30]);

    % Dropdown for selecting number of features
    ddNumFeatures = uidropdown(fig, 'Items', {'6', '8', '10', '12'}, 'Position', [20 fig.Position(4) - 250 100 30], 'Value', '12');

    % Axes for displaying results
    axisWidth = (fig.Position(3) - 80) / 4;
    axisHeight = 200;
    axisYPos = fig.Position(4) - 550;

    axOriginalIL = uiaxes(fig, 'Position', [20 axisYPos axisWidth axisHeight]);
    axLIME_Grid = uiaxes(fig, 'Position', [40 + axisWidth axisYPos axisWidth axisHeight]);
    axMasked = uiaxes(fig, 'Position', [60 + 2 * axisWidth axisYPos axisWidth axisHeight]);
    axBinarized = uiaxes(fig, 'Position', [80 + 3 * axisWidth axisYPos axisWidth axisHeight]);

    % Create footer for progress messages
    footerLabel = uilabel(fig, 'Text', 'Ready', 'FontSize', 14, 'Position', [20 10 fig.Position(3) - 40 30], 'HorizontalAlignment', 'left');

    % Variables to store loaded data and state
    net = [];
    singleImagePath = '';
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
        footerLabel.Text = 'Model loaded successfully.';
    end

    function selectSingleImage(method)
        [imageFile, imagePath] = uigetfile({'.jpg;.png;*.bmp'}, 'Select an Image');
        if isequal(imageFile, 0)
            return;
        end
        singleImagePath = fullfile(imagePath, imageFile);
        uialert(fig, ['Selected Image: ', singleImagePath], 'Success');
        footerLabel.Text = 'Image selected successfully.';
    end

    function selectOutputFolder()
        outputFolder = uigetdir('', 'Select Output Folder');
        if outputFolder == 0
            outputFolder = '';
        else
            uialert(fig, ['Selected Output Folder: ', outputFolder], 'Success');
            footerLabel.Text = 'Output folder selected successfully.';
        end
    end

    function startProcessing(method, mode)
        if isempty(net) || isempty(singleImagePath) || isempty(outputFolder)
            uialert(fig, 'Please load model and select an image/output folder first!', 'Error');
            return;
        end
        isProcessing = true;
        isPaused = false;
        footerLabel.Text = 'Processing... Please wait.';
        if strcmp(mode, 'single')
            numTopFeatures = str2double(ddNumFeatures.Value); % Get the number of features from the dropdown
            processSingleImage(singleImagePath, method, numTopFeatures);
        end
    end

    function pauseProcessing()
        if isProcessing
            isPaused = true;
            footerLabel.Text = 'Processing paused.';
        end
    end

    function stopProcessing()
        isProcessing = false;
        isPaused = false;
        footerLabel.Text = 'Processing stopped.';
    end

    % Function to process single image
    function processSingleImage(imagePath, method, numTopFeatures)
        img = imread(imagePath);
        imgResized = imresize(img, net.Layers(1).InputSize(1:2));
        [label, ~] = classify(net, imgResized);
        predClass = find(label == net.Layers(end).ClassNames);
        predClassStr = string(net.Layers(end).ClassNames(predClass)); % Convert to suitable type

        % Generate LIME map
        [limeMapGrid, featureMap, featureImportance] = imageLIME(net, imgResized, predClassStr, 'Segmentation', 'grid', 'NumFeatures', 64);

        % Normalize LIME map
        limeMapGrid = limeMapGrid - min(limeMapGrid(:));
        limeMapGrid = limeMapGrid / max(limeMapGrid(:));

        % Mask image using top features
        [~, idx] = maxk(featureImportance, numTopFeatures);
        mask = ismember(featureMap, idx);
        maskedImg = uint8(mask) .* imgResized;

        % Binarize the masked image
        binarizedMask = uint8(mask) * 255;

        % Display images
        imshow(img, 'Parent', axOriginalIL);
        title(axOriginalIL, 'Original Image');
        imshow(ind2rgb(uint8(limeMapGrid * 255), jet(256)), 'Parent', axLIME_Grid);
        title(axLIME_Grid, 'LIME Visualization');
        imshow(maskedImg, 'Parent', axMasked);
        title(axMasked, 'Masked Image');
        imshow(binarizedMask, 'Parent', axBinarized);
        title(axBinarized, 'Binarized Masked Image');

        % Save images
        [~, name, ext] = fileparts(imagePath);
        outputFileNameLIME = fullfile(outputFolder, [name, '_lime', ext]);
        outputFileNameMasked = fullfile(outputFolder, [name, '_masked', ext]);
        outputFileNameBinarized = fullfile(outputFolder, [name, '_binarized', ext]);
        imwrite(ind2rgb(uint8(limeMapGrid * 255), jet(256)), outputFileNameLIME);
        imwrite(maskedImg, outputFileNameMasked);
        imwrite(binarizedMask, outputFileNameBinarized);

        uialert(fig, 'Processing complete and images saved successfully.', 'Success');
        footerLabel.Text = 'Processing complete and images saved successfully.';
    end
end