function [y] = est_std_dev(Y,Xi,torq)
buf=norm((torq-Y*Xi),2)^2/(length(Y(:,1))-length(Xi));
C=buf*inv(Y'*Y);
for (i=1:length(C))
    y(i)=100*(sqrt(C(i,i))/abs(Xi(i)));
end
end

