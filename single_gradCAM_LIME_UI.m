function single_gradCAM_LIME_UI
    % single_gradCAM_LIME_UI - GUI for performing Grad-CAM and LIME on a single image
    %
    % Description:
    %   This function opens a GUI for performing Grad-CAM and LIME visualizations on a single image.
    %
    % Example:
    %   single_gradCAM_LIME_UI
    %
    % See also: bulk_gradCAM_LIME_UI, masked_LIME_UI, iou_calculation_UI
	
	
    % Create the main UI figure
    fig = uifigure('Name', 'Model Explanation Visualizer', 'Position', [100 100 1000 600], 'WindowStyle', 'normal');

    % Create tab group
    tg = uitabgroup(fig, 'Position', [0 50 1000 550]);

    % Create tabs
    tabGradCAM = uitab(tg, 'Title', 'Grad-CAM');
    tabImageLIME = uitab(tg, 'Title', 'ImageLIME');

    % Center positions for labels
    figWidth = 1000;
    labelWidth = 300;
    centerX = (figWidth - labelWidth) / 2;

    % Add titles to tabs
    uilabel(tabGradCAM, 'Text', 'Model Explanation - GradCAM', 'FontSize', 18, 'FontWeight', 'bold', 'Position', [centerX 500 300 30], 'FontColor', 'red');
    uilabel(tabImageLIME, 'Text', 'Model Explanation - LIME', 'FontSize', 18, 'FontWeight', 'bold', 'Position', [centerX 500 300 30], 'FontColor', 'red');

    % Create UI components for Grad-CAM tab
    btnLoadModelGC = uibutton(tabGradCAM, 'Text', 'Load Model', 'Position', [20 450 100 30], 'ButtonPushedFcn', @(btn,event) loadModel());
    btnSingleImageGC = uibutton(tabGradCAM, 'Text', 'Select Image', 'Position', [20 400 100 30], 'ButtonPushedFcn', @(btn,event) selectSingleImage('Grad-CAM'));
    btnOutputFolderGC = uibutton(tabGradCAM, 'Text', 'Output Folder', 'Position', [20 350 100 30], 'ButtonPushedFcn', @(btn,event) selectOutputFolder());
    btnStartGC = uibutton(tabGradCAM, 'Text', 'Start', 'Position', [20 300 100 30], 'ButtonPushedFcn', @(btn,event) startProcessing('Grad-CAM', 'single'));
    btnPauseGC = uibutton(tabGradCAM, 'Text', 'Pause', 'Position', [140 300 100 30], 'ButtonPushedFcn', @(btn,event) pauseProcessing());
    btnStopGC = uibutton(tabGradCAM, 'Text', 'Stop', 'Position', [260 300 100 30], 'ButtonPushedFcn', @(btn,event) stopProcessing());
    uilabel(tabGradCAM, 'Text', 'Results', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 250 100 30]);

    % Create UI components for ImageLIME tab
    btnLoadModelIL = uibutton(tabImageLIME, 'Text', 'Load Model', 'Position', [20 450 100 30], 'ButtonPushedFcn', @(btn,event) loadModel());
    btnSingleImageIL = uibutton(tabImageLIME, 'Text', 'Select Image', 'Position', [20 400 100 30], 'ButtonPushedFcn', @(btn,event) selectSingleImage('ImageLIME'));
    btnOutputFolderIL = uibutton(tabImageLIME, 'Text', 'Output Folder', 'Position', [20 350 100 30], 'ButtonPushedFcn', @(btn,event) selectOutputFolder());
    btnStartIL = uibutton(tabImageLIME, 'Text', 'Start', 'Position', [20 300 100 30], 'ButtonPushedFcn', @(btn,event) startProcessing('ImageLIME', 'single'));
    btnPauseIL = uibutton(tabImageLIME, 'Text', 'Pause', 'Position', [140 300 100 30], 'ButtonPushedFcn', @(btn,event) pauseProcessing());
    btnStopIL = uibutton(tabImageLIME, 'Text', 'Stop', 'Position', [260 300 100 30], 'ButtonPushedFcn', @(btn,event) stopProcessing());
    uilabel(tabImageLIME, 'Text', 'Results', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [20 250 100 30]);

    % Axes for displaying results
    axOriginal = uiaxes(tabGradCAM, 'Position', [20 20 350 200]);
    axGradCAM = uiaxes(tabGradCAM, 'Position', [400 20 350 200]);
    axOriginalIL = uiaxes(tabImageLIME, 'Position', [20 20 350 200]);
    axImageLIME_SP = uiaxes(tabImageLIME, 'Position', [400 240 350 200]);
    axImageLIME_Grid = uiaxes(tabImageLIME, 'Position', [400 20 350 200]);

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
    end

    function selectSingleImage(method)
        [imageFile, imagePath] = uigetfile({'*.jpg;*.png;*.bmp'}, 'Select an Image');
        if isequal(imageFile, 0)
            return;
        end
        singleImagePath = fullfile(imagePath, imageFile);
        uialert(fig, ['Selected Image: ', singleImagePath], 'Success');
    end

    function selectOutputFolder()
        outputFolder = uigetdir('', 'Select Output Folder');
        if outputFolder == 0
            outputFolder = '';
        else
            uialert(fig, ['Selected Output Folder: ', outputFolder], 'Success');
        end
    end

    function startProcessing(method, mode)
        if isempty(net) || isempty(singleImagePath) || isempty(outputFolder)
            uialert(fig, 'Please load model and select an image/output folder first!', 'Error');
            return;
        end
        isProcessing = true;
        isPaused = false;
        if strcmp(mode, 'single')
            processSingleImage(singleImagePath, method);
        end
    end

    function pauseProcessing()
        if isProcessing
            isPaused = true;
        end
    end

    function stopProcessing()
        isProcessing = false;
        isPaused = false;
    end

    % Function to process single image
    function processSingleImage(imagePath, method)
        img = imread(imagePath);
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
            imshow(img, 'Parent', axOriginal);
            title(axOriginal, 'Original Image');
            imshow(blendedImg, 'Parent', axGradCAM);
            title(axGradCAM, 'Grad-CAM Visualization');
            
            % Save the blended image
            blendedImgOriginalSize = imresize(blendedImg, [size(img, 1), size(img, 2)]);
            [~, name, ext] = fileparts(imagePath);
            outputFileName = fullfile(outputFolder, [name, '_', lower(method), ext]);
            imwrite(blendedImgOriginalSize, outputFileName);
        else % ImageLIME
            limeMapSP = imageLIME(net, imgResized, predClassStr, 'Segmentation', 'superpixels', 'NumFeatures', 64);
            overlayMaskSP = imresize(limeMapSP, net.Layers(1).InputSize(1:2));
            overlayMaskSP = overlayMaskSP / max(overlayMaskSP(:));
            heatmapImgSP = ind2rgb(uint8(overlayMaskSP * 255), jet(256));
                        blendedImgSP = 0.6 * im2double(imgResized) + 0.4 * heatmapImgSP;

            limeMapGrid = imageLIME(net, imgResized, predClassStr, 'Segmentation', 'grid', 'NumFeatures', 64);
            overlayMaskGrid = imresize(limeMapGrid, net.Layers(1).InputSize(1:2));
            overlayMaskGrid = overlayMaskGrid / max(overlayMaskGrid(:));
            heatmapImgGrid = ind2rgb(uint8(overlayMaskGrid * 255), jet(256));
            blendedImgGrid = 0.6 * im2double(imgResized) + 0.4 * heatmapImgGrid;

            imshow(img, 'Parent', axOriginalIL);
            title(axOriginalIL, 'Original Image');
            imshow(blendedImgSP, 'Parent', axImageLIME_SP);
            title(axImageLIME_SP, 'ImageLIME Super Pixel Visualization');
            imshow(blendedImgGrid, 'Parent', axImageLIME_Grid);
            title(axImageLIME_Grid, 'ImageLIME Grid Visualization');

            % Save the blended images
            blendedImgOriginalSizeSP = imresize(blendedImgSP, [size(img, 1), size(img, 2)]);
            blendedImgOriginalSizeGrid = imresize(blendedImgGrid, [size(img, 1), size(img, 2)]);
            [~, name, ext] = fileparts(imagePath);
            outputFileNameSP = fullfile(outputFolder, [name, '_imagelime_superpixel', ext]);
            outputFileNameGrid = fullfile(outputFolder, [name, '_imagelime_grid', ext]);
            imwrite(blendedImgOriginalSizeSP, outputFileNameSP);
            imwrite(blendedImgOriginalSizeGrid, outputFileNameGrid);
        end

        uialert(fig, 'Processing complete and images saved successfully.', 'Success');
    end
end

