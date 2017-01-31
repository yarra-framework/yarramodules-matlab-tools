%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function to provide a standard interface for reading 
%raw data files for all IDEA versions July 4, 2007, TZ

function [AscStr, BytesForHeadInfo, datapath, datafile]=PrepRead(DataFrom, bDumpTheHeaders,file,path)
global read_version_ctrl
%----------------------------------------------------------
read_version_ctrl.version = 'VB';
read_version_ctrl.BytesForHeadInfo=-1;
read_version_ctrl.NScans = 1;
read_version_ctrl.measOffset=0;
read_version_ctrl.hdrLength = -1;
%----------------------------------------------------------
AscStr=[];
BytesForHeadInfo=[];
datapath=[];
datafile=[];
if nargin<2,
    bDumpTheHeaders = 0;
end

if (nargin<1 || isempty(DataFrom))
    fid=fopen('COMMOM_Var.mat', 'r');%test if default information can be obtained
    if fid<0,
        [datafile, datapath]=uigetfile('*.*', 'Choose the file to be reconstructed:');
    else
        fclose(fid);
        com_path='';
        load('COMMOM_Var.mat', 'com_path')
%         [datafile, datapath]=uigetfile([com_path '*.*'], 'Choose the file to be reconstructed:');
        datafile=file;datapath=path;
    end

    if isequal(datafile,0) || isequal(datapath,0),
        return;
    end
    
    com_path=datapath; %#ok<NASGU>
    save('COMMOM_Var.mat', 'com_path');%save path information for next use
    DataFrom=[datapath, datafile];
end

if length(DataFrom)<5,
    disp('Invalid file name was found');
    return;
end

if findstr(DataFrom, '.out'),
    extensionF='.out';
elseif findstr(DataFrom, '.IMA') 
    extensionF='.IMA';
elseif findstr(DataFrom, '.ima') 
    extensionF='.ima';
elseif findstr(DataFrom, '.dcm')
    extensionF='.dcm';
else
    extensionF='.dat';
end

DataFrom=[DataFrom(1:(end-4)) extensionF];
if nargin==0,
    datafile=[datafile(1:(end-4)) extensionF];
else
    slashID=findstr(DataFrom, '\');
    if isempty(slashID),
        slashID=findstr(DataFrom, '/');
        slashSymbol = '/';
    else
        slashSymbol = '\';
    end
    datapath=DataFrom(1:slashID(end));
    datafile=DataFrom(1+slashID(end):end);
end

fidF=fopen(DataFrom, 'r','l');
if fidF<0,
    disp(['    ERROR: No required file {' DataFrom(1:(end-4)) extensionF '} was found!']);
    disp('..............................................................');
    return;
end

if strcmp(extensionF, '.dat')
    fseek(fid,0,'bof');
    firstInt  = fread(fid,1,'uint32');
    secondInt = fread(fid,1,'uint32');
    if and(firstInt < 10000, secondInt <= 64)%for VD verson
        %version = 'vd';
        disp('Software version: VD (!?)');

        % number of different scans in file stored in 2nd in
        NScans = secondInt;
        measID = fread(fid,1,'uint32');
        fileID = fread(fid,1,'uint32');
        % measOffset: points to beginning of header, usually at 10240 bytes
        measOffset = fread(fid,1,'uint64');
        measLength = fread(fid,1,'uint64');
        fseek(fid,measOffset,'bof');
        hdrLength  = fread(fid,1,'uint32');
        BytesForHeadInfo = measOffset + hdrLength;
        
        read_version_ctrl.version = 'VD';       
        read_version_ctrl.NScans = NScans;
        read_version_ctrl.measOffset=measOffset;
        read_version_ctrl.hdrLength = hdrLength; 
        read_version_ctrl.measLength = measLength; 
        read_version_ctrl.measID = measID; 
        read_version_ctrl.fileID = fileID; 
        
        fseek(fid,0,'bof');
        AscStr=fread(fidF, BytesForHeadInfo, '*char').';
        if nargin<2,%normally, we want to chop the data to a smaller section that contains most parameters.
            IdEff=findstr(AscStr, '### ASCCONV BEGIN ###');
            IdEffEnd=findstr(AscStr, '### ASCCONV END ###');
            AscStr=(AscStr(IdEff(1):IdEffEnd(end)));
        end        
    else%for VB13
        % in VB versions, the first 4 bytes indicate the beginning of the
        % raw data part of the file
        %version  = 'vb';
        disp('Software version: VB (!?)');
        fseek(fid,0,'bof');
        BytesForHeadInfo=fread(fidF, 1, 'int32');
        AscStr=fread(fidF, BytesForHeadInfo, '*char').';
        if nargin<2,%normally, we want to chop the data to a smaller section that contains most parameters.
            IdEff=findstr(AscStr, '### ASCCONV BEGIN ###');
            IdEffEnd=findstr(AscStr, '### ASCCONV END ###');
            AscStr=(AscStr(IdEff(1):IdEffEnd(end)));
        end
    end
elseif (~isempty(findstr(DataFrom, '.IMA')) || ~isempty(findstr(DataFrom, '.ima')) || ~isempty(findstr(DataFrom, '.dcm')))
    AscStr=fread(fidF, Inf, '*char').';
    if nargin<2,%normally, we want to chop the data to a smaller section that contains most parameters.
        IdEff=findstr(AscStr, '### ASCCONV BEGIN ###');
        IdEffEnd=findstr(AscStr, '### ASCCONV END ###');
        AscStr=(AscStr(IdEff(1):IdEffEnd(end)));
    end
else%%%for old version
    BytesForHeadInfo=32;
    fidAsc=fopen([DataFrom(1:(end-4)) '.asc'], 'r','l');
    if fidAsc<0,
        disp(['    No required file {' DataFrom(1:(end-4)) '.asc } was found!']);
        disp('    ERROR: Recon failed.');
        disp('..............................................................');
        return;
    end

    AscStr=fread(fidAsc, Inf, '*char').';
    fclose(fidAsc);
end
fclose(fidF);

read_version_ctrl.BytesForHeadInfo=BytesForHeadInfo;

if (bDumpTheHeaders<0)%dump the head into a text file
    pathCurrent=cd;
    disp(['------->Dumping head to file: ' pathCurrent slashSymbol 'Dump.evp']);
    dlmwrite([pathCurrent slashSymbol 'Dump.evp'], AscStr, '');
    disp('------->Done');
end
