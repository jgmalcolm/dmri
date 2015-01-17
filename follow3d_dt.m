function ff = follow3d_dt(S, u, b, mask, X, param)
  % initial state
  [x m fa] = deal(X(1:3), X(4:6), X(7));
  fiber = struct('x',  x, ...
                 'm',  m, ...
                 'fa', fa);

  % initialize tracts
  ff = tract_init(x);

  % initialize filter
  est = est_fn(u, b);
  
  % main loop
  ct = 0;
  while true
    % estimate
    fiber = step_euler(fiber, S, est, param);
    
    % unpack
    [x fa] = deal(fiber.x, fiber.fa);

    % terminate if off brain or in CSF
    is_brain = interp3scalar(mask, x, param.voxel) > .1;
    is_csf = fa < param.FA_min;

    %find curvature
    curv = FindCurvature(ff);
    rad_curv = iff(curv, 1/curv, 1);
    is_curving = rad_curv < param.min_radius; %we are curving fast...

    if ~is_brain || is_csf || ff.cur > param.max_len || is_curving
      if ff.cur > param.max_len, warning('wild fiber'); end
      ff = tract_done(ff);
      break
    end
    
    % record every millimeter
%     if ct == round(1/param.dt)
      ff = tract_push(ff, x);
%       ct = 0;
%     else
%       ct = ct + 1;
%     end
  end
end


function p = step_rk(p, S, est, param)
  v = param.voxel';
  % unpack
  [x m fa] = deal(p.x, p.m, p.fa);
  % move
  [t x] = ode23(@f, [0 1], p.x);
  % repack
  [p.x p.m p.fa] = deal(x(end,:)', m, fa);
  
  function dx = f(t, x)
    m_ = m;
    D = est(interp3exp(S, x, v));
    [U B] = svd(D);
    m = U(:,1);
    if (m_'*m) < 0, m = -m; end % align
    fa = tensor2fa(D);
    dx = m ./ v;
  end
end

function p = step_euler(p, S, est, param)
  v = param.voxel';
  % unpack
  [x m_ fa] = deal(p.x, p.m, p.fa);

  % move
  D = est(interp3exp(S, x, v));
  [U V] = svd(D);
  m = U(:,1);
  if (m_'*m) < 0, m = -m; end % align
  dx = m ./ v;
  x = x + param.dt * dx;
  fa = tensor2fa(D);

  % repack
  [p.x p.m p.fa] = deal(x, m, fa);
end

function fn = est_fn(u, b)
  ux = u(:,1); uy = u(:,2); uz = u(:,3);
  B = -b * [ux.^2  2*ux.*uy  2*ux.*uz  uy.^2  2*uy.*uz  uz.^2];
  
  fn = @est;
  
  function D = est(s)
    D = real(B \ log(s)); % ensure real since unconstrained
    D = D([1 2 3; 2 4 5; 3 5 6]);
  end
end
