function [vv bins nvv] = ds2bin(ss, vv)
  
  % determine min/max bin
  bins = colon(floor(min(cellfun(@(s) min(s), ss))), ...
               ceil( max(cellfun(@(s) max(s), ss))));
  m = size(vv{1},1);
  n = numel(bins);
  sz = [n 1];
  vv_empty = zeros(m,n);
  
%   assert(all(cellfun(@(s) s(1) < s(end), ss)));
  
  [vv nvv] = cellfun(@fiber2bins, ss, vv, 'Un', 0);
  nvv = sum(vertcat(nvv{:}),1);
  
  function [vv nvv] = fiber2bins(s, vv_)
    ds_L = floor(s);  ds_R = ceil(s+eps);
    w_R  = s - ds_L;  w_L  = 1 - w_R;
    
    % convert ds into indices
    ds = [ds_L(:); ds_R(:)] - bins(1) + 1;
    
    % distribute values
    vv = vv_empty;
    for i = 1:m
      vals = [w_L .* vv_(i,:) w_R .* vv_(i,:)];
      vv(i,:)  = accumarray(ds, vals, sz);
    end
    nvv = accumarray(ds, [w_L w_R], sz)';
  end
end
