clc, clear, close all;

%% USER-DEFINED PARAMETERS
Name = "C:\Users\Fabio\Nextcloud\DataSet\Standalone\Robot_identification\Sequential\Inertia\J4\Sequential_Joint_4_Inertia_Filtered";

%%
load(Name);
load('YNfunct.mat');
load('PARAMS');
ddxjp = ddxjp(2:8,:);
dxjp = dxjp(2:8,:);
xjp = xjp(2:8,:);
ddxjcp = ddxjcp(2:8,:);
dxjcp = dxjcp(2:8,:);
xjcp = xjcp(2:8,:);
xjt = xjt(2:8,:);
xjct = xjct(2:8,:);
count = length(xjt(1,:));
tic
for (i=1:count)
    YY(:,:,i) = YNfunct(ddxjp(1,i), ddxjp(2,i), ddxjp(3,i), ddxjp(4,i), ddxjp(5,i), ddxjp(6,i), ddxjp(7,i),...
        dxjp(1,i), dxjp(2,i), dxjp(3,i), dxjp(4,i), dxjp(5,i),dxjp(6,i), dxjp(7,i),...
        xjp(2,i), xjp(3,i), xjp(4,i), xjp(5,i), xjp(6,i), xjp(7,i));
    YYC(:,:,i) = YNfunct(ddxjcp(1,i), ddxjcp(2,i), ddxjcp(3,i), ddxjcp(4,i), ddxjcp(5,i), ddxjcp(6,i), ddxjcp(7,i),...
        dxjcp(1,i), dxjcp(2,i), dxjcp(3,i), dxjcp(4,i), dxjcp(5,i),dxjcp(6,i), dxjcp(7,i),...
        xjcp(2,i), xjcp(3,i), xjcp(4,i), xjcp(5,i), xjcp(6,i), xjcp(7,i));
    disp(i + "/" + count + "; " + toc + " secs (" + i/count*100 + "%)"+ ", REMAINING: " + ((toc*count/i)-toc)/60/60 + " hs" );
end

save(strcat(Name,'_all') +'.mat', 'xjct','xjcp','xjet','xjp','xjt','dxjcp','dxjet','dxjp','dxjt','ddxjcp','ddxjet','ddxjp','ddxjt','YY','YYC','PARAMS');