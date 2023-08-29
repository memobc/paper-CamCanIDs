function fitlm_wrapper(tbl, formula)
% a wrapper function around Matlab's fitlm function
% prints a formatted string to the console.

lm_fit = fitlm(tbl, formula);
hypothVec = zeros(1, length(lm_fit.CoefficientNames));
hypothVec(end) = 1;
[P,F,R] = coefTest(lm_fit, hypothVec);
fprintf('\n%s\t\tF(%d, %d) = %.03f, p = %.03f \n', lm_fit.Formula, R, lm_fit.DFE, F, P)

end