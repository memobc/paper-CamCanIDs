% consolidate scalining analysis

two   = load('scaling-analysis_numCPUs-2.mat');
four  = load('scaling-analysis_numCPUs-4.mat');
five  = load('scaling-analysis_numCPUs-5.mat');
six   = load('scaling-analysis_numCPUs-6.mat');
eight = load('scaling-analysis_numCPUs-8.mat');

% continuing to see benefits up to 12 workers
figure('Name', 'Benefits up to 12 workers');
plot(two.numWorkers, [two.t' four.t' five.t' six.t' eight.t'])
legend('two', 'four', 'five', 'six', 'eight')
xlabel('Number of Workers')
ylabel('Time To Completion')

% no benefit to having more than 5 cpus
figure('Name', 'No benefit to more than 5 cpus');
plot([2 4 5 6 8], [two.t' four.t' five.t' six.t' eight.t']')
legend('2', '4', '5', '6', '8', '12')
xlabel('Number of CPUs')
ylabel('Time To Completion')

% no benefit to having more than 12 workers
five_expanded = load('scaling-analysis_numCPUs-5_numWorkers-14_2_24.mat');
figure('Name', 'No Benefits to more than 12 workers');
plot([five.numWorkers five_expanded.numWorkers], [five.t five_expanded.t])

% is there a startup cost?
five_noSubstream = load('scaling-analysis_numCPUs-5_startupCost_noSubstream.mat');
five_Substream   = load('scaling-analysis_numCPUs-5_startupCost_Substream.mat');

figure('Name', 'Is there a startup cost? Without Substeam Option');
plot(five_noSubstream.t)

figure('Name', 'Is there a startup cost? With Substream Option');
plot(five_Substream.t)