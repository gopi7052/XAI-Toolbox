# XAI Toolbox for User-Friendly GUI-Based Grad-CAM and LIME [MATLAB]


![MATLAB_Tool_Methodology-1](https://github.com/user-attachments/assets/e3a8b282-c039-4daa-990d-c3fbddf690d2)

## Description
Deep learning researchers primarily focus on developing models with high accuracy, often neglecting the for decision-making whether the model is considering significant features. A model that does not consider significant features for its decisions is not reliable, even if it achieves high accuracy, as it may be basing its predictions on irrelevant or spurious features. Explainable AI (XAI) techniques help researchers make the decision-making process transparent by visualizing the features a model considers when making decisions, which in turn helps identify models that are both accurate and reliable. However, the emphasis on accuracy over reliability by researchers arises from a lack of awareness and lack of coding expertise to implement XAI techniques in experimentation, and difficulties in interpreting the XAI model output.

To raise awareness of the need for explainability and support researchers with limited coding expertise, we developed a MATLAB toolbox to generate Gradient-weighted Class Activation Mapping (Grad-CAM) and Local Interpretable Model-Agnostic Explanations (LIME) visualizations through user-friendly interfaces with adjustable parameters. This toolbox makes XAI techniques accessible to a wide variety of users. Additional features of this toolbox include the generation of visualizations for multiple images and options for qualitative and quantitative analyses of a model decision-making process. With the help of this toolbox, the field of ecology can better leverage deep learning while maintaining trust and reliability. This toolbox can be used in other fields, such as biology, healthcare, agriculture, industrial automation, environmental science, and remote sensing, where understanding model decisions is crucial.
![download (1)](https://github.com/user-attachments/assets/4c1ab51c-e4e7-4aaf-a80b-95b246b17dc4)
## Purpose
We designed this MATLAB toolbox for visualizing Grad-CAM and LIME explanations, simplifying interpretability for researchers with limited coding skills. Our toolbox enables users to create visualizations through an intuitive interface, facilitating the interpretation of model predictions without deep programming expertise. It includes essential features for generating Grad-CAM and LIME visuals with customizable parameters. Tutorials and examples are provided to aid users in mastering the toolbox's capabilities.


## Training and Saving a Model for Analysis
Pretrained or custom models in MATLAB can be used to train and save a deep learning model. For training pretrained models such as AlexNet, ResNet, or GoogleNet, the models are loaded and trained on selected dataset. For training custom models, a neural network architecture is defined layer by layer by the user and trained on a selected dataset. In both scenarios, training options such as the learning rate and number of epochs must be established. During model training, model performance is monitored using validation data. Upon achieving satisfactory performance after training, the trained model can be saved as a .mat file. This file contains the architecture and the learned weights information related to the trained network. This .mat file can be used for predictions or further training without starting from scratch. In this study, this file is used as the main input for functions in our toolbox in the process of generating Grad-CAM and LIME visualizations. A detailed description of these two training approaches is presented in the following subsections.

### Training and Saving a Pretrained Deep Learning Model
This approach is commonly referred to as transfer learning. To train and save a pretrained deep learning model on a specific data set, the following steps have to be followed  in MATLAB. Initially, a pretrained model has to be loaded. The data in the data set have to be organized into folders, with each folder representing a different class. While reading the data, the dataset has to be split into training and validation sets and pre-processed to resize the images to match the input size requirements of the model. For fine-tuning, the initial layers of the pretrained network need to be frozen to retain their learned features, and only the last few layers need to be trained. This is done by setting the learnable property of the initial layers to false. In addition, new layers can be added to the network to better fit the specifics of the dataset. For example, dropout layers might be added to prevent overfitting or additional fully connected layers to enhance learning capacity. The final layers of the model need to be modified to align it with the number of classes in the data set. 

The training parameters, such as learning rate, mini-batch size, number of epochs, and validation frequency, need to be set. For example, a learning rate of 0.001, a mini-batch size of 32, 10 epochs, and a validation check every 30 iterations might be used. After the parameters are set manually, the model is trained using these settings and the data. Hyperparameter tuning is the process of selecting the best set of hyperparameters for a machine learning model to optimize model performance, improve accuracy, reduce overfitting, and speed up convergence. Once training is complete, model performance is evaluated with validation data. Finally, the trained model is saved as a .mat file. This trained and saved model can be utilized as input for functions in our toolbox to create Grad-CAM and LIME visualizations.



### Creating and Training a Custom Deep Learning Model

If users prefer to create a custom model from scratch, they can build and train their own neural network. The architecture of the custom model must be defined layer by layer, specifying layers such as convolutional, ReLU, pooling, fully connected, and softmax layers. The parameters of each layer have to be customized according to the specific needs. The data set has to be organized and pre-processed by splitting it into training and validation sets. Images are resized to match the input size of the custom model. Training options are set to control the learning process, just as with a pretrained model. After the network is defined and the data is prepared, custom model training is initiated using the specified training options. The performance of the model is monitored during training using validation data and adjustments are made to the network if necessary. Upon achieving satisfactory performance, the trained custom model is saved as a \texttt{.mat} file. 

## Features
Here are the features provided by each script:
1. Single Image Processing: Allows users to process one image at a time using Grad-CAM and LIME techniques (single_gradCAM_LIME_UI.m).
2. Batch Image Processing: Supports the processing of multiple images in a batch using Grad-CAM and LIME techniques (bulk_gradCAM_LIME_UI.m).
3. Masked LIME Explanations: Generates LIME explanations with masked regions (masked_LIME_UI.m).
4. IoU Calculation: Computes the Intersection over Union (IoU) metric between a binarized image and a ground truth image (iou_calculation_UI.m).

## Usage

![Screenshot 2024-09-06 150812](https://github.com/user-attachments/assets/e5d71f07-809c-4412-ba4b-cbc7ac496316)

   
## Screenshots:
Beyond its utility in interpreting model decisions, our toolbox extends its value to diverse fields like healthcare, agriculture, and remote sensing. These areas benefit greatly from an enhanced understanding of model reasoning. Researchers in these domains can leverage our toolbox to gain insights into complex models and improve decision-making processes. With user-friendly tools and educational resources, our aim is to democratize the use of interpretability techniques, fostering broader adoption and innovation across scientific disciplines.




![download](https://github.com/user-attachments/assets/2af4dca1-1e0e-4fb1-ac96-9d6368c10016)



## Authors
1. Hari Kishan Kondaveeti, Ph.D
         2. Chinna Gopi Simhadri, (Ph.D)
