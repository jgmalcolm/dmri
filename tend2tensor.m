function [D M] = tend2tensor(fn)
  paths;
  D = shiftdim(nrrdZipLoad(fn),1);
  sz = size(D);
  D = reshape(D, [], 7);
  M = D(:,1) > 0;
  
  M = reshape(M, sz(1:3));
  D = reshape(D(:,2:7), [sz(1:3) 6]);
end
