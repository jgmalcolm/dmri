function [D S u b] = gen_square

  b = 900;  % typical b-value of PNL scans

  % eigenvalues for different tensors
  lambda_aniso   = [1200 100  100 ];
  lambda_iso     = [1500 1500 1500];
  lambda_prolate = [100 1200 1200];

  n = 20;
  D = zeros(n*n, 9);
  
  u = icosahedron(2);
  S = zeros(n*n, size(u,1));
  
  [xx yy] = ndgrid(1:n);
  
  % determine regions
  is_vert = 9 <= yy & yy <= 13;
  is_horz = 9 <= xx & xx <= 13;
  is_cross = is_vert | is_horz;
  is_square = is_vert & is_horz;
  is_outside = ~is_vert & ~is_horz & ~is_square;
  
  % place vertical anisotropic tensors
  [x y] = find(is_vert);
  [x y] = deal(x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D(is_vert,:) = tensors(V, 1e-6*diag(lambda_aniso));
  S(is_vert,:) = tensor2signal(D(is_vert,:), u, b);
  
  % place horizontal anisotropic tensors
  [x y] = find(is_horz);
  [x y] = deal(0*x, y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D(is_horz,:) = tensors(V, 1e-6*diag(lambda_aniso));
  S(is_horz,:) = tensor2signal(D(is_horz,:), u, b);
  
  % place center prolate tensors
  [x y] = find(is_square);
  [x y] = deal(0*x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 1;
  D(is_square,:) = tensors(V, 1e-6*diag(lambda_prolate));
  S(is_square,:) = tensor2signal(D(is_square,:), u, b);
  
  % place isotropic background
  [x y] = find(is_outside);
  [x y] = deal(0*x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 1;
  D(is_outside,:) = tensors(V, 1e-6*diag(lambda_iso));
  S(is_outside,:) = tensor2signal(D(is_outside,:), u, b);
  
  % finalize
  D = reshape(D, n, n, []);
  S = reshape(S, n, n, []);
  
end


function D = tensors(V, d)
  n = size(V,1);
  D = zeros(n, 9);
  for i = 1:n
    v = V(i,:)'; v = v/norm(v);
    a = pi/2*rand; v(:,2) = [sin(a) 0 cos(a)]';
    a = pi/2*rand; v(:,3) = [0 sin(a) cos(a)]';
    v = gramschmidt(v);
    t = v*d*v';
    D(i,:) = t(:);
  end
end



function [A] = gramschmidt(A)

% Gramm-Schmidt orthogonalization
%   GRAMSCHMIDT(A) orthogonalizes the columns of A by means of the Gramm-
% Schmidt procedure. Note that the number of columns of A is required to   
% be less or equal to the number of its rows.
% 
% written by Oleg Michailovich, August 2007

  [n,m]=size(A);

  if (m>n),
    error('The system is overcomplete. No stable results are possible!');
  end

  A(:,1)=A(:,1)/norm(A(:,1));
  for k=2:m,
    A(:,k)=A(:,k)-A(:,1:k-1)*(A(:,1:k-1)'*A(:,k));
    A(:,k)=A(:,k)/norm(A(:,k));
  end
end

function [u,fcs] = icosahedron(level)
%   Sample the unit sphere using regular icosahedron tessellation
%       
%                     [u,fcs] = icosahedron(level)
%   Input:
%             level - tessellation order
%   Output:
%                 u - N-by-3 matrix of samples of the unit circle
%               fcs - vertices-to-facets correspondence matrix
%  
%   written by Oleg Michailovich, February 5th, 2009

  C=1/sqrt(1.25);
  t=(2*pi/5)*(0:4)';
  u1=C*[cos(t) sin(t) 0.5*ones(5,1)];
  u2=C*[cos(t+0.2*pi) sin(t+0.2*pi) -0.5*ones(5,1)];
  u=[[0 0 1]; u1; u2; [0 0 -1]];

  if (level==0),
    return;
  else
    for lev=1:level,
      fcs=convhulln(u);
      N=size(fcs,1);
      U=zeros(3*N,3);
      for k=1:N,
        A=u(fcs(k,1),:);
        B=u(fcs(k,2),:);
        C=u(fcs(k,3),:);
        U(3*k-2:3*k,:)=0.5*[A+B; B+C; A+C];
      end
      U=unique(U,'rows');
      U=U./repmat(sqrt(sum(U.^2,2)),[1 3]);
      u=[u; U]; %#ok<AGROW>
    end
  end
  [C,ind]=sort(u(:,3),1,'descend');
  u=u(ind,:);
  index=find(u(:,3)==0);
  v=u(index,:);
  [C,ind]=sort(v(:,2),1,'descend');
  u(index,:)=v(ind,:);
  fcs=convhulln(u);
end



function [S F M] = tensor2signal(D, u, b)

  n = size(D, 1);
  S = zeros(n, length(u));
  F = zeros(n, length(u));
  M = zeros(n, 3);
  
  for i = 1:n
    d = reshape(D(i,:), [3 3]);
    % ADC signal
    S(i,:) = exp(-b*sum((u * d) .* u, 2)); % S0=1
    % ODF
    f = sqrt((pi*b)./sum((u * inv(d)) .* u, 2));
    F(i,:) = f / sum(f);  % unit mass
    % principle diffusion
    [V U] = svd(d);
    M(i,:) = U(1)*V(:,1); % principle eigenvector
  end
end
