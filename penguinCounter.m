function penguinCounter(folders,varargin)
%Image-level penguin density estimation for all images in FOLDERS using the 
%pretrained CNN model found in MODELPATH. 
%The computation is done on the gpu indexed by GPU. 
%Results are stored in the source folders.
%
%Example:
% penguinCounter('/data/DAMOa,/data/LOCKb',
%  'gpu',2,'modelPath','/data/penguinCounterNet.mat');

%setup 
if exist('vl_setupnn','file') == 0
  run('matconvnet-1.0-beta25/matlab/vl_setupnn.m');
end

opts.gpu = [];
opts.modelPath = fullfile(pwd,'penguinCounterNet.mat');

opts = vl_argparse(opts,varargin);

%if exist('opts.modelPath','file') == 0
%  error(['Model not found in ' opts.modelPath]);
%end

%create imdb
[imdb,fs] = buildIMDBfromFolders(folders);

%load model
import dagnn.*
net = load(opts.modelPath);
net = dagnn.DagNN.loadobj(net.net);

%init gpu
if ~isempty(opts.gpu)
  if isstr(opts.gpu)
    opts.gpu = str2double(opts.gpu);
  end
  g = gpuDevice(opts.gpu);
end

%print run info
clc;
disp('----- Penguin Counter -----')
disp(['Model path: ' opts.modelPath]);
disp(['GPU: ' num2str(g.Index) ' - ' g.Name]);
disp([num2str(numel(imdb)) ' images found']);
disp('Processing folders:');
for f = 1:numel(fs)
  disp(fs{f});
end
disp('---------------------------')
disp('');

%run counting
count = runCounter(net,imdb,opts.gpu);

%save
cell2csv(['count-' date '.csv'],count);
