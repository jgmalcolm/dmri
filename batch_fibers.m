function batch_fibers(F_icp);
  base = '/projects/schiz/pi/malcolm/fa/';
  clf
  %X_icp = loadsome(sprintf('%s/points_03_24_28_icp',base), 'Xi');
  %X_cnt = loadsome(sprintf('%s/points_03_24_28_counts',base),'counts');
  %F_icp = repackage(X_icp,X_cnt);
  ref   = loadsome(sprintf('%s/points_03_24_28_ref',base),'ref');
  [r03.bins r03.nc r03.sz] = fibers(03,F_icp(:,1),ref(1).u,ref(1).v);
  [r24.bins r24.nc r24.sz] = fibers(24,F_icp(:,2),ref(2).u,ref(2).v);
  [r28.bins r28.nc r28.sz] = fibers(28,R_icp(:,3),ref(3).u,ref(3).v);
  save('study_fibers', 'r03', 'r24', 'r28');
end

function [bins s_nc s_sz] = fibers(lbl,F_icp,u,v)
  origin = [0 0 0];
  base = '/projects/schiz/pi/malcolm/fa/';
  d = dir(sprintf('%s/*_%02d_3.mat', base, lbl))';
  
  tx = loadsome('label_sets_transforms', 'pose'); tx = tx{lbl};

  ALL = read_group('all');
  NC = read_group('nc');
  
      if lbl == 3,   eig = 1; len = 90;
  elseif lbl == 24,  eig = 1; len = 95;
  elseif lbl == 28,  eig = 2; len = 95; end
  
  s_nc = {};
  s_sz = {};
  b_min = 0; b_max = 0;
  
  for i = 1:numel(d)
    id = sscanf(d(i).name, '%05d');
    
    % load 2T
    fn = sprintf('%s/%05d_%02d_3', base, id, lbl);
    ff_2 = loadsome(fn, 'ff');
    keep = cellfun(@(f) size(f,2) < len && size(f,2) > 25, ff_2);
    ff_2 = {ff_2{keep}};
    ff_2 = cellfun(@orient, ff_2, 'Un',0);
    if numel(ff_2) < 5, continue, end

    % load 1T
    fn = sprintf('%s/%05d_%02d_3_1t', base, id, lbl);
    [ff_1 mm] = loadsome(fn, 'ff', 'mm');
    keep = cellfun(@(f) size(f,2) < len && size(f,2) > 25, ff_1);
    ff_1 = {ff_1{keep}}; vv_1 = cellfun(@f2v_1, ff_1, 'Un',0);
    [ff_1 vv_1] = cellfun(@orient, ff_1, vv_1, 'Un',0);
    vv_1_bak = vv_1; %save

    is_nc = ismember(id, NC);

    fprintf('case%05d %s %d\n', id, ...
            iff(is_nc, 'normal', 'schiz '), numel(ff_2));

    ff_icp = F_icp{id == ALL};
    
    % bin the values
    [xx ss vv_2] = fiber2arc(ff_2, mm, eig, ff_icp);
    vv_2_bak = vv_2; % save
    [vv_2 bins] = ds2bin(ss, vv_2);
     vv_1       = ds2bin(ss, vv_1);
    
    mu_1 = mean(cat(3,vv_1{:}),3);
    mu_2 = mean(cat(3,vv_2{:}),3);
    
    % use old method
    T = tx{id == ALL};
    [xx ss vv_2_] = fiber2arc_old(ff_2, mm, eig, T, origin);
    [vv_2_ bins_] = ds2bin(ss, vv_2_);
     vv_1_        = ds2bin(ss, vv_1_bak);

%     sp(7,7,7*(i-1)+1); hold on
%     x = [ff_2{:}];
%     plot3(x(1,:),x(2,:),x(3,:),'r.', 'MarkerSize', 1);
%     view(0,-180);
%     axis equal off
%     set(gca, 'XLim', [50 100], 'YLim', [0 80], 'ZLim', [0 80]);

%     sp(7,7,7*(i-1)+2); hold on
%     x = [ff_icp{:}];
%     plot3(x(1,:),x(2,:),x(3,:),'r.', 'MarkerSize', 1);
%     view(0,-180);
%     axis equal off
%     set(gca, 'XLim', [50 100], 'YLim', [0 80], 'ZLim', [0 80]);

%     sp(7,7,7*(i-1)+3); hold on
%     map(@(x) plot3(x(1,:),x(2,:),x(3,:),'r'), f_c);
%     view(0,-180);
%     axis equal off
%     set(gca, 'XLim', [50 100], 'YLim', [0 80], 'ZLim', [0 80]);

    sp(7,7,7*(i-1)+1); hold on
    cellfun(@(x) plot(x(1,:),x(3,:),'r'), ff_2); axis equal off
    set(gca, 'XLim', [50 100]); view(2);
    
    sp(7,7,7*(i-1)+2); hold on
    cellfun(@(x) plot(x(1,:),x(3,:),'w'), ff_icp); axis equal off
    set(gca, 'XLim', [50 100]); view(2);

    
    % registered
    sp(7,7,7*(i-1)+4); hold on
    cellfun(@(v) plot(bins, v(1,:),'b'), vv_1); axis off
    plot([0 0], [0 .6], 'w');
    set(gca, 'XLim', [-50 50], 'YLim', [0 .8]);
    sp(7,7,7*(i-1)+6); hold on
    cellfun(@(v) plot(bins, v(1,:),'r'), vv_2); axis off
    plot([0 0], [0 .6], 'w');
    set(gca, 'XLim', [-50 50], 'YLim', [0 .8]);
    
    % original
    sp(7,7,7*(i-1)+3); hold on
    cellfun(@(v) plot(bins_, v(1,:),'b'), vv_1_); axis off
    plot([0 0], [0 .6], 'y');
    set(gca, 'XLim', [-50 50], 'YLim', [0 .8]);
    sp(7,7,7*(i-1)+5); hold on
    cellfun(@(v) plot(bins_, v(1,:),'r'), vv_2_); axis off
    plot([0 0], [0 .6], 'y');
    set(gca, 'XLim', [-50 50], 'YLim', [0 .8]);

    if i == 7
%       for i = 1:7
%         x = f_c{i}; y = vv_1_{i}; z = vv_2_{i};

%         sp(7,7,7*(i-1)+5); hold on
%         plot3(x(1,:),x(2,:),x(3,:),'w'); axis equal off
%         set(gca, 'XLim', [40 110], 'YLim', [0 80], 'ZLim', [0 80]);
%         view(0,-180);

%         sp(7,7,7*(i-1)+6); hold on
%         plot3(x(1,:),x(2,:),y(1,:),'b.', ...
%               x(1,:),x(2,:),z(1,:),'r.','MarkerSize',1); axis off
%         %set(gca, 'XLim', [40 110], 'YLim', [0 80], 'ZLim', [0 .6]);
%         view(3);

% %         sp(7,7,7*(i-1)+7); hold on
% %         plot(x(1,:),y(1,:),'w'); axis off
% %         plot([73 73], [0 .6], 'y'); 
% %         set(gca, 'XLim', [50 100], 'YLim', [0 .6]);

%         sp(7,7,7*(i-1)+7); hold on
%         plot3(x(1,:),x(2,:),(y(1,:) - z(1,:)).^2,'y.','MarkerSize',1); axis off
%         %set(gca, 'XLim', [40 110], 'YLim', [0 80]);
%         view(3);
%       end
      keyboard
    end

    if is_nc,  s_nc{end+1} = {bins mu_1 mu_2};
    else       s_sz{end+1} = {bins mu_1 mu_2}; end
    if bins(1) < b_min,    b_min = bins(1);   end
    if b_max < bins(end),  b_max = bins(end); end
  end
  
  
  % gather samples
  n = b_max - b_min + 1;
  [nc_mu1 nc_mu2] = deal(nan(size(mu_1,1), n, numel(s_nc)));
  [sz_mu1 sz_mu2] = deal(nan(size(mu_1,1), n, numel(s_sz)));
  for i = 1:numel(s_nc)
    bins = s_nc{i}{1};
    bb = 1:numel(bins);
    nc_mu1(:,bins(1)-b_min + bb,i) = s_nc{i}{2};
    nc_mu2(:,bins(1)-b_min + bb,i) = s_nc{i}{3};
  end
  for i = 1:numel(s_sz)
    bins = s_sz{i}{1};
    bb = 1:numel(bins);
    sz_mu1(:,bins(1)-b_min + bb,i) = s_sz{i}{2};
    sz_mu2(:,bins(1)-b_min + bb,i) = s_sz{i}{3};
  end
  
  % final output
  s_nc = struct('mu1', nc_mu1, 'mu2', nc_mu2);
  s_sz = struct('mu1', sz_mu1, 'mu2', sz_mu2);
  bins = b_min:b_max;
end

function s = update(s, b, v1, v2)
  s
  m = size(v1,1);
  % lengthen on left?
  if b(1) < s.bins(1)
    % reference is shorter
    dx = s.bins(1) - b(1);
    warning('1: dx %d\n', dx);
    s.vv1 = padL(s.vv1, dx);
    s.vv2 = padL(s.vv2, dx);
    s.bins = b(1):s.bins(end);
    assert(isequal(s.bins-s.bins(1)+1, 1:numel(s.bins)));
  elseif s.bins(1) < b(1)
    % new is shorter
    dx = b(1) - s.bins(1);
    warning('2: dx %d\n', dx);
    v1 = padL(v1, dx);
    v2 = padL(v2, dx);
  end
  % lengthen on right?
  if s.bins(end) < b(end)
    % reference is shorter
    dx = b(end) - s.bins(end);
    warning('3: dx %d\n', dx);
    s.vv1 = padR(s.vv1, dx);
    s.vv2 = padR(s.vv2, dx);
    s.bins = s.bins(1):b(end);
    assert(isequal(s.bins-s.bins(1)+1, 1:numel(s.bins)));
  elseif b(end) < s.bins(end)
    % new is shorter
    dx = s.bins(end) - b(end);
    warning('4: dx %d\n', dx);
    v1 = padR(v1, dx);
    v2 = padR(v2, dx);
  end
  assert(s.bins(1) <= b(1) && b(end) <= s.bins(end));
  
  % update
  s.n = s.n + 1;
  s.vv1(:,:,s.n) = v1;
  s.vv2(:,:,s.n) = v2;
end

function M = padL(M, dx)
  M(:,dx+(1:end),:) = M;   % move
  M(:,1:dx,:)       = nan; % fill
end
function M = padR(M, dx)
  M(:,end+(1:dx),:) = nan; % fill
end

function [f g] = orient(f, g)
  if size(f,2) < 1, return, end
  if f(1,1) < f(1,end)
    f = f(:,end:-1:1); % reverse
    if nargin == 2
      g = g(:,end:-1:1);
    end
  end
end


function v = f2v_1(f)
  D  = f(4:9,:);
  
  D_ = D;
  tr = sum(D([1 4 6],:));
  D_([1 4 6],:) = D([1 4 6],:) - tr([1 1 1],:)/3;
  
  
  w = diag([1 2 2 1 2 1]);
  nrm = sqrt(sum(w*D.^2))+eps;
  fa = sqrt(3/2 * sum(w*D_.^2))./nrm;
  
  n = size(f,2);
  rd = zeros(1,n);
  for i = 1:n
    [U V] = svd(reshape(D([1 2 3 2 4 5 3 5 6],i), 3, 3));
    rd(i) = V(2,2)/V(1,1);
  end
  
  v = [fa; fa; tr; nrm; rd];
end
