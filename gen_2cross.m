function [S is_cross] = gen_2cross(u, th, sigma, mode, b, lambda)
  error('use gen_2cross_w');

% theta - angle between fibers
  
  % signal/tensor parameters
%   if ~exist('sigma'), sigma = 0; end
%   if ~exist('mode'), mode = 0; end
%   if ~exist('b'), b = 1000; end
  
  if ~exist('lambda')
    lambda = [1200 100 100]; % 01045
  end

  th = pi/2 - th * pi/180; % reorient: angle off vertical
  d_iso = 1e-6*diag([1500 1500 1500]);
  d_aniso = 1e-6*diag(lambda);

  paths;

  k = size(u,1); % sample directions
  
  nx = 70; ny = 20;
  S = zeros(nx*ny, k); % ADC signal
  
  [xx yy] = ndgrid(1:nx,1:ny);

  % vertical
  switch mode
   case {0 .5} % thick
    is_vert = 6 <= yy & yy <= 15;
   case {1 1.5} % medium
    is_vert = 7 <= yy & yy <= 14;
   case 2 % thin
    is_vert = 9 <= yy & yy <= 11;
  end
  [x y] = find(is_vert);
  [x y] = deal(x, 0*y);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_aniso);
  S(is_vert,:)= tensor2signal(D, u, b);

  % crossing
  switch mode
   case {0 .5} % block
     is_cross = 1 <= xx & xx <= 50 & is_vert;
   case {1 1.5} % thick crossing
    is_cross = abs(cos(th)*(xx-nx/2) + sin(th)*(yy-ny/2)) <= 4;
   case 2 % thin crossing
    switch 90 - th*180/pi
     case 40,   fx = 1.9;
     case 50,   fx = 2.1;
     case 60,   fx = 2.2;
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
  s = tensor2signal(D, u, b);

  if mode == 0.5
    n = 10; % number of graded rows (n=10 --> 0:.1:1)
    [x y] = find(is_cross);
    % graded area
    ind  = find(x >= 50-n);
    ind_ = sub2ind(size(is_cross), x(ind), y(ind));
    w = (50 - x(ind))/(2*n);
    S(ind_,:) = diag(1-w)*S(ind_,:) + diag(w)*s(ind,:);
    % averaged area
    ind  = find(x < 50-n);
    ind_ = sub2ind(size(is_cross), x(ind), y(ind));
    S(ind_,:) = (S(ind_,:) + s(ind,:))/2;
    is_cross = false(size(is_cross));
    is_cross(ind_) = true;
  elseif mode == 1.5
    % averaged area
    S(is_cross,:) = (S(is_cross,:) + s)/2; % average
    for i = 7:14
      xx = find(is_cross(:,i));
      yy = i*ones(size(xx));
      % determine top/bottom of column
      top = min(xx);  bot = max(xx);
      n = numel(top:bot); % graded length
      
      %-- above
      ind = sub2ind(size(is_cross), xx-n,  yy);
      w = 1-(xx+n - bot)/(2*n);
      [x yy_] = find(is_cross);
      S(ind,:) = diag(w)*S(ind,:) + diag(1-w)*s(yy_==i,:);
      %-- below
      ind = sub2ind(size(is_cross), xx+n,  yy);
      w = 1-(xx+n - bot)/(2*n); w = w(end:-1:1);
      [x yy_] = find(is_cross);
      S(ind,:) = diag(w)*S(ind,:) + diag(1-w)*s(yy_==i,:);
    end
  else
    S(is_cross,:) = (S(is_cross,:) + s)/2; % average
  end
  
  % isotropic
  is_uniform = ~is_vert & ~is_cross;
  [x y] = find(is_uniform);
  V = [x(:) y(:)]; V(:,3) = 0;
  D = tensors(V, d_iso);
  S(is_uniform,:) = tensor2signal(D, u, b);
  
  % count fibers in each voxel
  nfibers = is_vert + is_cross + is_uniform;
  
  % normalize
  if sigma
    for i = 1:size(S,2)
      s = S(:,i);
      x = sigma * mean(s) * randn(size(s));
      y = sigma * mean(s) * randn(size(s));
      S(:,i) = sqrt((s + x).^2 + y.^2);
    end
  end

  % finalize
  is_cross = is_cross & is_vert;
  S = reshape(S, nx, ny, []);
end
