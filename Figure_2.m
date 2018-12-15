clc;
clear;
close all;
%% initialization
mct=100; % max circulation times
X=zeros(1,mct); %  t is the variables
G=zeros(1,mct); % value of function G(x)
G_D=zeros(1,mct); % value of function G'(x)
G_DD=zeros(1,mct); % value of function G'(x)

a=1; % scaling parameter alpha
q_0_sam=[0,0.3,0.3,0.6];
q_1_sam=[0,0,0.3,0.3];
% beta = linspace(1,20,100);
beta =1:0.1:12;
opt_x=zeros(length(q_0_sam),length(beta));
for q_index=1:length(q_0_sam)
    q_0=q_0_sam(q_index);
    q_1=q_1_sam(q_index);
    for b_index=1:length(beta)
        b=beta(b_index);
        %% function
        c_1=a*b/2/gamma(1/b); 
        c_2=(2*q_0-1)/2/(1-q_0-q_1);
        c_3=1/4/(1-q_0-q_1)^2;
        PDF = @(x) c_1*exp(-(a*abs(x)).^b);           % function f(x)
        CDF = @(x)integral(PDF,-inf,x);                             % function F(x)
        FUN_G=@(x) -c_1^2*exp(-2*(a*abs(x)).^b)./(1/4-((1-q_0-q_1)*integral(PDF,-inf,x)-1/2+q_0).^2);   % function G(x)
        FUN_G_D=@(x) -2*c_1^2*exp(-2*(a*abs(x)).^b)./(1/4-((1-q_0-q_1)*integral(PDF,-inf,x)-1/2+q_0).^2).* ... 
            ( -a^b*b*abs(x).^(b-1) + c_1*exp(-(a*abs(x)).^b).*(integral(PDF,-inf,x)+c_2) ./ (c_3-(integral(PDF,-inf,x)+c_2).^2) ); % the first order derivative of G(x)
        %% circulation
        X(1)=0.01/a; % give an initial point
        stop_criterion=(1e-5)*a^3; % stop criterion
        ct=1; % circulation time
        lambda=stop_criterion+1;
        %% Gradient descent method
        while(ct<=mct&&lambda>stop_criterion)
        %             G(ct)=FUN_G(X(ct)); 
            G_D(ct)=FUN_G_D(X(ct));
            t=1/a^4;
            while(X(ct)+t*(-G_D(ct))<0)
                t=0.5*t;
            end;
            while(  FUN_G(X(ct)+t*(-G_D(ct)))  >  (FUN_G(X(ct))  +  0.2*t*(-G_D(ct)^2))  )
                t=0.5*t;
            end
            X(ct+1)=X(ct)-t*G_D(ct);
            if X(ct+1)>1
                    X(ct+1)=1;
            end
%             if X(ct+1)>1.5
%                 X(ct+1)=
%             end
            lambda=abs(G_D(ct));
            ct=ct+1;
        end
        ct=ct-1;
        opt_x(q_index,b_index)=X(ct)/a;
    end
end
%% plot
alw = 0.75;    % AxesLineWidth
fsz = 20;      % Fontsize
lw = 1.5;      % LineWidth
msz = 10;       % MarkerSize
close all;
plot(beta,opt_x(1,:),'-r',beta,opt_x(2,:),'-.b',beta,opt_x(3,:),'--k',beta,opt_x(4,:),':m','LineWidth',lw);
hold on;
plot(beta,(1-1./beta).^(1./beta),'--k','LineWidth',2.5);
plot([0 1],[0 0],'-r',[0 1],[0 0],'-.b',[0 1],[0 0],'--k',[0 1],[0 0],':m','LineWidth',lw);
xlabel('\beta','Fontsize',fsz)
ylabel('\alpha x^*','Fontsize',fsz)
legend('q_0=0.0,q_1=0.0','q_0=0.3,q_1=0.0','q_0=0.3,q_1=0.3','q_0=0.6,q_1=0.3')

%\alpha{x_1}=(1-1/\beta)^{1/\beta}
% save optimum_vs_beta;



