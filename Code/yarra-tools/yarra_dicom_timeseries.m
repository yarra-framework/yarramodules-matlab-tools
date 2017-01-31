function yarra_dicom_timeseries( data, output_path )
% DICOM_TIMESERIES Write out a 4D data set as dicom files,
%   /series{n}.slice{n}.dcm
%   This is the form expected by SetDCMTags.

for z=1:size(data,3)
    for t=1:size(data,4)
        dicomwrite(abs(data(:,:,z,t)),[output_path '/series' num2str(t,'%03d') '.slice' num2str(z,'%03d') '.dcm'])
    end
end
end

