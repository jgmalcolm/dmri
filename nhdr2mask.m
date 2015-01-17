function m = nhdr2mask(fn, sz)
  fid = fopen(fn, 'r');
  m = fread(fid, inf, 'short') ~= 0;
  fclose(fid);
  m = reshape(m, sz);
end
