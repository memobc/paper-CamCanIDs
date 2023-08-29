function fd = D_extract_motion(x)

   T = readtable(x, 'FileType', 'text', 'Delimiter', '\t');
   fd = mean(T.framewise_displacement, 'omitnan');

end
