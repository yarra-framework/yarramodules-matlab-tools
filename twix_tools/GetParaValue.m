%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Modified from 2002 codes, July 03, 2007 TZ
%Input parameter name string, AscString
%paraName validNumStartWith (e.g. =) a number/number array (if 15] is also a number, ] shall be included in valid_numEND)
function p=GetParaValue(ParaName, AscStr, IsArray, valid_numEND, validNumStartWith, sureValidEnd) %#ok<INUSL,INUSD>

if nargin<2,
    p=[];
    return;
end
if nargin<3,
    IsArray=0;
else
    IsArray=1;
end
if nargin<4 || isempty(valid_numEND)
    valid_numEND=']';
end
%valid_numEND='QAZWSXEDCRFVTGBYHNUJMIKOLP\/(){}[]|,<>!@#$%^&*~_"';
if nargin<5
    validNumStartWith='=';
end

if nargin<6,
    sureValidEnd = [];
end

id_temp=findstr(AscStr, ParaName);
if isempty(id_temp), %no match
    p=[];
    if isempty(p)
        disp(['Warning: required string {' ParaName '} cannot be found!']);
    end
    return;
end

if ~isempty(validNumStartWith)
    id_dev=findstr(AscStr(id_temp(1):end), validNumStartWith)+1; %value is found after a =
    if (isempty(id_dev)),
        p=[];
        if isempty(p)
            disp(['Warning: no string {' validNumStartWith '} was found after the required string {' ParaName '}!']);
        end
        return;
    end
else
    id_dev=0;
end

id=id_temp(1)+id_dev(1);%default using the first found
if ~isempty(sureValidEnd)
    id_sureEnd=findstr(AscStr(id_temp(1):end), sureValidEnd);
    if isempty(id_sureEnd)
        sureValidEnd = [];
    end
end
if isempty(sureValidEnd)
    if length(id_dev)==1,%search to the end
        id_end=length(AscStr);
    else %till the next '=' 
        id_end=id_temp(1)+id_dev(2)-1;
    end
else
    id_end=id_temp(1)+id_sureEnd(1)-1;
end

p=partition_str(AscStr(id:id_end), valid_numEND);
if ((~isempty(p)) &&  (~IsArray)) %if it is not an array, we retruned only the first number.
    p=p(1);
end


function X=partition_str(str, valid_numEND)
%function partion a string into number assuming space delimited,
%first, the letter parts at the end and begin is discarded
%return [], if no number found
if isempty(str),
    X=[];
    return;
end

str=upper(str);
len_str=length(str);

X_temp=zeros(1, len_str);
num_total=0;
id_start=0;

for zz=1:len_str,
    if id_start==0, %havent determine the start point
		if (abs(str(zz))<=abs('9') && abs(str(zz))>=abs('0')) | ...
                abs(str(zz))==abs('-') | abs(str(zz))==abs('+') | abs(str(zz))==abs('.'),
           id_start=zz;
           if zz==len_str,
               id_end=zz;
               num_total=num_total+1;
               X_temp(num_total)=str2double(str(id_start:id_end));
           end
		end
    else %star detemined, need the end
        ID_numEND=findstr(valid_numEND, str(zz));
        if (isspace(str(zz)) | zz==len_str ...
                | (~isempty(ID_numEND))), %legal number termined
            
            if (zz==len_str)
                if (abs(str(zz))<=abs('9') && abs(str(zz))>=abs('0')),
                    id_end=zz;
                else
                    id_end=zz-1;
                end
            else
                id_end=zz-1;
            end
            
            if strcmp(str(zz), 'U'),
                unit=1e-6;
            elseif strcmp(str(zz), 'M')
                unit=1e-3;
            else
                unit=1;
            end
            num_str=str2double(str(id_start:id_end));

            if ~isempty(num_str),
                num_total=num_total+1;
                X_temp(num_total)=unit*num_str;
            end
            id_start=0;
        elseif (abs(str(zz))==abs('-') | abs(str(zz))==abs('+') | abs(str(zz))==abs('.')),
            Y=findstr(str(id_start:(zz-1)), str(zz));
            if ~isempty(Y), %data with double '-', '.' abort counting
                id_start=0;
            end
        elseif (abs(str(zz))<=abs('9') && abs(str(zz))>=abs('0')) %not a number
            ; %#ok<NOSEM>
        else
            id_start=0;
        end
    end
end

if num_total==0,
    X=[];
else
    X=X_temp(1:num_total);
end



