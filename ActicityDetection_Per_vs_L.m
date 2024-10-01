% Acticity detection performance study: study of pilot sequence length L 
% versuse exact recovery (ER) and missdetection (MD) for different values 
% of sparsity levels K. The pilot symbols are random Bernoulli pilots. 
% 
% If you use this code, then please cite: 
%
% Leatile Marata, Esa Ollila, and Hirley Alves: 
%  "Activity Detection for Massive Random Access using Covariance-based 
%   Matching Pursuit." arXiv preprint arXiv:2405.02741 (2024).
% 
clearvars;
%%
MC_iters = 5000;   % number of MC iterations
N = 1000; % number of MTD-s
M = 40;   % number of antennas

SNRlow = -15; % lowest power device in dB
SNRhigh = 0;  % highest power device in dB

Llist = 32+[0 16 32 48]; % pilot lengths 
Klist = 10:10:50; % sparsity levels 
Pmd = zeros(length(Llist),2,length(Klist)); % missdetection rates
Per = zeros(length(Llist),2,length(Klist)); % exact recovery rates 
tme = zeros(length(Llist),2,length(Klist)); % computation times

%% Setting the number of cores to 1 
% For fair comparison we set maximum number of cores to one. Without this
% option, on an 8-core macbook pro M3, our method had much better
% performance due to more efficient use of cores than the competing
% iterative approaches 
numCores = feature('numCores');
disp(['Number of CPU cores: ', num2str(numCores)]);
maxNumCompThreads(1); % set to 1 due to comparison of computation times
%% Loop
for k = 1:length(Klist)
    rng('default');
    K = Klist(k);
    fprintf('\n---- K=%3d',K)
    for m = 1:length(Llist)
        L   = Llist(m); 
        fprintf('\n- L=%3d ',L);
        [Pmd(m,:,k),Per(m,:,k),tme(m,:,k)] = activityDetectionPE(L,N,K,M,MC_iters,SNRlow,SNRhigh);
    end
end
%% return the number of cores back to normal:
ncores = maxNumCompThreads('automatic');
fprintf('Number of CPU cores: %d', ncores);
%%  Figure 1: missdetection rates
fignro=10;
figure(fignro);clf
semilogy(Llist,Pmd(:,1,1),'rx-','DisplayName',sprintf('CW $K=%d$',Klist(1)),'LineWidth',2,'MarkerSize',10);
hold on;
semilogy(Llist,Pmd(:,1,2),'rx:','DisplayName',sprintf('$K=%d$',Klist(2)),'LineWidth',2,'MarkerSize',10);
semilogy(Llist,Pmd(:,1,3),'rx--','DisplayName',sprintf('$K=%d$',Klist(3)),'LineWidth',2,'MarkerSize',10);
semilogy(Llist,Pmd(:,1,4),'rx-.','DisplayName',sprintf('$K=%d$',Klist(4)),'LineWidth',2,'MarkerSize',10);
semilogy(Llist,Pmd(:,1,5),'rx-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
%--MP
semilogy(Llist,Pmd(:,2,1),'bo-','DisplayName',sprintf('MP $K=%d$',Klist(1)),'LineWidth',2,'MarkerSize',10);
semilogy(Llist,Pmd(:,2,2),'bo:','DisplayName',sprintf('$K=%d$',Klist(2)),'LineWidth',2,'MarkerSize',10);
semilogy(Llist,Pmd(:,2,3),'bo--','DisplayName',sprintf('$K=%d$',Klist(3)),'LineWidth',2,'MarkerSize',10);
semilogy(Llist,Pmd(:,2,4),'bo-.','DisplayName',sprintf('$K=%d$',Klist(4)),'LineWidth',2,'MarkerSize',10);
semilogy(Llist,Pmd(:,2,5),'bo-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
xlabel('L (pilot length)');
ylabel('Probability of missdetection');
legend('FontSize',19);
grid on;

%% Figure 2: computation times 
figure(fignro+1);clf
subplot(1,2,1);
plot(Llist,tme(:,1,1),'rx-','DisplayName',sprintf('K=%d',Klist(1)),'LineWidth',2,'MarkerSize',10);
hold on;
plot(Llist,tme(:,1,2),'bx-','DisplayName',sprintf('K=%d',Klist(2)),'LineWidth',2,'MarkerSize',10);
plot(Llist,tme(:,1,3),'kx-','DisplayName',sprintf('K=%d',Klist(3)),'LineWidth',2,'MarkerSize',10);
plot(Llist,tme(:,1,4),'mx-','DisplayName',sprintf('K=%d',Klist(4)),'LineWidth',2,'MarkerSize',10);
plot(Llist,tme(:,1,5),'gx-','DisplayName',sprintf('K=%d',Klist(5)),'LineWidth',2,'MarkerSize',10);
ax = axis;
axis([ax(1:2) 0 ax(4)]);
xlabel('L');
ylabel('Time (s)');
legend('FontSize',19);
title('CWO')
grid;
%-- MP
subplot(1,2,2);
plot(Llist,tme(:,2,1),'rx-','DisplayName',sprintf('K=%d',Klist(1)),'LineWidth',2,'MarkerSize',10);
hold on;
plot(Llist,tme(:,2,2),'bx-','DisplayName',sprintf('K=%d',Klist(2)),'LineWidth',2,'MarkerSize',10);
plot(Llist,tme(:,2,3),'kx-','DisplayName',sprintf('K=%d',Klist(3)),'LineWidth',2,'MarkerSize',10);
plot(Llist,tme(:,2,4),'mx-','DisplayName',sprintf('K=%d',Klist(4)),'LineWidth',2,'MarkerSize',10);
plot(Llist,tme(:,2,5),'gx-','DisplayName',sprintf('K=%d',Klist(5)),'LineWidth',2,'MarkerSize',10);
axis([ax(1:2) 0 ax(4)]);
xlabel('L');
title('CL-MP')
grid;
legend('FontSize',19);


%%
figure(fignro+2);clf
plot(Llist,Per(:,1,1),'rx-','DisplayName',sprintf('K=%d',Klist(1)),'LineWidth',2,'MarkerSize',10);
hold on;
plot(Llist,Per(:,1,2),'rx:','DisplayName',sprintf('K=%d',Klist(2)),'LineWidth',2,'MarkerSize',10);
plot(Llist,Per(:,1,3),'rx--','DisplayName',sprintf('K=%d',Klist(3)),'LineWidth',2,'MarkerSize',10);
plot(Llist,Per(:,1,4),'rx-.','DisplayName',sprintf('K=%d',Klist(4)),'LineWidth',2,'MarkerSize',10);
plot(Llist,Per(:,1,5),'rx-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
%--MP
plot(Llist,Per(:,2,1),'bo-','DisplayName',sprintf('MP K=%d',Klist(1)),'LineWidth',2,'MarkerSize',10);
plot(Llist,Per(:,2,2),'bo:','DisplayName',sprintf('K=%d',Klist(2)),'LineWidth',2,'MarkerSize',10);
plot(Llist,Per(:,2,3),'bo--','DisplayName',sprintf('K=%d',Klist(3)),'LineWidth',2,'MarkerSize',10);
plot(Llist,Per(:,2,4),'bo-.','DisplayName',sprintf('K=%d',Klist(4)),'LineWidth',2,'MarkerSize',10);
plot(Llist,Per(:,2,5),'bo-','DisplayName',sprintf('$K=%d$',Klist(5)),'LineWidth',2,'MarkerSize',10);
xlabel('L (pilot length)');
ylabel('Probability of exact recovery');
title(sprintf('MC iters = %d',MC_iters))
legend('FontSize',19);
grid on;