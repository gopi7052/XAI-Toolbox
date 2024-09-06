function iou_calculation_UI
    % iou_calculation_UI - GUI for calculating Intersection over Union (IoU)
    %
    % Description:
    %   This function opens a GUI for calculating the Intersection over Union (IoU) for given masks.
    %
    % Example:
    %   iou_calculation_UI
    %
    % See also: bulk_gradCAM_LIME_UI, single_gradCAM_LIME_UI, masked_LIME_UI

   
    % Create the main UI figure in full screen
    fig = uifigure('Name', 'Model Explanation Visualizer', 'WindowState', 'maximized');
    movegui(fig, 'center');
    
    % Add title to main UI figure
    titlePosition = [fig.Position(3)/2 - 150, fig.Position(4) - 50, 300, 30];
    uilabel(fig, 'Text', 'Model Explanation - LIME', 'FontSize', 18, 'FontWeight', 'bold', 'Position', titlePosition, 'FontColor', 'red');

    % Create UI components for main UI figure
    btnSelectBinarizedIL = uibutton(fig, 'Text', 'Select Binarized Masked Image', 'Position', [20 fig.Position(4) - 100 200 30], 'ButtonPushedFcn', @(btn,event) selectBinarizedImage());
    btnSelectGroundTruthIL = uibutton(fig, 'Text', 'Select Ground Truth Image', 'Position', [20 fig.Position(4) - 150 200 30], 'ButtonPushedFcn', @(btn,event) selectGroundTruthImage());
    btnStartIL = uibutton(fig, 'Text', 'Start', 'Position', [20 fig.Position(4) - 200 100 30], 'ButtonPushedFcn', @(btn,event) startProcessing());

    % Axes for displaying results
    axisWidth = (fig.Position(3) - 80) / 3;
    axisHeight = 200;
    axisYPos = fig.Position(4) - 550;

    axBinarizedIL = uiaxes(fig, 'Position', [20 axisYPos axisWidth axisHeight]);
    axGroundTruthIL = uiaxes(fig, 'Position', [40 + axisWidth axisYPos axisWidth axisHeight]);
    axIoUIL = uiaxes(fig, 'Position', [60 + 2 * axisWidth axisYPos axisWidth axisHeight]);

    % Create footer for progress messages
    footerLabel = uilabel(fig, 'Text', 'Ready', 'FontSize', 14, 'Position', [20 10 fig.Position(3) - 40 30], 'HorizontalAlignment', 'left');

    % Variables to store loaded data and state
    binarizedImagePath = '';
    groundTruthImagePath = '';
    isProcessing = false;
    isPaused = false;

    % Nested functions for button callbacks
    function selectBinarizedImage()
        [imageFile, imagePath] = uigetfile({'.jpg;.png;*.bmp'}, 'Select Binarized Masked Image');
        if isequal(imageFile, 0)
            return;
        end
        binarizedImagePath = fullfile(imagePath, imageFile);
        uialert(fig, ['Selected Binarized Masked Image: ', binarizedImagePath], 'Success');
        footerLabel.Text = 'Binarized masked image selected successfully.';
    end

    function selectGroundTruthImage()
        [imageFile, imagePath] = uigetfile({'.jpg;.png;*.bmp'}, 'Select Ground Truth Image');
        if isequal(imageFile, 0)
            return;
        end
        groundTruthImagePath = fullfile(imagePath, imageFile);
        uialert(fig, ['Selected Ground Truth Image: ', groundTruthImagePath], 'Success');
        footerLabel.Text = 'Ground truth image selected successfully.';
    end

    function startProcessing()
        if isempty(binarizedImagePath) || isempty(groundTruthImagePath)
            uialert(fig, 'Please select both the binarized masked image and ground truth image first!', 'Error');
            return;
        end
        isProcessing = true;
        isPaused = false;
        footerLabel.Text = 'Processing... Please wait.';
        processImages(binarizedImagePath, groundTruthImagePath);
    end

    function processImages(binarizedImagePath, groundTruthImagePath)
        binarizedImg = imread(binarizedImagePath);
        groundTruthImg = imread(groundTruthImagePath);

        % Convert to grayscale if necessary
        binarizedImg = im2gray(binarizedImg);
        groundTruthImg = im2gray(groundTruthImg);

        % Resize images to the same size
        targetSize = [size(groundTruthImg, 1), size(groundTruthImg, 2)];
        binarizedImg = imresize(binarizedImg, targetSize);

        % Ensure the images are binary
        binarizedImg = imbinarize(binarizedImg);
        groundTruthImg = imbinarize(groundTruthImg);

        % Calculate IoU
        intersection = binarizedImg & groundTruthImg;
        union = binarizedImg | groundTruthImg;
        IoU = sum(intersection(:)) / sum(union(:));

        % Create IoU image
        IoUImage = double(intersection) * 255;

        % Display images
        imshow(binarizedImg, 'Parent', axBinarizedIL);
        title(axBinarizedIL, 'Binarized Masked Image');
        imshow(groundTruthImg, 'Parent', axGroundTruthIL);
        title(axGroundTruthIL, 'Ground Truth Image');
        imshow(IoUImage, 'Parent', axIoUIL);
        title(axIoUIL, sprintf('IoU Image (IoU = %.2f)', IoU));

        % Save images
        [~, name, ext] = fileparts(binarizedImagePath);
        outputFileNameIoU = fullfile(fileparts(binarizedImagePath), [name, '_iou', ext]);
        imwrite(IoUImage, outputFileNameIoU);

        uialert(fig, 'Processing complete and images saved successfully.', 'Success');
        footerLabel.Text = 'Processing complete and images saved successfully.';
    end
end