clc,clear,close all;

%%
Name = "./Sequential_Joint_4_Inertia_Filtered_all.mat";
std_limit=20; %Relative standard deviation threshold to consider as essential parameters. 


%%
load(Name)
load('PARAMS.mat');
torq= xjt(4,:)';
YY = squeeze(YY(4,25:64,:))';

[Q,R,P]=qr(YY,0);
disp(strcat('RANK: ', num2str(rank(Q*R)), '/', num2str(length(YY(1,:)))));

KnewParams= [       string('I5XXR'), 0;
     string('I5ZZR'), 0;
     string('I5XY'), 0;
     string('I5XZ'), 0;
     string('I5YZ'), -0.00137;
     string('M5X'), 0;
     string('M5YR'), -0.0882;
     string('FS5'), 0;
     string('FV5'), 0;
     string('TOFF5'), 0;
     string('I6XXR'), 0.0190;
     string('I6ZZR'),0.0141;
     string('I6XY'),0;
     string('I6XZ'),0.0038;
     string('I6YZ'),0.0055;
     string('M6X'),-0.0043;
     string('M6YR'),-0.1180;
     string('FS6'), 0;
     string('FV6'), 0;
     string('TOFF6'), 0;
     string('I7XXR'),0;
     string('I7ZZ'), 0;
     string('I7XY'), 0;
     string('I7XZ'), 0;
     string('I7YZ'), 0;
     string('M7X'), 0;
     string('M7Y'), 0;
     string('FS7'), 0;
     string('FV7'), 0;
     string('TOFF7'), 0;
];

PARAMS_4=PARAMS(25:64);
PARAMS_original = PARAMS_4;
PARAMS_complet=zeros(length(PARAMS_original),1);

torq_original = torq;
YY_original = YY;

if(~isempty(KnewParams))
    for(i=1:length(KnewParams(:,1)))
        r=KnewParams(i,1)==arrayfun(@char, PARAMS_4, 'uniform', 0);
        order(i)=find(r==1);
    end
    [order,I]=sort(order);KnewParams=KnewParams(I,:);
    for (i=length(order):-1:1)
        torq = torq - YY(:,order(i))*str2double(KnewParams(i,2));
        YY(:,order(i))=[];
    end
    PARAMS_4(order)=[];
    PARAMS_complet(order)=KnewParams(:,2);
end
YY(:,3:6)=[];
YY(:,1)=[];
PARAMS_4(3:6)=[];
PARAMS_4(1)=[];
tita_LS = (YY'*YY)\YY'*torq; %SOLUTION
std_dev = est_std_dev(YY,tita_LS,torq)';
while(1)
    [val, idx] = max(abs(std_dev));
    if (val>std_limit)
        YY(:,idx)=[];     
        PARAMS_4(idx)=[];
        tita_LS=(YY'*YY)\YY'*torq;
        std_dev = est_std_dev(YY,tita_LS,torq);
    else
        break;
    end
end

disp (['PARAMETER||||Estimation||||STDE']);
for(i=1:length(PARAMS_4))
    disp(['Est ' , string(i), ': ', string(PARAMS_4(i)), ' |||| ', num2str(tita_LS(i)), ' |||| ', num2str(std_dev(i))]);
end

for (i=1:length(tita_LS))
    for(j=1:length(PARAMS_original))
       if(isequaln(PARAMS_original(j),PARAMS_4(i)))
           PARAMS_complet(j)=tita_LS(i);
           break;
       end
    end
end


figure
plot(torq_original)
hold on
plot(YY_original*PARAMS_complet)
grid on;
legend('Measured Torque','Reconstructed Torque')
title(strcat('Joint 4 Torque Reconstruction. Percent Error:',num2str(100*norm(torq_original-YY_original*PARAMS_complet,2)/norm(torq_original,2)),'%'),'FontSize',14)
disp (['Condition Number: ', num2str(cond(YY))]);
xlabel('Measurements','FontSize',13)
ylabel('Torque[Nm]','FontSize',13)
