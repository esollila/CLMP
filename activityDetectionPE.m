function [Pmd,Per,tme] = activityDetectionPE(L,N,K,M,iter,SNRlow,SNRhigh)

iter_cwo = 15; % max iter for CWO
    
md = zeros(1,2); 
per = zeros(1,2);
cputme = zeros(1,2);

for i=1:iter       
    
    % Create random signal powers gamma from Unif(SNRlow, SNRhigh) in dB
    gamma_dB = SNRlow + (SNRhigh- SNRlow)*rand(N,1);
    gamma = 10.^(gamma_dB/10);

    % Create random Bernoulli pilot matrix
    A = (1-2*binornd(1,0.5,[L, N]))/sqrt(2) + 1i*(1-2*binornd(1,0.5,[L, N]))/sqrt(2);
    norms = sum(abs(A.^2));
    assert(all(abs(norms-L*ones(1,N))<1e-10));

    % Random activity pattern
    sup = randperm(N,K);
    [~,tmp] = sort(gamma(sup),'descend');
    sup = sup(tmp);

    %% Generate data and compute the SCM
    X = diag(sqrt(gamma(sup)))*(randn(K,M) + 1i*randn(K,M))/sqrt(2);   
    Z = (randn(L,M) + 1i*randn(L,M))/sqrt(2);
    Y = A(:,sup)*X + Z;
    cov_m = (1/M)*Y*(Y'); 

    %% 1. CW optimization 
    tStart = tic;
    gam1= ML_coord_descent_round(cov_m, A, iter_cwo, 1,[]);
    tEnd = toc(tStart);
    cputme(1) = cputme(1) + tEnd;
    [~,Ilocs1] = maxk(gam1,K);
    err1 = numel(setdiff(Ilocs1,sup));
    md(1) = md(1) + err1/K;
    if err1==0
        per(1) = per(1) + 1;
    end

    %% 2. CL-MP (proposed method)
    tStart = tic;
    Ilocs2 = CLMP(A,cov_m,K,1);       
    tEnd= toc(tStart);
    cputme(2) = cputme(2) + tEnd;
    err2 = numel(setdiff(Ilocs2,sup));
    md(2) = md(2) + err2/K;
    if err2==0
        per(2) = per(2) + 1;
    end
    
    if mod(i,500)==0
        fprintf('.')
    end
end
Pmd = md/iter
Per = per/iter
tme = cputme/iter

