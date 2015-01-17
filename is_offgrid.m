function r = is_offgrid(pos, sz)
  r = any(pos < .5 | (sz+.5)' < pos);
end
