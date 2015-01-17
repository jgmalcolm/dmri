function [S is_cross] = gen_2cross_w(u, th, w1, sigma, mode, b, lambda)
% theta - angle between fibers
  
  %lambda = [1700 200 200];  % Arish
  if ~exist('lambda')
    lambda = [1200 100 100]; % 01045
  end
  
  w2 = 1 - w1;
  th = pi/2 - th * pi/180; % reorient: angle off vertical
  d_iso = 1e-6*diag([1500 1500 1500]);
  d_aniso = 1e-6*diag(lambda);

  paths;

  %randn('state', 0); % introducing...determinism!

  k = size(u,1); % sample directions

  nx = 70; ny = 20;
  S = zeros(nx*ny, k, 2); % ADC signal

  [xx yy] = ndgrid(1:nx,1:ny);

  % vertical
  switch mode
   case 0 % thick
    is_vert = 6 <= yy & yy <= 15;
   case 1 % medium
    is_vert = 7 <= yy & yy <= 14;
   case 2 % thin
    is_vert = 9 <= yy & yy <= 11;
  end
  [x y] = find(is_vert);
  [x y] = deal(x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_vert,:,1) = tensor2signal(D, u, b);

  % crossing
  switch mode
   case 0 % block
     is_cross = 1 <= xx & xx <= 50 & is_vert;
   case 1 % thick crossing
    is_cross = abs(cos(th)*(xx-nx/2) + sin(th)*(yy-ny/2)) <= 4;
   case 2 % thin crossing
    switch 90 - th*180/pi
     case 40,   fx = 1.9;
     case 50,   fx = 2.1;
     case 60,   fx = 2.1;
     case 70,   fx = 2.1;
     case 80,   fx = 2.2;
     case 90,   fx = 2.1;
     otherwise, error('unsupported angle');
    end
    is_cross = abs(cos(th)*(xx-nx/2) + sin(th)*(yy-ny/2)) <= fx;
  end
  % repeat a unit vector along that orientation
  V = [-sin(th) cos(th) 0] + eps;
  V = repmat(V, nnz(is_cross), 1);
  D = tensors(V, d_aniso);
  S(is_cross,:,2) = tensor2signal(D, u, b);

  % isotropic
  is_uniform = ~is_vert & ~is_cross;
  [x y] = find(is_uniform);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_iso);
  S(is_uniform,:,1) = tensor2signal(D, u, b);

  % package up
  is_cross = is_cross & is_vert;
  S(is_cross,:,1) =   w1   * S(is_cross,:,1);
  S(is_cross,:,2) = (1-w1) * S(is_cross,:,2);
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
