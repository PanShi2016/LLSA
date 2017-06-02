function [] = LLSA(k,alpha) 
% Local Lanczos Spectral Approximation
% k: number of Lanczos iteration
% alpha: a parameter controls local minimal conductance

if nargin < 1
    k = 4;
end

if nargin < 2
    alpha = 1.03;
end

graphPath = '../example/Amazon/graph';
communityPath = '../example/Amazon/community';

% load graph
graph = loadGraph(graphPath);

% load truth communities
comm = loadCommunities(communityPath);

% choose a community from truth communities randomly
commId = randi(length(comm));

% choose 3 nodes from selected community randomly
seedId = randperm(length(comm{commId}),3);
seed = comm{commId}(seedId);

% grab subgraph from each seed set
sample = hkgrow(graph,seed);

% preprocessing, delete isolated nodes
subgraph = graph(sample,sample);
idx = find(sum(subgraph)==0);
if length(idx) > 0
    sample = setdiff(sample,sample(idx));
end

% approximate local eigenvector of transition matrix with largest eigenvalue
subgraph = graph(sample,sample);
p = zeros(1,length(sample));
[~, ind] = intersect(sample,seed);
p(ind) = 1/length(ind);
p = p/norm(p);
[v,~] = lanczos_Nrw(subgraph,p',k,1);

% bound detected community by local minimal conductance
% compute conductance
[~,I] = sort(v,'descend');
conductance = zeros(1,length(I));
for j = 1 : length(I)
    conductance(j) = getConductance(subgraph,I(1:j));
end

% compute first local minimal conductance
[~,I2] = intersect(I,ind);
startId = max(I2);
index = GetLocalCond(conductance,startId,alpha);
detectedComm = sample(I(1:index));

% compute F1 score
jointSet = intersect(detectedComm,comm{commId});
jointLen = length(jointSet);
F1 = 2*jointLen/(length(detectedComm)+length(comm{commId}));

% printing out result
fprintf('The detected community is')
disp(detectedComm')
fprintf('The F1 score between detected community and ground truth community is %.3f\n',F1)

% save out result
savePathandName = '../example/Amazon/output_LLSA.txt';
dlmwrite(savePathandName,'The detected community is','delimiter','');
dlmwrite(savePathandName,detectedComm','-append','delimiter','\t','precision','%.0f');
dlmwrite(savePathandName,'The F1 score between detected community and ground truth community is','-append','delimiter','');
dlmwrite(savePathandName,F1,'-append','delimiter','\t','precision','%.3f');

end
