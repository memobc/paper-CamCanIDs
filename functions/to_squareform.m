function squareform_r = to_squareform(R)
% turns a R matrix to a squareform vct

D              = 1-R;
squareform_d = squareform(D);
squareform_r = squareform_d;

end