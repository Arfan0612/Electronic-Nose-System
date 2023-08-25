%clear previous session's work
clear
clc

%arduinosetup(); %to setup the board again

%-------------------------------------------------Setup function
N = 1; %data collector counter
Maxdata = 300;  % pre-allocate memory 
MaxTime = 1200; % 20 minutes
warmup_time = 900; % 15 minutes
prep_fruit = 15; % 15 seconds for fruit to prep into chamber

%Directory of Excel folder
Excel = 'C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Gathered Data in Excel\';
ExcelType = '.xlsx';
 
%Directory of Plot folder
Plot = 'C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Plotted graphs\';
PlotType = '.png';

%sum for humidity and temperature
%to find average for each testing 
humidity = zeros(Maxdata,1,'double');
temperature = zeros(Maxdata,1,'double');

%initializing arduino board object 
a = arduino("COM7","Mega2560","Libraries","Adafruit/DHTxx");
    
%initialize the DHT22 sensor object 
sensor = addon(a, 'Adafruit/DHTxx', 'D7','DHT22');

%store time
time = 0;
%array to store timer
stoptime = zeros(Maxdata,1,'double');

%store each mq sensor values in its own array
%use array of zeroes to preallocate memory
a2 = zeros(Maxdata,1,'double');
a3 = zeros(Maxdata,1,'double');
a4 = zeros(Maxdata,1,'double');
a5 = zeros(Maxdata,1,'double');
a6 = zeros(Maxdata,1,'double');
a7 = zeros(Maxdata,1,'double');
a8 = zeros(Maxdata,1,'double');
a9 = zeros(Maxdata,1,'double');
a135 = zeros(Maxdata,1,'double');
a136 = zeros(Maxdata,1,'double');
a138 = zeros(Maxdata,1,'double');

%-------------------------------------------------main function

%Ask for user input
filename1 = input('Excel Filename: ','s'); %name of excel file
sheet = input('Sheet No: '); %specify what sheet in a Excel File
filename2 = input('Graph Name: ','s'); %name of plot picture

%asking if user wants to warm-up the sensors
fprintf('\nDo you want to warm-up? 1:Yes | 2:No')
warmup = input('\n');

%create full directory
Exceldirectory = strcat(Excel,filename1,ExcelType);
Plotdirectory = strcat(Plot,filename2,PlotType); 

%-------------------------------------------------loop function
while (1)
    if (time<MaxTime)
        %read DHT22 sensor
        temperature(N) = readTemperature(sensor);
        humidity(N) = readHumidity(sensor);

        tic %start timer

        %reading sensor voltage of each sensor
        %set to 2 decimal places for each sensor voltage%.2f
        mq2 = round(a.readVoltage('A10'),2);
        mq3 = round(a.readVoltage('A8'),2);
        mq4 = round(a.readVoltage('A6'),2);
        mq5 = round(a.readVoltage('A5'),2);
        mq6 = round(a.readVoltage('A2'),2);
        mq7 = round(a.readVoltage('A1'),2);
        mq8 = round(a.readVoltage('A0'),2);
        mq9 = round(a.readVoltage('A9'),2);
        mq135 = round(a.readVoltage('A7'),2);
        mq136 = round(a.readVoltage('A4'),2);
        mq138 = round(a.readVoltage('A3'),2);
        
        pause(1);%delay 1 seconds before next step
        currentTime = toc; %stop timer and record

        time = time + round(currentTime,2);% timer between sensor input
        
        %if statement to see if user wanted to warm-up sensors
        %and if the time is more than warm-up time or not 
        if(warmup == 1 && (time <= warmup_time))
            %printing time before warmup ends
            fprintf('Sensor has warmed up for %.2fs\n',time);
        else
            %purpose of if statement is to set the first set of inputs at 0 seconds
            %due to delay start of around 2 seconds everytime first time run
            if(N == 1)
                fprintf('\nExperiment will start in %d seconds!!\n',prep_fruit);
                pause(prep_fruit);
                warmup = 2; %change so that the program knows it doesnt need to warm-up anymore
                time = 0; %reset timer for actual time in the experiment
                stoptime(N) = 0.00; 
            else
                %put the time into an array 
                stoptime(N) = time;
            end
            
            %replace the zeros in each index in an array
            a2(N) = mq2;
            a3(N) = mq3;
            a4(N) = mq4;
            a5(N) = mq5;
            a6(N) = mq6;
            a7(N) = mq7;
            a8(N) = mq8;
            a9(N) = mq9;
            a135(N) = mq135;
            a136(N) = mq136;
            a138(N) = mq138; 
            
            %print values onto command window 
            printvalue(N,time,temperature(N),humidity(N),mq2,mq3,mq4,mq5,mq6,mq7,mq8,mq9,mq135,mq136,mq138);

            N = N+1; %increment sample data collected
        end

    else
        N = N-1; %minus 1 due to bug in indexing for total collected data per sensor
        break    
    end

end

%find average humidity and temperature for each testing and print end
%message
[temp, humi] = weather_summary(N,temperature,humidity);

%call function to export raw data into Excel
toExcel(Exceldirectory,sheet,stoptime,a2,a3,a4,a5,a6,a7,a8,a9,a135,a136,a138);

%call function to make the graph of sensor voltage vs time
graphing(Plotdirectory,stoptime,a2,a3,a4,a5,a6,a7,a8,a9,a135,a136,a138,temp,humi);

%call function to make subplots of each sensor into a singular folder
subplots(filename2,PlotType,stoptime,a2,a3,a4,a5,a6,a7,a8,a9,a135,a136,a138);

%clear the board object created
clear sensor
clear a


%---------------------------Function definition after program 

function printvalue(N,time,temperature,humidity,mq2,mq3,mq4,mq5,mq6,mq7,mq8,mq9,mq135,mq136,mq138)
    %printing values of sensor on command window
    fprintf("Data: %d\n",N);
    fprintf("Time: %.2f s\n",time);
    fprintf('Temperature: %.2f °C\n', temperature);
    fprintf('Humidity: %.2f %% \n', humidity);
    fprintf("MQ-2: %.2f\n", mq2);
    fprintf("MQ-3: %.2f\n", mq3);
    fprintf("MQ-4: %.2f\n", mq4);
    fprintf("MQ-5: %.2f\n", mq5);
    fprintf("MQ-6: %.2f\n", mq6);
    fprintf("MQ-7: %.2f\n", mq7);
    fprintf("MQ-8: %.2f\n", mq8);
    fprintf("MQ-9: %.2f\n", mq9);
    fprintf("MQ-135: %.2f\n", mq135);
    fprintf("MQ-136: %.2f\n", mq136);
    fprintf("MQ-138: %.2f\n", mq138); 
    fprintf("\n");
end

function [temp, humi] = weather_summary(N,temperature,humidity)
    %remove 'Nan' values from array
    temperature = rmmissing(temperature);
    humidity = rmmissing(humidity);

    %calculate average over N number of data 
    temp = round(mean(temperature),1);
    humi = round(mean(humidity),1);

    %print end messages
    fprintf('------------------------------------------\n');
    fprintf('Program Summary\n');
    fprintf('------------------------------------------\n');
    fprintf('Data collected: %d\n',N);
    fprintf("Average Temperature: %.2f °C\n",temp);
    fprintf("Average Humidity: %.2f %%\n",humi);

end

function toExcel(Exceldirectory,sheet,stoptime,a2,a3,a4,a5,a6,a7,a8,a9,a135,a136,a138)
    %array of headers to be inputed in Excel file
    header = ["Time(s)","MQ-2(V)","MQ-3(V)","MQ-4(V)","MQ-5(V)","MQ-6(V)","MQ-7(V)","MQ-8(V)","MQ-9(V)","MQ-135(V)","MQ-136(V)","MQ-138(V)"];
    
    %write the header in the Excel file 
    writematrix(header, Exceldirectory,"Sheet",sheet);
    
    %write time and sensors voltage in the Excel file
    %different sensor is input in different colomn
    %written on the 'sheet' of the Excel file
    writematrix(stoptime,Exceldirectory,'Sheet',sheet,'Range','A2');
    writematrix(a2,Exceldirectory,'Sheet',sheet,'Range','B2');
    writematrix(a3,Exceldirectory,'Sheet',sheet,'Range','C2');
    writematrix(a4,Exceldirectory,'Sheet',sheet,'Range','D2');
    writematrix(a5,Exceldirectory,'Sheet',sheet,'Range','E2');
    writematrix(a6,Exceldirectory,'Sheet',sheet,'Range','F2');
    writematrix(a7,Exceldirectory,'Sheet',sheet,'Range','G2');
    writematrix(a8,Exceldirectory,'Sheet',sheet,'Range','H2');
    writematrix(a9,Exceldirectory,'Sheet',sheet,'Range','I2');
    writematrix(a135,Exceldirectory,'Sheet',sheet,'Range','J2');
    writematrix(a136,Exceldirectory,'Sheet',sheet,'Range','K2');
    writematrix(a138,Exceldirectory,'Sheet',sheet,'Range','L2');
end

function graphing(Plotdirectory,stoptime,a2,a3,a4,a5,a6,a7,a8,a9,a135,a136,a138,temp,humi)
    %convert humidity and temperature to a string for printing
    temp = string(temp);
    humi = string(humi);
    %create the subtitle for humidity and temperature
    sub = strcat('Average °C = ',temp,'    Average % = ',humi);

    %plot the graph 
    plot(stoptime,a2,'-r');
    hold on %used to plot more than one graph
    plot(stoptime,a3,'-g');
    plot(stoptime,a4,'-b');
    plot(stoptime,a5,'-c');
    plot(stoptime,a6,'-m');
    plot(stoptime,a7,'-y');
    plot(stoptime,a8,'-k');
    plot(stoptime,a9,'-s');
    plot(stoptime,a135,'b-o');
    plot(stoptime,a136,'-*');
    plot(stoptime,a138,'-d');
    hold off %after finishing the plotting

    %necessary labelling of the graph
    grid on;
    title('Sensor Voltage vs Time');
    subtitle(sub);
    xlabel('Time elapsed (s)'); %x-labelling
    ylabel('Sensor Voltage (V)'); %y-labelling
    legend('MQ-2','MQ-3','MQ-4','MQ-5','MQ-6','MQ-7','MQ-8','MQ-9','MQ-135','MQ-136','MQ-138');

    %exporting plotted graph as png
    f = gcf; %to get the current figure and assign to 'f'
    exportgraphics(f,Plotdirectory); %export the plot
end

function subplots(filename2,PlotType,stoptime,a2,a3,a4,a5,a6,a7,a8,a9,a135,a136,a138)
    %setting to correct directory and making a new folder
    subplot_directory = strcat('C:\Users\Arfan Danial\OneDrive - University of Nottingham Malaysia\Summer 2022\Summer Research Intern Essentials\Subplot graphs\',filename2);
    mkdir(subplot_directory);
    
    plot(stoptime,a2,'-r');
    f = gcf;
    exportgraphics(f,strcat(subplot_directory,'\MQ-2',PlotType));

    plot(stoptime,a3,'-g');
    exportgraphics(f,strcat(subplot_directory,'\MQ-3',PlotType));

    plot(stoptime,a4,'-b');
    exportgraphics(f,strcat(subplot_directory,'\MQ-4',PlotType));

    plot(stoptime,a5,'-c');
    exportgraphics(f,strcat(subplot_directory,'\MQ-5',PlotType));

    plot(stoptime,a6,'-m');
    exportgraphics(f,strcat(subplot_directory,'\MQ-6',PlotType));

    plot(stoptime,a7,'-y');
    exportgraphics(f,strcat(subplot_directory,'\MQ-7',PlotType));
    
    plot(stoptime,a8,'-k');
    exportgraphics(f,strcat(subplot_directory,'\MQ-8',PlotType));

    plot(stoptime,a9,'-s');
    exportgraphics(f,strcat(subplot_directory,'\MQ-9',PlotType));

    plot(stoptime,a135,'b-o');
    exportgraphics(f,strcat(subplot_directory,'\MQ-135',PlotType));

    plot(stoptime,a136,'-*');
    exportgraphics(f,strcat(subplot_directory,'\MQ-136',PlotType));

    plot(stoptime,a138,'-d');
    exportgraphics(f,strcat(subplot_directory,'\MQ-138',PlotType));
end 

