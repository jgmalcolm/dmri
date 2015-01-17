function demo_mesh
% demonstrates how the mesh should look
% loops through each square and draws outline of that square
  
  n = 10; % tesselation level (higher == finer)
  
  [xx yy zz] = sphere(n); % generate coordinates
  
  % convert that format into sequential format where each set of four
  % coordinates is a new square
  X = [];
  for r = 1:n
    for c = 1:n
      ind = sub2ind(size(xx), [r r r+1 r+1], [c c+1 c+1 c])';
      sq = [xx(ind) yy(ind) zz(ind)];
      X = [X; sq];
    end
  end
  

  % draw what we just created
  clf; hold on;
  for i = 1:n*n
    sq = X((i-1)*4 + (1:4),:);
    plot3(sq(:,1),sq(:,2),sq(:,3), 'y');
  end
  view(3);
  
  % parameters at this voxel (direction and two eigenvalues)
  %p = [[1 0 0]  1200 100];
  p = [[1 0 0]  1700 300];
  
  % now deform the mesh according to these parameters
  X_ = tensor(X, p);
  for i = 1:n*n
    sq = X_((i-1)*4 + (1:4),:);
    plot3(sq(:,1),sq(:,2),sq(:,3), 'r');
  end

end


function u_ = tensor(u, p)
% scales unit vectors according to parameters
%  u -- unit vectors [Nx3]
%  p=[m l1 l2] -- m orientation, l1/l2 primary/secondary eigenvalue
%  u_ -- scaled vectors
  
  % unpack
  m = p(1:3);
  assert(norm(m) == 1);
  l1 = p(4);
  l2 = p(5);
  
  if m(1) < 0
    m = -m;
  end
  x = m(1); y = m(2); z = m(3);
  R = [x,  y,                      z,
       y,  y*y/(1+x)-1,    y*z/(1+x),
       z,  y*z/(1+x),    z*z/(1+x)-1];
  D = R * diag(1./[l1 l2 l2]) * R' * 1e-6;
  
  % scaling factor (diffusion signal)
  D_ = (u * D) .* u;
  beta = sqrt(pi/1000) * sum(D_,2);
  
  % rescale to size (HACK: just for our display purposes here)
  beta = beta / sum(beta) * 3e2;
  
  % scale vectors
  u_ = beta(:,[1 1 1]) .* u;
end


  %alpha = exp( -1000 * sum(D_,2));
