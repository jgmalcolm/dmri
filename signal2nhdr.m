function signal2nhdr(S, u, b, fn)
  assert(ndims(S) == 4); % 3D signal
  assert(size(u,1) > 3 && size(u,2) == 3);

  hdr = sprintf(['NRRD0005\n' ...
                 '# Complete NRRD file format specification at:\n' ...
                 '# http://teem.sourceforge.net/nrrd/format.html\n' ...
                 'type: float\n' ...
                 'dimension: 5\n' ...
                 'space: left-posterior-superior\n' ...
                 'sizes: %d %d 1 %d\n' ...
                 'space directions: (1,0,0) (0,1,0) (0,0,1) none\n' ...
                 'centerings: ??? cell cell cell\n' ...
                 'kinds: list space space space\n' ...
                 'endian: little\n' ...
                 'encoding: gzip\n' ...
                 'space units: "mm" "mm" "mm"\n' ...
                 'space origin: (0,0,0)\n' ...
                 'data file: %s.raw.gz\n' ...
                 'modality:=DWMRI\n' ...
                 'DWMRI_b-value:=%d\n'], ...
                size(S), fn, b);
  grads = '';
  for i = 1:size(u,1)
    grads = sprintf('%sDWMRI_gradient_%04d:= %9f %9f %9f\n', ...
                    grads, i-1, u(i,:));
  end
  
  
  % write header
  fid = fopen([fn '.nhdr'], 'w');
  fprintf(fid, hdr);
  fprintf(fid, grads);
  fclose(fid);
  
  % write and compress data
  fid = fopen([fn '.raw'], 'w');
  fwrite(fid, single(S), 'single');
  fclose(fid);
  system(['rm -f ' fn '.raw.gz && gzip ' fn '.raw']); % compress
end
