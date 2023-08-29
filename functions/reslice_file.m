function out = reslice_file(defImg, resliceImgs)

    matlabbatch{1}.spm.spatial.coreg.write.ref = {defImg}; % image defining space
    matlabbatch{1}.spm.spatial.coreg.write.source = cellstr(resliceImgs); % images to reslice
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

    spm_jobman('run', matlabbatch);

    out = cellstr(resliceImgs);
    out = cellfun(@append_r, out, 'UniformOutput', false);
    out = char(out);
    
    function out = append_r(in)
        % add an "r" to the beginning of a filename
        [dir, fn, ext] = fileparts(in);
        out = fullfile(dir, ['r' fn ext]);
    end

end