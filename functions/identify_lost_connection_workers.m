% read in the slurm outputs and check for "lost connection" errors

a = dir([pwd filesep '*.out']);

for i = 1:length(a)
    f = fileread(a(i).name);
    %fprintf([f '\n\n']);
    %pause(1)
    if contains(f, 'Error') | contains(f, 'TIME')
        fprintf([a(i).name '\n'])
        edit(a(i).name)
    end
end