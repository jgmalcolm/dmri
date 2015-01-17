function show_curves(ff,dd)
  disp = true;

  vv = map(@average_fibers,  ff);
  %dd = map(@average_tensors, dd);
  vv = reshape({vv{:,1:3:end}}, size(vv,1), []);
%   vv(:,2:2:end) = [];
  %dd(:,2:2:end) = [];

  prnt = @(i) print('-dpng', '-r100', sprintf('figs/miccai_1t/synth_%02d',i));

  [nmode nth] = size(vv);
  
  clf
  max_len = max(flat(cellfun(@(y) max(cellfun(@(x)size(x,2),y)), ff)));
  xx = 1:max_len;
  for i = 1:numel(vv)
    if disp, sp(nth,nmode,i), else clf, end
    [ax h1 h2] = plotyy(xx,vv{i}(1,:), xx,vv{i}(2,:));
    set(ax(1), 'YLim', [1e-9 3e-8]);
    set(ax(2), 'YLim', [0 1.7e4]);
    set(ax, 'XTickLabel', [], 'YTick', []);
    set(h1, 'Color', 'r', 'LineWidth', 4);
    set(h2, 'Color', 'b', 'LineWidth', 4);
    axis(ax, 'off');
    if ~disp, prnt(i), end
  end
end


function v = fibers2scalars(X)
  n = size(X,2);
  [x X P] = deal(X(1:2,:), X(3:7,:), X(8:end,:));
  P = reshape(P, 5, 5, []);
  
  v = zeros(2,n);
  for i = 1:n
    v(1,i) = det(P(1:3,1:3,i));
    v(2,i) = det(P(4:5,4:5,i));
  end
  %v(end+1,:) = l2fa(X(4:5,:));
end

function v = average_fibers(ff)
  vv = map(@fibers2scalars, ff);
  vv = reshape(vv, 1, 1, numel(vv));
  vv = cell2mat(vv);
  v = mean(vv,3);
end


function v = average_tensors(dd)
  vv = map(@tensors2scalars, dd);
  vv = reshape(vv, 1, 1, numel(vv));
  vv = cell2mat(vv);
  v = mean(vv,3);
end

function v = tensors2scalars(D)
  D = reshape(D([1 2 3 2 4 5 3 5 6],:), 3, 3, []);
  n = size(D,3);
  v = zeros(2,n);
  for i = 1:n
    d = D(:,:,i);
    v(:,i) = [d2fa(d) cp(d)];
  end
end


function v = cp(D)
  S = sort(eig(D), 1, 'descend');
  assert(S(1) >= S(2) && S(2) >= S(3));
  v = 2*(S(2) - S(3))/sum(S);
end
