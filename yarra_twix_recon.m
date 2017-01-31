function yarra_twix_recon(data_path, data_file, mode_path, mode_section, out_path,recon_function_name)
%% This is an entry point for a yarra modefile. 
%  Invoking this as a reconstruction module looks something like this:
%  [Reconstruction]
%    Bin=%hmb
%    Args="-nodesktop -nosplash -r %hq try, addpath(genpath('%bu/[MODE FOLDER]/')); yarra_twix_recon('%rid/','%rif','%mc',[PARAMS SECTION],'%rod',[RECON FUNCTION]); catch e, disp(e.message); end, quit; %hq"
%  
%  [MODE FOLDER] is the name of the reconstruction mode folder;
%  [PARAMS SECTION] is the name of the section of the modefile INI where
%       the reconstruction function can find parameters, ex 'GRASP'
%  [RECON FUNCTION] is a string that corresponds to the name of a function
%       in the path to perform the construction.
%       If the function is 'func', it's called with the parameters:
%           func(image_data, twix_metadata, params, out_path).
%       This function is reponsible for reconstructing the image and
%       writing the final images to the output directory.

    [image_obj, AscStrFull] = yarra_parse_twix(data_path,data_file);
    params = yarra_read_mode_section(mode_path,mode_section);
    
    recon_function = str2func(recon_function_name);
    data = recon_function(image_obj, AscStrFull,params,out_path);
    
