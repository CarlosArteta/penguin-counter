function count = runCounter(net,imdb,gpu)
%run the penguin counter given by NET on the images in the IMDB

net.mode = 'test';
net.vars(net.getVarIndex('x36')).precious = 1 ;
net.vars(net.getVarIndex('pred_s')).precious = 1 ;
net.vars(net.getVarIndex('pred_l')).precious = 1 ;
% net.vars(net.getVarIndex('pred_u')).precious = 1 ;
segTH = 1;
densAmp = 1e4;
%
if ~isempty(gpu)
  net.move('gpu');
  useGpu = 1;
else
  useGpu = 0;
end

count = cell(numel(imdb),2);

%%
for i=1:numel(imdb)
  disp(['Image ' num2str(i) '/' num2str(numel(imdb))]) ;
  
  try
    orgIm = imread(imdb{i});
  catch
    warning('Could not read %s', imdb{i});
    continue;
  end

  sz = size(orgIm);
  
  im = single(orgIm);
  im = im-imresize(net.meta.normalization.averageImage,[size(im,1) size(im,2)],...
    'method','nearest');
  
  if useGpu
    im = gpuArray(im) ;
  end
  inputs = {'input', im} ;
  
  net.eval(inputs) ;
  
  density = gather(net.vars(net.getVarIndex('pred_l')).value) ;
  density = reshapeLayer(density,[size(orgIm,1) size(orgIm,2)]);
  
  seg = gather(net.vars(net.getVarIndex('pred_s')).value) ;
  seg = reshapeLayer(seg,[size(orgIm,1) size(orgIm,2)]);
  
  seg(1:100,:) = 0;
  seg(sz(1)-100:sz(1),:) = 0;

  density(seg<segTH) = 0;
  density = density/densAmp;
  
  count{i,1} = imdb{i};
  count{i,2} = sum(density(:));
  
  [folderName, imName] = fileparts(imdb{i});
  if exist([folderName '_count'],'dir')==0
    mkdir([folderName '_count']);
  end
  
  save(fullfile([folderName '_count'],[imName '.mat']),'density');
end

end
