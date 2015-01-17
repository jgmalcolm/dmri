function xx = analytic_registration(xx)

  label_cnt = numel(xx{1});
  wt = [1 1 1]/3;
  %wt = [1 0 0];
  
  Covar = cell(size(xx,2),label_cnt);

  n = numel(xx);
  
  for m = 1:n
    % compute reference centroid, covariance, stdev
    Cm = [];
    for j = 1:label_cnt  
      X = xx{m}{j};
      Cm = [Cm; mean(X)];
      Covar{m,j} = cov(X);
      S{m,j} = diag(std(X));
    end

    % compare against rest of images
    for h = m+1:n
      
      C = [];
      for j = 1:label_cnt
        C = [C; mean(xx{h}{j})];
        Covari = cov(xx{h}{j});

        % find angle between covariance matrices
        [a d b] = svd(Covar{m,j} * Covari');
        rot = a * eye(3) * b';
        theta_x(j) = atan(-rot(2,3)/rot(3,3));
        theta_y(j) = atan(rot(1,3) * cos(theta_x(j))/rot(3,3));
        theta_z(j) = atan(-rot(1,2)/rot(1,1));
      end
      
      %%-- translation
      t = sum([wt; wt; wt] .* (C' - Cm'),2);
      
      %%-- rotation
      nthetax = sum(wt .* theta_x);
      nthetay = sum(wt .* theta_y);
      nthetaz = sum(wt .* theta_z);

      R = [1 0 0;0 cos(-nthetax) -sin(-nthetax);0 sin(-nthetax) cos(-nthetax)] * ...
          [cos(-nthetay) 0 sin(-nthetay);0 1 0;-sin(-nthetay) 0 cos(-nthetay)] * ...
          [cos(-nthetaz) -sin(-nthetaz) 0;sin(-nthetaz) cos(-nthetaz) 0;0 0 1];
      A = [inv(R) -t]; % inverse transform
      
      tpts = transform(xx{h}, A, mean(C));
      
      %%-- scaling
      C = [];
      for j = 1:label_cnt
        C = [C; mean(tpts{j})];
        S{h,j} = diag(std(tpts{j}));

        sxx(j) = sqrt(S{m,j}(1,1)/S{h,j}(1,1));
        syy(j) = sqrt(S{m,j}(2,2)/S{h,j}(2,2));
        szz(j) = sqrt(S{m,j}(3,3)/S{h,j}(3,3));
      end
      scx = sum(wt .* sxx); 
      scy = sum(wt .* syy); 
      scz = sum(wt .* szz);
      
      % apply transformation about the origin of C
      A = [scx 0 0 0;0 scy 0 0;0 0 scz 0;];
      tpts = transform(tpts, A, mean(C));
      
      fprintf('%2d-%2d, (%5.1f %5.1f %5.1f)  (%5.1f %5.1f %5.1f)  (%0.3f %0.3f %0.3f)\n', ...
              m, h, t, [nthetax nthetay nthetaz]*180/pi,scx,scy,scz);

      xx{h} = tpts;
    end
  end
end



function m_ = transform(m, pose, orig)
  for i = 1:size(m,2)
      pts = m{i};
      pts = pts - repmat(orig,[size(pts,1),1]); % center about origin
      pts_ = pose * [pts ones(size(pts,1),1)]';
      m_{i} = (pts_ + repmat(orig',[1,size(pts_,2)]))'; % un-center
  end
end
