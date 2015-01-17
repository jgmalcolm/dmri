function fig_ODF_comparison(fa, mask, S, u, b)
  
  is_roi = false;
  is_signal = false;
  is_1t = false;
  is_2t = false;
  is_sh = true;

  colormap jet
  
  slice = 70;
  fa = sq(fa(:,slice,:));
  mask = sq(mask(:,slice,:));
  S = sq(S(:,slice,:,:));
  
  fa = permute(fa, [2 1]);
  mask = permute(mask, [2 1]);
  S  = permute(S,  [2 1 3]);
  u = u(:,[3 1 2]); % account for slice
  
  fa = fa .* mask;
  fa = minmax(fa);
  fa(fa==0) = 1;
  clf; imagesc(fa(:,:,[1 1 1])); axis image off
  hold on;
  set(gca, 'Position', [0 0 1 1]);
  set(gcf, 'PaperUnits', 'inches', ...
           'PaperSize', [8.5 8], ...
           'PaperPositionMode', 'manual', ...
           'PaperPosition', [.25 2 8 4]);
  
  yy = [1 22] + 66;
  xx = [1 12] + 19;
  
  if is_roi
    h = plot(yy([1 1 2 2 1]), xx([1 2 2 1 1]), 'r', 'LineWidth', 4);
    print('-dpng', 'figs/pv/roi');

  elseif is_signal
    mask = mask .* (fa > .25);
    fcs = convhulln(u);
    set(gca, 'XLim', yy, 'YLim', xx);
    for r = xx(1):xx(2)
      for c = yy(1):yy(2)
        if ~mask(r,c), continue, end
        s = flat(S(r,c,[1:end 1:end]));
        odf(s/1.2, u, fcs, [r c 0]');
      end
    end
    print('-dpng', 'figs/pv/signal');

  elseif is_1t
    mask = mask .* (fa > .25);
    fcs = convhulln(u);
    set(gca, 'XLim', yy, 'YLim', xx);
    for r = xx(1):xx(2)
      for c = yy(1):yy(2)
        if ~mask(r,c), continue, end
        s = flat(S(r,c,[1:end 1:end]));
        [d D] = direct_1T(u, b, s);
        [f m] = full_tensor_odf(D, u, b);
        odf_axes(32*f, u, m, [r c 0]', 'r');
      end
    end
    print('-dpng', 'figs/pv/odf_1t');

  elseif is_2t
    mask = mask .* (fa > .25);
    fcs = convhulln(u);
    set(gca, 'XLim', yy, 'YLim', xx);

    lb = [-inf -inf -inf 100 100 -inf -inf -inf 100 100];
    ub = [ inf  inf  inf inf inf  inf  inf  inf inf inf];
    [f_fn h_fn] = model_2tensor(u, b);
    
    for r = xx(1):xx(2)
      for c = yy(1):yy(2)
        if ~mask(r,c), continue, end
        s = flat(S(r,c,[1:end 1:end])); s = double(s);
        
        % determine initial config based on single tensor fit
        [d D] = direct_1T(u, b, s);
        [V U] = svd(D);
        m = V(:,1); m = m / norm(m);
        if compute_cp(D) > .2
          l = [U(1) (U(2,2)+U(3,3))/2]' * 1e6;
          m1 = V(:,2); m1 = m1 / norm(m1);
          m2 = V(:,3); m2 = m2 / norm(m2);
          x0 = [m1; l; m2; l];
          est = est_lm(x0, lb, ub, f_fn, h_fn);
          X = est(s);

          [m1 l1 m2 l2] = state2tensor(X);
          X1 = [r r; c c] + m1(1:2)*[-1 1]/2;
          X2 = [r r; c c] + m2(1:2)*[-1 1]/2;
          plot(X1(2,:),X1(1,:),'r', ...
               X2(2,:),X1(1,:),'r', ...
               'LineWidth', 3);
        else
          X = [r r; c c] + m(1:2)*[-1 1]/2;
          plot(X(2,:), X(1,:), 'r', 'LineWidth', 3);
        end
        drawnow
      end
    end
    print('-dpng', 'figs/pv/odf_2t_axes');

  elseif is_sh
    mask = mask .* (fa > .25);
    fcs = convhulln(u);
    set(gca, 'XLim', yy, 'YLim', xx);
    L = 6;
    lambda = .008;

    for r = xx(1):xx(2)
      for c = yy(1):yy(2)
        if ~mask(r,c), continue, end
        s = flat(S(r,c,[1:end 1:end])); s = double(s);
        F = sh2odf(s, u, lambda, L);
        odf(30*F, u, fcs, [r c 0]'); drawnow
      end
    end
    %print('-dpng', 'figs/pv/odf_sh');
  end
end


function [f m] = full_tensor_odf(D, u, b)
  f = sqrt((pi*b)./sum((u * inv(D)) .* u, 2));
  f = f / sum(f);  % unit mass
  if nargout == 2
    [V U] = svd(D);
    m = U(1) * V(:,1);
  end
end

function v = compute_cp(D)
  S = sort(eig(D), 1, 'descend');
  assert(S(1) >= S(2) && S(2) >= S(3));
  v = 2*(S(2) - S(3))/sum(S);
end



function F = sh2odf(s, u, lambda, L)
  paths;
  s = s / norm(s);

  %[Y B R] = MultiResParam(0, u);
  %[Cf F] = odfestim_fODF(s, u, L, B, Y, R, lambda);
  [Cs S Cf F] = odfestim(s, u, L, lambda);
  F = S;
  F = F /sum(F);
end
