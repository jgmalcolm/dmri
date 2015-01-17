function S = gen_variety(u, th, sigma, is_graded, b)
  paths;
  
  th = pi/2 - th * pi/180; % reorient: angle off vertical
  d_iso   = 1e-6*diag([1500 1500 1500]);
  d_aniso = 1e-6*diag([1200 100  100 ]); % 01045

  nx = 40; ny = 40;
  xx = repmat((1:nx)', 1, ny);
  
  %%-- generate fields to draw from
  % anisotropic
  V = xx(:); V(:,2:3) = 0;
  S_ani = tensor2signal(tensors(V, d_aniso), u, b);
  % isotropic
  S_iso = tensor2signal(tensors(V, d_iso), u, b);
  % crossing
  V = repmat([-sin(th) cos(th) 0] + eps, nx*ny, 1);
  S_cx = tensor2signal(tensors(V, d_aniso), u, b);
  
  %%-- combine
  S = S_ani; % default: up
  % striaght and cross
  ind = (16 <= xx & xx <= 25);
  S(ind,:) = (S(ind,:) + S_cx(ind,:))/2;
  % iso at end
  ind = (xx <= 5);
  S(ind,:) = S_iso(ind,:);
  
  %%-- add in gradient sections
  if is_graded
    ww = repmat((.2:.2:.8)', [ny size(u,1)]);
    ww_ = 1 - ww;
    % striaght to cross
    ind = (26 <= xx & xx <= 29);
    S(ind,:) = ww.*S_ani(ind,:) + ww_.*(S_ani(ind,:)+S_cx(ind,:))/2;
    % cross to straight
    ind = (16 <= xx & xx <= 19);
    S(ind,:) = ww.*S(ind,:) + ww_.*S_ani(ind,:);
    % straight to iso
    ind = (6 <= xx & xx <= 9);
    S(ind,:) = ww.*S_ani(ind,:) + ww_.*S_iso(ind,:);
  end
  
  %%-- introduce noise
  if sigma
    for i = 1:size(S,1)
      s = S(i,:);
      x = sigma * mean(s) * randn(size(s));
      y = sigma * mean(s) * randn(size(s));
      S(i,:) = sqrt((s + x).^2 + y.^2);
    end
  end
  
  S = reshape(S, nx, ny, []);
end
