function [image_obj, AscStrFull ] = yarra_parse_twix(path, file)
%% Reads the image data and parameter data from a twix file
%  path = the directory containing the file
%  file = the filename
[image_obj,MDH] = mapVBVD2014([path file]);
[AscStrFull, BytesForHeadInfo, datapath, datafile]=PrepRead([],1,file, path);  

end