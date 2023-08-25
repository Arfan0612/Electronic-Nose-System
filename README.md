# Introduction
The research's aim is to develop an e-nose system to determine fruit ripeness, crucial for assessing shelf life. Different fruit aromas are linked to their ripeness levels. MATLAB is used for data collection, 
focusing on bananas, mangoes, and tomatoes at unripe, ripe, and overripe stages. MATLAB's user-friendly add-on assists in building classification models, employing machine learning algorithms like decision 
trees and support vector machines.

# Methodology
The stages taken in this research can be summarized into 4 categories:
- Data Acquisition
- Data preparation
- Machine Learning
- Evaluation

# Folders
### Classification Session
This folder includes the different MATLAB session to test a total of 11 combination of features to get the ideal data input for training.

### Datasets for model
This folder contains raw and preprocessed datasets with each dataset containing the features such as mean, RMS, skew, etc.
The prepocessed worflow picture is also included in this folder. The datasets are split into 20% training and 80% testing.

### Gathered Data in Excel
This folder contains exact values obtained gas sensor during data collection with the fruits in the gas chamber.
- Acquire_Arduino_Data.m contains the code used to do data collection using an Arduino MEGA.
- Refer to ABBREVIATION MEANING text file to know which fruit each dataset is for

### Plotted graphs and Subplot graphs
These folders just contain the visual representation of the sensor response during data collection where:
- Plotted graphs showcases all 11 gas sensor response in one graph
- Subplot graphs shows each sensors individual responses
- Refer to ABBREVIATION MEANING text file to know which fruit each dataset is for


