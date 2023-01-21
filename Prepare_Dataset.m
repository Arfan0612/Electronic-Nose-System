retry = 'y';

while retry == 'y'
    %clear previous session's memory
    clear
    clc

    %set max number of samples to extract from file 
    maxrows = 1:840;

    training_model = 'C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Datasets for Model\Training Dataset';
    testing_model = 'C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Datasets for Model\Testing Dataset';
    graph_directory1 = 'C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Datasets for Model\Plot Figures\Raw Figures\';
    graph_directory2 = 'C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Datasets for Model\Plot Figures\Preprocessed Figures\';

    %creating common directory where raw data is stored
    directory = 'C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Gathered Data in Excel\';
    fileType = '.xlsx';

    %Ask user if want to prepare training or testing dataset
    decision = input('Dataset Preparation? (1:Training | 2:Testing) ');
    choice = input('1:Raw data or 2:Preprocessed data |  ');
    filename = input('Filename: ','s');
    
    %N determines number of sheets to be read
    N = input('Number of Sheet: ');

    %call function to determine the fruit and its ripeness based on
    %filename
    fruit_type = determineFruit(filename);

    for loop = 1:1:N
        
        %ask user for specific sheet to be read from the Excel file
        sheet_number = input('\nSheet Number: ');
        Openfile = readmatrix(strcat(directory, filename, fileType), "Sheet", sheet_number);

        %organize the read file into different sensor data
        %reduce the noise of the signal of each sensor response
        Time = Openfile(maxrows,1);
        MQ2 = Openfile(maxrows,2);
        MQ3 = Openfile(maxrows,3);
        MQ4 = Openfile(maxrows,4);
        MQ5 = Openfile(maxrows,5);
        MQ6 = Openfile(maxrows,6);
        MQ7 = Openfile(maxrows,7);
        MQ8 = Openfile(maxrows,8);
        MQ9 = Openfile(maxrows,9);
        MQ135 = Openfile(maxrows,10);
        MQ136 = Openfile(maxrows,11);
        MQ138 = Openfile(maxrows,12);

            
        %create matrix of all 11 sensor responses
        data_table = [MQ2,MQ3,MQ4,MQ5,MQ6,MQ7,MQ8,MQ9,MQ135,MQ136,MQ138];
        
        %check if user wants to do preprocessing on signals
        %raw data 
        if (decision == 1 && choice == 1)
            %create directory for saving figures into raw data figures file
            Plotdirectory = strcat(graph_directory1,string(fruit_type),'.',string(sheet_number),".png");

            %plot the raw data graph and save it
            graphing(Plotdirectory,data_table);

        %preprocessed data
        elseif (decision == 1 && choice == 2)
            %perform signal pre-processing on all 11 sensor responses
            data_table = preprocess(data_table);

            %create directory for saving figures into preprocesed data figures file
            Plotdirectory = strcat(graph_directory2,string(fruit_type),'.',string(sheet_number),".png");

            %plot the preprocesed data graph and save it
            graphing(Plotdirectory,data_table);
        end

        %extract features from each sensor response
        %round the feature's value to 3 decimal places
        feature_extracted = round(featureExtract(data_table),3);

        %assign appropiate target
        target = fruit_type;
        
        %create array that combines features and classifier
        final_array = [feature_extracted,target];

        %export data to a specified spreadsheet
        %readExport(decision, choice, training_model, testing_model, final_array);

    end

    %ask if user want to do another Excel file
    retry = input("\nDo you want to continue? ",'s');
end


%function definition--------------------------
function fruit = determineFruit(fruit_type)
    if (fruit_type == "CA")
        fruit = 0;

    elseif(fruit_type == "CURB")
        fruit = 1;
 
    elseif (fruit_type == "CRB")
        fruit = 2;
    
    elseif (fruit_type == "CORB")
        fruit = 3;

    elseif (fruit_type == "CURM")
        fruit = 4;

    elseif (fruit_type == "CRM")
        fruit = 5;

    elseif (fruit_type == "CORM")
        fruit = 6;

    elseif (fruit_type == "CURT")
        fruit = 7;

    elseif (fruit_type == "CRT")
        fruit = 8;

    elseif (fruit_type == "CORT")
        fruit = 9;

    else
        fruit = 10;

    end

end

function postprocessed = preprocess(preprocessed)
    %step 1: wavelet signal denoising
    processed_1 = wdenoise(preprocessed, 9, ...
                    'Wavelet', 'sym4', ...
                    'DenoisingMethod', 'Bayes', ...
                    'ThresholdRule', 'Median', ...
                    'NoiseEstimate', 'LevelIndependent');

    %step 2: Outlier Removal using Hampel Filter
    processed_2 = hampel(processed_1);

    %step 3: Smoothing the data
    processed_3 = smoothdata(processed_2,'gaussian');

    postprocessed = processed_3;
end

function features = featureExtract(table)
    %Average value in sensor responses
    sub_feature1 = mean(table);

    %RMS value in sensor responses
    sub_feature2= rms(table);

    %Standard Deviation in sensor responses
    sub_feature3 = std(table);
    
    %Peak-magnitude to RMS ratio in sensor responses
    %intialize array to temporary store feature
    sub_feature4 = zeros(1,11);
    for m = 1:1:11
        sub_feature4(m) = peak2rms(table(:,m));
    end

    %Skewness of each sensor response
    sub_feature5 =  skewness(table);

%     disp(table);
%     disp(sub_feature1);
%     disp(sub_feature2);
%     disp(sub_feature3);
%     disp(sub_feature4);
%     disp(sub_feature5);

    features = [sub_feature1,sub_feature2,sub_feature3,sub_feature4,...
        sub_feature5];

end

function readExport(decision, choice, training_model, testing_model, table)
    mean_header = ["Mean_MQ-2","Mean_MQ-3","Mean_MQ-4","Mean_MQ-5","Mean_MQ-6","Mean_MQ-7",...
        "Mean_MQ-8","Mean_MQ-9","Mean_MQ-135","Mean_MQ-136","Mean_MQ-138"];

    RMS_header = ["RMS_MQ-2","RMS_MQ-3","RMS_MQ-4","RMS_MQ-5","RMS_MQ-6","RMS_MQ-7","RMS_MQ-8",...
        "RMS_MQ-9","RMS_MQ-135","RMS_MQ-136","RMS_MQ-138"];

    Std_header = ["Std_MQ-2","Std_MQ-3","Std_MQ-4","Std_MQ-5","Std_MQ-6","Std_MQ-7","Std_MQ-8",...
        "Std_MQ-9","Std_MQ-135","Std_MQ-136","Std_MQ-138"];

    Peak2rms_header = ["Peak2RMS-2","Peak2RMS-3","Peak2RMS-4","Peak2RMS-5","Peak2RMS-6","Peak2RMS-7","Peak2RMS-8",...
        "Peak2RMS-9","Peak2RMS-135","Peak2RMS-136","Peak2RMS-138"]; 

    skew_header = ["Skew_MQ-2","Skew_MQ-3","Skew_MQ-4","Skew_MQ-5","Skew_MQ-6","Skew_MQ-7","Skew_MQ-8",...
        "Skew_MQ-9","Skew_MQ-135","Skew_MQ-136","Skew_MQ-138"];

    classifier_header = "Classifier";

    header = [mean_header,RMS_header,Std_header,Peak2rms_header,skew_header,classifier_header];

    %adjust directory according to if user want to export Raw or
    %Preprocessed data
    if(choice == 1)
        training_model = strcat(training_model,'_Raw.xlsx');
        testing_model = strcat(testing_model,'_Raw.xlsx');
        
    elseif (choice == 2)
        training_model = strcat(training_model,'_Preprocessed.xlsx');
        testing_model = strcat(testing_model,'_Preprocessed.xlsx');
    end

    %determine if user wants to add to either training or testing dataset
    if (decision == 1)
        %read file
        %check if file is empty
        empty = isempty(readmatrix(training_model));

        %if empty, headers will be inputed
        if (empty==1)
            writematrix(header,training_model);
        end

        %export dataset and append to Training dataset Excel file
        writematrix(table,training_model,"WriteMode", "append");

    elseif(decision == 2)
        %read file
        %check if file is empty
        empty = isempty(readmatrix(testing_model));
        
        %if empty, headers will be inputed
        if (empty==1)
            writematrix(header,testing_model);
        end

        %export dataset and append to Testing dataset Excel file
        writematrix(table, testing_model, "WriteMode", "append");
    end
    
end

function graphing(Plotdirectory,table)
    for i = 1:1:11
        %create tile styled plot
        nexttile

        %plot colomn by colomn
        plot(table(:,i));

        %deciding title of each subplot
        if (i==1)
            title('MQ-2');
        elseif (i==2)
            title('MQ-3');
        elseif (i==3)
            title('MQ-4');
        elseif(i==4)
            title('MQ-5');
        elseif(i==5)
            title('MQ-6');
        elseif(i==6)
            title('MQ-7');
        elseif(i==7)
            title('MQ-8');
        elseif(i==8)
            title('MQ-9');
        elseif(i==9)
            title('MQ-135');
        elseif(i==10)
            title('MQ-136');
        elseif(i==11)
            title('MQ-138');
        end
    end

    %exporting plotted graph as png
    f = gcf; %to get the current figure and assign to 'f'
    %exportgraphics(f,Plotdirectory); %export the plot
end

