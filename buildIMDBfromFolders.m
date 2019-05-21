function [imdb,fs] = buildIMDBfromFolders(folders)
%Finds images in the given folder and returns them within an IMDB structure

imdb = {};
imExt = {'.JPG','.jpg','.png','.PNG'};

%break folders separated by semi-colon or commas
fs = strsplit(folders,';|,|:','DelimiterType','RegularExpression');

for i = 1:numel(fs)
  for e = 1:numel(imExt)    
    folderIm = dir(fullfile(fs{i}, ['*' imExt{e}]));
    [~,folderIm] = cellfun(@fileparts, {folderIm.name}, 'UniformOutput',false);
    folderIm = strcat(folderIm',imExt{e});
    imdb = [imdb ; fullfile(fs{i},folderIm)];
  end
end


