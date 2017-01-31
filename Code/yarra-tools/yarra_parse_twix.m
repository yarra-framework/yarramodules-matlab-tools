function [image_obj, AscStrFull ] = yarra_parse_twix(path, file)

[image_obj,MDH] = mapVBVD2014([path file]);
[AscStrFull, BytesForHeadInfo, datapath, datafile]=PrepRead([],1,file, path);  

end