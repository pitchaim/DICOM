%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
%   renameDicomSeries.m
%   
%       (9/30/2016) Austin Marcus
%       ~(10/3/16) updated to loop through
%       ~all subdirectories of base directory
%       ~(10/4/16) updated to output only
%       ~one log file for entire directory
%
%       -Takes directory of DICOM files,
%       -renames directory based on name
%       -of scan from file header.
%
%       -Outputs log file listing all series
%       -with #files, scan parameters
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wrapper function - takes outer directory
function renameDicomSeries(base_dir)

    if ~ischar(base_dir) or ~exist(base_dir)
        error('%s is not a valid directory.', base_dir)
    end
    
    cd(base_dir)
    
    contents = dir;
    dirflags = [contents.isdir];
    subdirs = contents(dirflags);
    
    pathparts = strsplit(base_dir, '/');
    base_name = pathparts{end};
    
    subdirs(1:2) = [];
    
    logfile = fopen(strcat('DICOM_log_', base_name, '.txt'), 'at'); %start log file
    fprintf(logfile, '%s\n', '---------------------------Start of logfile-------------------------------');
    fprintf(logfile, '%s\n', '');
    
    for i = 1:length(subdirs)
        disp(['working on directory: ', subdirs(i).name]);
        renameSeries(subdirs(i).name, i, logfile);
    end
    fprintf(logfile, '%s\n', repmat('-',1,130));
    fclose(logfile);
end

% sub-directory parser
function renameSeries(source_dir, curnum, logfile)
    
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
        if curnum == 1
            % print log file header
            fprintf(logfile, 'Study: %s\tDate: %s\tStart time: %s\n', info.RequestedProcedureDescription, ...
                [num2str(info.PerformedProcedureStepStartDate(1:4)), '/', num2str(info.PerformedProcedureStepStartDate(5:6)), '/', num2str(info.PerformedProcedureStepStartDate(7:8))], ...
                sprintf('%s:%s', info.PerformedProcedureStepStartTime(1:2), info.PerformedProcedureStepStartTime(3:4)));
            fprintf(logfile, 'Subject age: %s\t\tGender: %s\t\tWeight(kg): %s\n', info.PatientAge, info.PatientSex, num2str(info.PatientWeight, '%.1f'));
            fprintf(logfile, '%s\n', '');
            fprintf(logfile, '%s\n', repmat('-',1,130));
            fprintf(logfile, '%s \t%s%s%s%s%s%s%s%s%s%s\t%s\n', '#', 'SERIES', ...
                repmat(' ', 1, 69), 'SEQUENCE NAME', repmat(' ', 1, 5), '#FILES', ...
                repmat(' ', 1, 4), 'SLICE', repmat(' ', 1, 2), 'TR(ms)', repmat(' ', 1, 5 - length('TR(ms')), 'TE(ms)');
            fprintf(logfile, '%s\n', repmat('-',1,130));
        end
        namestr = info.SeriesDescription; %get name of first DICOM file
        cd ..
        if exist(namestr)
            namestr = [namestr, '_', num2str(curnum)]; % sub-directory renamed
                                                       % with number suffix
                                                       % if not first of
                                                       % series type
        end
        mkdir(namestr) %make new directory
        cd(namestr)
        for i = 1:length(dicom_list)
            %get metadata from current dicom file
            dicom_file = fullfile('..', source_dir, dicom_list(i).name);
            temp_info = dicominfo(dicom_file);
            dicom_filename = temp_info.Filename; %get file's name
            [path, name, ext] = fileparts(dicom_filename);
            dicom_name = [name, ext];
            dicom_series = temp_info.SeriesDescription; %get name of scan series
            dicom_mod_date = temp_info.FileModDate; %get file's modification date
            movefile(fullfile('..', source_dir, dicom_list(i).name)); %copy to new dir
            file_count = file_count + 1;
        end
        %spacing things for readable logfile
        if length(num2str(info.RepetitionTime)) < 4
            spacestr = repmat(' ', 1, 5 - length(num2str(info.RepetitionTime)) + 2);
        else
            spacestr = repmat(' ', 1, 5 - length(num2str(info.RepetitionTime)) + 1);
        end
        fprintf(logfile, '%02d\t%s%s%s%s%d%s%.1f%s%.1f%s\t%.1f\n', curnum, info.SeriesDescription, ...
            repmat(' ', 1, 75 - length(info.SeriesDescription)), info.SequenceName, ...
            repmat(' ', 1, 18 - length(info.SequenceName)), file_count, ...
            repmat(' ', 1, 10 - length(num2str(file_count))), info.SliceThickness, ...
            repmat(' ', 1, 5 - length(num2str(info.SliceThickness))), info.RepetitionTime, ...
            spacestr, info.EchoTime);
    end
    cd ..
    rmdir(source_dir);
end
   
        
    
            
    
    