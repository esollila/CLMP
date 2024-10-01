function Ilocs = CLMP(A,RY,K,sig)
% Ilocs = CLMP(A,RY,K,sig)
%
% Sparse support recovery algorithm using greedy covariance 
% learning matching pursuit (CL-MP) described in reference below
%
% INPUT: 
%   A      - Dictionary of size L x N
%   RY     - Sample covariance matrix (SCM), size L x L
%   K      - number of non-zero sources (positive integer) 
%   sig    - known noise variance (a positive  real-valued scalar)
%
% OUTPUT:
%   Ilocs  -  support of non-zeros signal powers (a K-vector)
%
% Reference: 
%
%  Leatile Marata, Esa Ollila, and Hirley Alves: 
%  "Activity Detection for Massive Random Access using Covariance-based 
%   Matching Pursuit." arXiv preprint arXiv:2405.02741 (2024).
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize variables
N = size(A,2);  % number of dictionary entries
assert(isequal(round(K),K) && isreal(K) && K >0,'''K'' must be a positive integer');
assert(isreal(sig) && sig>0,'''sig'' must be positive');

%% Initialize
Ilocs = zeros(1,K);
B =  (1/sig)*A;
gam = zeros(1,K);
%% Loop
for k = 1:K
    
    %% 1. go through basis vectors
    gamma_num = real(sum(conj(B).*(RY*B)));
    gamma_denum = real(sum(conj(A).*B));
    gamma_denum(gamma_denum<=10^-18) = 10^-18; % make sure not zero
    gamma = subplus(gamma_num./(gamma_denum.^2) - 1./gamma_denum);
    tmp  = gamma.*gamma_denum;
    fk = log(1+tmp) - tmp;     
    
    %% 2. Update the index set 
    tmp = setdiff(1:N,Ilocs(1:k-1));
    [~,indx] = min(fk(tmp));
    indx = tmp(indx);
    Ilocs(k) = indx;

    %% 3. Update gamma0  
    gam(k) = gamma(indx);
    %% 4. Update B = Sigma^-1 * A using Shermann-Morrison formula
    if k < K
        a = A(:,indx);
        b = B(:,indx); 
        B =  B - (gam(k)/(1+gam(k)*real(a'*b)))*b*(a'*B);
    end

end
end

