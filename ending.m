function [ff_ fid] = ending(ff, A, B)
%this function finds fibers that start/end in A and B.
  N = 15000; %not more than N fibers we expect in one bundle
  n = numel(ff);
  ff_ = cell(1,N);
  cnt = 0;
  fid = cell(1,N);

  [nx ny nz] = size(A);

  for i = 1:n
    % unpack
    f = round(ff{i});
    if(size(f,2) < 7)
        continue;
    end
    %use only the last 3 end points
    xx = [f(1,1:3) f(1,end-2:end)];
    yy = [f(2,1:3) f(2,end-2:end)];
    zz = [f(3,1:3) f(3,end-2:end)];

    % clamp
    xx = max(1, min(nx, xx));
    yy = max(1, min(ny, yy));
    zz = max(1, min(nz, zz));
    
    % check if end points lie in A and B
    ind = ((zz-1)*ny + (yy-1))*nx + xx;
    %is_A = (A(ind(1)) == 1) && (B(ind(2)) == 1);
    %is_B = (A(ind(2)) == 1) && (B(ind(1)) == 1);
    is_A = any(A(ind(1:3))) && any(B(ind(4:end)));
    is_B = any(B(ind(1:3))) && any(A(ind(4:end)));
    if is_A || is_B
        cnt = cnt + 1;
        ff_{cnt} = ff{i};
        fid{cnt} = i;
    end
    
    
  end
  
  % trim
  if cnt
    ff_ = ff_(1:cnt);
    fid = fid(1:cnt);
    fid = cell2mat(fid);
  else
   ff_ = [];
   fid = [];
  end

end
