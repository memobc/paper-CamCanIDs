function [yesno] = isequal_nii(inputArg1,inputArg2)

Y1 = spm_read_vols(spm_vol(inputArg1));
Y2 = spm_read_vols(spm_vol(inputArg2));
yesno = isequaln(Y1, Y2);

end

