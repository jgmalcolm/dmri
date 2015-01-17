function D = tend2mask(fn)
  paths;
  D = shiftdim(nrrdZipLoad(fn),1);
  D = reshape(D, [], 7);
  D = D(D(:,1) > 0,2:end)';
end
