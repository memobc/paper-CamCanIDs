function [areEqual] = compare_connectivity(ConnTbl,NewConnTbl)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

NewConnTbl = NewConnTbl(1:400, 1:400); % remove the hippocampus
areEqual = isequal(NewConnTbl, ConnTbl); % are the connectivity matrices equal?

end

