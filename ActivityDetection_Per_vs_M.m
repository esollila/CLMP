% Acticity detection performance study: study of number of antennas M
% versuse exact recovery (ER) and missdetection (MD) for different values 
% of sparsity levels K. The pilot symbols are random Bernoulli pilots and
% length of the pilots is L=64.
% 
% If you use this code, then please cite: 
%
% Leatile Marata, Esa Ollila, and Hirley Alves: 
%  "Activity Detection for Massive Random Access using Covariance-based 
%   Matching Pursuit." arXiv preprint arXiv:2405.02741 (2024).
% 
clearvars;
%%
MC_iters =5000;   % number of MC iterations
N = 1000; % number of MTD-s
L = 64; % pilot length 
Mlist = 10:10:60;    % different sets of antennas 

SNRlow = -15; % lowest power device in dB
SNRhigh = 0;  % highest power device in dB

Klist = 10:10:50; % the number of active devices considered 
Pmd = zeros(length(Mlist),2,length(Klist)); % missdetection rates 
Per = zeros(length(Mlist),2,length(Klist)); % exact recover rates 
tme = zeros(length(Mlist),2,length(Klist)); % computation times 

%% Setting the number of cores to 1 
% For fair comparison we set maximum number of cores to one. Without this
% option, on an 8-core macbook pro M3, our method had much better
% performance due to more efficient use of cores than the competing
% iterative approaches 
numCores = feature('numCores');
disp(['Number of CPU cores: ', num2str(numCores)]);
maxNumCompThreads(1); % set the number of cores to 1 
%% Loop
for k = 1:length(Klist)        
    rng('default');
    K = Klist(k);
    fprintf('\n---- K=%3d',K)
    for m = 1:length(Mlist)
        M  = Mlist(m); % choose the number of antennas
        fprintf('\n- M=%3d ',M);
        [Pmd(m,:,k),Per(m,:,k),tme(m,:,k)] = activityDetectionPE(L,N,K,M,MC_iters,SNRlow,SNRhigh);
    end
end
%% return the number of cores back to normal:
ncores = maxNumCompThreads('automatic');
fprintf('Number of CPU cores: %d', ncores);
%% Figure 1: missdetection rates
fignro=1;
figure(fignro);clf
semilogy(Mlist,Pmd(:,1,1),'rx-','DisplayName',sprintf('CW $K=%d$',Klist(1)),'LineWidth',2,'MarkerSize',10);
hold on;
semilogy(Mlist,Pmd(:,1,2),'rx:','DisplayName',sprintf('$K=%d$',Klist(2)),'LineWidth',2,'MarkerSize',10);
semilogy(Mlist,Pmd(:,1,3),'rx--','DisplayName',sprintf('$K=%d$',Klist(3)),'LineWidth',2,'MarkerSize',10);
semilogy(Mlist,Pmd(:,1,4),'rx-.','DisplayName',sprintf('$K=%d$',Klist(4)),'LineWidth',2,'MarkerSize',10);
semilogy(Mlist,Pmd(:,1,5),'rx-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
%--MP
semilogy(Mlist,Pmd(:,2,1),'bo-','DisplayName',sprintf('MP $K=%d$',Klist(1)),'LineWidth',2,'MarkerSize',10);
semilogy(Mlist,Pmd(:,2,2),'bo:','DisplayName',sprintf('$K=%d$',Klist(2)),'LineWidth',2,'MarkerSize',10);
semilogy(Mlist,Pmd(:,2,3),'bo--','DisplayName',sprintf('$K=%d$',Klist(3)),'LineWidth',2,'MarkerSize',10);
semilogy(Mlist,Pmd(:,2,4),'bo-.','DisplayName',sprintf('$K=%d$',Klist(4)),'LineWidth',2,'MarkerSize',10);
semilogy(Mlist,Pmd(:,2,5),'bo-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
xlabel('M (number of antennas)');
ylabel('Probability of missdetection');
legend('FontSize',19);
grid on;

%% Figure 2: exact recovery rates 
figure(fignro+1);clf
plot(Mlist,Per(:,1,1),'rx-','DisplayName',sprintf('K=%d',Klist(1)),'LineWidth',2,'MarkerSize',10);
hold on;
plot(Mlist,Per(:,1,2),'rx:','DisplayName',sprintf('K=%d',Klist(2)),'LineWidth',2,'MarkerSize',10);
plot(Mlist,Per(:,1,3),'rx--','DisplayName',sprintf('K=%d',Klist(3)),'LineWidth',2,'MarkerSize',10);
plot(Mlist,Per(:,1,4),'rx-.','DisplayName',sprintf('K=%d',Klist(4)),'LineWidth',2,'MarkerSize',10);
plot(Mlist,Per(:,1,5),'rx-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
%--MP
plot(Mlist,Per(:,2,1),'bo-','DisplayName',sprintf('MP K=%d',Klist(1)),'LineWidth',2,'MarkerSize',10);
plot(Mlist,Per(:,2,2),'bo:','DisplayName',sprintf('K=%d',Klist(2)),'LineWidth',2,'MarkerSize',10);
plot(Mlist,Per(:,2,3),'bo--','DisplayName',sprintf('K=%d',Klist(3)),'LineWidth',2,'MarkerSize',10);
plot(Mlist,Per(:,2,4),'bo-.','DisplayName',sprintf('K=%d',Klist(4)),'LineWidth',2,'MarkerSize',10);
plot(Mlist,Per(:,2,5),'bo-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
xlabel('M (number of antennas)');
ylabel('Probability of exact recovery');
legend('FontSize',19);
grid on;
%% Figure 3: computation times 
tmp=mean(tme,1);
cputme = reshape(tmp,size(tmp,2:3))';
cputme = cputme(:,[2,1]);

figure(fignro+2);clf
bar(Klist,cputme)
legend('CL-MP','CWO')
ylabel('Running time [s]')
xlabel('K (number of active devices)')
