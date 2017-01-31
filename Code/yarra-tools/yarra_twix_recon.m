function yarra_twix_recon(data_path, data_file, mode_path, mode_section, out_path,recon_function_name)
    [image_obj, AscStrFull] = yarra_parse_twix(data_path,data_file);
    params = yarra_read_mode_section(mode_path,mode_section);
    
    recon_function = str2func(recon_function_name);
    data = recon_function(image_obj, AscStrFull,params,out_path);
    
