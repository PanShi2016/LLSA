function [V,lambda,alpha] = lanczos(A,q1,kmax,j,btol);
%
% Run Lanczos iteration for kmax steps.  Also quit if beta(k) < btol,
% indicating an approximate invariant subspace.

% Set default args
if nargin < 5
  btol = 1e-8;
end

% Diagonal scaling vectors
d = full(sum(A,2));
sd = sqrt(d);

% Run Lanczos for a few steps (with D-inner product)
k  = 0;
qk = 0;
r  = q1/norm(sd.*q1);
b  = 1;
alpha = zeros(kmax,1);
beta = zeros(kmax,1);
residual = zeros(1,kmax);
Q = zeros(length(q1),kmax);
while (k < kmax) && (b > btol);
  k        = k+1;
  qkm1     = qk;
  qk       = r/b;
  Q(:,k)   = qk;
  Aqk      = A*qk;
  alpha(k) = qk'*Aqk;
  r        = Aqk./d-qk*alpha(k)-qkm1*b;
  b        = norm(sd.*r);
  beta(k)  = b;
end

% Solve projected eigenvalue problem
T = diag(alpha) + diag(beta(1:end-1),1) + diag(beta(1:end-1),-1);
[QT,Lambda] = eig(T);
[lambda,idx] = sort(diag(Lambda), 'descend');
QT = QT(:,idx);

% Form eigenvector matrix
V = Q*QT;
V = V(:,j);
