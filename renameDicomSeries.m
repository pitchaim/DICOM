%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
%   renameDicomSeries.m
%   
%       (9/30/2016) Austin Marcus
%       ~(10/3/16) updated to loop through
%       ~all subdirectories of base directory
%
%       -Takes directory of DICOM files,
%       -renames directory based on name
%       -of scan from file header.
%       -Outputs log file DICOM_log.txt,
%       -containing list of files moved
%       -to new directory, with date 
%       -modified & series name for each
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function renameDicomSeries(base_dir)

    if ~ischar(base_dir) or ~exist(base_dir)
        error('%s is not a valid directory.', base_dir)
    end
    
    cd(base_dir)
    
    contents = dir;
    dirflags = [contents.isdir];
    subdirs = contents(dirflags);
    subdirs(1:2) = [];
    
    for i = 1:length(subdirs)
        disp(['working on directory: ', subdirs(i).name]);
        renameSeries(subdirs(i).name, i);
    end
end

function renameSeries(source_dir, curnum)
    
    if ~ischar(source_dir) or ~exist(source_dir)
        error('%s is not a valid directory.', source_dir)
    end
    
    cd(source_dir)
    
    file_count = 0;
    
    dicom_list=dir(fullfile(sprintf('*.dcm'))); %get list of all DICOM files
    if length(dicom_list) == 0
        error('No DICOM files found.')
    else
        info = dicominfo(fullfile(source_dir, dicom_list(1).name));
        namestr = info.SeriesDescription; %get name of first DICOM file
        cd ..
        if exist(namestr)
            namestr = [namestr, '_', num2str(curnum)];
        end
        mkdir(namestr) %make new directory
        cd(namestr)
        logfile = fopen('DICOM_log.txt', 'at'); %start log file
        fprintf(logfile, '%s \n', 'Start of logfile. Files listed below have been successfully copied.');
        fprintf(logfile, '%s\n', '---------------------------------------------------------------------------');
        fprintf(logfile, '%s \t\t%s | %s | %s\n', 'NUMBER', 'NAME', 'SERIES', 'MOD DATE');
        fprintf(logfile, '%s\n', '---------------------------------------------------------------------------');
        for i = 1:length(dicom_list)
            dicom_file = fullfile('..', source_dir, dicom_list(i).name);
            temp_info = dicominfo(dicom_file);
            dicom_filename = temp_info.Filename; %get file's name
            [path, name, ext] = fileparts(dicom_filename);
            dicom_name = [name, ext];
            dicom_series = temp_info.SeriesDescription; %get name of scan series
            dicom_mod_date = temp_info.FileModDate; %get file's modification date
            %dicom_size = temp_info.FileSize; %get file's size
            movefile(fullfile('..', source_dir, dicom_list(i).name));
            if curnum < 9
                fprintf(logfile, '%d)  \t\t%s | %s | %s\n', i, dicom_name, dicom_series, dicom_mod_date);
            elseif curnum > 9 and curnum < 100
                fprintf(logfile, '%d) \t\t%s | %s | %s\n', i, dicom_name, dicom_series, dicom_mod_date);
            else
                fprintf(logfile, '%d)\t\t%s | %s | %s\n', i, dicom_name, dicom_series, dicom_mod_date);
            end
            file_count = file_count + 1;
        end
        fprintf(logfile, '%s\n', '---------------------------------------------------------------------------');
        if file_count == length(dicom_list)
            fprintf(logfile, '%s \n', 'Copy completed - number of files copied matches number of files found.')
        else
            fprintf(logfile, '%s \n', 'One or more files were not copied. Please check file index numbers above to verify.')
        end
    end
    cd ..
    rmdir(source_dir);
end
   
        
    
            
    
    