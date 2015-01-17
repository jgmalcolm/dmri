function tensors2nhdr(D, fn)
  assert(ndims(D) == 3); % 2D tensor field

  hdr = sprintf(['NRRD0005\n' ...
                 '# Complete NRRD file format specification at:\n' ...
                 '# http://teem.sourceforge.net/nrrd/format.html\n' ...
                 'type: float\n' ...
                 'dimension: 4\n' ...
                 'space: left-posterior-superior\n' ...
                 'sizes: %d %d 1 %d\n' ...
                 'space directions: (1,0,0) (0,1,0) (0,0,1) none\n' ...
                 'centerings: cell cell cell ???\n' ...
                 'kinds: space space space list\n' ...
                 'endian: little\n' ...
                 'encoding: gzip\n' ...
                 'space units: "mm" "mm" "mm"\n' ...
                 'space origin: (0,0,0)\n' ...
                 'data file: %s.raw.gz\n'], ...
                size(D), fn);
  
  
  % write header
  fid = fopen([fn '.nhdr'], 'w');
  fprintf(fid, hdr);
  fclose(fid);
  
  % write and compress data
  fid = fopen([fn '.raw'], 'w');
  fwrite(fid, single(D), 'single');
  fclose(fid);
  system(['rm -f ' fn '.raw.gz && gzip ' fn '.raw']); % compress
end