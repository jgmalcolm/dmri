function [S is_cross] = gen_3cross_w(u, th, w1, sigma, mode, b, lambda)
% theta -- angle between fibers
% w1 -- weight of primary fiber (other two divide remainder)
  
  if ~exist('lambda')
    lambda = [1200 100 100]; % 01045
  end

  th = pi/2 - th * pi/180; % reorient: angle off vertical
  d_iso = 1e-6*diag([1500 1500 1500]);
  d_aniso = 1e-6*diag(lambda);

  paths;

  k = size(u,1); % sample directions
  
  nx = 70; ny = 20;
  S = zeros(nx*ny, k, 3); % ADC signal
  
  [xx yy] = ndgrid(1:nx,1:ny);

  % vertical
  switch mode
   case 0 % thick
    is_vert = 6 <= yy & yy <= 15;
   case 1 % medium
    is_vert = 7 <= yy & yy <= 14;
   otherwise, error('unsupported');
  end
  [x y] = find(is_vert);
  [x y] = deal(x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_vert,:,1) = tensor2signal(D, u, b);

  % crossing
  switch mode
   case 0 % block
     is_cross = 11 <= xx & xx <= 60 & is_vert;
   case 1 % thick crossing
    is_cross = abs(cos(th)*(xx-nx/2) + sin(th)*(yy-ny/2)) <= 4;
  end
  % repeat a unit vector along that orientation
  V = [-sin(th) cos(th) 0];
  V = repmat(V, nnz(is_cross), 1);
  D = tensors(V, d_aniso);
  S(is_cross,:,2) = tensor2signal(D, u, b);

  % third fiber
  is_tri = is_cross & is_vert;
  th = pi/2 - th;
  V = [-cos(th) cos(th)*(1-cos(th))/sin(th)];
  V(3) = sqrt(1 - norm(V)^2);
  V = repmat(V, nnz(is_tri), 1);
  D = tensors(V, d_aniso);
  S(is_tri,:,3) = tensor2signal(D, u, b);
  
  % isotropic
  is_uniform = ~is_vert & ~is_cross;
  [x y] = find(is_uniform);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_iso);
  S(is_uniform,:,1) = tensor2signal(D, u, b);

  
  % package up
  is_cross = is_cross & is_vert;
  S(is_cross,:,1) =   w1     * S(is_cross,:,1);
  S(is_cross,:,2) = (1-w1)/2 * S(is_cross,:,2);
  S(is_cross,:,3) = (1-w1)/2 * S(is_cross,:,3);
  S = reshape(sum(S,3), [], size(u,1));

  % add noise to image DWI
  if sigma
    for i = 1:size(S,2)
      s = S(:,i);
      x = sigma * mean(s) * randn(size(s));
      y = sigma * mean(s) * randn(size(s));
      s = sqrt((s + x).^2 + y.^2);
      S(:,i) = s;
    end
  end
  S = reshape(S, nx, ny, []);
end
