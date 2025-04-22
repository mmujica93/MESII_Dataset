clc; clear; format long; close all, fclose all;

%% USER-DEFINED PARAMETERS
Name="PTP_1";                           %Path to the folder containing the RAW data
joint = 1;                              %1 to 7 corresponding to the joint if sequential trajectory. 8 for global trajectory.
plotting=0;                             %if plots want to be made = 1
if_filter = 1;                          %0 for no filter, 1 for filter
freq_filt_butter = 3.5;                 %Butterworth Filter Cut-Off Frequency
nfilt = 2;                              %Butterworth Filter Order
decima = 20;                            %Decimation Parameter 20 for dataset
limit = 0.05;                           %Zero-Velocity Parameter %.05 for dataset
deleted_rows_beginning=100;             %Border Effect Deletion - Number of measurements
deleted_rows_end=100;                   %Border Effect Deletion - Number of measurements
%% FILE READING
directoryName = "./"+Name+"/";
fileIDfts = fopen(directoryName + 'ft_sensor.log','r'); 
fileIDjcp = fopen(directoryName + 'jnt_cmd_position.log','r'); 
fileIDjct = fopen(directoryName + 'jnt_cmd_torque.log','r');
fileIDjet = fopen(directoryName + 'jnt_ext_torque.log','r'); 
fileIDjp = fopen(directoryName + 'jnt_position.log','r');
fileIDjt = fopen(directoryName + 'jnt_torque.log','r');

formatSpec = '%f   %f   %f   %f   %f   %f   %f   %f   #';
xjcp_raw = fscanf(fileIDjcp,formatSpec,[8, inf]);
xjp_raw = fscanf(fileIDjp,formatSpec,[8, inf]);
xjct_raw = fscanf(fileIDjct,formatSpec,[8, inf]);
xjet_raw = fscanf(fileIDjet,formatSpec,[8, inf]);
xjt_raw = fscanf(fileIDjt,formatSpec,[8, inf]);

formatSpec = '%f   %f   %f   %f   %f   %f   %f   #';
xfts_raw = fscanf(fileIDfts,formatSpec,[7, inf]);
%% PARAMETERS
minimum_rows = min([length(xfts_raw),length(xjcp_raw), length(xjct_raw), length(xjet_raw), length(xjp_raw), length(xjt_raw)]);
dt = 1/1000; % Data Sampling Frequency [Hz]
fech = 1/dt;
fnyq = fech/2;
ob = freq_filt_butter/fnyq;
[b,a] = butter(nfilt,ob); 
if (joint==8)
   limit_inf=1;
   limit_sup=7;
else
    limit_inf=joint;
    limit_sup=joint;
end
%% Equal Size and Sign
xjt_raw(2:8,:)=xjt_raw(2:8,:)*-1;
xjet_raw(2:8,:)=xjet_raw(2:8,:)*-1;
xjct_raw(2:8,:)=xjct_raw(2:8,:)*-1;
xfts_raw = xfts_raw(:,1:minimum_rows);
xjcp_raw = xjcp_raw(:,1:minimum_rows);
xjp_raw = xjp_raw(:,1:minimum_rows);
xjct_raw = xjct_raw(:,1:minimum_rows);
xjet_raw = xjet_raw(:,1:minimum_rows);
xjt_raw = xjt_raw(:,1:minimum_rows);

time = xjt_raw(1,:)-xjt_raw(1,1);

if (plotting==1)
    plot7(1,time,xjt_raw(2:8,:),'Raw Torque','time[s]','Torque [N.m]')
    plot7(8,time,xjet_raw(2:8,:),'Raw Ext Torque','time[s]','Torque [N.m]')
    plot7(15,time,xjct_raw(2:8,:),'Raw Cmd Torque','time[s]','Torque [N.m]')
    plot7(22,time,xjcp_raw(2:8,:),'Raw Cmd Position','time[s]','Position [rad]')
    plot7(29,time,xjp_raw(2:8,:),'Raw Position','time[s]','Position [rad]')
end
%% Filtering
if (if_filter==1)
xjcp_filt(1,:)=xjcp_raw(1,:);
xjct_filt(1,:)=xjct_raw(1,:);
xjet_filt(1,:)=xjet_raw(1,:);
xjp_filt(1,:)=xjp_raw(1,:);
xjt_filt(1,:)=xjt_raw(1,:);
xfts_filt(1,:)=xfts_raw(1,:);
 for (i=1:7)
    xjcp_filt(i+1,:) = filtfilt(b,a,xjcp_raw(i+1,:));
    xjct_filt(i+1,:) = filtfilt(b,a,xjct_raw(i+1,:));
    xjet_filt(i+1,:) = filtfilt(b,a,xjet_raw(i+1,:));
    xjp_filt(i+1,:) = filtfilt(b,a,xjp_raw(i+1,:));
    xjt_filt(i+1,:) = filtfilt(b,a,xjt_raw(i+1,:));
    if(i<7)
        xfts_filt(i+1,:) = filtfilt(b,a,xfts_raw(i+1,:));
    end
 end
else
    xjcp_filt=xjcp_raw;
    xjct_filt=xjct_raw;
    xjet_filt=xjet_raw;
    xjp_filt=xjp_raw;
    xjt_filt=xjt_raw;
    xfts_filt=xfts_raw;
end
 
 if (plotting==1)
     plot7(1,time,xjt_filt(2:8,:),'Filtered Torque','time[s]','Torque [N.m]')
     plot7(8,time,xjet_filt(2:8,:),'Filtered Ext Torque','time[s]','Torque [N.m]')
     plot7(15,time,xjct_filt(2:8,:),'Filtered Cmd Torque','time[s]','Torque [N.m]')
     plot7(22,time,xjcp_filt(2:8,:),'Filtered Cmd Position','time[s]','Position [rad]')
     plot7(29,time,xjp_filt(2:8,:),'Filtered Position','time[s]','Position [rad]')
 end


%% SPEEDS AND ACCELERATIONS
for (i=3:length(xjt_filt(1,:))-2)
   dxjcp_filt(2:8,i-1) = (xjcp_filt(2:8,i+1) - xjcp_filt(2:8,i-1))/(time(i+1)-time(i-1));
   dxjct_filt(2:8,i-1) = (xjct_filt(2:8,i+1) - xjct_filt(2:8,i-1))/(time(i+1)-time(i-1));
   dxjet_filt(2:8,i-1) = (xjet_filt(2:8,i+1) - xjet_filt(2:8,i-1))/(time(i+1)-time(i-1));
   dxjp_filt(2:8,i-1) = (xjp_filt(2:8,i+1) - xjp_filt(2:8,i-1))/(time(i+1)-time(i-1));
   %dxjt_filt(2:8,i-1) = (xjt_filt(2:8,i+1) - xjt_filt(2:8,i-1))/(time(i+1)-time(i-1));
   %dxfts_filt(2:8,i-1) = (xfts_filt(2:8,i+1) - xfts_filt(2:8,i-1))/(time(i+1)-time(i-1));
      
   ddxjcp_filt(2:8,i-1) = (xjcp_filt(2:8,i+2) - 2*xjcp_filt(2:8,i)  + xjcp_filt(2:8,i-2))/(4*((time(i+1)-time(i-1))/2)^2);
   ddxjct_filt(2:8,i-1) = (xjct_filt(2:8,i+2) - 2*xjct_filt(2:8,i) + xjct_filt(2:8,i-2))/(4*((time(i+1)-time(i-1))/2)^2);
   ddxjet_filt(2:8,i-1) = (xjet_filt(2:8,i+2) - 2*xjet_filt(2:8,i) + xjet_filt(2:8,i-2))/(4*((time(i+1)-time(i-1))/2)^2);
   ddxjp_filt(2:8,i-1) = (xjp_filt(2:8,i+2) - 2*xjp_filt(2:8,i) + xjp_filt(2:8,i-2))/(4*((time(i+1)-time(i-1))/2)^2);
   %ddxjt_filt(2:8,i-1) = (xjt_filt(2:8,i+2) - 2*xjt_filt(2:8,i) + xjt_filt(2:8,i-2))/(4*((time(i+1)-time(i-1))/2)^2);
   %ddxfts_filt(2:8,i-1) = (xfts_filt(2:8,i+2) - 2*xfts_filt(2:8,i) + xfts_filt(2:8,i-2))/(4*((time(i+1)-time(i-1))/2)^2);
end
xfts_filt(:,1)=[];
xjcp_filt(:,1)=[]; 
xjct_filt(:,1)=[];  
xjet_filt(:,1)=[];  
xjp_filt(:,1)=[]; 
xjt_filt(:,1)=[];
time(1)=[];
lng = length(xjt_filt(1,:));
xfts_filt(:,lng-1:lng)=[];
xjcp_filt(:,lng-1:lng)=[]; 
xjct_filt(:,lng-1:lng)=[];  
xjet_filt(:,lng-1:lng)=[];  
xjp_filt(:,lng-1:lng)=[]; 
xjt_filt(:,lng-1:lng)=[];
time(lng-1:lng)=[];
lng = length(xjt_filt(1,:));

if (plotting==1)
    plot7(36,time,dxjp_filt(2:8,:),'Filtered Speed','time[s]','Speed [rad/s]')
    plot7(43,time,ddxjp_filt(2:8,:),'Filtered Acceleration','time[s]','Acceleration [rad/s^2]')
    plot7(50,time,dxjcp_filt(2:8,:),'Filtered Cmd Speed','time[s]','Speed [rad/s]')
    plot7(57,time,ddxjcp_filt(2:8,:),'Filtered Cmd Acceleration','time[s]','Acceleration [rad/s^2]')
end
%% Border Effect
xfts_filt = xfts_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
xjcp_filt = xjcp_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
xjct_filt = xjct_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
xjet_filt = xjet_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
xjp_filt = xjp_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
xjt_filt = xjt_filt(:,deleted_rows_beginning:lng-deleted_rows_end);

%dxfts_filt = dxfts_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
dxjcp_filt = dxjcp_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
dxjct_filt = dxjct_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
dxjet_filt = dxjet_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
dxjp_filt = dxjp_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
%dxjt_filt = dxjt_filt(:,deleted_rows_beginning:lng-deleted_rows_end);

%ddxfts_filt = ddxfts_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
ddxjcp_filt = ddxjcp_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
ddxjct_filt = ddxjct_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
ddxjet_filt = ddxjet_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
ddxjp_filt = ddxjp_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
%ddxjt_filt = ddxjt_filt(:,deleted_rows_beginning:lng-deleted_rows_end);
time=time(deleted_rows_beginning:lng-deleted_rows_end);

for (i=1:8)
    if (i<8)
        xfts(i,:) = downsample(xfts_filt(i,:),decima);
    end
   xjcp(i,:) = downsample(xjcp_filt(i,:),decima);
   xjct(i,:) = downsample(xjct_filt(i,:),decima);
   xjet(i,:) = downsample(xjet_filt(i,:),decima);
   xjp(i,:) = downsample(xjp_filt(i,:),decima);
   xjt(i,:) = downsample(xjt_filt(i,:),decima);
   
 %  dxfts(i,:) = downsample(dxfts_filt(i,:),decima);
   dxjcp(i,:) = downsample(dxjcp_filt(i,:),decima);
   dxjct(i,:) = downsample(dxjct_filt(i,:),decima);
   dxjet(i,:) = downsample(dxjet_filt(i,:),decima);
   dxjp(i,:) = downsample(dxjp_filt(i,:),decima);
 %  dxjt(i,:) = downsample(dxjt_filt(i,:),decima);
   
 %  ddxfts(i,:) = downsample(ddxfts_filt(i,:),decima);
   ddxjcp(i,:) = downsample(ddxjcp_filt(i,:),decima);
   ddxjct(i,:) = downsample(ddxjct_filt(i,:),decima);
   ddxjet(i,:) = downsample(ddxjet_filt(i,:),decima);
   ddxjp(i,:) = downsample(ddxjp_filt(i,:),decima);
%   ddxjt(i,:) = downsample(ddxjt_filt(i,:),decima);
end
time = downsample(time,decima);
%% ELIMINATION OF 0 SPEED 
for (i = limit_inf:limit_sup)
search = find(abs(dxjp(i+1,:))>=limit);
xfts = xfts(:,search);
xjcp = xjcp(:,search);
xjct = xjct(:,search);
xjet = xjet(:,search);
xjp = xjp(:,search);
xjt = xjt(:,search);

dxjcp = dxjcp(:,search);
dxjct = dxjct(:,search);
dxjet = dxjet(:,search);
dxjp = dxjp(:,search);
%dxjt = dxjt(:,search);
%dxfts = dxfts(:,search);

ddxjcp = ddxjcp(:,search);
ddxjct = ddxjct(:,search);
ddxjet = ddxjet(:,search);
ddxjp = ddxjp(:,search);
%ddxjt = ddxjt(:,search);
%ddxfts = ddxfts(:,search);

time=time(:,search);
end

if (plotting==1)
    plot7(1,time,xjt(2:8,:),'Final Torque','time[s]','Torque [N.m]')
    plot7(8,time,xjet(2:8,:),'Final Ext Torque','time[s]','Torque [N.m]')
    plot7(15,time,xjct(2:8,:),'Final Cmd Torque','time[s]','Torque [N.m]')
    plot7(22,time,xjcp(2:8,:),'Final Cmd Position','time[s]','Position [rad]')
    plot7(29,time,xjp(2:8,:),'Final Position','time[s]','Position [rad]')
    plot7(36,time,dxjp(2:8,:),'Final Speed','time[s]','Speed [rad/s]')
    plot7(43,time,ddxjp(2:8,:),'Final Acceleration','time[s]','Acceleration [rad/s^2]')
    plot7(50,time,dxjcp(2:8,:),'Final Cmd Speed','time[s]','Speed [rad/s]')
    plot7(57,time,ddxjcp(2:8,:),'Final Cmd Acceleration','time[s]','Acceleration [rad/s^2]')
end

dxjcp(1,:)=xjp(1,:);
dxjp(1,:)=xjp(1,:);
ddxjcp(1,:)=xjp(1,:);
ddxjp(1,:)=xjp(1,:);
%% SAVING ON ANOTHER FILE
Name=strcat(Name,'_Filtered')
directoryName = "./"+Name+"/";
mkdir(directoryName)
formatSpec = '%f   %f   %f   %f   %f   %f   %f   %f   #\n';
fileIDjcp = fopen(directoryName + 'jnt_cmd_position.log','w'); 
fileIDjct = fopen(directoryName + 'jnt_cmd_torque.log','w');
fileIDjet = fopen(directoryName + 'jnt_ext_torque.log','w'); 
fileIDjp = fopen(directoryName + 'jnt_position.log','w');
fileIDjt = fopen(directoryName + 'jnt_torque.log','w');
fileIDdjcp = fopen(directoryName + 'jnt_cmd_speed.log','w'); 
fileIDddjcp = fopen(directoryName + 'jnt_cmd_accel.log','w'); 
fileIDdjp = fopen(directoryName + 'jnt_speed.log','w');
fileIDddjp = fopen(directoryName + 'jnt_accel.log','w');
formatSpec = '%f   %f   %f   %f   %f   %f   %f   #\n';
fileIDfts = fopen(directoryName + 'ft_sensor.log','w'); 


fprintf(fileIDfts,formatSpec,xfts);
fprintf(fileIDjcp,formatSpec,xjcp);
fprintf(fileIDjct,formatSpec,xjct);
fprintf(fileIDjet,formatSpec,xjet);
fprintf(fileIDjp,formatSpec,xjp);
fprintf(fileIDjt,formatSpec,xjt);
fprintf(fileIDdjcp,formatSpec,dxjcp);
fprintf(fileIDddjcp,formatSpec,ddxjcp);
fprintf(fileIDdjp,formatSpec,dxjp);
fprintf(fileIDddjp,formatSpec,ddxjp);


save(Name +'.mat', 'xfts', 'xjcp','xjct','xjet','xjp','xjt','dxjcp','dxjp','ddxjcp','ddxjp');