function batch_fa_error
  
  for b = [1000]
    fn = sprintf('matlab_2cross_lambda_b%d', b);
    tract = loadsome(fn, 'tract');
    
    ff_1t = loadsome([fn '_1T'], 'ff');
    ff_kf = loadsome([fn '_2T_KF'], 'ff');
    ff_lm = loadsome([fn '_2T_LM'], 'ff');

    [e_1t e_kf e_lm] = deal(cell(size(tract)));
    for i = 1:numel(tract)
      T = tract(i);
      fa = l2fa(T.lambda(1:2));
      fprintf('FA: b=%d  angle: %d  w %.1f  fa %.2f\n', b, T.th, T.w, fa);
      ff_ = filter_crossing(ff_kf{i}, T.is_cross);
      e_1t{i} = error(@one2fa, ff_1t{i}, fa);
      e_kf{i} = error(@two2fa, ff_,      fa);
      e_lm{i} = error(@two2fa, ff_lm{i}, fa);
    end
    
    save([fn '_2T_e'], 'e_1t', 'e_kf', 'e_lm');
  end
end

function e = error(fn, ff, fa)
  e = map(fn, ff);
  e = abs([e{:}] - fa);
end

function fa = two2fa(f)
  if size(f,1) == 12, f = f(3:end,:); end % drop coordinates
  n = size(f,2);
  fa = zeros(1,n);
  for i = 1:n
    [m1 l1 m2 l2] = state2tensor(f(:,i));
    fa(i) = l2fa(l1) + l2fa(l2);
  end
  fa = fa / 2;
end
function fa = one2fa(D)
  n = size(D,2);
  D = D([1 2 3 2 4 5 3 5 6],:);
  D = reshape(D, [3 3 n]);
  fa = zeros(1,n);
  for i = 1:n
    fa(i) = d2fa(D(:,:,i));
  end
end
