function R = from_squareform(squareform_r)

    squareform_d = 1-squareform_r;
    D = squareform(squareform_d);
    R = 1-D;

end

