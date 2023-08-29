function [L, R] = split_surface_mesh(M)
% function for splitting a surface mesh into left and right hemipheres

nVertices = size(M.vertices, 1);
halfTrue  = true(nVertices/2, 1);
halfFalse = false(nVertices/2, 1);

L = gifti(spm_mesh_split(M, vertcat(halfTrue, halfFalse)));
R = gifti(spm_mesh_split(M, vertcat(halfFalse, halfTrue)));

end